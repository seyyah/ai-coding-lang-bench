# Walkthrough

> Accumulated proof-of-work log. Each iteration appends a dated entry.
> See [AGENT.md](./AGENT.md) for entry template and update protocol.

---

## 2026-04-14 — Process First-Time Contributor PR & Update PR Guidelines

**Contributor**: AI agent (Antigravity)
**What was done**: 
- Investigated PR #56 (`pomodorotimer`) that was stuck waiting for maintainer approval.
- Identified that GitHub Actions requires maintainer approval for first-time fork contributors before running workflows.
- Evaluated PR #56 against `validate-problem.yml` rules and found that the problem name violated the `mini` prefix rule (must be `mini<name>`).
- Closed PR #56 with a comment explaining the naming violation and the reason for the stalled workflow.
- Updated `AGENT.md` to explicitly mandate the `mini` prefix in the New Problem Checklist and added a protocol for handling PRs from first-time contributors (inspect, message-close if invalid, or `gh run approve` if valid).
**Observations**: The `mini` prefix rule was previously only shown in examples rather than strictly mandated in the checklist, leading to invalid submissions like `pomodorotimer`. First-time contributor workflow stalls are confusing to new users without clear documentation.
**Next**: Await resubmission of the pomodoro timer problem with the correct name (`minipomodoro`) and structure.

---

## 2026-03-28 — Clean Architecture Refactor: DRY Configs & Unified CLI

**Contributor**: AI agent (Claude Code)
**What was done**: Full DRY refactor of the project structure to eliminate redundancy and unify the CLI.
- Migrated `benchmark.rb`, `report.rb`, `plot.py` from project root into `src/` directory.
- Created `bin/which-language` unified CLI supporting `benchmark`, `report`, `plot`, `run` subcommands — replaces all deleted bash wrappers.
- Extracted hardcoded `LANGUAGES` hash from `benchmark.rb` into `config/languages.yml`; added `lib/language_loader.rb` to load it (with optional `config/languages.local.yml` override support).
- Deleted five redundant bash scripts: `scripts/run-all.sh`, `scripts/run-benchmark.sh`, `scripts/generate-report.sh`, `scripts/generate-figures.sh`, `scripts/resolve-output-root.sh`.
- Fixed `src/benchmark.rb` relative paths (`../lib/`) and `BASE_DIR` to correctly reference project root instead of `src/`.
- Updated `CLAUDE.md`, `README.md`, `program.md`, `AGENT.md` to reflect new structure and CLI commands.

**Observations**:
- `bin/which-language run <codex> <problem>` now replaces the four-step manual workflow (benchmark → report → plot → inspect).
- Language toolchains can now be overridden per-machine via `config/languages.local.yml` without touching Ruby source.
- Bash wrapper scripts were duplicating argument parsing already present in `benchmark.rb`; removing them eliminates the drift risk.

**Decisions made**:
- Kept `scripts/` directory for platform install helpers (`install_mac.sh`, `install_windows.ps1`) — these are not orchestration wrappers.
- Named the CLI `bin/which-language` to match the project identity; `bin/run` was considered but rejected as too generic.

**Next**: Validate Groq adapter with real benchmark runs (plan.md #1); add miniplaylist problem definition (plan.md Other).

---

## 2026-03-28 — Standardization of Codex Configuration and CoC Enforcement

**Contributor**: AI agent (Antigravity)
**What was done**: Standardized the `config/codexes.yml` and its usage in the codebase, and enforced strong "Convention over Configuration" (CoC) rules in `program.md`. 
- Updated `codexes.yml`: Fixed `aider` indentation bug. Consolidated redundant keys (`api_url` -> `api_endpoint`, `model_name` -> `model`). Removed Groq-specific clutter.
- Updated Ruby adapters (`gemini_codex.rb`, `openai_codex.rb`, `groq_codex.rb`): Refactored internal variables mapping to use the normalized `model` and `api_endpoint` parameters exclusively. Updated error messages and metric logging to match. Extracted common `run_generation`, `calculate_cost`, `log_execution`, and `handle_error` methods into `BaseCodex` to enforce DRY principles.
- Updated `claude_codex.rb` and `aider_codex.rb`: Reused `log_execution` and `handle_error` from `BaseCodex`.
- Updated `codex_loader.rb`: Fallback logic checks `model` primarily.
- Updated `program.md`: Added **The Golden Rule: Convention over Configuration (CoC)** section outlining mandatory keys and strict penalties (PR rejection, AI forced reversion) for violations.

**Observations**:
- Ruby codex adapaters were previously mixing logic for `model` vs `model_name` and `api_url` vs `api_endpoint`. This inconsistency was prone to YAML setup errors.
- The `codexes.yml` file is now much cleaner and easier to template for new models.
- Adapters are significantly slimmer and strictly adhere to DRY/CoC principles. `BaseCodex` now manages the shared `run_generation` loop, API costs, error handling, and file creation logic automatically.
- Successfully verified the deeply refactored OpenAICodex against `minigit` using `--dry-run`. All 45 targets initialized correctly and the Markdown report was correctly generated.

**Next**: Proceed with adding new benchmark problems or expanding codex coverage.

## 2026-03-28 — Documentation infrastructure setup

**Contributor**: AI agent (Antigravity)
**What was done**: Deep codebase review + created autoresearch-inspired documentation loop. Added `program.md` (agent entry point), `AGENT.md` (contributor protocol), `plan.md` (living iteration plan), `walkthrough.md` (this file). Updated CLAUDE.md, README.md, INDEX.md, ROADMAP.md for coherence.

**Observations**:
- Codebase has 6 codex adapters (claude, gemini, openai, groq, aider + base) but ROADMAP.md was missing Groq/Aider status
- README.md had a broken markdown code block in Installation section (unclosed backtick)
- No iterative contribution mechanism existed — contributors had no way to track what was tried, what worked, what's next
- Karpathy's `program.md` pattern (single entry-point skill file) maps well to this project's multi-contributor model

**Decisions made**:
- `program.md` is the universal entry point (human reads it, agent reads it)
- `AGENT.md` mandates documentation updates — this is the enforcement mechanism
- `plan.md` replaces informal TODO tracking with structured experiment tracking
- `walkthrough.md` provides institutional memory across sessions
- CLAUDE.md remains as technical internals doc but now points to AGENT.md for contribution protocol

**Next**: Validate Groq and Aider adapters with real benchmark runs (plan.md items #1, #2)

---

## 2026-03-28 — MiniGrades fix + problem structure rules

**Contributor**: AI agent (Antigravity)
**What was done**: Rewrote all 5 minigrades problem files to match minigit quality level. Added mandatory problem structure rules to program.md.

**Key changes**:
- `problem.json`: replaced incompatible schema with minigit-style (binary_name, v1/v2 spec/test/prompt)
- `SPEC-v1.txt`: 6 commands (init, add, add-grade, delete, list, average-mock), deterministic exact-output format
- `SPEC-v2.txt`: extends v1 with 8 commands (+del-grade, real calc-avg, report, enhanced list)
- `test-v1.sh`: 17 tests, language-agnostic (`./minigrades` not `python3 solution.py`), `PASS:`/`FAIL:` format
- `test-v2.sh`: 25 tests, same format
- `program.md`: added "Problem structure (mandatory)" section with JSON schema, SPEC rules, test script rules

**Observations**:
- Original minigrades was Python-specific (hardcoded `python3 solution.py`) — now language-agnostic
- Test output format was `[PASSED]`/`[FAILED]` — benchmark.rb's `run_tests()` regex expects `PASS:`/`FAIL:` and `PASSED:`/`FAILED:` summary → fixed
- v1 delete message was "Student deleted successfully." but v2 was "Student and all grades deleted successfully." — normalized per version

**Next**: Run `ruby benchmark.rb --problem minigrades --dry-run` to validate loading

## 2026-03-27 — Add TPS Metric and Fix miniplaylist
**Contributor**: Antigravity
**What was done**: Added Tokens Per Second (TPS) metrics to `report.rb` and `plot.py`. Rewrote `miniplaylist` problem.json, specs, and tests to adhere to strict Convention over Configuration guidelines.
**Codex/Problem/Language**: N/A (Codebase maintenance + miniplaylist)
**Key metrics**: N/A
**Observations**: The newly proposed `miniplaylist` had language-specific lock-ins (forced `python3` instead of the binary) and did not follow the required schema variables like `binary_name`.
**Decisions made**: TPS was defined as `Output Tokens / Time` to objectively measure model inference speeds irrespective of environmental constraints.
**Next**: Ready to run `miniplaylist` benchmarks properly.
