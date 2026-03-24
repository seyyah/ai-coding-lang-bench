# AI Coding Language Benchmark

Benchmark platform for comparing **AI coding systems** across three axes:

- **problem** — e.g. MiniGit today, more tomorrow
- **codex** — Claude, Gemini, OpenAI, and future adapters
- **language** — Python, Ruby, Rust, Go, TypeScript, etc.

The repository started as a Claude-focused MiniGit experiment and is now being generalized into a reusable **multi-problem, multi-codex, multi-language benchmark harness**.

> Start here: [QUICK_START.md](./QUICK_START.md) · Need the doc map? [INDEX.md](./INDEX.md) · Want internals? [CLAUDE.md](./CLAUDE.md)

## What this repository is for

This project helps answer questions like:

- Which codex is fastest on the same problem?
- Which programming languages are cheapest for agent-generated implementations?
- How much does type-checking overhead change time, cost, or LOC?
- How stable are repeated runs across trials?

Today the canonical bundled problem is **MiniGit**, but the benchmark runner is structured so new problems can be added under `problems/<problem>/`.

## The mental model

Think of the benchmark as a matrix:

| Dimension | Defined by | Example |
|----------|------------|---------|
| Problem | `problems/<problem>/problem.json` + assets | `minigit` |
| Codex | `lib/codexes/*.rb` + `config/codexes*.yml` | `claude`, `gemini`, `openai` |
| Language | `LANGUAGES` in `benchmark.rb` | `python`, `rust`, `ruby/steep` |

Each benchmark run writes outputs under a namespaced root:

```text
artifacts/<codex>/<model>/<problem>/
  generated/
  logs/
  results/
  figures/
```

The `<model>` segment comes from `config.model`. Values like `gemini/gemini-2.5-pro`
intentionally create deeper namespaces under the selected codex.

That layout is now the default for both helper scripts and direct `benchmark.rb` usage.

## First successful run

### 1. Prerequisites

- Ruby
- the toolchains for the languages you want to benchmark
- at least one enabled codex

### 2. Configure a codex safely

Prefer **local overrides** instead of editing committed config directly.

Create `config/codexes.local.yml`:

```yaml
codexes:
  gemini:
    enabled: true
    config:
      api_key: "${GOOGLE_API_KEY}"
```

Then export your key:

```bash
export GOOGLE_API_KEY="your-key"
```

`config/codexes.local.yml` is gitignored, so local secrets and enablement stay out of the repo.

### 3. Smoke test the full pipeline

```bash
bash scripts/run-all.sh gemini minigit --dry-run --lang python --trials 1
```

This verifies:

- problem loading
- output namespacing
- report generation
- figure generation

Dry runs are isolated under:

```text
artifacts/<codex>/<model>/<problem>/dry-run/
```

### 4. Run a real benchmark

```bash
bash scripts/run-all.sh gemini minigit --lang python --trials 1
```

Or, if you prefer the raw runner:

```bash
ruby benchmark.rb --codex gemini --problem minigit --lang python --trials 1
```

### 5. Read the outputs

- raw results: `artifacts/<codex>/<model>/<problem>/results/results.json`
- report: `artifacts/<codex>/<model>/<problem>/results/report.md`
- figures: `artifacts/<codex>/<model>/<problem>/figures/`
- generated code / build artifacts: `artifacts/<codex>/<model>/<problem>/generated/`

### Installation

### Windows Environment Setup
If you are running the benchmarks on Windows, you can automatically install the required languages and compilers using the provided PowerShell script.

Open your terminal as Administrator and run:
```powershell
.\scripts\install_windows.ps1

### 🍏 macOS Setup

For macOS users, we provide an automated setup script that uses **Homebrew** to seamlessly install all required languages, compilers, and sub-dependencies. The script is idempotent, meaning it will safely skip packages that are already installed on your system.

**Prerequisites:**
Ensure you have [Homebrew](https://brew.sh/) installed before running the script.

**Installation Steps:**
1. Open your terminal in the root directory of the project.
2. Make the script executable:
   ```bash
   chmod +x scripts/install_mac.sh



## What is already generalized

### Multiple problems

Each problem lives in its own folder:

```text
problems/<problem>/
  problem.json
  SPEC-v1.txt
  SPEC-v2.txt
  test-v1.sh
  test-v2.sh
```

`problem.json` declares:

- display name
- output binary name
- phase-specific specs
- phase-specific tests
- prompt templates

#### Multiple codexes

Codexes use an adapter interface:

- `run_generation(prompt, dir:, log_path:)`
- `version`
- optional `warmup`
- optional `parse_metrics`

This keeps the benchmark runner independent from any specific vendor.

### Multiple languages

Supported languages are defined centrally in `benchmark.rb` via the `LANGUAGES` hash.

Each entry provides things like:

- source extensions for LOC counting
- a version command
- optional extra prompting for typed variants like `python/mypy` and `ruby/steep`

## Current support

### Codexes implemented now

| Codex | Status | Notes |
|------|--------|-------|
| Claude Code | ✅ | default CLI adapter |
| Gemini | ✅ | API adapter with metrics extraction |
| OpenAI | ✅ | Responses API adapter with optional cost accounting |
| Groq | ✅ | API adapter with robust parsing features for supported models |

See [ROADMAP.md](./ROADMAP.md) for planned adapters such as DeepSeek, Qwen, Aider, Cline, and more.

### Languages currently benchmarkable

- Dynamic: `python`, `ruby`, `javascript`, `perl`, `lua`
- Static: `rust`, `go`, `c`, `typescript`, `java`
- Functional: `scheme`, `ocaml`, `haskell`
- Typed variants: `python/mypy`, `ruby/steep`

## Important current assumptions

The framework is generalized, but it still intentionally assumes a few things:

1. **Two benchmark phases** exist: `v1` then `v2`
2. Each problem supplies shell-based tests for both phases
3. The implementation must expose the executable named by `binary_name`
4. Languages are still configured in code (`LANGUAGES`), not a separate data file

Those constraints are acceptable for now, but they are worth knowing if you plan to add more problem families.

## Repository layout

```text
.
├── benchmark.rb
├── report.rb
├── plot.py
├── problems/
│   └── minigit/
├── lib/
│   ├── codex_loader.rb
│   └── codexes/
├── config/
│   ├── codexes.yml
│   └── codexes.local.yml   # local override, gitignored
├── scripts/
└── artifacts/
    └── <codex>/<model>/<problem>/
```

## Recommended commands

### Run benchmark only

```bash
bash scripts/run-benchmark.sh gemini minigit --lang python --trials 1
```

### Run benchmark + report + figures

```bash
bash scripts/run-all.sh gemini minigit --lang python --trials 1
```

### Use the raw runner

```bash
ruby benchmark.rb --codex gemini --problem minigit --lang python --trials 1
ruby benchmark.rb --help
```

## Historical context

This repository began with the published Claude Code / MiniGit experiment:

- [Which Programming Language Is Best for Claude Code?](https://dev.to/mame/which-programming-language-is-best-for-claude-code-508a)
- [Japanese version](https://zenn.dev/mametter/articles/3e8580ec034201)

Treat that write-up as **historical benchmark context**, not as the entire identity of this repository. The codebase is now evolving toward a broader benchmark platform.

## Contributors

- [mame](https://github.com/mame)
- [berkevnl](https://github.com/berkevnl)
- [Ahmetngz](https://github.com/Ahmetngz)

## Where to go next

- Want a guided first run? → [QUICK_START.md](./QUICK_START.md)
- Want the documentation map? → [INDEX.md](./INDEX.md)
- Want internal architecture? → [CLAUDE.md](./CLAUDE.md)
- Want future integrations? → [ROADMAP.md](./ROADMAP.md)
- Want codex comparison notes? → [CODEX_COMPARISON.md](./CODEX_COMPARISON.md)

## Similar projects
- https://autocodebench.github.io
- https://livecodebench.github.io
