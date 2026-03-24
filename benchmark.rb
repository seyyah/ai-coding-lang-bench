#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'time'
require 'open3'
require 'timeout'
require 'shellwords'
require 'set'
require 'rbconfig'
require_relative 'lib/codex_loader'

<<<<<<< HEAD
# --- SENIN SISTEMINE OZEL AYARLAR (WINDOWS) ---
IS_WINDOWS = true 
=======
require 'dotenv'
Dotenv.load

>>>>>>> 6019372e73af381488a9a9d215358d11fd81cf95
BASE_DIR = File.expand_path(__dir__)
PROBLEMS_DIR = File.join(BASE_DIR, 'problems')
TRIALS = 3

# Diller ve Versiyon Komutları (Sadece senin sistemindeki PATH komutları)
LANGUAGES = {
  'rust'        => { exts: %w[rs],     version_cmd: 'rustc --version' },
  'go'          => { exts: %w[go],     version_cmd: 'go version' },
  'c'           => { exts: %w[c h],     version_cmd: 'gcc --version' },
  'typescript'  => { exts: %w[ts],     version_cmd: 'npx tsx --version' },
  'javascript'  => { exts: %w[js],     version_cmd: 'node --version' },
  'java'        => { exts: %w[java],   version_cmd: 'java --version' },
  'perl'        => { exts: %w[pl pm],   version_cmd: 'perl --version' },
  'python'      => { exts: %w[py],      version_cmd: 'py --version || python --version' },
  'ruby'        => { exts: %w[rb],      version_cmd: 'ruby --version' },
  'ruby/steep'  => { exts: %w[rb rbs], version_cmd: 'steep --version' },
  'lua'         => { exts: %w[lua],     version_cmd: 'lua -v' },
  'scheme'      => { exts: %w[scm],     version_cmd: 'guile --version' },
  'ocaml'       => { exts: %w[ml mli], version_cmd: 'ocaml --version' },
  'haskell'     => { exts: %w[hs],     version_cmd: 'ghc --version' },
}

# ---------------------------------------------------------------------------
# CLI args
# ---------------------------------------------------------------------------

selected_languages = nil
selected_trials = TRIALS
selected_start = 1
selected_codex = nil
selected_problem = nil
selected_output_root = nil
dry_run = false

def available_problem_keys
  Dir.glob(File.join(PROBLEMS_DIR, '**', 'problem.json')).filter_map do |path|
    relative = path.delete_prefix("#{PROBLEMS_DIR}/")
    next if relative == 'problem.json'
    File.dirname(relative)
  end.sort
end

i = 0
while i < ARGV.length
  case ARGV[i]
  when '--lang', '-l'
    selected_languages = ARGV[i + 1].split(',').map(&:strip)
    i += 2
  when '--trials', '-t'
    selected_trials = ARGV[i + 1].to_i
    i += 2
  when '--start', '-s'
    selected_start = ARGV[i + 1].to_i
    i += 2
  when '--codex', '-c'
    selected_codex = ARGV[i + 1]
    i += 2
  when '--problem', '-p'
    selected_problem = ARGV[i + 1]
    i += 2
  when '--output-root'
    selected_output_root = File.expand_path(ARGV[i + 1], BASE_DIR)
    i += 2
  when '--dry-run'
    dry_run = true
    i += 1
<<<<<<< HEAD
=======
  when '--help', '-h'
    available_problems = available_problem_keys
    puts <<~HELP
      Usage: ruby benchmark.rb [OPTIONS]

      Options:
        --lang, -l LANGS       Comma-separated list of languages to test
        --trials, -t NUM       Number of trials per language (default: #{TRIALS})
        --start, -s NUM        Starting trial number (default: 1)
        --codex, -c NAME       AI codex to use: #{CodexLoader.available_codexes.join(', ')} (default: #{CodexLoader.default_codex})
        --problem, -p NAME     Problem key under problems/ (default: minigit#{available_problems.empty? ? '' : "; available: #{available_problems.join(', ')}"})
        --output-root PATH     Write generated/, logs/, and results/ under PATH
        --dry-run              Dry run mode (don't actually run codex)
        --help, -h             Show this help message

      Examples:
        ruby benchmark.rb --lang python --trials 1
        ruby benchmark.rb --codex gemini --lang ruby,python
        ruby benchmark.rb --codex gemini --problem minigit
        ruby benchmark.rb --codex claude --problem minigit --lang python --dry-run
        ruby benchmark.rb --trials 10 --start 11

      By default, outputs are written under:
        artifacts/<codex>/<model>/<problem>/
      or, for dry runs:
        artifacts/<codex>/<model>/<problem>/dry-run/
    HELP
    exit 0
>>>>>>> 6019372e73af381488a9a9d215358d11fd81cf95
  else
    i += 1
  end
end

languages_to_run = selected_languages || LANGUAGES.keys
selected_codex ||= CodexLoader.default_codex
problem = selected_problem || 'minigit'

if selected_output_root.nil?
<<<<<<< HEAD
  selected_output_root = File.join(BASE_DIR, 'artifacts', selected_codex, problem, (dry_run ? 'dry-run' : ''))
=======
  selected_output_root = CodexLoader.default_output_root(
    selected_codex,
    problem: problem,
    base_dir: BASE_DIR,
    dry_run: dry_run,
  )
>>>>>>> 6019372e73af381488a9a9d215358d11fd81cf95
end

work_dir = File.join(selected_output_root, 'generated')
results_dir = File.join(selected_output_root, 'results')
logs_dir = File.join(selected_output_root, 'logs')

# ---------------------------------------------------------------------------
# Helpers (Windows Icin Fixlendi)
# ---------------------------------------------------------------------------

def run_cmd(cmd, dir: nil, timeout: 600)
  opts = { chdir: dir } if dir
  
  # Windows'ta bash betiklerini calistirabilmek icin bash sarmali
  final_cmd = cmd.include?('.sh') ? "bash #{cmd.gsub('\\', '/')}" : cmd

  stdin_r, stdout_r, stderr_r, wait_thr = Open3.popen3(final_cmd, **opts)
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

def get_version(lang)
  config = LANGUAGES[lang]
  return 'not installed' unless config
  
  begin
    # Capture3 kullanarak sistemde olmayan komutlarin cokmesini engelliyoruz
    stdout, stderr, status = Open3.capture3(config[:version_cmd])
    if status.success?
      (stdout.strip.empty? ? stderr.strip : stdout.strip).lines.first&.strip || 'unknown'
    else
      'not installed'
    end
  rescue Errno::ENOENT
    'not installed'
  end
end

def count_loc(dir, lang, binary_name: 'minigit')
  config = LANGUAGES[lang]
  exts = config[:exts] || [config[:ext]].flatten.compact
  return 0 if exts.empty?

  files = exts.flat_map { |e| Dir.glob(File.join(dir, '**', "*.#{e}")) }
  files.reject! { |f| f.include?('/node_modules/') || f.include?('/target/') }

  executable = File.join(dir, binary_name)
  if File.exist?(executable) && !files.include?(executable)
    begin
      content = File.read(executable, encoding: 'UTF-8')
      files << executable if content.valid_encoding?
    rescue StandardError; end
  end

  files.sum do |f|
    begin
      File.readlines(f).count { |l| !l.strip.empty? }
    rescue StandardError; 0; end
  end
end

def run_tests(test_script, dir:)
  # Windows Git Bash ortaminda testi zorla
  result = run_cmd("bash #{test_script.to_s.gsub('\\', '/')}", dir: dir, timeout: 120)

  output = result[:stdout] + result[:stderr]
  passed = output.scan(/PASS:/i).size
  failed = output.scan(/FAIL:/i).size
  
  passed_sum = output[/PASSED:\s*(\d+)/i, 1]
  failed_sum = output[/FAILED:\s*(\d+)/i, 1]
  passed = passed_sum.to_i if passed_sum
  failed = failed_sum.to_i if failed_sum

  if passed == 0 && failed == 0 && result[:success]
    passed = 1
  end

  { success: (failed == 0 && passed > 0), passed: passed, failed: failed, total: passed + failed, output: output }
end

def load_problem_config(problem)
  problem_dir = File.join(PROBLEMS_DIR, problem)
  config_path = File.join(problem_dir, 'problem.json')
  raw = JSON.parse(File.read(config_path))
  {
    name: raw['name'], dir: problem_dir, binary_name: raw['binary_name'],
    v1_spec: File.join(problem_dir, raw['v1_spec']),
    v1_test: File.join(problem_dir, raw['v1_test']),
    v1_prompt: raw['v1_prompt'],
    v2_spec: File.join(problem_dir, raw['v2_spec']),
    v2_test: File.join(problem_dir, raw['v2_test']),
    v2_prompt: raw['v2_prompt']
  }
end

def render_problem_prompt(template, language:, binary_name:, problem_name:)
  template.gsub('{{language}}', language.capitalize).gsub('{{binary_name}}', binary_name).gsub('{{problem_name}}', problem_name)
end

def write_benchmark_metadata(dir, language:, binary_name:)
  File.write(File.join(dir, '.benchmark-language'), "#{language}\n")
  File.write(File.join(dir, '.benchmark-binary-name'), "#{binary_name}\n")
end

# ---------------------------------------------------------------------------
# Main Execution
# ---------------------------------------------------------------------------

puts '=' * 60
puts 'AI Coding Language Benchmark (Windows Optimized)'
puts '=' * 60

problem_config = load_problem_config(problem)
codex = dry_run ? nil : CodexLoader.create_codex(selected_codex)
codex_version = dry_run ? 'dry-run' : codex.version

puts "Codex: #{selected_codex} | Version: #{codex_version}"
puts "Problem: #{problem} | Trials: #{selected_trials}"

# Language versions listesi
puts '--- Language Versions ---'
versions = {}
languages_to_run.each do |lang|
  versions[lang] = get_version(lang)
  puts "  #{lang}: #{versions[lang]}"
end

FileUtils.mkdir_p(work_dir); FileUtils.mkdir_p(results_dir); FileUtils.mkdir_p(logs_dir)

unless dry_run
  puts '--- Warmup ---'
  warmup_dir = File.join(work_dir, '.warmup')
  FileUtils.mkdir_p(warmup_dir); codex.warmup(warmup_dir); FileUtils.rm_rf(warmup_dir)
end

results = []
problem_run_name = problem.tr('/', '-')

selected_trials.times do |trial_idx|
  trial = selected_start + trial_idx
  languages_to_run.each do |lang|
    next if versions[lang] == 'not installed'
    
    puts "\n[Trial #{trial}] Running #{lang}..."
    v1_dir = File.join(work_dir, "#{problem_run_name}-#{lang.tr('/', '-')}-#{trial}-v1")
    v2_dir = File.join(work_dir, "#{problem_run_name}-#{lang.tr('/', '-')}-#{trial}-v2")
    FileUtils.mkdir_p(v1_dir)
    write_benchmark_metadata(v1_dir, language: lang, binary_name: problem_config[:binary_name])

    record = { language: lang, trial: trial, codex: selected_codex, v1_dir: v1_dir, v2_dir: v2_dir }

    # Phase 1
    FileUtils.cp(problem_config[:v1_spec], v1_dir); FileUtils.cp(problem_config[:v1_test], v1_dir)
    v1_prompt = render_problem_prompt(problem_config[:v1_prompt], language: lang, binary_name: problem_config[:binary_name], problem_name: problem_config[:name])
    
    v1_log = File.join(logs_dir, "#{problem_run_name}-#{lang.tr('/', '-')}-#{trial}-v1.json")
    v1_res = codex.run_generation(v1_prompt, dir: v1_dir, log_path: v1_log)
    
    test_res = run_tests(File.basename(problem_config[:v1_test]), dir: v1_dir)
    record.merge!({ v1_time: v1_res[:elapsed_seconds], v1_pass: test_res[:success], v1_loc: count_loc(v1_dir, lang), v1_metrics: v1_res[:metrics] })

    # Phase 2
    FileUtils.cp_r(v1_dir, v2_dir); FileUtils.cp(problem_config[:v2_spec], v2_dir); FileUtils.cp(problem_config[:v2_test], v2_dir)
    v2_prompt = render_problem_prompt(problem_config[:v2_prompt], language: lang, binary_name: problem_config[:binary_name], problem_name: problem_config[:name])
    
    v2_log = File.join(logs_dir, "#{problem_run_name}-#{lang.tr('/', '-')}-#{trial}-v2.json")
    v2_res = codex.run_generation(v2_prompt, dir: v2_dir, log_path: v2_log)
    
    test_res_v2 = run_tests(File.basename(problem_config[:v2_test]), dir: v2_dir)
    record.merge!({ v2_time: v2_res[:elapsed_seconds], v2_pass: test_res_v2[:success], v2_loc: count_loc(v2_dir, lang), v2_metrics: v2_res[:metrics] })

    results << record
  end
end

# Save Meta & Results
meta = { date: Time.now.to_s, codex: selected_codex, problem: problem, trials: selected_trials, versions: versions }
File.write(File.join(results_dir, 'meta.json'), JSON.pretty_generate(meta))
File.write(File.join(results_dir, 'results.json'), JSON.pretty_generate(results))

puts "\nDONE! Results saved to #{results_dir}"