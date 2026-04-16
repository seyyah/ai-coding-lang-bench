# AI Coding Language Benchmark

> **Contributors**: Read [AGENT.md](./AGENT.md) for the contribution protocol and [program.md](./program.md) for the current research focus.

## Overview

Multi-codex benchmark that has various AI coding assistants (Claude Code, Gemini, etc.) implement coding problems (MiniGit, MiniGrades, etc.) in multiple languages, comparing generation time, LOC, token usage, and pass rate.

## Repository Structure

```
bin/
  which-language     # Unified CLI entry point (benchmark / report / plot / run)
src/
  benchmark.rb       # Benchmark runner (Ruby)
  report.rb          # Report generator (results.json -> report.md)
  plot.py            # Graph generator (results.json -> figures/*.png)
lib/
  codexes/
    base_codex.rb    # Abstract interface
    claude_codex.rb  # Claude Code CLI adapter
    gemini_codex.rb  # Google Gemini API adapter
    openai_codex.rb  # OpenAI Responses API adapter
    groq_codex.rb    # Groq API adapter
    aider_codex.rb   # Aider CLI adapter
  codex_loader.rb    # Loads and instantiates adapters
  language_loader.rb # Loads language config from YAML
config/
  codexes.yml        # Codex configuration
  languages.yml      # Language toolchain configuration
problems/
  minigit/
    problem.json     # Problem-specific prompt + asset config
    SPEC-v1.txt      # v1 spec
    SPEC-v2.txt      # v2 spec (extends v1)
    test-v1.sh       # v1 test suite
    test-v2.sh       # v2 test suite
artifacts/
  <codex>/<model>/<problem>/
    generated/       # Generated source/build artifacts
    logs/            # Codex logs
    results/         # Raw result data + meta + report
    figures/         # Generated graphs
```

The `data` branch (orphan) contains generated artifacts and logs.

## How It Works

1. Run `bin/which-language run <codex> <problem>`
2. For each language × trial:
   - v1: Create working dir, copy problem assets, invoke the selected codex
   - v2: Copy v1 result, invoke the codex to extend
3. Run test scripts independently to verify
4. Measure wall-clock time, LOC, token usage, and cost
5. Report and figures are generated automatically by the `run` subcommand

## Key Commands

```bash
bin/which-language run claude minigit                        # Full pipeline (default: all langs × 3 trials)
bin/which-language benchmark claude minigit --lang python --trials 1  # Benchmark only
bin/which-language report claude minigit                     # Generate report from existing results
bin/which-language plot claude minigit                       # Generate figures from existing results
bin/which-language benchmark claude minigit --dry-run        # Dry run (no API calls)
```

Prefer `config/codexes.local.yml` for local secrets and enablement overrides.

## Multi-Codex Architecture

Each codex adapter implements:
- `run_generation(prompt, dir:, log_path:)` — Generate code
- `version` — Get codex version
- `warmup(warmup_dir)` — Optional warmup
- `parse_metrics(raw_output)` — Extract token/cost data

To add a new codex:
1. Create `lib/codexes/your_codex.rb` extending `BaseCodex`
2. Add configuration to `config/codexes.yml`
3. Run: `bin/which-language benchmark your_codex minigit --dry-run`

See [AGENT.md](./AGENT.md) for the full integration checklist.

## Codex Specifications

### Implemented

| Codex | Provider | Type | Context | Pricing (in/out per 1M) |
|-------|----------|------|---------|------------------------|
| **Claude Code** | Anthropic | CLI | 200K | ~$15/$75 |
| **Gemini** | Google | API | 1M | $0.25/$1.50 |
| **OpenAI** | OpenAI | API | 128K | $5/$15 (GPT-4o) |
| **Groq** | Groq | API | 128K | varies by model |
| **Aider** | Open Source | CLI | model-dependent | N/A (wraps other models) |

### Benchmark Results (historical)

**Claude Code** (Original Study):
- Ruby: 73.1s, $0.36, 219 LOC, 40/40 pass
- Python: 74.6s, $0.38, 235 LOC, 40/40 pass
- JavaScript: 81.1s, $0.39, 248 LOC, 40/40 pass

**Gemini** (Flash-Lite):
- JavaScript: 173.3s, $0.005, 125 LOC, 40/40 pass
- Python: 167.9s, $0.005, 138 LOC, 39/40 pass
- Ruby: 136.5s, $0.004, 154 LOC, 29/40 pass

### Research Questions

1. Which codex is **fastest** for different languages?
2. Which is most **cost-effective**?
3. Do **specialized models** (e.g., Qwen Coder) outperform general ones?
4. How do **open source** models compare to proprietary ones?
5. What's the overhead of **CLI tools** (Aider, Cline) vs direct API?

See [plan.md](./plan.md) for planned codex integrations and current experiment status.

## Supported Languages

`rust`, `go`, `c`, `typescript`, `javascript`, `java`, `perl`, `python`, `python/mypy`, `ruby`, `ruby/steep`, `lua`, `scheme`, `ocaml`, `haskell`

To add a language, add an entry to `config/languages.yml`.

## Problem Model

Problems are loaded from `problems/<problem>/problem.json` and assume a two-phase structure:

- `v1_spec`, `v1_test`, `v1_prompt`
- `v2_spec`, `v2_test`, `v2_prompt`

Each run writes outputs under `artifacts/<codex>/<model>/<problem>/`, while dry-runs are isolated under `artifacts/<codex>/<model>/<problem>/dry-run/`.

## MiniGit Technical Notes

- Custom hash function "MiniHash" (FNV-1a variant, 64-bit, 16-char hex output)
- Data stored under `.minigit/` (objects/, commits/, index, HEAD)
- No external libraries allowed, stdlib only
- Exact string matching required (determinism rules)

## Notes

- This is not a git repository for MiniGit itself; individual implementations under `artifacts/<codex>/<model>/<problem>/generated/` may use `git init` as part of their build process
- The `data` branch is an orphan branch with no common history with `main`
- Originally focused on Claude Code, now a **multi-codex benchmark platform**

