# frozen_string_literal: true

require_relative 'base_codex'
require 'json'
require 'time'
require 'shellwords'
require 'fileutils'

# ClaudeCodex: Adapter for the Claude Code CLI.
# Handles command-line interaction and JSON event stream parsing.
class ClaudeCodex < BaseCodex
  def initialize(config = {})
    super('claude', config)
    
    # Environment and Execution Metadata
    @extra_path       = presence(config[:extra_path]) || ''
    @timeout_seconds  = integer_or_default(config[:timeout_seconds], 1200)
    @cooldown_seconds = float_or_default(config[:cooldown_seconds], 1.0)
    
    # Critical: Ensure the CLI binary is available in the environment
    validate_cli_availability!
  end

  def version
    # Safe retrieval of 'claude --version'
    result = run_cmd('claude --version', timeout: 5)
    result[:success] ? result[:stdout].strip : 'unknown'
  rescue StandardError
    'unknown'
  end

  def warmup(warmup_dir)
    puts "  Warmup: Validating Claude Code CLI (v#{version})..."
    run_generation('Respond with just OK.', dir: warmup_dir)
  end

  def run_generation(prompt, dir:, log_path: nil)
    start_time = Time.now
    
    # Build CLI command with JSON output and auto-permission skip
    cmd = build_command(prompt)

    begin
      # Execution via centralized BaseCodex logic
      result = run_cmd(cmd, dir: dir, timeout: @timeout_seconds)
      elapsed = Time.now - start_time
      metrics = parse_metrics(result[:stdout])

      log_execution(log_path, prompt, result[:stdout]) if log_path && result[:stdout]
      
      # Claude CLI handles file creation, but we use BaseCodex extraction as a safety measure
      save_generated_code(result[:stdout], dir)
      sleep(@cooldown_seconds)

      {
        success: result[:success],
        elapsed_seconds: elapsed.round(1),
        metrics: metrics,
        stdout: result[:stdout],
        stderr: result[:stderr]
      }
    rescue StandardError => e
      handle_error(e, start_time)
    end
  end

  private

  def build_command(prompt)
    # Configure PATH and clear CLAUDECODE variable for an isolated execution environment
    env_prefix = "unset CLAUDECODE && export PATH=#{@extra_path}:$PATH && "
    "#{env_prefix}claude -p #{Shellwords.escape(prompt)} --dangerously-skip-permissions --output-format json"
  end

  def parse_metrics(raw_output)
    return nil if raw_output.to_s.strip.empty?

    # Claude CLI may output multiple JSON objects in a stream; we target the final 'result'
    processed = raw_output.dup.force_encoding('UTF-8')
    events = JSON.parse(processed.strip)
    events = [events] unless events.is_a?(Array)

    result_event = events.reverse.find { |e| e.is_a?(Hash) && e['type'] == 'result' }
    return nil unless result_event

    usage = result_event['usage'] || {}
    {
      input_tokens:   usage['input_tokens'] || 0,
      output_tokens:  usage['output_tokens'] || 0,
      cache_creation: usage['cache_creation_input_tokens'] || 0,
      cache_read:     usage['cache_read_input_tokens'] || 0,
      cost_usd:       result_event['total_cost_usd'] || 0.0,
      num_turns:      result_event['num_turns'] || 0,
      duration_ms:    result_event['duration_ms'] || 0,
      model:          'claude-code-cli'
    }
  rescue JSON::ParserError
    nil
  end

  def log_execution(path, prompt, raw_stdout)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate({
      prompt: prompt,
      raw_output: raw_stdout,
      timestamp: Time.now.iso8601
    }))
  end

  def handle_error(e, start_time)
    puts "\n" + ("!" * 50)
    puts "❌ CLAUDE CLI ERROR: #{e.message}"
    puts ("!" * 50) + "\n"
    { success: false, elapsed_seconds: (Time.now - start_time).round(1), error: e.message }
  end

  def validate_cli_availability!
    # Check for the existence of the claude binary in the system PATH
    `which claude`
    raise CodexError, "Claude CLI not found in PATH (#{@extra_path})" unless $?.success?
  end
end
