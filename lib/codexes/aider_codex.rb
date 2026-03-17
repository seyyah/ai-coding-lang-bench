require 'open3'
require 'fileutils'

class AiderCodex
  def initialize(config)
    @config = config || {}
    @model = ENV['AIDER_MODEL'] || @config['model'] || 'gemini/gemini-2.5-flash'
  end

  def warmup(dir)
    puts "  [Aider] Isınma turu yapılıyor..."
    run_generation("Respond with OK.", dir: dir)
  end

  def run_generation(prompt, dir:, log_path: nil)
    # Aider test scriptinin aradığı dosyayı uzantısız yaratıyoruz
    main_file = "minigit"
    File.write(File.join(dir, main_file), "#!/usr/bin/env python3\n") unless File.exist?(File.join(dir, main_file))
    
    files = Dir.glob(File.join(dir, '*')).select { |f| File.file?(f) }.map { |f| File.basename(f) }

    enhanced_prompt = prompt + "\n\nCRITICAL INSTRUCTION: Write the COMPLETE Python implementation inside the '#{main_file}' file. Overwrite it entirely."

    # 🚨 SİHİRLİ ÇÖZÜM: Komutu Array (dizi) olarak veriyoruz, Windows CMD aradan çıkıyor!
    cmd = [
      "py", "-3.12", "-m", "aider",
      "--no-git", "--yes",
      "--no-show-model-warnings",
      "--edit-format", "whole",
      "--model", @model,
      "--message", enhanced_prompt
    ] + files
    
    start_time = Time.now
    
    env = { "GEMINI_API_KEY" => ENV['GEMINI_API_KEY'] }
    opts = { chdir: dir }
    
    # cmd dizisinin başına * koyarak Open3'e güvenli bir şekilde aktarıyoruz
    stdin_r, stdout_r, stderr_r, wait_thr = Open3.popen3(env, *cmd, **opts)
    stdin_r.close
    
    stdout = stdout_r.read
    stderr = stderr_r.read
    
    stdout_r.close
    stderr_r.close
    
    status = wait_thr.value
    elapsed = Time.now - start_time

    if !status.success? || elapsed < 2.0
      puts "\n============================================================"
      puts "AIDER ÇÖKTÜ! İŞTE GİZLENEN GERÇEK HATA MESAJI:"
      puts "------------------------------------------------------------"
      puts stderr.empty? ? stdout : stderr
      puts "============================================================\n"
    end

    if log_path
      FileUtils.mkdir_p(File.dirname(log_path))
      File.write(log_path, stdout)
      File.write(log_path + ".err", stderr)
    end

    {
      stdout: stdout,
      stderr: stderr,
      success: status.success?,
      elapsed_seconds: elapsed.round(1),
      metrics: nil
    }
  end

  def version
    `py -3.12 -m aider --version`.strip
  rescue Errno::ENOENT
    "not installed"
  end
end