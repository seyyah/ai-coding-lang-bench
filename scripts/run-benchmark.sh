#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <codex> <problem> [benchmark args...]" >&2
  exit 1
fi

codex="$1"
problem="$2"
shift 2

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
extra_args=("$@")
dry_run=false
explicit_output_root=""

for ((i = 0; i < ${#extra_args[@]}; i++)); do
  case "${extra_args[$i]}" in
    --dry-run)
      dry_run=true
      ;;
    --output-root)
      if (( i + 1 < ${#extra_args[@]} )); then
        explicit_output_root="${extra_args[$((i + 1))]}"
      fi
      ;;
  esac
done

if [[ -n "$explicit_output_root" ]]; then
  output_root="$explicit_output_root"
elif [[ "$dry_run" == true ]]; then
  output_root="$repo_root/artifacts/$codex/$problem/dry-run"
else
  output_root="$repo_root/artifacts/$codex/$problem"
fi

mkdir -p "$output_root"

echo "==> Running benchmark"
echo "    codex: $codex"
echo "    problem: $problem"
echo "    output: $output_root"

exec ruby "$repo_root/benchmark.rb" \
  --codex "$codex" \
  --problem "$problem" \
  --output-root "$output_root" \
  "${extra_args[@]}"

