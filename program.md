# Program

> Entry point for human and AI contributors. Read this first.

## What this project benchmarks

This repo measures **AI coding systems** (codexes) across multiple dimensions: generation time, cost, lines of code, and test pass rate — across multiple programming languages and coding problems.

## Current research question

**Which codex produces the fastest, cheapest, and most correct implementations across languages?**

Active focus areas:
1. Expanding codex coverage (DeepSeek, Qwen, Grok next)
2. Adding new benchmark problems beyond MiniGit
3. Cross-codex comparative analysis

## The iteration loop

Every contribution — human or AI — follows this tight loop:

```
1. READ     → program.md (this file) + plan.md (current goals)
2. WORK     → run experiments, add adapters, fix bugs, add problems
3. MEASURE  → run benchmarks, collect metrics, compare results
4. DOCUMENT → update walkthrough.md (what you did) + plan.md (what's next)
```

### Rules

- **Before starting work**: read `plan.md` to see what's active and what's next
- **After each experiment or code change**: append a dated entry to `walkthrough.md`
- **When adding new features**: actively update descriptive `.md` files (`program.md`, `CLAUDE.md`, `README.md`) so the context remains fresh
- **Before ending your session**: update `plan.md` with next steps and open questions
- **Always**: follow the contributor protocol in `AGENT.md`

## The Golden Rule: Convention over Configuration (CoC)

This codebase enforces strict Convention over Configuration (CoC) principles for all Codex adapters (`config/codexes.yml` and `lib/codexes/*.rb`). 

**Mandatory CODEX Keys:**
- `api_endpoint` (never `api_url`, `url`, etc.)
- `model` (never `model_name`, `backend_model`, etc.)
- `api_key`
- Pricing metrics: `price_input_1m`, `price_output_1m`, `price_cached_input_1m`

**🚨 STRICT PUNISHMENT FOR VIOLATIONS 🚨**
Any contributor (AI or Human) violating these conventions by introducing redundant keys, arbitrary aliases, or ad-hoc adapter configurations **WILL BE PENALIZED**.
- Pull requests violating CoC will be instantly rejected.
- AI Agents caught deviating from these exact key names will be forcefully instructed to revert their own changes before proceeding.
- Do not invent new configuration keys when an existing standard key applies.

## Problem structure (mandatory)

Every problem lives under `problems/<name>/` and **must** contain exactly these 5 files:

```
problems/<name>/
  problem.json       # metadata + prompt templates
  SPEC-v1.txt        # v1 specification (deterministic)
  SPEC-v2.txt        # v2 specification (extends v1)
  test-v1.sh         # v1 test suite
  test-v2.sh         # v2 test suite
```

### problem.json (required keys)

```json
{
  "name": "ProblemName",
  "binary_name": "problemname",
  "v1_spec": "SPEC-v1.txt",
  "v1_test": "test-v1.sh",
  "v1_prompt": "Implement {{binary_name}} as described in SPEC-v1.txt using {{language}}...",
  "v2_spec": "SPEC-v2.txt",
  "v2_test": "test-v2.sh",
  "v2_prompt": "Read SPEC-v2.txt and extend the existing {{binary_name}}..."
}
```

All 7 keys (`name`, `binary_name`, `v1_spec`, `v1_test`, `v1_prompt`, `v2_spec`, `v2_test`, `v2_prompt`) are **mandatory**. Missing keys → `src/benchmark.rb` aborts.

### SPEC files rules

- Plain text, deterministic, exact-output specifications
- Section headers with `========` separators
- Every command: input → exact output string → exit code
- Determinism rules section mandatory
- v2 **extends** v1 (superset of commands)

### Test script rules

- Shebang: `#!/usr/bin/env bash`
- Language-agnostic: call `../minigit` or `../<binary_name>`, never `python3 solution.py`
- Build step: check for `Makefile`, `build.sh`, `chmod +x`
- Output format: `PASS: <test name>` or `FAIL: <test name>`
- Summary block at end:
  ```
  PASSED: <n>
  FAILED: <n>
  TOTAL:  <n>
  ```
- Exit 0 if all pass, exit 1 if any fail

### Canonical example: `problems/minigit/`

Use minigit as the reference when creating new problems.

## File map (the important ones)

| File | Role | Who edits |
|------|------|-----------|
| `program.md` | This file — current focus + iteration loop | Human |
| `plan.md` | Living iteration plan — active experiments + backlog | Human + Agent |
| `walkthrough.md` | Proof-of-work log — dated entries per iteration | Human + Agent |
| `AGENT.md` | Contributor protocol — rules, conventions, checklists | Human |
| `bin/which-language` | Unified CLI — orchestrates benchmark/report/plot | Human + Agent |
| `src/benchmark.rb` | Benchmark runner — the code the agent extends | Human + Agent |
| `lib/codexes/*.rb` | Codex adapters — the main extension point | Human + Agent |
| `problems/*/` | Problem definitions — specs, tests, prompts | Human + Agent |

## Quick links

- Architecture details → [CLAUDE.md](./CLAUDE.md)
- Contributor protocol → [AGENT.md](./AGENT.md)
- Iteration plan → [plan.md](./plan.md)
- Proof-of-work log → [walkthrough.md](./walkthrough.md)

