# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'open3'
require 'timeout'

# BaseCodex: The central ancestor for all adapters.
# Orchestrates file management, shell execution, and code extraction logic.
class BaseCodex
  class CodexError < StandardError; end

  attr_reader :name

  def initialize(name, config = {})
    @name = name
    @config = config || {}

    # Dynamic settings from config/codexes.yml
    @supported_extensions = @config[:supported_extensions] || []
    @language_mappings    = @config[:language_mappings] || {}
    @shebangs             = @config[:shebangs] || {}
  end

  # --- Abstract Interface (To be implemented by subclasses) ---
  def run_generation(prompt, dir:, log_path: nil)
    start_time = Time.now
    begin
      raw, response_text, usage = call_api(prompt)
      elapsed = Time.now - start_time
      metrics = build_metrics(usage, elapsed)

      log_execution(log_path, prompt, metrics, usage, raw) if log_path
      save_generated_code(response_text, dir)
      sleep(@cooldown_seconds || 1.0)

      { success: true, elapsed_seconds: elapsed.round(1), metrics: metrics, response_text: response_text }
    rescue StandardError => e
      handle_error(e, start_time)
    end
  end

  def call_api(prompt); raise NotImplementedError; end
  def version; raise NotImplementedError; end
  def warmup(warmup_dir); { success: true, elapsed_seconds: 0.0 }; end

  protected

  attr_reader :config

  # --- Data Sanitization Helpers ---
  def presence(v); (s = v.to_s.strip).empty? ? nil : s; end
  def float_or_nil(v); Float(v.to_s.delete(',')) rescue nil; end
  def float_or_default(v, d); float_or_nil(v) || d; end
  def integer_or_default(v, d); Integer(v.to_s.delete(',')) rescue d; end

  # --- Common Operations ---
  def calculate_cost(input, output, cached: 0)
    million = 1_000_000.0
    total = 0.0
    total += ((input - cached) / million) * (@price_input_1m || 0.0)
    total += (cached / million) * (@price_cached_input_1m || @price_input_1m || 0.0)
    total += (output / million) * (@price_output_1m || 0.0)
    total.round(8)
  end

  def log_execution(path, prompt, metrics, usage, raw)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate({
      model: @model,
      prompt: prompt,
      metrics: metrics,
      usage: usage,
      raw_response: raw
    }))
  end

  def handle_error(e, start_time)
    puts "\n" + ("!" * 50)
    puts "❌ #{@name.upcase} ADAPTER ERROR: #{@model} -> #{e.message}"
    puts ("!" * 50) + "\n"
    { success: false, elapsed_seconds: (Time.now - start_time).round(1), error: e.message }
  end

  # --- Central Execution Engine ---
  def run_cmd(cmd, dir: nil, timeout: 600, env: {})
    opts = { chdir: dir }.compact
    env_hash = env.transform_keys(&:to_s)
    
    # Open3.popen3: Allows independent management of stdin, stdout, and stderr
    Open3.popen3(env_hash, cmd, **opts) do |stdin, stdout, stderr, wait_thr|
      stdin.close
      
      # UTF-8 Protection: Clean up non-standard characters in CLI output
      [stdout, stderr].each { |io| io.set_encoding('UTF-8', invalid: :replace, undef: :replace) }
      
      out_content = err_content = ''
      begin
        Timeout.timeout(timeout) do
          out_content = stdout.read
          err_content = stderr.read
        end
      rescue Timeout::Error
        Process.kill('TERM', wait_thr.pid) rescue nil
        out_content << "\n[Execution timeout after #{timeout}s]"
      end
      
      status = wait_thr.value
      { stdout: out_content, stderr: err_content, exit_code: status.exitstatus, success: status.success? }
    end
  rescue StandardError => e
    { stdout: '', stderr: e.message, exit_code: 1, success: false }
  end

  # --- Code Extraction and Saving (The Magic) ---
  def save_generated_code(response_text, dir)
    return if response_text.to_s.strip.empty?

    lang = read_benchmark_value(dir, '.benchmark-language') || infer_language_from_dir(dir)
    binary_name = read_benchmark_value(dir, '.benchmark-binary-name') || 'minigit'
    
    blocks = extract_code_blocks(response_text, binary_name)
    written_files = []

    # 1. Process Metadata-driven Named Blocks
    blocks.select { |b| b[:filename] }.each do |block|
      path = File.join(dir, block[:filename])
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, block[:code])
      written_files << block[:filename]
    end

    # 2. Process Primary Block (Unnamed but language-compliant)
    primary = choose_primary_block(blocks, lang)
    if primary
      target = primary_target_for(lang, binary_name: binary_name)
      if target && !written_files.include?(target)
        code = normalize_script(primary[:code], lang, target, binary_name)
        File.write(File.join(dir, target), code)
        written_files << target
      end
    # 3. Last Resort: Clean and save raw text if no blocks are found
    elsif written_files.empty? && response_text.length > 20
      target = primary_target_for(lang, binary_name: binary_name)
      clean = response_text.gsub(/```.*?```/m, '').strip
      File.write(File.join(dir, target), normalize_script(clean, lang, target, binary_name))
      written_files << target
    end

    # Prepare runtime files (build.sh, etc.) and set permissions
    ensure_runtime_files(lang, dir, written_files, binary_name)
    chmod_targets(dir, binary_name)
  end

  private

  def extract_code_blocks(text, binary_name)
    blocks = []
    text.scan(/```[ \t]*(?<lang>[A-Za-z0-9_+-]*)[ \t]*\n(?<code>.*?)```/m) do |lang_tag, code|
      # Attempt to infer filename from the text context preceding the code block
      context = text[[0, text.index(code).to_i - 400].max, 400]
      blocks << {
        fence_lang: lang_tag.downcase.strip,
        filename: infer_filename(context, binary_name),
        code: code.strip
      }
    end
    blocks
  end

  def infer_filename(context, binary_name)
    # Scan for common extensions
    exts = %w[rb py go rs c h ts js java pl lua ml hs cs php cpp hpp Makefile build\.sh]
    pattern = exts.join('|')
    
    # Check backticks for specific targets (e.g., `main.c`)
    backticked = context.scan(/`([^`\n]+)`/).flatten.reverse.find do |t|
      t.match?(/\A(#{binary_name}|Makefile|build\.sh|[\w.\/-]+\.(?:#{pattern}))\z/i)
    end
    return backticked if backticked

    # Check for "file named X" descriptive patterns
    context[/file named\s+[`"]?([A-Za-z0-9._\/-]+)[`"]?/i, 1]
  end

  def choose_primary_block(blocks, lang)
    return nil if blocks.empty?
    expected = {
      'python' => %w[python py], 'ruby' => %w[ruby rb], 'c' => %w[c cpp],
      'go' => %w[go], 'rust' => %w[rust rs], 'javascript' => %w[js javascript]
    }.fetch(lang.split('/').first, [lang])
    
    blocks.find { |b| expected.include?(b[:fence_lang]) } || blocks.max_by { |b| b[:code].length }
  end

  def primary_target_for(lang, binary_name: 'minigit')
    {
      'go' => 'main.go', 'rust' => 'main.rs', 'c' => 'main.c', 
      'java' => 'MiniGit.java', 'typescript' => 'main.ts'
    }.fetch(lang, binary_name)
  end

  def normalize_script(code, lang, target, binary_name)
    return code if target != binary_name || code.start_with?('#!')
    shebang = @shebangs[lang] || {
      'python' => '#!/usr/bin/env python3', 'ruby' => '#!/usr/bin/env ruby',
      'javascript' => '#!/usr/bin/env node'
    }[lang.split('/').first]
    shebang ? "#{shebang}\n#{code}\n" : code
  end

  def ensure_runtime_files(lang, dir, written, bin)
    case lang.split('/').first
    when 'go'    then write_if_missing(dir, 'build.sh', "#!/bin/bash\ngo build -o #{bin} main.go\n", written)
    when 'rust'  then write_if_missing(dir, 'build.sh', "#!/bin/bash\nrustc -O main.rs -o #{bin}\n", written)
    when 'c'     then write_if_missing(dir, 'build.sh', "#!/bin/bash\ngcc -O2 -o #{bin} main.c\n", written)
    when 'java'  then 
      write_if_missing(dir, 'build.sh', "#!/bin/bash\njavac MiniGit.java\n", written)
      write_if_missing(dir, bin, "#!/bin/bash\njava MiniGit \"$@\"\n", written)
    end
  end

  def write_if_missing(dir, file, content, written)
    path = File.join(dir, file)
    unless written.include?(file) || File.exist?(path)
      File.write(path, content)
      written << file
    end
  end

  def chmod_targets(dir, bin)
    [bin, 'build.sh', 'Makefile', 'makefile'].each do |f|
      path = File.join(dir, f)
      FileUtils.chmod(0755, path) if File.exist?(path)
    end
  end

  def read_benchmark_value(dir, file)
    path = File.join(dir, file)
    File.read(path).strip if File.file?(path) rescue nil
  end

  def infer_language_from_dir(dir)
    File.basename(dir)[/-(rust|go|c|typescript|javascript|java|python|ruby|lua)-/i, 1] || 'python'
  end
end
