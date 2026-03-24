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
  base_dir="$explicit_output_root"
else
  base_dir="$(bash "$script_dir/resolve-output-root.sh" "$codex" "$problem" "$dry_run")"
fi

bash "$script_dir/run-benchmark.sh" "$codex" "$problem" "${extra_args[@]}"
bash "$script_dir/generate-report.sh" "$codex" "$problem" --base-dir "$base_dir"
bash "$script_dir/generate-figures.sh" "$codex" "$problem" --base-dir "$base_dir"

echo
echo "All artifacts written under: $base_dir"

