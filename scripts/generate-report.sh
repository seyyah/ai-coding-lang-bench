#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <codex> <problem>" >&2
  exit 1
fi

codex="$1"
problem="$2"
shift 2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
base_dir="$(bash "$script_dir/resolve-output-root.sh" "$codex" "$problem")"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-dir)
      base_dir="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

results_dir="$base_dir/results"
results_json="$results_dir/results.json"
meta_json="$results_dir/meta.json"
report_md="$results_dir/report.md"

if [[ ! -f "$results_json" ]]; then
  echo "Missing results file: $results_json" >&2
  exit 1
fi

echo "==> Generating report"
echo "    input:  $results_json"
echo "    output: $report_md"

exec ruby "$repo_root/report.rb" \
  --codex "$codex" \
  --results "$results_json" \
  --meta "$meta_json" \
  --output "$report_md"

