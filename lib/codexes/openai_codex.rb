# frozen_string_literal: true

require_relative 'base_codex'
require 'net/http'
require 'json'
require 'uri'
require 'time'
require 'fileutils'

# OpenAICodex: Advanced adapter for OpenAI models.
# Features chat completions, granular cost accounting, and context caching support.
class OpenAICodex < BaseCodex
  DEFAULT_ENDPOINT = 'https://api.openai.com/v1/chat/completions'
  MILLION = 1_000_000.0

  def initialize(config = {})
    super('openai', config)
    
    # API Credentials - Priority: Config -> Environment Variables
    @api_key      = presence(config[:api_key]) || ENV['OPENAI_API_KEY']
    @api_endpoint = presence(config[:api_endpoint]) || DEFAULT_ENDPOINT
    @organization = presence(config[:organization]) || ENV['OPENAI_ORG_ID']
    @project      = presence(config[:project]) || ENV['OPENAI_PROJECT_ID']
    @model_name   = presence(config[:model]) || presence(config[:model_name])
    
    # Runtime Settings
    @cooldown_seconds  = float_or_default(config[:cooldown_seconds], 0.5)
    @timeout_seconds   = integer_or_default(config[:timeout_seconds], 1200)
    @max_output_tokens = config[:max_output_tokens]
    
    # Pricing Metrics (USD per 1M tokens)
    @price_input_1m        = float_or_nil(config[:price_input_1m])
    @price_cached_input_1m = float_or_nil(config[:price_cached_input_1m]) || @price_input_1m
    @price_output_1m       = float_or_nil(config[:price_output_1m])

    raise CodexError, 'OPENAI_API_KEY not configured' unless @api_key
  end

  def version; @model_name; end

  # Lightweight request to verify connectivity and model status
  def warmup(warmup_dir)
    puts "  Warmup: Running trivial prompt on OpenAI (#{@model_name})..."
    run_generation('Respond with just OK.', dir: warmup_dir)
  end

  def run_generation(prompt, dir:, log_path: nil)
    start_time = Time.now
    begin
      raw, response_text, usage = call_openai_api(prompt)
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

  # Executes the core HTTP POST request using standard Chat Completions payload
  def call_openai_api(prompt)
    uri = URI(@api_endpoint)
    req = Net::HTTP::Post.new(uri).tap do |r|
      r['Content-Type'] = 'application/json'
      r['Authorization'] = "Bearer #{@api_key}"
      r['OpenAI-Organization'] = @organization if @organization
      r['OpenAI-Project'] = @project if @project
      r.body = JSON.generate(request_payload(prompt))
    end

    # Perform secure HTTP request using dynamic host and port
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: @timeout_seconds) { |http| http.request(req) }
    parse_response(response)
  end

  def request_payload(prompt)
    {
      model: @model_name,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.1,
      max_tokens: @max_output_tokens
    }.compact # Removes nil values (like max_tokens) from the payload
  end

  def parse_response(response)
    unless response.is_a?(Net::HTTPSuccess)
      # Extract OpenAI specific error messages from the JSON body
      err = JSON.parse(response.body)['error']['message'] rescue response.body
      raise CodexError, "HTTP #{response.code}: #{err}"
    end
    
    data = JSON.parse(response.body)
    [data, data.dig('choices', 0, 'message', 'content') || '', data['usage'] || {}]
  end

  # Normalizes API usage into project-standard metrics
  def build_metrics(usage, elapsed)
    input  = usage['prompt_tokens'] || 0
    output = usage['completion_tokens'] || 0
    cached = usage.dig('prompt_tokens_details', 'cached_tokens') || 0
    
    {
      input_tokens: input,
      output_tokens: output,
      cost_usd: calculate_cost(input, cached, output),
      model: @model_name,
      duration_ms: (elapsed * 1000).round
    }
  end

  # Cost calculation based on dynamic pricing and cached token benefits
  def calculate_cost(input, cached, output)
    total = 0.0
    total += ((input - cached) / MILLION) * (@price_input_1m || 0)
    total += (cached / MILLION) * (@price_cached_input_1m || 0)
    total += (output / MILLION) * (@price_output_1m || 0)
    total.round(8)
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
    puts "❌ OPENAI ADAPTER ERROR: #{@model_name} -> #{e.message}"
    puts ("!" * 50) + "\n"
    { success: false, elapsed_seconds: (Time.now - start_time).round(1), error: e.message }
  end
end
