#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Rebuilds results.json from existing logs + generated dirs (no re-generation).
# Use when benchmark.rb crashes before saving results.
#
# Usage: ruby rebuild_results.rb --codex aider --problem minigit

require 'json'
require 'fileutils'
require 'open3'

BASE_DIR     = __dir__
PROBLEMS_DIR = File.join(BASE_DIR, 'problems')
ARTIFACTS    = File.join(BASE_DIR, 'artifacts')

LANGUAGES = {
  'rust'        => { exts: %w[rs] },
  'go'          => { exts: %w[go] },
  'c'           => { exts: %w[c h] },
  'typescript'  => { exts: %w[ts] },
  'javascript'  => { exts: %w[js] },
  'java'        => { exts: %w[java] },
  'perl'        => { exts: %w[pl pm] },
  'python'      => { exts: %w[py] },
  'python/mypy' => { exts: %w[py] },
  'ruby'        => { exts: %w[rb] },
  'ruby/steep'  => { exts: %w[rb rbs] },
  'lua'         => { exts: %w[lua] },
  'scheme'      => { exts: %w[scm] },
  'ocaml'       => { exts: %w[ml mli] },
  'haskell'     => { exts: %w[hs] },
}

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

selected_codex   = 'aider'
selected_problem = 'minigit'

i = 0
while i < ARGV.length
  case ARGV[i]
  when '--codex', '-c'   then selected_codex   = ARGV[i + 1]; i += 2
  when '--problem', '-p' then selected_problem = ARGV[i + 1]; i += 2
  else i += 1
  end
end

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def count_loc(dir, lang, binary_name: 'minigit')
  config = LANGUAGES[lang]
  exts   = config[:exts]
  files  = exts.flat_map { |e| Dir.glob(File.join(dir, '**', "*.#{e}")) }
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
    rescue StandardError; 0
    end
  end
end

def run_tests(test_script, dir:)
  cmd    = "bash #{test_script}"
  stdout, stderr, status = Open3.capture3(cmd, chdir: dir)
  output = stdout + stderr

  passed_summary = output[/PASSED:\s*(\d+)/, 1]
  failed_summary = output[/FAILED:\s*(\d+)/, 1]

  passed = passed_summary ? passed_summary.to_i : output.scan(/^PASS:/).size
  failed = failed_summary ? failed_summary.to_i : output.scan(/^FAIL:/).size

  { success: status.success?, passed: passed, failed: failed, total: passed + failed, output: output }
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

work_dir    = File.join(ARTIFACTS, selected_codex, selected_problem)
logs_dir    = File.join(work_dir, 'logs')
results_dir = File.join(work_dir, 'results')
generated   = File.join(work_dir, 'generated')

problem_config_path = File.join(PROBLEMS_DIR, selected_problem, 'problem.json')
problem_config      = JSON.parse(File.read(problem_config_path))

v1_test = File.join(PROBLEMS_DIR, selected_problem, problem_config['v1_test'])
v2_test = File.join(PROBLEMS_DIR, selected_problem, problem_config['v2_test'])
binary  = problem_config['binary_name'] || 'minigit'

puts "Rebuilding results for codex=#{selected_codex} problem=#{selected_problem}"
puts "Generated dir: #{generated}"
puts

results = []

LANGUAGES.each_key do |lang|
  dir_name = lang.tr('/', '-')

  # Find all trials for this language (exact dir_name match, no substring collisions)
  trial_dirs = Dir.glob(File.join(generated, "*-#{dir_name}-[0-9]*-v1"))
                  .select { |d| File.basename(d) =~ /\A[^-]+-#{Regexp.escape(dir_name)}-\d+-v1\z/ }
                  .sort
  next if trial_dirs.empty?

  trial_dirs.each do |v1_dir|
    trial = v1_dir[/-(\d+)-v1$/, 1]&.to_i
    next unless trial

    v2_dir   = v1_dir.sub(/-v1$/, '-v2')
    log_base = File.basename(v1_dir).sub(/-v1$/, '')

    # Read timing + metrics from log
    v1_log_path = File.join(logs_dir, "#{log_base}-v1-#{selected_codex}.json")
    v2_log_path = File.join(logs_dir, "#{log_base}-v2-#{selected_codex}.json")

    v1_log = File.exist?(v1_log_path) ? JSON.parse(File.read(v1_log_path)) : {}
    v2_log = File.exist?(v2_log_path) ? JSON.parse(File.read(v2_log_path)) : {}

    v1_time    = v1_log['elapsed_seconds']
    v2_time    = v2_log['elapsed_seconds']
    v1_metrics = v1_log['metrics']
    v2_metrics = v2_log['metrics']

    # Use the test script copied into the generated dir (same as benchmark.rb does)
    v1_local_test = File.join(v1_dir, File.basename(v1_test))
    v2_local_test = File.join(v2_dir, File.basename(v2_test))

    print "  #{lang} trial #{trial} v1: "
    v1_test_result = if Dir.exist?(v1_dir) && File.exist?(v1_local_test)
                       run_tests(v1_local_test, dir: v1_dir)
                     else
                       { success: false, passed: 0, failed: 0, total: 0 }
                     end
    puts "#{v1_test_result[:passed]}/#{v1_test_result[:total]} passed"

    print "  #{lang} trial #{trial} v2: "
    v2_test_result = if Dir.exist?(v2_dir) && File.exist?(v2_local_test)
                       run_tests(v2_local_test, dir: v2_dir)
                     else
                       { success: false, passed: 0, failed: 0, total: 0 }
                     end
    puts "#{v2_test_result[:passed]}/#{v2_test_result[:total]} passed"

    v1_loc = Dir.exist?(v1_dir) ? count_loc(v1_dir, lang, binary_name: binary) : 0
    v2_loc = Dir.exist?(v2_dir) ? count_loc(v2_dir, lang, binary_name: binary) : 0

    results << {
      language:       lang,
      trial:          trial,
      codex:          selected_codex,
      v1_dir:         v1_dir,
      v2_dir:         v2_dir,
      v1_time:        v1_time,
      v1_pass:        v1_test_result[:success],
      v1_passed_count: v1_test_result[:passed],
      v1_failed_count: v1_test_result[:failed],
      v1_total_count:  v1_test_result[:total],
      v1_loc:          v1_loc,
      v2_time:        v2_time,
      v2_pass:        v2_test_result[:success],
      v2_passed_count: v2_test_result[:passed],
      v2_failed_count: v2_test_result[:failed],
      v2_total_count:  v2_test_result[:total],
      v2_loc:          v2_loc,
      v1_metrics:     v1_metrics,
      v2_metrics:     v2_metrics,
    }
  end
end

puts
FileUtils.mkdir_p(results_dir)
results_path = File.join(results_dir, 'results.json')
File.write(results_path, JSON.pretty_generate(results))
puts "Wrote #{results.size} records to #{results_path}"
puts 'Run `ruby report.rb --codex aider` to generate the report.'
