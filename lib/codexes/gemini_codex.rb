# frozen_string_literal: true

require_relative 'base_codex'
require 'net/http'
require 'json'
require 'uri'
require 'time'
require 'fileutils'

# GeminiCodex: Optimized adapter for Google Gemini API.
# Handles content generation using the Google AI SDK/Vertex-style REST endpoints.
class GeminiCodex < BaseCodex
  MILLION = 1_000_000.0

  def initialize(config = {})
    super('gemini', config)
    
    # API Credentials & Config
    @api_key      = presence(config[:api_key]) || ENV['GOOGLE_API_KEY']
    @api_endpoint = presence(config[:api_endpoint]) || presence(config[:api_url])
    @model        = presence(config[:model]) || presence(config[:model_name])
    
    # Runtime Settings
    @cooldown_seconds = float_or_default(config[:cooldown_seconds], 1.2)
    @timeout_seconds  = integer_or_default(config[:timeout_seconds], 600)
    
    # Pricing Metrics (USD per 1M tokens)
    @price_input_1m  = float_or_default(config[:price_input_1m], 0.0)
    @price_output_1m = float_or_default(config[:price_output_1m], 0.0)

    validate_config!
  end

  def version; @model; end

  # Connectivity check with a minimal prompt
  def warmup(warmup_dir)
    puts "  Warmup: Validating Gemini connectivity (#{@model})..."
    run_generation('Respond with just OK.', dir: warmup_dir)
  end

  def call_api(prompt)
    uri = URI("#{@api_endpoint}/#{@model}:generateContent?key=#{@api_key}")
    
    req = Net::HTTP::Post.new(uri).tap do |r|
      r['Content-Type'] = 'application/json'
      r.body = JSON.generate({ contents: [{ parts: [{ text: prompt }] }] })
    end

    # Establish SSL connection and perform the request
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: @timeout_seconds) do |http| 
      http.request(req) 
    end.then { |res| parse_response(res) }
  end

  # Parses the JSON response and extracts error messages if the request failed
  def parse_response(response)
    unless response.is_a?(Net::HTTPSuccess)
      # Extract nested error message if available in Google's JSON format
      err = JSON.parse(response.body)['error']['message'] rescue response.body
      raise CodexError, "Gemini API failure (#{response.code}): #{err}"
    end
    
    data = JSON.parse(response.body)
    usage = data['usageMetadata'] || {}
    [data, data.dig('candidates', 0, 'content', 'parts', 0, 'text') || '', usage]
  end

  # Normalizes usage metadata into project-standard metrics
  def build_metrics(usage, elapsed)
    input  = usage['promptTokenCount'] || 0
    output = usage['candidatesTokenCount'] || 0
    
    {
      input_tokens: input,
      output_tokens: output,
      cost_usd: calculate_cost(input, output),
      model: @model,
      duration_ms: (elapsed * 1000).round
    }
  end

  def validate_config!
    raise CodexError, 'GOOGLE_API_KEY not configured' unless @api_key
    raise CodexError, 'Gemini API URL not configured' unless @api_endpoint
    raise CodexError, 'Model name not configured for Gemini' unless @model
  end
end
