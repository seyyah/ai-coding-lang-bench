# frozen_string_literal: true

require_relative 'base_codex'
require 'net/http'
require 'json'
require 'uri'
require 'time'
require 'fileutils'

# OpenAI Responses API adapter
class OpenAICodex < BaseCodex
  API_ENDPOINT = 'https://api.openai.com/v1/responses'
  DEFAULT_TIMEOUT_SECONDS = 1200
  DEFAULT_COOLDOWN_SECONDS = 0.5

  def initialize(config = {})
    super('openai', config)
    @api_key = presence(config[:api_key]) || ENV['OPENAI_API_KEY']
    @model_name = presence(config[:model]) || presence(config[:model_name]) || 'gpt-4.1'
    @organization = presence(config[:organization]) || ENV['OPENAI_ORG_ID']
    @project = presence(config[:project]) || ENV['OPENAI_PROJECT_ID']
    @api_endpoint = presence(config[:api_endpoint]) || API_ENDPOINT
    @cooldown_seconds = float_or_default(config[:cooldown_seconds], DEFAULT_COOLDOWN_SECONDS)
    @timeout_seconds = integer_or_default(config[:timeout_seconds], DEFAULT_TIMEOUT_SECONDS)
    @max_output_tokens = config[:max_output_tokens]
    @price_input_1m = float_or_nil(config[:price_input_1m])
    @price_cached_input_1m = float_or_nil(config[:price_cached_input_1m])
    @price_output_1m = float_or_nil(config[:price_output_1m])

    raise CodexError, 'OPENAI_API_KEY not configured' unless presence(@api_key)
  end

  def version
    @model_name
  end

  def warmup(warmup_dir)
    puts "  Warmup: Running trivial prompt on OpenAI (#{@model_name})..."
    result = run_generation('Respond with just the word OK.', dir: warmup_dir)
    puts "  Warmup done in #{result[:elapsed_seconds]}s (success=#{result[:success]})"
    result
  end

  def run_generation(prompt, dir:, log_path: nil)
    start_time = Time.now

    begin
      raw_response, response_text, usage = call_openai_api(prompt)
      elapsed = Time.now - start_time
      metrics = build_metrics(usage, elapsed)

      if log_path
        FileUtils.mkdir_p(File.dirname(log_path))
        File.write(log_path, JSON.pretty_generate({
          model: @model_name,
          prompt: prompt,
          response_text: response_text,
          usage: usage,
          metrics: metrics,
          raw_response: raw_response,
        }))
      end

      save_generated_code(response_text, dir)
      sleep(@cooldown_seconds)

      {
        success: true,
        elapsed_seconds: elapsed.round(1),
        metrics: metrics,
        response_text: response_text,
      }
    rescue StandardError => e
      elapsed = Time.now - start_time
      {
        success: false,
        elapsed_seconds: elapsed.round(1),
        metrics: nil,
        error: e.message,
      }
    end
  end

  private

  def call_openai_api(prompt)
    uri = URI(@api_endpoint)
    request_body = {
      model: @model_name,
      input: [{
        role: 'user',
        content: [{ type: 'input_text', text: prompt }],
      }],
    }
    request_body[:max_output_tokens] = @max_output_tokens if @max_output_tokens

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.open_timeout = [@timeout_seconds, 30].min
    http.read_timeout = @timeout_seconds

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    request['OpenAI-Organization'] = @organization if @organization
    request['OpenAI-Project'] = @project if @project
    request.body = JSON.generate(request_body)

    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      raise CodexError, "OpenAI API error: #{response.code} #{response.message}\n#{response.body}"
    end

    data = JSON.parse(response.body)
    [data, extract_response_text(data), data['usage'] || {}]
  end

  def extract_response_text(data)
    direct = presence(data['output_text'])
    return direct if direct

    texts = Array(data['output']).flat_map do |item|
      next [] unless item.is_a?(Hash)

      Array(item['content']).filter_map do |content|
        next unless content.is_a?(Hash)
        next unless %w[output_text text].include?(content['type'])

        presence(content['text'])
      end
    end

    texts.join("\n\n")
  end

  def build_metrics(usage, elapsed)
    input_tokens = usage['input_tokens'] || 0
    output_tokens = usage['output_tokens'] || 0
    input_details = usage['input_tokens_details'] || {}
    output_details = usage['output_tokens_details'] || {}
    cached_tokens = input_details['cached_tokens'] || 0
    reasoning_tokens = output_details['reasoning_tokens'] || 0

    {
      input_tokens: input_tokens,
      output_tokens: output_tokens,
      cache_creation_tokens: 0,
      cache_read_tokens: cached_tokens,
      num_turns: 1,
      cost_usd: calculate_cost(input_tokens, cached_tokens, output_tokens),
      model: @model_name,
      duration_ms: (elapsed * 1000).round,
      reasoning_tokens: reasoning_tokens,
    }
  end

  def calculate_cost(input_tokens, cached_tokens, output_tokens)
    uncached_input_tokens = [input_tokens - cached_tokens, 0].max
    total = 0.0
    total += (uncached_input_tokens / 1_000_000.0) * @price_input_1m if @price_input_1m

    cached_price = @price_cached_input_1m || @price_input_1m
    total += (cached_tokens / 1_000_000.0) * cached_price if cached_price
    total += (output_tokens / 1_000_000.0) * @price_output_1m if @price_output_1m
    total.round(8)
  end

  def presence(value)
    return nil if value.nil?

    stripped = value.to_s.strip
    stripped.empty? ? nil : stripped
  end

  def float_or_nil(value)
    return nil if value.nil? || value.to_s.strip.empty?

    value.to_f
  end

  def float_or_default(value, default)
    parsed = float_or_nil(value)
    parsed.nil? ? default : parsed
  end

  def integer_or_default(value, default)
    return default if value.nil? || value.to_s.strip.empty?

    value.to_i
  end

  def save_generated_code(response_text, dir)
    lang = read_benchmark_value(dir, '.benchmark-language') || infer_language_from_dir(dir)
    binary_name = read_benchmark_value(dir, '.benchmark-binary-name') || 'minigit'
    blocks = extract_code_blocks(response_text, binary_name)
    written_files = []

    named_blocks = blocks.select { |block| block[:filename] }
    if named_blocks.any?
      named_blocks.each do |block|
        path = File.join(dir, block[:filename])
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, block[:code])
        written_files << block[:filename]
      end
    end

    primary_block = choose_primary_block(blocks, lang)
    if primary_block
      target = primary_target_for(lang, binary_name: binary_name)
      unless target.nil? || written_files.include?(target)
        code = normalize_script_for_target(primary_block[:code], lang, target, binary_name: binary_name)
        File.write(File.join(dir, target), code)
        written_files << target
      end
    elsif written_files.empty?
      File.write(File.join(dir, 'generated_code.txt'), response_text.strip)
      written_files << 'generated_code.txt'
    end

    ensure_runtime_files(lang, dir, written_files, binary_name: binary_name)
    chmod_if_present(File.join(dir, binary_name))
    chmod_if_present(File.join(dir, 'build.sh'))
  end

  def read_benchmark_value(dir, filename)
    path = File.join(dir, filename)
    return unless File.file?(path)

    File.read(path, encoding: 'UTF-8').strip
  rescue StandardError
    nil
  end

  def infer_language_from_dir(dir)
    dir_name = File.basename(dir)
    dir_name = dir_name[/-(rust|go|c|typescript|javascript|java|perl|python(?:-mypy)?|ruby(?:-steep)?|lua|scheme|ocaml|haskell)-\d+-v[12]$/, 1] ||
      dir_name.sub(/^minigit-/, '').sub(/-\d+-v[12]$/, '')
    {
      'python-mypy' => 'python/mypy',
      'ruby-steep' => 'ruby/steep'
    }.fetch(dir_name, dir_name)
  end

  def extract_code_blocks(response_text, binary_name)
    blocks = []
    response_text.to_enum(:scan, /```(?<lang>[A-Za-z0-9_+-]*)\n(?<code>.*?)```/m).each do
      match = Regexp.last_match
      context = response_text[[match.begin(0) - 300, 0].max...match.begin(0)]
      blocks << {
        fence_lang: match[:lang].to_s.downcase,
        filename: infer_filename_from_context(context, binary_name),
        code: match[:code].strip,
      }
    end
    blocks
  end

  def infer_filename_from_context(context, binary_name)
    binary_pattern = Regexp.escape(binary_name)
    backticked = context.scan(/`([^`\n]+)`/).flatten.reverse.find do |token|
      token.match?(/\A(?:#{binary_pattern}|Makefile|makefile|build\.sh|[\w.\/-]+\.(?:rb|rbs|py|go|rs|c|h|ts|js|java|pl|pm|lua|scm|ml|mli|hs))\z/)
    end
    return backticked if backticked

    file_named = context[/file named\s+[`"]?([A-Za-z0-9._\/-]+)[`"]?/i, 1]
    return file_named if file_named

    recent_context = context.lines.last(4).join
    return 'Makefile' if recent_context.match?(/\bThe Makefile\b|\bMakefile\b/i)
    return 'build.sh' if recent_context.match?(/\bbuild\.sh\b/i)

    nil
  end

  def choose_primary_block(blocks, lang)
    return nil if blocks.empty?

    expected_fences = expected_fence_langs(lang)
    blocks.find { |block| expected_fences.include?(block[:fence_lang]) } ||
      blocks.max_by { |block| block[:code].length }
  end

  def expected_fence_langs(lang)
    {
      'python' => %w[python py],
      'python/mypy' => %w[python py],
      'ruby' => %w[ruby rb],
      'ruby/steep' => %w[ruby rb rbs],
      'javascript' => %w[javascript js node],
      'typescript' => %w[typescript ts],
      'perl' => %w[perl pl],
      'lua' => %w[lua],
      'scheme' => %w[scheme scm guile],
      'rust' => %w[rust rs],
      'go' => %w[go],
      'c' => %w[c],
      'java' => %w[java],
      'ocaml' => %w[ocaml ml],
      'haskell' => %w[haskell hs]
    }.fetch(lang, [])
  end

  def primary_target_for(lang, binary_name: 'minigit')
    {
      'python' => binary_name,
      'python/mypy' => binary_name,
      'ruby' => binary_name,
      'ruby/steep' => binary_name,
      'javascript' => binary_name,
      'perl' => binary_name,
      'lua' => binary_name,
      'go' => 'main.go',
      'rust' => 'main.rs',
      'c' => 'main.c',
      'java' => 'MiniGit.java',
      'typescript' => 'main.ts',
      'scheme' => 'main.scm',
      'ocaml' => 'main.ml',
      'haskell' => 'Main.hs'
    }[lang]
  end

  def normalize_script_for_target(code, lang, target, binary_name: 'minigit')
    return code if target != binary_name || code.start_with?('#!')

    shebang = {
      'python' => '#!/usr/bin/env python3',
      'python/mypy' => '#!/usr/bin/env python3',
      'ruby' => '#!/usr/bin/env ruby',
      'ruby/steep' => '#!/usr/bin/env ruby',
      'javascript' => '#!/usr/bin/env node',
      'perl' => '#!/usr/bin/env perl',
      'lua' => '#!/usr/bin/env lua'
    }[lang]

    shebang ? "#{shebang}\n#{code}\n" : code
  end

  def ensure_runtime_files(lang, dir, written_files, binary_name: 'minigit')
    case lang
    when 'go'
      write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nset -e\ngo build -o #{binary_name} main.go\n", written_files)
    when 'rust'
      write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nset -e\nrustc -O main.rs -o #{binary_name}\n", written_files)
    when 'c'
      write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nset -e\ngcc -O2 -o #{binary_name} main.c\n", written_files)
    when 'java'
      write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nset -e\njavac MiniGit.java\n", written_files)
      write_if_missing(dir, binary_name, launcher_script('java'), written_files)
    when 'typescript'
      write_if_missing(dir, binary_name, launcher_script('typescript'), written_files)
    when 'scheme'
      write_if_missing(dir, binary_name, launcher_script('scheme'), written_files)
    when 'ocaml'
      write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nset -e\nocamlc -o #{binary_name} main.ml\n", written_files)
    when 'haskell'
      write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nset -e\nghc -O2 -o #{binary_name} Main.hs\n", written_files)
    end
  end

  def launcher_script(kind)
    case kind
    when 'java'
      <<~BASH
        #!/usr/bin/env bash
        set -e
        DIR="$(cd "$(dirname "$0")" && pwd)"
        exec java -cp "$DIR" MiniGit "$@"
      BASH
    when 'typescript'
      <<~BASH
        #!/usr/bin/env bash
        set -e
        DIR="$(cd "$(dirname "$0")" && pwd)"
        exec tsx "$DIR/main.ts" "$@"
      BASH
    when 'scheme'
      <<~BASH
        #!/usr/bin/env bash
        set -e
        DIR="$(cd "$(dirname "$0")" && pwd)"
        exec guile -s "$DIR/main.scm" "$@"
      BASH
    end
  end

  def write_if_missing(dir, relative_path, content, written_files)
    return if written_files.include?(relative_path)

    path = File.join(dir, relative_path)
    File.write(path, content)
    written_files << relative_path
  end

  def chmod_if_present(path)
    FileUtils.chmod(0755, path) if File.exist?(path)
  end
end