# frozen_string_literal: true

require_relative 'base_codex'
require 'net/http'
require 'json'
require 'uri'
require 'time'
require 'fileutils'

# GroqCodex: Adapter for high-performance inference via Groq API.
# Utilizes OpenAI-compatible chat completion endpoints.
class GroqCodex < BaseCodex
  MILLION = 1_000_000.0

  def initialize(config = {})
    super('groq', config)
    
    # API Credentials & Config
    @api_key      = presence(config[:api_key]) || ENV['GROQ_API_KEY']
    @api_url      = presence(config[:api_url]) || presence(config[:api_endpoint])
    @model_name   = presence(config[:model]) || presence(config[:model_name])
    
    # Runtime Settings
    @cooldown_seconds = float_or_default(config[:cooldown_seconds], 1.5)
    @timeout_seconds  = integer_or_default(config[:timeout_seconds], 60)
    
    # Pricing (USD per 1M tokens)
    @price_input_1m  = float_or_default(config[:price_input_1m], 0.0)
    @price_output_1m = float_or_default(config[:price_output_1m], 0.0)

    validate_config!
  end

  def version; @model_name; end

  # Lightweight request to verify connectivity and model readiness
  def warmup(warmup_dir)
    puts "  Warmup: Running trivial prompt on Groq (#{@model_name})..."
    run_generation('Respond with just OK.', dir: warmup_dir)
  end

  def run_generation(prompt, dir:, log_path: nil)
    start_time = Time.now
    begin
      raw, response_text, usage = call_groq_api(prompt)
      elapsed = Time.now - start_time
      metrics = build_metrics(usage, elapsed)

      log_execution(log_path, prompt, metrics, usage, raw) if log_path
      save_generated_code(response_text, dir)
      sleep(@cooldown_seconds)

      { success: true, elapsed_seconds: elapsed.round(1), metrics: metrics, response_text: response_text }
    rescue StandardError => e
      handle_error(e, start_time)
    end
  end

  private

  # Executes the HTTP POST request to the Groq backend
  def call_groq_api(prompt)
    uri = URI.parse(@api_url)
    
    # Path Fallback: Ensure a valid chat completions path is used
    path = uri.path.empty? ? '/openai/v1/chat/completions' : uri.path

    req = Net::HTTP::Post.new(path).tap do |r|
      r['Content-Type']  = 'application/json'
      r['Authorization'] = "Bearer #{@api_key}"
      r.body = JSON.generate(request_payload(prompt))
    end

    # Perform secure HTTP request
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', read_timeout: @timeout_seconds) do |http| 
      http.request(req) 
    end.then { |res| parse_response(res) }
  end

  def request_payload(prompt)
    {
      model: @model_name,
      messages: [
        { role: 'system', content: system_instruction },
        { role: 'user', content: prompt }
      ],
      temperature: 0.1,
      max_tokens: 4096
    }
  end

  def system_instruction
    <<~TEXT
      You are a senior software engineer. Respond ONLY with the source code. 
      Do not include conversational text or notes. 
      Always wrap code in triple backticks with the language identifier.
    TEXT
  end

  def parse_response(response)
    unless response.is_a?(Net::HTTPSuccess)
      # Extract error message from JSON body if possible
      err = JSON.parse(response.body)['error']['message'] rescue response.body
      raise CodexError, "Groq API failure (#{response.code}): #{err}"
    end
    
    data = JSON.parse(response.body)
    usage = data['usage'] || {}
    [data, data.dig('choices', 0, 'message', 'content') || '', usage]
  end

  def build_metrics(usage, elapsed)
    input  = usage['prompt_tokens'] || 0
    output = usage['completion_tokens'] || 0
    
    {
      input_tokens: input,
      output_tokens: output,
      cost_usd: calculate_cost(input, output),
      model: @model_name,
      duration_ms: (elapsed * 1000).round
    }
  end

  def calculate_cost(input, output)
    ((input / MILLION) * @price_input_1m + (output / MILLION) * @price_output_1m).round(8)
  end

  def log_execution(path, prompt, metrics, usage, raw)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate({
      model: @model_name,
      prompt: prompt,
      metrics: metrics,
      usage: usage,
      raw_response: raw
    }))
  end

  def handle_error(e, start_time)
    puts "\n" + ("!" * 50)
    puts "❌ GROQ ADAPTER ERROR: #{@model_name} -> #{e.message}"
    puts ("!" * 50) + "\n"
    { success: false, elapsed_seconds: (Time.now - start_time).round(1), error: e.message }
  end

  def validate_config!
    raise CodexError, 'GROQ_API_KEY not configured' unless @api_key
    raise CodexError, 'Groq API URL/Endpoint not configured' unless @api_url
    raise CodexError, 'Model name not configured for Groq' unless @model_name
  end
end
