#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'time'
require 'open3'
require 'timeout'
require 'shellwords'
require 'set'
require_relative '../lib/language_loader'
require_relative '../lib/codex_loader'

require 'dotenv'
Dotenv.load

BASE_DIR = File.expand_path('..', __dir__)
PROBLEMS_DIR = File.join(BASE_DIR, 'problems')

GO_DIR = File.join(Dir.home, '.local', 'go')
NPM_PREFIX = File.join(Dir.home, '.local', 'npm')

LANGUAGES = LanguageLoader.load_config

TRIALS = 3

def available_problem_keys
  Dir.glob(File.join(PROBLEMS_DIR, '**', 'problem.json')).filter_map do |path|
    relative = path.delete_prefix("#{PROBLEMS_DIR}/")
    next if relative == 'problem.json'

    File.dirname(relative)
  end.sort
end

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
  else
    abort "Unknown option: #{ARGV[i]}\nRun `ruby benchmark.rb --help` for usage."
  end
end

languages_to_run = selected_languages || LANGUAGES.keys
selected_codex ||= CodexLoader.default_codex
problem = selected_problem || 'minigit'

if selected_trials < 1
  abort '--trials must be at least 1'
end

if selected_start < 1
  abort '--start must be at least 1'
end

unknown_languages = languages_to_run.reject { |lang| LANGUAGES.key?(lang) }
unless unknown_languages.empty?
  abort <<~ERROR
    Unknown language(s): #{unknown_languages.join(', ')}
    Available languages: #{LANGUAGES.keys.join(', ')}
  ERROR
end

if selected_output_root.nil?
  selected_output_root = CodexLoader.default_output_root(
    selected_codex,
    problem: problem,
    base_dir: BASE_DIR,
    dry_run: dry_run,
  )
end

work_dir = File.join(selected_output_root, 'generated')
results_dir = File.join(selected_output_root, 'results')
logs_dir = File.join(selected_output_root, 'logs')

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def run_cmd(cmd, dir: nil, timeout: 600)
  opts = {}
  opts[:chdir] = dir if dir
  stdin_r, stdout_r, stderr_r, wait_thr = Open3.popen3(cmd, **opts)
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

def extra_path
  "#{GO_DIR}/bin:#{NPM_PREFIX}/bin"
end

def get_version(lang)
  config = LANGUAGES[lang]
  cmd = "export PATH=#{extra_path}:$PATH && #{config[:version_cmd]}"
  result = run_cmd(cmd)
  if result[:success]
    (result[:stdout].strip.empty? ? result[:stderr].strip : result[:stdout].strip).lines.first&.strip || 'unknown'
  else
    'not installed'
  end
end

def count_loc(dir, lang, binary_name: 'minigit')
  config = LANGUAGES[lang]
  exts = config[:exts]
  files = exts.flat_map { |e| Dir.glob(File.join(dir, '**', "*.#{e}")) }
  files.reject! { |f| f.include?('/node_modules/') || f.include?('/target/') }

  # For scripting languages the executable itself can be the source (no extension)
  executable = File.join(dir, binary_name)
  if File.exist?(executable) && !files.include?(executable)
    begin
      content = File.read(executable, encoding: 'UTF-8')
      files << executable if content.valid_encoding?
    rescue StandardError
      # skip binary files
    end
  end

  files.sum do |f|
    begin
      File.readlines(f).count { |l| !l.strip.empty? }
    rescue StandardError
      0
    end
  end
end


def run_tests(test_script, dir:)
  cmd = "export PATH=#{extra_path}:$PATH && bash #{test_script}"
  result = run_cmd(cmd, dir: dir, timeout: 120)

  output = result[:stdout] + result[:stderr]
  passed_summary = output[/PASSED:\s*(\d+)/, 1]
  failed_summary = output[/FAILED:\s*(\d+)/, 1]

  passed = if passed_summary
             passed_summary.to_i
           else
             output.scan(/^PASS:/).size
           end

  failed = if failed_summary
             failed_summary.to_i
           else
             output.scan(/^FAIL:/).size
           end

  {
    success: result[:success],
    passed: passed,
    failed: failed,
    total: passed + failed,
    output: output,
  }
end

def load_problem_config(problem)
  problem_dir = File.join(PROBLEMS_DIR, problem)
  config_path = File.join(problem_dir, 'problem.json')

  unless File.file?(config_path)
    available = available_problem_keys
    abort <<~ERROR
      Problem config not found: #{config_path}
      Expected layout:
        problems/#{problem}/problem.json
        problems/#{problem}/SPEC-v1.txt
        problems/#{problem}/SPEC-v2.txt
        problems/#{problem}/test-v1.sh
        problems/#{problem}/test-v2.sh
      #{available.empty? ? '' : "Available problems: #{available.join(', ')}"}
    ERROR
  end

  raw = JSON.parse(File.read(config_path))
  required_keys = %w[binary_name v1_spec v1_test v1_prompt v2_spec v2_test v2_prompt]
  missing_keys = required_keys.reject { |key| raw[key].is_a?(String) && !raw[key].strip.empty? }

  unless missing_keys.empty?
    abort "Problem config missing keys in #{config_path}: #{missing_keys.join(', ')}"
  end

  config = {
    name: raw['name'].to_s.strip.empty? ? problem : raw['name'],
    dir: problem_dir,
    binary_name: raw['binary_name'],
    v1_spec: File.join(problem_dir, raw['v1_spec']),
    v1_test: File.join(problem_dir, raw['v1_test']),
    v1_prompt: raw['v1_prompt'],
    v2_spec: File.join(problem_dir, raw['v2_spec']),
    v2_test: File.join(problem_dir, raw['v2_test']),
    v2_prompt: raw['v2_prompt'],
  }

  asset_keys = %i[v1_spec v1_test v2_spec v2_test]
  missing_assets = asset_keys.filter_map do |key|
    next if File.exist?(config[key])

    "  #{key}: #{config[key]}"
  end

  unless missing_assets.empty?
    abort "Problem assets missing for '#{problem}':\n#{missing_assets.join("\n")}"
  end

  config
rescue JSON::ParserError => e
  abort "Invalid JSON in #{config_path}: #{e.message}"
end

def render_problem_prompt(template, language:, binary_name:, problem_name:)
  {
    '{{language}}' => language.capitalize,
    '{{binary_name}}' => binary_name,
    '{{problem_name}}' => problem_name,
  }.reduce(template.dup) do |result, (token, value)|
    result.gsub(token, value)
  end
end

def write_benchmark_metadata(dir, language:, binary_name:)
  File.write(File.join(dir, '.benchmark-language'), "#{language}\n")
  File.write(File.join(dir, '.benchmark-binary-name'), "#{binary_name}\n")
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

puts '=' * 60
puts 'AI Coding Language Benchmark'
puts '=' * 60
puts

# Initialize codex
problem_config = load_problem_config(problem)
codex = dry_run ? nil : CodexLoader.create_codex(selected_codex)
codex_version = dry_run ? 'dry-run' : codex.version

puts "Codex: #{selected_codex}"
puts "Codex Version: #{codex_version}"
puts "Problem: #{problem}"
puts "Problem Assets: #{problem_config[:dir]}"
puts "Languages: #{languages_to_run.join(', ')}"
puts "Trials: #{selected_start}..#{selected_start + selected_trials - 1} (#{selected_trials} trials)"
puts "Output Root: #{selected_output_root || BASE_DIR}"
puts "Dry run: #{dry_run}"
puts

# Language versions
puts '--- Language Versions ---'
versions = {}
languages_to_run.each do |lang|
  versions[lang] = get_version(lang)
  puts "  #{lang}: #{versions[lang]}"
end
puts

# Ensure directories exist
FileUtils.mkdir_p(work_dir)
FileUtils.mkdir_p(results_dir)
FileUtils.mkdir_p(logs_dir)

# Warmup: run a trivial prompt so codex's process/cache is hot
unless dry_run
  puts '--- Warmup ---'
  warmup_dir = File.join(work_dir, '.warmup')
  FileUtils.mkdir_p(warmup_dir)
  codex.warmup(warmup_dir)
  FileUtils.rm_rf(warmup_dir)
  puts
end

results = []
problem_run_name = problem.tr('/', '-')
v1_test_name = File.basename(problem_config[:v1_test])
v2_test_name = File.basename(problem_config[:v2_test])

selected_trials.times do |trial_idx|
  trial = selected_start + trial_idx
  languages_to_run.each do |lang|
    puts '=' * 60
    puts "Trial #{trial} (#{trial_idx + 1}/#{selected_trials}) - #{lang}"
    puts '=' * 60

    dir_name = lang.tr('/', '-')
    v1_dir = File.join(work_dir, "#{problem_run_name}-#{dir_name}-#{trial}-v1")
    v2_dir = File.join(work_dir, "#{problem_run_name}-#{dir_name}-#{trial}-v2")
    FileUtils.rm_rf(v1_dir)
    FileUtils.rm_rf(v2_dir)
    FileUtils.mkdir_p(v1_dir)
    write_benchmark_metadata(v1_dir, language: lang, binary_name: problem_config[:binary_name])

    record = {
      language: lang, trial: trial, codex: selected_codex, v1_dir: v1_dir, v2_dir: v2_dir,
      v1_time: nil, v1_pass: false, v1_passed_count: 0, v1_failed_count: 0, v1_total_count: 0, v1_loc: 0,
      v2_time: nil, v2_pass: false, v2_passed_count: 0, v2_failed_count: 0, v2_total_count: 0, v2_loc: 0,
      v1_metrics: nil, v2_metrics: nil,
    }

    # --- Phase 1: v1 ---
    puts "\n--- Phase 1: v1 ---"
    FileUtils.cp(problem_config[:v1_spec], v1_dir)
    FileUtils.cp(problem_config[:v1_test], v1_dir)

    v1_prompt = render_problem_prompt(
      problem_config[:v1_prompt],
      language: lang,
      binary_name: problem_config[:binary_name],
      problem_name: problem_config[:name]
    )
    v1_prompt += " #{LANGUAGES[lang][:extra_prompt]}" if LANGUAGES[lang][:extra_prompt]

    if dry_run
      puts "  [DRY RUN] Would run #{selected_codex} with prompt for v1 #{lang}"
      record[:v1_time] = 0
    else
      v1_log = File.join(logs_dir, "#{problem_run_name}-#{dir_name}-#{trial}-v1-#{selected_codex}.json")
      puts "  Running #{selected_codex}..."
      v1_result = codex.run_generation(v1_prompt, dir: v1_dir, log_path: v1_log)
      record[:v1_time] = v1_result[:elapsed_seconds]
      record[:v1_metrics] = v1_result[:metrics]
      puts "  #{selected_codex.capitalize} finished in #{v1_result[:elapsed_seconds]}s (success=#{v1_result[:success]})"

      puts '  Running v1 tests...'
      test_result = run_tests(v1_test_name, dir: v1_dir)
      record[:v1_pass] = test_result[:success]
      record[:v1_passed_count] = test_result[:passed]
      record[:v1_failed_count] = test_result[:failed]
      record[:v1_total_count] = test_result[:total]
      puts "  Tests: #{test_result[:passed]}/#{test_result[:total]} passed (#{test_result[:success] ? 'PASS' : 'FAIL'})"
      if !test_result[:success] && !test_result[:output].strip.empty?
        puts '  Test output excerpt:'
        test_result[:output].lines.last(8).each { |line| puts "    #{line.rstrip}" }
      end

      record[:v1_loc] = count_loc(v1_dir, lang, binary_name: problem_config[:binary_name])
      puts "  LOC: #{record[:v1_loc]}"
    end

    # --- Phase 2: v2 (copy v1 then extend) ---
    puts "\n--- Phase 2: v2 ---"
    FileUtils.cp_r(v1_dir, v2_dir)
    write_benchmark_metadata(v2_dir, language: lang, binary_name: problem_config[:binary_name])
    FileUtils.cp(problem_config[:v2_spec], v2_dir)
    FileUtils.cp(problem_config[:v2_test], v2_dir)

    v2_prompt = render_problem_prompt(
      problem_config[:v2_prompt],
      language: lang,
      binary_name: problem_config[:binary_name],
      problem_name: problem_config[:name]
    )
    v2_prompt += " #{LANGUAGES[lang][:extra_prompt]}" if LANGUAGES[lang][:extra_prompt]

    if dry_run
      puts "  [DRY RUN] Would run #{selected_codex} with prompt for v2 #{lang}"
      record[:v2_time] = 0
    else
      v2_log = File.join(logs_dir, "#{problem_run_name}-#{dir_name}-#{trial}-v2-#{selected_codex}.json")
      puts "  Running #{selected_codex}..."
      v2_result = codex.run_generation(v2_prompt, dir: v2_dir, log_path: v2_log)
      record[:v2_time] = v2_result[:elapsed_seconds]
      record[:v2_metrics] = v2_result[:metrics]
      puts "  #{selected_codex.capitalize} finished in #{v2_result[:elapsed_seconds]}s (success=#{v2_result[:success]})"

      puts '  Running v2 tests...'
      test_result = run_tests(v2_test_name, dir: v2_dir)
      record[:v2_pass] = test_result[:success]
      record[:v2_passed_count] = test_result[:passed]
      record[:v2_failed_count] = test_result[:failed]
      record[:v2_total_count] = test_result[:total]
      puts "  Tests: #{test_result[:passed]}/#{test_result[:total]} passed (#{test_result[:success] ? 'PASS' : 'FAIL'})"
      if !test_result[:success] && !test_result[:output].strip.empty?
        puts '  Test output excerpt:'
        test_result[:output].lines.last(8).each { |line| puts "    #{line.rstrip}" }
      end

      record[:v2_loc] = count_loc(v2_dir, lang, binary_name: problem_config[:binary_name])
      puts "  LOC: #{record[:v2_loc]}"
    end

    results << record
    puts
  end
end

# ---------------------------------------------------------------------------
# Save results JSON
# ---------------------------------------------------------------------------

puts '=' * 60
puts 'Saving results...'
puts '=' * 60

# Save metadata alongside results
meta = {
  date: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
  codex: selected_codex,
  problem: problem,
  codex_version: codex_version,
  trials: selected_trials,
  versions: versions,
}

File.write(File.join(results_dir, 'meta.json'), JSON.pretty_generate(meta))

# Load existing results and append new ones
results_path = File.join(results_dir, 'results.json')
existing = if File.exist?(results_path)
             JSON.parse(File.read(results_path)) rescue []
           else
             []
           end
new_results = results.map { |r| r.transform_keys(&:to_s) }
replacement_keys = new_results.map { |r| [r['codex'].to_s, r['language'].to_s, r['trial'].to_s] }.to_set
existing.reject! do |r|
  replacement_keys.include?([r['codex'].to_s, r['language'].to_s, r['trial'].to_s])
end
all_results = existing + new_results
File.write(results_path, JSON.pretty_generate(all_results))

puts "Results saved to #{results_dir}/"
puts 'Run `ruby report.rb` to generate the report.'
