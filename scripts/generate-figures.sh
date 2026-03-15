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
base_dir="$repo_root/artifacts/$codex/$problem"

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

results_json="$base_dir/results/results.json"
outdir="$base_dir/figures"

if [[ ! -f "$results_json" ]]; then
  echo "Missing results file: $results_json" >&2
  exit 1
fi

echo "==> Generating figures"
echo "    input:  $results_json"
echo "    output: $outdir"

exec python3 "$repo_root/plot.py" \
  "$results_json" \
  --codex "$codex" \
  --outdir "$outdir"

