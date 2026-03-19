# frozen_string_literal: true

require_relative 'base_codex'
require 'open3'
require 'json'
require 'time'
require 'timeout'
require 'shellwords'
require 'fileutils'

# Aider CLI adapter (https://aider.chat)
# Wraps the aider CLI tool to generate code using any supported model.
# Primary free use: Ollama with a local model (no API key needed).
# Alternative: Gemini free tier (1000 req/day).
class AiderCodex < BaseCodex
  DEFAULT_TIMEOUT_SECONDS = 1200
  DEFAULT_COOLDOWN_SECONDS = 0.0

  def initialize(config = {})
    super('aider', config)
    @model           = config[:model]           || 'ollama/qwen2.5-coder:7b'
    @api_key         = config[:api_key]         || nil
    @aider_path      = config[:aider_path]      || 'aider'
    @timeout         = (config[:timeout_seconds]  || DEFAULT_TIMEOUT_SECONDS).to_i
    @cooldown        = (config[:cooldown_seconds] || DEFAULT_COOLDOWN_SECONDS).to_f
    @ollama_api_base = config[:ollama_api_base] || ENV['OLLAMA_API_BASE'] || nil
  end

  def version
    result = run_cmd("#{@aider_path} --version 2>&1")
    result[:stdout].strip.then { |v| v.empty? ? 'unknown' : v }
  end

  def warmup(warmup_dir)
    puts "  Warmup: Running trivial prompt on Aider (#{@model})..."
    result = run_generation('Create a file hello.txt containing just the word OK.', dir: warmup_dir)
    puts "  Warmup done in #{result[:elapsed_seconds]}s (success=#{result[:success]})"
    sleep(@cooldown) if @cooldown > 0
    result
  end

  def run_generation(prompt, dir:, log_path: nil)
    unless aider_available?
      return {
        success: false,
        elapsed_seconds: 0.0,
        metrics: nil,
        error: "aider not found at '#{@aider_path}'. Install with: pip install aider-chat"
      }
    end

    lang        = read_benchmark_value(dir, '.benchmark-language') || infer_language_from_dir(dir)
    binary_name = read_benchmark_value(dir, '.benchmark-binary-name') || 'minigit'
    source_file = primary_target_for(lang, binary_name: binary_name) || binary_name
    source_path = File.join(dir, source_file)

    # Aider requires the target file to already exist.
    # For script languages without file extensions, seed with a shebang so
    # Aider knows the language and rewrites the file rather than ignoring it.
    FileUtils.mkdir_p(File.dirname(source_path))
    unless File.exist?(source_path) && File.size?(source_path)
      File.write(source_path, initial_content_for(lang))
    end

    cmd = build_command(prompt, source_file)

    env = {}
    env['OLLAMA_API_BASE'] = @ollama_api_base if @ollama_api_base

    start_time = Time.now
    result     = run_cmd(cmd, dir: dir, timeout: @timeout, env: env)
    elapsed    = Time.now - start_time

    raw_output = "#{result[:stdout]}\n#{result[:stderr]}"
    metrics    = parse_metrics(raw_output)
    metrics[:duration_ms] = (elapsed * 1000).round if metrics

    # Aider only edits the source file; build scripts and launcher wrappers
    # are added here (same logic as GeminiCodex / OpenAICodex).
    written_files = [source_file]
    ensure_runtime_files(lang, dir, written_files, binary_name: binary_name)
    chmod_if_present(File.join(dir, binary_name))
    chmod_if_present(File.join(dir, 'build.sh'))

    if log_path
      FileUtils.mkdir_p(File.dirname(log_path))
      File.write(log_path, JSON.pretty_generate(
        model:        @model,
        lang:         lang,
        source_file:  source_file,
        prompt:       prompt,
        stdout:       result[:stdout],
        stderr:       result[:stderr],
        exit_code:    result[:exit_code],
        elapsed_seconds: elapsed.round(1),
        metrics:      metrics
      ))
    end

    sleep(@cooldown) if @cooldown > 0

    # Aider occasionally exits non-zero on warnings even after writing code
    success = result[:success] || (File.size?(source_path) || 0) > 0

    {
      success: success,
      elapsed_seconds: elapsed.round(1),
      metrics: metrics,
      stdout: result[:stdout],
      stderr: result[:stderr]
    }
  rescue StandardError => e
    elapsed = Time.now - start_time rescue 0.0
    {
      success: false,
      elapsed_seconds: elapsed.to_f.round(1),
      metrics: nil,
      error: e.message
    }
  end

  def parse_metrics(raw_output)
    return nil if raw_output.nil? || raw_output.strip.empty?

    # Aider prints token/cost summary lines, e.g.:
    #   Tokens: 1,234 sent, 567 received.
    #   Cost: $0.001 message, $0.002 session.
    sent     = raw_output[/Tokens:\s*([\d,]+)\s+sent/,          1]&.gsub(',', '')&.to_i || 0
    received = raw_output[/sent,\s*([\d,]+)\s+received/,        1]&.gsub(',', '')&.to_i || 0
    cost     = raw_output[/Cost:\s*\$([\d.]+)\s+message/,       1]&.to_f || 0.0
    model    = raw_output[/^Model:\s*(.+)$/,                    1]&.strip || @model

    {
      input_tokens:          sent,
      output_tokens:         received,
      cache_creation_tokens: 0,
      cache_read_tokens:     0,
      num_turns:             1,
      cost_usd:              cost.round(8),
      model:                 model,
      duration_ms:           0   # filled in by run_generation
    }
  rescue StandardError
    nil
  end

  private

  def aider_available?
    result = run_cmd("#{@aider_path} --version 2>/dev/null", timeout: 10)
    result[:exit_code] != 127 # 127 = command not found
  rescue StandardError
    false
  end

  def build_command(prompt, source_file)
    parts = [
      @aider_path,
      '--message', Shellwords.escape(prompt),
      '--yes-always',
      '--no-git',
      '--edit-format', 'whole',
      '--model', Shellwords.escape(@model)
    ]

    if @api_key
      parts += ['--api-key', Shellwords.escape("#{api_key_prefix}=#{@api_key}")]
    end

    parts << Shellwords.escape(source_file)
    parts.join(' ')
  end

  # Infer the api-key provider prefix from the model string.
  # e.g. "gemini/gemini-2.0-flash-exp" → "gemini"
  #      "openai/gpt-4o" → "openai"
  def api_key_prefix
    @model.split('/').first
  end

  def run_cmd(cmd, dir: nil, timeout: @timeout, env: {})
    opts = {}
    opts[:chdir] = dir if dir
    merged_env = env.empty? ? {} : env
    stdin_r, stdout_r, stderr_r, wait_thr = Open3.popen3(merged_env, cmd, **opts)
    stdin_r.close
    stdout_r.set_encoding('UTF-8')
    stderr_r.set_encoding('UTF-8')
    stdout = stderr = ''
    begin
      Timeout.timeout(timeout) do
        stdout = stdout_r.read
        stderr = stderr_r.read
      end
    rescue Timeout::Error
      Process.kill('TERM', wait_thr.pid) rescue nil
      stdout = stdout_r.read rescue ''
      stderr = "Timeout after #{timeout}s"
    end
    stdout_r.close
    stderr_r.close
    status = wait_thr.value
    { stdout: stdout, stderr: stderr, exit_code: status.exitstatus, success: status.success? }
  end

  # -------------------------------------------------------------------------
  # File helpers (mirrors GeminiCodex / OpenAICodex)
  # -------------------------------------------------------------------------

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
      'ruby-steep'  => 'ruby/steep'
    }.fetch(dir_name, dir_name)
  end

  def primary_target_for(lang, binary_name: 'minigit')
    {
      'python'      => binary_name,
      'python/mypy' => binary_name,
      'ruby'        => binary_name,
      'ruby/steep'  => binary_name,
      'javascript'  => binary_name,
      'perl'        => binary_name,
      'lua'         => binary_name,
      'go'          => 'main.go',
      'rust'        => 'main.rs',
      'c'           => 'main.c',
      'java'        => 'MiniGit.java',
      'typescript'  => 'main.ts',
      'scheme'      => 'main.scm',
      'ocaml'       => 'main.ml',
      'haskell'     => 'Main.hs'
    }[lang]
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

  # Seed content so Aider recognises the language for extension-less scripts.
  def initial_content_for(lang)
    shebang = {
      'python'      => '#!/usr/bin/env python3',
      'python/mypy' => '#!/usr/bin/env python3',
      'ruby'        => '#!/usr/bin/env ruby',
      'ruby/steep'  => '#!/usr/bin/env ruby',
      'javascript'  => '#!/usr/bin/env node',
      'perl'        => '#!/usr/bin/env perl',
      'lua'         => '#!/usr/bin/env lua'
    }[lang]
    shebang ? "#{shebang}\n# TODO: implement\n" : ''
  end
end
