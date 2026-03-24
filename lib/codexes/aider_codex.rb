require_relative 'base_codex'
require 'open3'
require 'fileutils'

class AiderCodex < BaseCodex
  def initialize(config = {})
    super('aider', config || {})
    @model = config[:model] || config['model'] || 'gemini/gemini-2.5-pro'
    
    # API Anahtarı Yönetimi
    raw_key = config[:gemini_api_key] || config['gemini_api_key']
    if raw_key == "${GOOGLE_API_KEY}"
      @api_key = ENV['GOOGLE_API_KEY']
    else
      @api_key = raw_key || ENV['GEMINI_API_KEY'] || ENV['GOOGLE_API_KEY']
    end
  end

  def warmup(dir)
    puts "  [Aider] Isınma turu yapılıyor... Model: #{@model}"
    run_generation("Respond with 'OK'. Do not write any code.", dir: dir)
  end

  def run_generation(prompt, dir:, log_path: nil)
    start_time = Time.now
    
    # Dosyaları hazırla
    target_files = Dir.glob(File.join(dir, '*')).select { |f| File.file?(f) }
    if target_files.empty?
      fallback_file = File.join(dir, "main.py")
      File.write(fallback_file, "# Benchmark Entry Point\n")
      target_files = [fallback_file]
    end
    file_names = target_files.map { |f| File.basename(f) }

    # Komut dizisi
    cmd = [
      "py", "-3.12", "-m", "aider",
      "--no-git", "--yes", "--no-show-model-warnings",
      "--edit-format", "whole",
      "--model", @model,
      "--message", prompt + "\n\nCRITICAL: Write COMPLETE code in the files: #{file_names.join(', ')}"
    ] + file_names
    
    env = { 
      "GEMINI_API_KEY" => @api_key,
      "PYTHONIOENCODING" => "utf-8" 
    }

    # --- KRİTİK DEĞİŞİKLİK: capture3 kullanarak sessizce çalıştır ---
    stdout, stderr, status = Open3.capture3(env, *cmd, chdir: dir)

    # Logları diske yaz (PR artifactları için gerekli)
    if log_path
      FileUtils.mkdir_p(File.dirname(log_path))
      File.write(log_path, stdout)
      File.write(log_path + ".err", stderr) unless stderr.strip.empty?
    end

    {
      stdout: stdout,
      stderr: stderr,
      success: status.success?,
      elapsed_seconds: (Time.now - start_time).round(1),
      metrics: parse_metrics(stdout)
    }
  end

  def version
    `py -3.12 -m aider --version`.strip
  rescue
    "not installed"
  end

  private

  def parse_metrics(stdout)
    input = 0; output = 0; cost = 0.0
    
    # Gelişmiş Regex: '3.0k' gibi değerleri ve virgülleri yakalar
    # Örn: "Tokens: 3.0k sent, 1.3k received. Cost: $0.02"
    stdout.scan(/Tokens:\s*([\d.k,]+)\s*sent,\s*([\d.k,]+)\s*received\.\s*Cost:\s*\$([\d.]+)/i) do |s, r, c|
      input += parse_aider_number(s)
      output += parse_aider_number(r)
      cost += c.to_f
    end

    { input_tokens: input, output_tokens: output, total_cost: cost.round(4) }
  end

  def parse_aider_number(str)
    num_str = str.delete(',').downcase
    if num_str.include?('k')
      (num_str.to_f * 1000).to_i
    else
      num_str.to_i
    end
  end
end