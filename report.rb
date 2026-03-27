#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: utf-8
#
# Generates a markdown report from results/results.json + results/meta.json
#

require 'json'
require 'optparse'
require 'fileutils'

BASE_DIR    = File.expand_path(__dir__)
RESULTS_DIR = File.join(BASE_DIR, 'results')

options = {
  results_path: File.join(RESULTS_DIR, 'results.json'),
  meta_path: nil,
  output_path: nil,
  codex: nil,
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby report.rb [options]'
  opts.on('--codex NAME', 'Filter to a codex (e.g. claude, gemini, all)') { |v| options[:codex] = v }
  opts.on('--results PATH', 'Path to results.json') { |v| options[:results_path] = v }
  opts.on('--meta PATH', 'Path to meta.json') { |v| options[:meta_path] = v }
  opts.on('--output PATH', 'Where to write the markdown report') { |v| options[:output_path] = v }
end.parse!(ARGV)

# --- KRİTİK DÜZELTME: DOSYA YOLU BULMA ---
# Eğer varsayılan results/results.json yoksa artifacts içini tara
if !File.exist?(options[:results_path])
  pattern = File.join(BASE_DIR, 'artifacts', '**', 'results', 'results.json')
  all_files = Dir.glob(pattern)
  # En güncel dosyayı seç (Hata payını sıfıra indirir)
  latest = all_files.max_by { |f| File.mtime(f) }
  options[:results_path] = latest if latest
end

abort 'Error: results.json not found. Please run a benchmark first.' unless options[:results_path] && File.exist?(options[:results_path])
# -----------------------------------------

results_dir = File.dirname(options[:results_path])
options[:meta_path] ||= File.join(results_dir, 'meta.json')
options[:output_path] ||= File.join(results_dir, 'report.md')

def fmt(n)
  n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
end

def stddev(values)
  return 0.0 if values.size <= 1

  mean = values.sum / values.size.to_f
  Math.sqrt(values.sum { |v| (v - mean)**2 } / (values.size - 1).to_f)
end

def record_codex(record)
  return record['codex'] if record['codex']
  # Groq/Qwen desteği için küçük bir ekleme (orijinal yapıyı bozmaz)
  return record['model'] if record['model'] 
  return 'claude' if record.key?('v1_claude') || record.key?('v2_claude')

  'unknown'
end

def phase_metrics(record, phase)
  metrics = record["#{phase}_metrics"]
  return metrics if metrics.is_a?(Hash)

  codex = record_codex(record)
  legacy = record["#{phase}_#{codex}"]
  return legacy if legacy.is_a?(Hash)

  fallback = record["#{phase}_claude"]
  fallback.is_a?(Hash) ? fallback : nil
end

def metric_field(record, phase, field)
  metrics = phase_metrics(record, phase)
  metrics ? (metrics[field] || 0) : 0
end

def total_tokens(metrics)
  return 0 unless metrics

  (metrics['input_tokens'] || 0) + (metrics['output_tokens'] || 0) +
    (metrics['cache_creation_tokens'] || 0) + (metrics['cache_read_tokens'] || 0)
end

results = JSON.parse(File.read(options[:results_path]))
meta = File.exist?(options[:meta_path]) ? JSON.parse(File.read(options[:meta_path])) : {}

selected_codex = options[:codex] || meta['codex']
if selected_codex && selected_codex != 'all'
  results = results.select { |r| record_codex(r).to_s.include?(selected_codex) }
end

abort 'No matching results found.' if results.empty?

languages = results.map { |r| r['language'] }.uniq
versions  = meta['versions'] || {}

# ---------------------------------------------------------------------------
report = []

report_codex = if selected_codex && selected_codex != 'all'
                 selected_codex
               else
                 'all codexes'
               end

report << '# AI Coding Language Benchmark Report'
report << ''
report << '## Environment'
report << "- Date: #{meta['date']}" if meta['date']
report << "- Codex filter: #{report_codex}"
report << "- Problem: #{meta['problem']}" if meta['problem']
report << "- Codex version: #{meta['codex_version']}" if meta['codex_version']
report << "- Trials per language: #{meta['trials']}" if meta['trials']
report << "- Records in report: #{results.size}"
report << ''

report << '## Language Versions'
report << '| Language | Version |'
report << '|----------|---------|'
languages.each { |l| report << "| #{l.capitalize} | #{versions[l] || 'unknown'} |" }
report << ''

# --- RESULTS SUMMARY ---
report << '## Results Summary'
report << '| Language | v1 Time | v1 Turns | v1 LOC | v1 Tests | v2 Time | v2 Turns | v2 LOC | v2 Tests | Total Time | Avg Cost |'
report << '|----------|---------|----------|--------|----------|---------|----------|--------|----------|------------|----------|'

languages.each do |lang|
  lr = results.select { |r| r['language'] == lang }
  n  = lr.size.to_f
  next if n.zero?

  v1_times = lr.map { |r| r['v1_time'] || 0 }
  v1_avg = (v1_times.sum / n).round(1)
  v1_sd  = stddev(v1_times).round(1)

  v2_times = lr.map { |r| r['v2_time'] || 0 }
  v2_avg = (v2_times.sum / n).round(1)
  v2_sd  = stddev(v2_times).round(1)

  total_times = lr.map { |r| (r['v1_time'] || 0) + (r['v2_time'] || 0) }
  total_avg = (total_times.sum / n).round(1)
  total_sd  = stddev(total_times).round(1)

  v1_turns = (lr.sum { |r| metric_field(r, 'v1', 'num_turns') } / n).round(1)
  v2_turns = (lr.sum { |r| metric_field(r, 'v2', 'num_turns') } / n).round(1)

  v1_loc = (lr.sum { |r| r['v1_loc'] || 0 } / n).round(0)
  v2_loc = (lr.sum { |r| r['v2_loc'] || 0 } / n).round(0)

  v1_pass = lr.count { |r| r['v1_pass'] }
  v2_pass = lr.count { |r| r['v2_pass'] }
  v1_tests = "#{v1_pass}/#{lr.size}"
  v2_tests = "#{v2_pass}/#{lr.size}"

  total_cost = lr.sum { |r| %w[v1 v2].sum { |ph| metric_field(r, ph, 'cost_usd') } }
  avg_cost = total_cost / n

  report << "| #{lang.capitalize} " \
            "| #{v1_avg}s\u00B1#{v1_sd}s " \
            "| #{v1_turns} " \
            "| #{v1_loc} " \
            "| #{v1_tests} " \
            "| #{v2_avg}s\u00B1#{v2_sd}s " \
            "| #{v2_turns} " \
            "| #{v2_loc} " \
            "| #{v2_tests} " \
            "| #{total_avg}s\u00B1#{total_sd}s " \
            "| $#{'%.2f' % avg_cost} |"
end
report << ''

# --- TOKEN SUMMARY ---
report << '## Token Summary'
report << '| Language | Avg Input | Avg Output | Avg Cache Create | Avg Cache Read | Avg Total | Avg Cost |'
report << '|----------|-----------|------------|------------------|----------------|-----------|----------|'

languages.each do |lang|
  lr = results.select { |r| r['language'] == lang }
  n  = lr.size.to_f
  next if n.zero?

  sum_input = sum_output = sum_cache_create = sum_cache_read = 0
  sum_cost = 0.0

  lr.each do |r|
    %w[v1 v2].each do |ph|
      sum_input        += metric_field(r, ph, 'input_tokens')
      sum_output       += metric_field(r, ph, 'output_tokens')
      sum_cache_create += metric_field(r, ph, 'cache_creation_tokens')
      sum_cache_read   += metric_field(r, ph, 'cache_read_tokens')
      sum_cost         += metric_field(r, ph, 'cost_usd')
    end
  end

  avg_total = ((sum_input + sum_output + sum_cache_create + sum_cache_read) / n).round(0)

  report << "| #{lang.capitalize} " \
            "| #{fmt((sum_input / n).round(0))} " \
            "| #{fmt((sum_output / n).round(0))} " \
            "| #{fmt((sum_cache_create / n).round(0))} " \
            "| #{fmt((sum_cache_read / n).round(0))} " \
            "| #{fmt(avg_total)} " \
            "| $#{'%.4f' % (sum_cost / n)} |"
end
report << ''

# --- FULL RESULTS ---
report << '## Full Results'
report << '| Codex | Language | Trial | v1 Time | v1 Turns | v1 LOC | v1 Tests | v2 Time | v2 Turns | v2 LOC | v2 Tests | Total Time | Cost |'
report << '|-------|----------|-------|---------|----------|--------|----------|---------|----------|--------|----------|------------|------|'

results.each do |r|
  v1t = r['v1_pass'] ? 'PASS' : 'FAIL'
  v2t = r['v2_pass'] ? 'PASS' : 'FAIL'
  v1_tests = "#{r['v1_passed_count']}/#{r['v1_total_count']} #{v1t}"
  v2_tests = "#{r['v2_passed_count']}/#{r['v2_total_count']} #{v2t}"

  v1_turns = metric_field(r, 'v1', 'num_turns')
  v2_turns = metric_field(r, 'v2', 'num_turns')

  total_time = ((r['v1_time'] || 0) + (r['v2_time'] || 0)).round(1)
  cost = %w[v1 v2].sum { |ph| metric_field(r, ph, 'cost_usd') }

  report << "| #{record_codex(r)} | #{r['language'].capitalize} | #{r['trial']} " \
            "| #{r['v1_time']}s | #{v1_turns} | #{r['v1_loc']} | #{v1_tests} " \
            "| #{r['v2_time']}s | #{v2_turns} | #{r['v2_loc']} | #{v2_tests} " \
            "| #{total_time}s | $#{'%.2f' % cost} |"
end
report << ''

# --- FULL TOKENS ---
report << '## Full Tokens'
report << '| Codex | Language | Trial | Phase | Input | Output | Cache Create | Cache Read | Total | Cost USD |'
report << '|-------|----------|-------|-------|-------|--------|--------------|------------|-------|----------|'

results.each do |r|
  %w[v1 v2].each do |phase|
    metrics = phase_metrics(r, phase)
    if metrics
      tot = total_tokens(metrics)
      report << "| #{record_codex(r)} | #{r['language'].capitalize} | #{r['trial']} | #{phase} " \
                "| #{fmt(metrics['input_tokens'] || 0)} | #{fmt(metrics['output_tokens'] || 0)} " \
                "| #{fmt(metrics['cache_creation_tokens'] || 0)} | #{fmt(metrics['cache_read_tokens'] || 0)} " \
                "| #{fmt(tot)} | $#{'%.4f' % (metrics['cost_usd'] || 0)} |"
    else
      report << "| #{record_codex(r)} | #{r['language'].capitalize} | #{r['trial']} | #{phase} | - | - | - | - | - | - |"
    end
  end
end
report << ''

report_path = options[:output_path]
FileUtils.mkdir_p(File.dirname(report_path))
File.write(report_path, report.join("\n") + "\n")
puts "Report written to: #{report_path}"
