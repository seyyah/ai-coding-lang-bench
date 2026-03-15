# frozen_string_literal: true

require_relative 'base_codex'
require 'net/http'
require 'json'
require 'uri'
require 'time'
require 'fileutils'


# Google Gemini API adapter
class GeminiCodex < BaseCodex
  API_ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models'

  # Gemini 3.1 Flash-Lite Official Pricing (Per 1 Million Tokens)
  PRICE_INPUT_1M = 0.25
  PRICE_OUTPUT_1M = 1.5

  def initialize(config = {})
    super('gemini', config)
    @api_key = config[:api_key] || ENV['GOOGLE_API_KEY']
    @model_name = config[:model_name] || 'gemini-3.1-flash-lite-preview'
    @cooldown_seconds = config[:cooldown_seconds] || 1.2

    raise CodexError, 'GOOGLE_API_KEY not configured' unless @api_key
  end

  def version
    @model_name
  end

  def warmup(warmup_dir)
    puts "  Warmup: Running trivial prompt on Gemini (#{@model_name})..."
    result = run_generation('Respond with just the word OK.', dir: warmup_dir)
    puts "  Warmup done in #{result[:elapsed_seconds]}s (success=#{result[:success]})"
    sleep(@cooldown_seconds)
    result
  end

  def run_generation(prompt, dir:, log_path: nil)
    start_time = Time.now

    begin
      response_text, input_tokens, output_tokens = call_gemini_api(prompt)

      # Calculate cost
      cost_usd = calculate_cost(input_tokens, output_tokens)

      elapsed = Time.now - start_time

      # Save to log if requested
      if log_path
        FileUtils.mkdir_p(File.dirname(log_path))
        log_data = {
          model: @model_name,
          prompt: prompt,
          response: response_text,
          input_tokens: input_tokens,
          output_tokens: output_tokens,
          cost_usd: cost_usd,
          elapsed_seconds: elapsed.round(1)
        }
        File.write(log_path, JSON.pretty_generate(log_data))
      end

      # Save generated code to working directory
      save_generated_code(response_text, dir)

      # Cooldown to respect rate limits
      sleep(@cooldown_seconds)

      {
        success: true,
        elapsed_seconds: elapsed.round(1),
        metrics: {
          input_tokens: input_tokens,
          output_tokens: output_tokens,
          cache_creation_tokens: 0,
          cache_read_tokens: 0,
          num_turns: 1,
          cost_usd: cost_usd,
          model: @model_name,
          duration_ms: (elapsed * 1000).round
        },
        response_text: response_text
      }
    rescue StandardError => e
      elapsed = Time.now - start_time
      {
        success: false,
        elapsed_seconds: elapsed.round(1),
        metrics: nil,
        error: e.message
      }
    end
  end

  private

  def call_gemini_api(prompt)
    uri = URI("#{API_ENDPOINT}/#{@model_name}:generateContent?key=#{@api_key}")

    request_body = {
      contents: [{
        parts: [{ text: prompt }]
      }]
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 600

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = JSON.generate(request_body)

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise CodexError, "Gemini API error: #{response.code} #{response.message}\n#{response.body}"
    end

    data = JSON.parse(response.body)

    # Extract response text
    response_text = data.dig('candidates', 0, 'content', 'parts', 0, 'text') || ''

    # Extract token counts
    usage = data['usageMetadata'] || {}
    input_tokens = usage['promptTokenCount'] || 0
    output_tokens = usage['candidatesTokenCount'] || 0

    [response_text, input_tokens, output_tokens]
  end

  def calculate_cost(input_tokens, output_tokens)
    input_cost = (input_tokens / 1_000_000.0) * PRICE_INPUT_1M
    output_cost = (output_tokens / 1_000_000.0) * PRICE_OUTPUT_1M
    (input_cost + output_cost).round(8)
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
        code: match[:code].strip
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
