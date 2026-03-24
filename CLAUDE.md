# AI Coding Language Benchmark

## Overview

Multi-codex benchmark that has various AI coding assistants (Claude Code, Gemini, etc.) implement "MiniGit" (a minimal git clone) in multiple languages, comparing generation time, LOC, token usage, and pass rate.

## Repository Structure

```
problems/
  minigit/
    problem.json     # Problem-specific prompt + asset config
    SPEC-v1.txt      # MiniGit v1 spec (init/add/commit/log)
    SPEC-v2.txt      # MiniGit v2 spec (v1 + status/diff/checkout/reset/rm/show)
    test-v1.sh       # v1 test suite (11 tests)
    test-v2.sh       # v2 test suite (30 tests)
benchmark.rb         # Benchmark runner (Ruby)
report.rb            # Report generator (results.json -> report.md)
plot.py              # Graph generator (results.json -> figures/*.png)
artifacts/
  <codex>/
    <model>/
      <problem>/
      generated/     # Generated source/build artifacts
      logs/          # Codex logs
      results/       # Raw result data + meta + report
      figures/       # Generated graphs
```

The `data` branch (orphan) contains:
```
artifacts/
  <codex>/<model>/<problem>/
    generated/
    logs/
```

## How It Works

1. Run `ruby benchmark.rb`
2. For each language x trial:
   - v1: Create `artifacts/<codex>/<model>/<problem>/generated/<problem>-{lang}-{trial}-v1/`, copy problem assets from `problems/<problem>/`, invoke the selected codex
   - v2: Copy v1 result to `<problem>-{lang}-{trial}-v2/`, invoke the selected codex to extend
3. Run test scripts independently to verify
4. Measure wall-clock time, LOC, token usage, and cost
5. Run `ruby report.rb` to generate the report
6. Run `python3 plot.py` to generate graphs

## Key Commands

```bash
ruby benchmark.rb                                    # All languages x 3 trials (default: claude)
ruby benchmark.rb --lang python --trials 1           # Single language test
ruby benchmark.rb --codex gemini --lang ruby         # Use Gemini instead of Claude
ruby benchmark.rb --codex gemini --problem minigit   # Writes to artifacts/gemini/gemini-3.1-flash-lite-preview/minigit/
ruby benchmark.rb --trials 10 --start 11             # Trials 11-20
ruby benchmark.rb --dry-run                          # Dry run
ruby benchmark.rb --help                             # Show all options
ruby report.rb                                       # Generate report
python3 plot.py                                      # Generate graphs
bash scripts/run-all.sh gemini minigit --lang python --trials 1
```

Prefer `config/codexes.local.yml` for local secrets and enablement overrides.

## Multi-Codex Architecture

The benchmark uses an adapter pattern to support multiple AI coding systems:

```
lib/
  codexes/
    base_codex.rb         # Abstract interface
    claude_codex.rb       # Claude Code CLI adapter
    gemini_codex.rb       # Google Gemini API adapter
    openai_codex.rb       # OpenAI Responses API adapter
  codex_loader.rb         # Loads and instantiates adapters
config/
  codexes.yml             # Codex configuration
```

Each codex adapter implements:
- `run_generation(prompt, dir:, log_path:)` - Generate code
- `version` - Get codex version
- `warmup(warmup_dir)` - Optional warmup
- `parse_metrics(raw_output)` - Extract token/cost data

To add a new codex:
1. Create `lib/codexes/your_codex.rb` extending `BaseCodex`
2. Add configuration to `config/codexes.yml`
3. Run: `ruby benchmark.rb --codex your_codex`

## Supported Languages (LANGUAGES hash in benchmark.rb)

rust, go, c, typescript, javascript, java, perl, python, python/mypy, ruby, ruby/steep, lua, scheme, ocaml, haskell

To add a language, add an entry to the `LANGUAGES` hash. Tests just call `./minigit`, so the implementation only needs to produce an executable with that name.

## Problem Model

Problems are loaded from `problems/<problem>/problem.json` and currently assume a two-phase structure:

- `v1_spec`, `v1_test`, `v1_prompt`
- `v2_spec`, `v2_test`, `v2_prompt`

Each run writes outputs under `artifacts/<codex>/<model>/<problem>/`, while dry-runs are isolated under `artifacts/<codex>/<model>/<problem>/dry-run/`.

## MiniGit Technical Notes

- Custom hash function "MiniHash" (FNV-1a variant, 64-bit, 16-char hex output)
- Data stored under `.minigit/` (objects/, commits/, index, HEAD)
- No external libraries allowed, stdlib only
- Exact string matching required (determinism rules)

## Multi-Codex Expansion

This benchmark originally targeted Claude Code, but has been refactored to support multiple AI coding assistants:

### Current Support
- ✅ **Claude Code** (Anthropic) - Original implementation
- ✅ **Gemini** (Google) - API integration with Flash-Lite/Pro
- ✅ **OpenAI** - Responses API integration

### Planned Integrations
See **[ROADMAP.md](./ROADMAP.md)** for the complete list of 20+ planned codexes including:
- 🔴 **High Priority**: DeepSeek (V3.2, R1)
- 🟡 **Medium Priority**: Qwen (3.5 Coder), Aider, Cline, Grok 3
- 🟢 **Future**: Llama 4, Mistral, GLM-4.7, self-hosted models

### Architecture Benefits
- **Unified Interface**: All codexes use the same `BaseCodex` API
- **Easy Comparison**: Run the same task across multiple codexes
- **Extensible**: Add new codexes by creating a single adapter file
- **Language-Agnostic**: Test codex performance across 15 programming languages

### Research Questions
1. Which codex is **fastest** for different languages?
2. Which is most **cost-effective**?
3. Do **specialized models** (e.g., Qwen Coder) outperform general ones?
4. How do **open source** models compare to proprietary ones?
5. What's the overhead of **CLI tools** (Aider, Cline) vs direct API?

See **[CODEX_COMPARISON.md](./CODEX_COMPARISON.md)** for detailed technical comparison.

## Contributing

We welcome contributions of:
- **New codex adapters** (implement `BaseCodex` interface)
- **Benchmark results** (run existing codexes, submit data)
- **Analysis scripts** (improve reporting/visualization)
- **Language additions** (add new programming languages)

## Notes

- This is not a git repository for MiniGit itself; individual implementations under `artifacts/<codex>/<model>/<problem>/generated/` may use `git init` as part of their build process
- The `data` branch is an orphan branch with no common history with `main`
- Originally focused on Claude Code, now a **multi-codex benchmark platform**
