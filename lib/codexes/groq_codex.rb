# frozen_string_literal: true

require_relative 'base_codex'
require 'net/http'
require 'json'
require 'uri'
require 'time'
require 'fileutils'
require 'openssl'

# Groq API adapter (OpenAI Compatible) - Production Grade
class GroqCodex < BaseCodex
  API_URL = 'https://api.groq.com/openai/v1/chat/completions'

  # Groq Llama 3.3 70B Pricing (March 2026)
  PRICE_INPUT_1M = 0.59
  PRICE_OUTPUT_1M = 0.79

  def initialize(config = {})
    super('groq', config)
    @api_key = config[:api_key] || ENV['GROQ_API_KEY']
    @model_name = config[:model] || config[:model_name] || 'llama-3.3-70b-versatile'
    @cooldown_seconds = config[:cooldown_seconds] || 1.5

    raise CodexError, 'GROQ_API_KEY not configured' unless @api_key
  end

  def version
    @model_name
  end

  def warmup(warmup_dir)
    puts "  Warmup: Running trivial prompt on Groq (#{@model_name})..."
    result = run_generation('Respond with just OK.', dir: warmup_dir)
    puts "  Warmup done in #{result[:elapsed_seconds]}s (success=#{result[:success]})"
    sleep(@cooldown_seconds)
    result
  end

  def run_generation(prompt, dir:, log_path: nil)
    start_time = Time.now

    begin
      response_text, input_tokens, output_tokens = call_groq_api(prompt)
      cost_usd = calculate_cost(input_tokens, output_tokens)
      elapsed = Time.now - start_time

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

      save_generated_code(response_text, dir)
      sleep(@cooldown_seconds)

      {
        success: true,
        elapsed_seconds: elapsed.round(1),
        metrics: {
          input_tokens: input_tokens,
          output_tokens: output_tokens,
          cost_usd: cost_usd,
          model: @model_name,
          duration_ms: (elapsed * 1000).round
        },
        response_text: response_text
      }
    rescue StandardError => e
      puts "!!! GROQ DEBUG ERROR: #{e.message}"
      elapsed = Time.now - start_time
      {
        success: false,
        elapsed_seconds: elapsed.round(1),
        metrics: nil,
        error: "Groq Error: #{e.message}"
      }
    end
  end

  private

  def call_groq_api(prompt)
    uri = URI.parse(API_URL)
    
    # SYSTEM PROMPT INJECTION: Forcing the model to focus only on code generation
    system_instruction = <<~TEXT
      You are a senior software engineer. 
      Respond ONLY with the source code. 
      Do not include any conversational text, explanations, or notes.
      Always wrap your code in triple backticks with the correct language identifier (e.g., ```python).
    TEXT

    request_body = {
      model: @model_name,
      messages: [
        { role: 'system', content: system_instruction },
        { role: 'user', content: prompt }
      ],
      temperature: 0.1,
      max_tokens: 4096 
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 60

    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    request.body = JSON.generate(request_body)

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      error_msg = JSON.parse(response.body)['error']['message'] rescue response.body
      raise CodexError, "Groq API error (#{response.code}): #{error_msg}"
    end

    data = JSON.parse(response.body)
    response_text = data.dig('choices', 0, 'message', 'content') || ''
    usage = data['usage'] || {}
    
    [response_text, usage['prompt_tokens'] || 0, usage['completion_tokens'] || 0]
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

    # 1. Write blocks with identified filenames (e.g., Makefile)
    blocks.select { |block| block[:filename] }.each do |block|
      path = File.join(dir, block[:filename])
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, block[:code])
      written_files << block[:filename]
    end

    # 2. Select the primary code block and write to the target file
    primary_block = choose_primary_block(blocks, lang)
    if primary_block
      target = primary_target_for(lang, binary_name: binary_name)
      if target && !written_files.include?(target)
        code = normalize_script_for_target(primary_block[:code], lang, target, binary_name: binary_name)
        File.write(File.join(dir, target), code)
        written_files << target
      end
    # FALLBACK: If no markdown blocks were captured but response is substantial,
    # clean the response and treat it as code (prevents LOC 1 issues).
    elsif written_files.empty? && response_text.length > 200
      target = primary_target_for(lang, binary_name: binary_name) || binary_name
      clean_code = response_text.gsub(/```[a-z]*|```/, '').strip
      code = normalize_script_for_target(clean_code, lang, target, binary_name: binary_name)
      File.write(File.join(dir, target), code)
      written_files << target
    end

    ensure_runtime_files(lang, dir, written_files, binary_name: binary_name)
    
    # Set executable permissions
    [binary_name, 'build.sh'].each do |f|
      path = File.join(dir, f)
      FileUtils.chmod(0755, path) if File.exist?(path)
    end
  end

  def extract_code_blocks(response_text, binary_name)
    blocks = []
    # Flexible Regex: Handles leading whitespace, varied sat-ends (\r\n), and nameless blocks
    response_text.to_enum(:scan, /```[ \t]*(?<lang>[A-Za-z0-9_+-]*)[ \t]*\r?\n(?<code>.*?)```/m).each do
      match = Regexp.last_match
      context = response_text[[match.begin(0) - 400, 0].max...match.begin(0)]
      blocks << {
        fence_lang: match[:lang].to_s.downcase.strip,
        filename: infer_filename_from_context(context, binary_name),
        code: match[:code].strip
      }
    end
    blocks
  end

  def infer_filename_from_context(context, binary_name)
    binary_pattern = Regexp.escape(binary_name)
    backticked = context.scan(/`([^`\n]+)`/).flatten.reverse.find do |token|
      token.match?(/\A(?:#{binary_pattern}|Makefile|makefile|build\.sh|[\w.\/-]+\.(?:rb|py|go|rs|c|h|ts|js|java|pl|lua|scm|ml|hs))\z/)
    end
    return backticked if backticked
    context[/file named\s+[`"]?([A-Za-z0-9._\/-]+)[`"]?/i, 1]
  end

  def choose_primary_block(blocks, lang)
    return nil if blocks.empty?
    expected = { 
      'python' => %w[python py], 'ruby' => %w[ruby rb], 
      'go' => %w[go], 'rust' => %w[rust rs], 'c' => %w[c] 
    }.fetch(lang, [])
    # Find block for the expected language, otherwise fallback to the longest code block
    blocks.find { |b| expected.include?(b[:fence_lang]) } || blocks.max_by { |b| b[:code].length }
  end

  def primary_target_for(lang, binary_name: 'minigit')
    { 'python' => binary_name, 'ruby' => binary_name, 'go' => 'main.go', 'rust' => 'main.rs', 'c' => 'main.c' }[lang]
  end

  def normalize_script_for_target(code, lang, target, binary_name: 'minigit')
    return code if code.start_with?('#!')
    shebang = { 'python' => '#!/usr/bin/env python3', 'ruby' => '#!/usr/bin/env ruby' }[lang]
    shebang ? "#{shebang}\n#{code}\n" : code
  end

  def ensure_runtime_files(lang, dir, written_files, binary_name: 'minigit')
    case lang
    when 'go' then write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\ngo build -o #{binary_name} main.go\n", written_files)
    when 'rust' then write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nrustc -O main.rs -o #{binary_name}\n", written_files)
    when 'c' then write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\ngcc -O2 -o #{binary_name} main.c\n", written_files)
    end
  end

  def read_benchmark_value(dir, filename)
    path = File.join(dir, filename)
    File.file?(path) ? File.read(path, encoding: 'UTF-8').strip : nil
  rescue StandardError
    nil
  end

  def infer_language_from_dir(dir)
    dir_name = File.basename(dir)
    dir_name[/-(rust|go|c|typescript|javascript|java|perl|python|ruby|lua|scheme|ocaml|haskell)-\d+-v[12]$/, 1] || 'python'
  end

  def write_if_missing(dir, rel_path, content, written)
    return if written.include?(rel_path)
    File.write(File.join(dir, rel_path), content)
    written << rel_path
  end
end
