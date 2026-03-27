# frozen_string_literal: true

require_relative 'base_codex'
require 'open3'
require 'json'
require 'time'
require 'timeout'
require 'shellwords'
require 'fileutils'

# AiderCodex: Specialized adapter for the Aider CLI tool (https://aider.chat).
# Wraps the aider CLI tool to generate code using any supported model.
# Handles local file manipulation and token/cost parsing from CLI output.
class AiderCodex < BaseCodex
  DEFAULT_TIMEOUT_SECONDS = 1200
  DEFAULT_COOLDOWN_SECONDS = 0.0

  def initialize(config = {})
    super('aider', config || {})
    
    # Configuration-driven CLI Metadata
    @model        = presence(config[:model]) || 'gemini/gemini-2.0-flash'
    @python_bin   = presence(config[:python_bin]) || 'python3'
    @edit_format  = presence(config[:edit_format]) || 'whole'
    @aider_path   = presence(config[:aider_path]) || 'aider'
    
    # API Key Management (Support both conventions)
    raw_key = config[:gemini_api_key] || config[:api_key]
    if raw_key.to_s == '${GOOGLE_API_KEY}' || raw_key.nil?
      @api_key = ENV['GOOGLE_API_KEY'] || ENV['GEMINI_API_KEY']
    else
      @api_key = raw_key
    end

    @timeout  = (config[:timeout_seconds]  || DEFAULT_TIMEOUT_SECONDS).to_i
    @cooldown = (config[:cooldown_seconds] || DEFAULT_COOLDOWN_SECONDS).to_f

    validate_config!
  end

  def version
    # Utilizing centralized run_cmd for version checking
    result = run_cmd("#{@python_bin} -m aider --version")
    result[:success] ? result[:stdout].strip : 'not installed'
  rescue StandardError
    'not installed'
  end

  def warmup(dir)
    puts "  Warmup: Validating Aider CLI (Model: #{@model})..."
    result = run_generation("Respond with 'OK'.", dir: dir)
    puts "  Warmup done in #{result[:elapsed_seconds]}s (success=#{result[:success]})"
    sleep(@cooldown) if @cooldown > 0
    result
  end

  def run_generation(prompt, dir:, log_path: nil)
    start_time = Time.now
    
    # Prepare environment and target files
    lang         = read_benchmark_value(dir, '.benchmark-language') || infer_language_from_dir(dir)
    binary_name  = read_benchmark_value(dir, '.benchmark-binary-name') || 'minigit'
    source_file  = primary_target_for(lang, binary_name: binary_name) || binary_name
    source_path  = File.join(dir, source_file)

    # Aider requires the target file to already exist (Seed content)
    FileUtils.mkdir_p(File.dirname(source_path))
    unless File.exist?(source_path) && File.size?(source_path)
      File.write(source_path, initial_content_for(lang))
    end

    begin
      # Build Command & Env
      file_names = ensure_target_files(dir)
      cmd = build_aider_command(prompt, file_names)
      env = { 
        'GEMINI_API_KEY' => @api_key.to_s, 
        'PYTHONIOENCODING' => 'utf-8' 
      }

      # Execution via centralized BaseCodex logic or direct Open3
      result = run_cmd(cmd, dir: dir, env: env, timeout: @timeout)
      elapsed = Time.now - start_time
      
      raw_output = "#{result[:stdout]}\n#{result[:stderr]}"
      metrics = parse_metrics(raw_output)
      metrics[:duration_ms] = (elapsed * 1000).round if metrics

      # Post-generation: Ensure runtime files and permissions
      written_files = [source_file]
      ensure_runtime_files(lang, dir, written_files, binary_name: binary_name)
      chmod_if_present(File.join(dir, binary_name))
      chmod_if_present(File.join(dir, 'build.sh'))

      log_execution(log_path, prompt, result, metrics, lang, source_file) if log_path

      # Success check: exit code or file growth
      success = result[:success] || (File.exist?(source_path) && File.size(source_path) > 20)

      sleep(@cooldown) if @cooldown > 0

      {
        success: success,
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

  def build_aider_command(prompt, files)
    base_args = [
      *@python_bin.split, '-m', 'aider',
      '--no-git',
      '--yes',
      '--no-show-model-warnings',
      '--edit-format', @edit_format,
      '--model', @model,
      '--message', "#{prompt}\n\nCRITICAL: Write COMPLETE code for: #{files.join(', ')}"
    ]
    Shellwords.join(base_args + files)
  end

  def parse_metrics(raw_output)
    return nil if raw_output.nil? || raw_output.strip.empty?

    # Captures Aider's terminal output: "Tokens: 1.2k sent, 300 received. Cost: $0.01"
    sent     = raw_output[/Tokens:\s*([\d,.k]+)\s+sent/i,   1]
    received = raw_output[/sent,\s*([\d,.k]+)\s+received/i, 1]
    cost     = raw_output[/Cost:\s*\$([\d.]+)/i,             1]&.to_f || 0.0
    model    = raw_output[/^Model:\s*(.+)$/,                 1]&.strip || @model

    {
      input_tokens:  parse_aider_number(sent),
      output_tokens: parse_aider_number(received),
      cost_usd:      cost.round(8),
      model:         model,
      num_turns:     1,
      duration_ms:   0 # Filled by caller
    }
  rescue StandardError
    nil
  end

  def parse_aider_number(str)
    return 0 if str.nil?
    num_str = str.delete(',').downcase
    num_str.include?('k') ? (num_str.to_f * 1000).to_i : num_str.to_i
  end

  def log_execution(path, prompt, result, metrics, lang, source_file)
    FileUtils.mkdir_p(File.dirname(path))
    log_data = {
      model: @model,
      lang: lang,
      source_file: source_file,
      prompt: prompt,
      success: result[:success],
      stdout: result[:stdout],
      stderr: result[:stderr],
      metrics: metrics,
      timestamp: Time.now.iso8601
    }
    File.write(path, JSON.pretty_generate(log_data))
  end

  def handle_error(e, start_time)
    elapsed = Time.now - start_time rescue 0.0
    { success: false, elapsed_seconds: elapsed.round(1), metrics: nil, error: e.message }
  end

  # --- File & Language Helpers ---

  def ensure_target_files(dir)
    targets = Dir.glob(File.join(dir, '*')).select { |f| File.file?(f) && !f.start_with?('.') }
    if targets.empty?
      fallback = File.join(dir, 'main.c')
      File.write(fallback, "// Generated by Benchmark\n")
      targets = [fallback]
    end
    targets.map { |f| File.basename(f) }
  end

  def read_benchmark_value(dir, filename)
    path = File.join(dir, filename)
    File.read(path, encoding: 'UTF-8').strip if File.file?(path)
  rescue StandardError
    nil
  end

  def infer_language_from_dir(dir)
    dir_name = File.basename(dir)
    matched = dir_name[/-(rust|go|c|typescript|javascript|java|perl|python(?:-mypy)?|ruby(?:-steep)?|lua|scheme|ocaml|haskell)-\d+-v[12]$/, 1]
    matched ||= dir_name.sub(/^minigit-/, '').sub(/-\d+-v[12]$/, '')
    { 'python-mypy' => 'python/mypy', 'ruby-steep' => 'ruby/steep' }.fetch(matched, matched)
  end

  def primary_target_for(lang, binary_name: 'minigit')
    targets = {
      'go' => 'main.go', 'rust' => 'main.rs', 'c' => 'main.c',
      'java' => 'MiniGit.java', 'typescript' => 'main.ts',
      'scheme' => 'main.scm', 'ocaml' => 'main.ml', 'haskell' => 'Main.hs'
    }
    targets[lang] || binary_name
  end

  def initial_content_for(lang)
    shebangs = {
      'python' => '#!/usr/bin/env python3', 'ruby' => '#!/usr/bin/env ruby',
      'javascript' => '#!/usr/bin/env node', 'perl' => '#!/usr/bin/env perl',
      'lua' => '#!/usr/bin/env lua'
    }
    shebangs[lang] ? "#{shebangs[lang]}\n# TODO: implement\n" : ''
  end

  def ensure_runtime_files(lang, dir, written_files, binary_name: 'minigit')
    # Build scripts and launchers logic preserved from feature branch
    case lang
    when 'go', 'rust', 'c', 'ocaml', 'haskell'
      cmd = case lang
            when 'go' then "go build -o #{binary_name} main.go"
            when 'rust' then "rustc -O main.rs -o #{binary_name}"
            when 'c' then "gcc -O2 -o #{binary_name} main.c"
            when 'ocaml' then "ocamlc -o #{binary_name} main.ml"
            when 'haskell' then "ghc -O2 -o #{binary_name} Main.hs"
            end
      write_if_missing(dir, 'build.sh', "#!/usr/bin/env bash\nset -e\n#{cmd}\n", written_files)
    when 'java', 'typescript', 'scheme'
      # Launcher scripts for interpreted/VM languages
      write_if_missing(dir, binary_name, launcher_script(lang), written_files)
    end
  end

  def launcher_script(kind)
    case kind
    when 'java' then "#!/usr/bin/env bash\nexec java MiniGit \"$@\""
    when 'typescript' then "#!/usr/bin/env bash\nexec tsx main.ts \"$@\""
    when 'scheme' then "#!/usr/bin/env bash\nexec guile -s main.scm \"$@\""
    end
  end

  def write_if_missing(dir, rel_path, content, written)
    return if written.include?(rel_path)
    File.write(File.join(dir, rel_path), content)
    written << rel_path
  end

  def chmod_if_present(path)
    FileUtils.chmod(0755, path) if File.exist?(path)
  end

  def validate_config!
    raise CodexError, 'Aider requires GOOGLE_API_KEY / GEMINI_API_KEY' unless @api_key
  end

  def presence(val)
    val.to_s.strip.empty? ? nil : val
  end
end