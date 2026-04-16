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
    @model        = presence(config[:model]) || presence(config[:model_name])
    
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

  def version; @model; end

  # Lightweight request to verify connectivity and model status
  def warmup(warmup_dir)
    puts "  Warmup: Running trivial prompt on OpenAI (#{@model})..."
    run_generation('Respond with just OK.', dir: warmup_dir)
  end

  def call_api(prompt)
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
      model: @model,
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
      cost_usd: calculate_cost(input, output, cached: cached),
      model: @model,
      duration_ms: (elapsed * 1000).round
    }
  end
end
