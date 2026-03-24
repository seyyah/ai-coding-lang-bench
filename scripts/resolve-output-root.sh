#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 <codex> <problem> [dry-run:true|false]" >&2
  exit 1
fi

codex="$1"
problem="$2"
dry_run="${3:-false}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

ruby - "$repo_root" "$codex" "$problem" "$dry_run" <<'RUBY'
repo_root, codex, problem, dry_run = ARGV
require File.join(repo_root, 'lib', 'codex_loader')

puts CodexLoader.default_output_root(
  codex,
  problem: problem,
  base_dir: repo_root,
  dry_run: dry_run == 'true',
)
RUBY