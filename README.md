# Which Programming Language Is Best for AI Coding Agents?

A quantitative benchmark comparing how efficiently various AI coding assistants generate code across multiple programming languages.

**Originally** a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) benchmark, now supports multiple AI codexes including **Google Gemini**.

> **📚 Navigation**: [INDEX.md](./INDEX.md) | **⚡ Quick Start**: [QUICK_START.md](./QUICK_START.md) | **🗺️ Roadmap**: [ROADMAP.md](./ROADMAP.md)

For the original Claude Code benchmark discussion, see: [Which Programming Language Is Best for Claude Code?](https://dev.to/mame/which-programming-language-is-best-for-claude-code-508a) / [日本語版](https://zenn.dev/mametter/articles/3e8580ec034201)

## TL;DR

**Original Claude Code Results**: At least for prototyping-scale tasks, Ruby, Python, and JavaScript (not TypeScript) appear to be the best fit for Claude Code — fastest, cheapest, and most stable.

**Multi-Codex Status**: Now supports multiple AI coding assistants. Compare Claude, Gemini, and more across the same tasks and languages. See [ROADMAP.md](./ROADMAP.md) for planned integrations.

## Motivation

"Static typing prevents AI hallucination bugs!" vs. "Dynamic typing saves tokens!" — qualitative arguments abound, but quantitative data is scarce. This experiment aims to fill that gap.

## Supported AI Codexes

| Codex | Provider | Status | Integration | Notes |
|-------|----------|--------|-------------|-------|
| **Claude Code** | Anthropic | ✅ Supported | CLI | Default, Opus/Sonnet models |
| **Gemini** | Google | ✅ Supported | API | Flash-Lite/Pro, 1M context, free tier |
| **OpenAI** | OpenAI | 🚧 Planned | API | GPT-4o, o3, o4-mini |
| **DeepSeek** | DeepSeek | 🚧 Planned | API | V3.2, R1, cheapest at $0.27/1M |
| **Qwen** | Alibaba | 🚧 Planned | API | 3.5 Coder, SWE-Bench leader |
| **Aider** | Open Source | 🚧 Planned | CLI | 75+ model support |
| **Cline** | Open Source | 🚧 Planned | CLI | 4M+ installations |
| **Others** | Various | 📋 Roadmap | - | See [ROADMAP.md](./ROADMAP.md) for 20+ more |

**See [ROADMAP.md](./ROADMAP.md)** for the complete list of planned integrations including Grok, Llama, Mistral, and specialized tools.

## Experiment

We ask AI coding assistants (originally Claude Code Opus 4.6, now supporting multiple codexes) to implement a **mini-git** — a simplified version of Git — in various programming languages, and measure the time, cost, and lines of code for each.

The task is split into two phases:

* **v1 (New project)**: Implement `init`, `add`, `commit`, and `log`.
* **v2 (Feature extension)**: Add `status`, `diff`, `checkout`, `reset`, `rm`, and `show`.

Problem assets now live under `problems/<problem>/`. For MiniGit, the prompt is driven by [`problems/minigit/problem.json`](./problems/minigit/problem.json) and the benchmark copies [`SPEC-v1.txt`](./problems/minigit/SPEC-v1.txt) plus [`test-v1.sh`](./problems/minigit/test-v1.sh) from that directory. v2 is analogous.

### Languages

| Category | Languages |
|----------|-----------|
| Dynamic | Python, Ruby, JavaScript, Perl, Lua |
| Dynamic + type checker | Python/mypy, Ruby/Steep |
| Static | TypeScript, Go, Rust, C, Java |
| Functional | Scheme (dynamic), OCaml (static), Haskell (static) |

Python/mypy writes fully type-annotated Python verified with `mypy --strict`. Ruby/Steep writes RBS type signatures verified with `steep check`. These allow direct comparison of type-checking overhead within the same language.

Each language was run **20 times**. A custom hash algorithm (not SHA-256) is used to avoid library-dependent variation.

## Results

| Language | Tests passed (v1+v2) | Time (v1+v2) | Avg. cost | LOC (v2) |
|----------|---------------------:|--------------:|----------:|---------:|
| Ruby | 40/40 | 73.1s ± 4.2s | $0.36 | 219 |
| Python | 40/40 | 74.6s ± 4.5s | $0.38 | 235 |
| JavaScript | 40/40 | 81.1s ± 5.0s | $0.39 | 248 |
| Go | 40/40 | 101.6s ± 37.0s | $0.50 | 324 |
| Rust | 38/40 | 113.7s ± 54.8s | $0.54 | 303 |
| Java | 40/40 | 115.4s ± 34.4s | $0.50 | 303 |
| Python/mypy | 40/40 | 125.3s ± 19.0s | $0.57 | 326 |
| OCaml | 40/40 | 128.1s ± 28.9s | $0.58 | 216 |
| Perl | 40/40 | 130.2s ± 44.2s | $0.55 | 315 |
| Scheme | 40/40 | 130.6s ± 39.9s | $0.60 | 310 |
| TypeScript | 40/40 | 133.0s ± 29.4s | $0.62 | 310 |
| Lua | 40/40 | 143.6s ± 43.0s | $0.58 | 398 |
| C | 40/40 | 155.8s ± 40.9s | $0.74 | 517 |
| Haskell | 39/40 | 174.0s ± 44.2s | $0.74 | 224 |
| Ruby/Steep | 40/40 | 186.6s ± 69.7s | $0.84 | 304 |

Out of 600 runs (15 configurations × 2 phases × 20 trials), only 3 failed: Rust (2) and Haskell (1).

### Total Time and Cost (v1 + v2)

![Total time](./artifacts/gemini/minigit/figures/total_time.png)

![Total cost](./artifacts/gemini/minigit/figures/total_cost.png)

Ruby, Python, and JavaScript are the top 3 — fast (73–81s), cheap ($0.36–0.39), and stable (low stddev). From 4th place onward, variance increases sharply.

Time and cost are strongly correlated:

![Time vs Cost](./artifacts/gemini/minigit/figures/total_time_vs_cost.png)

### Lines of Code (v2)

![Lines of code](./artifacts/gemini/minigit/figures/total_lines.png)

OCaml (216), Ruby (219), and Haskell (224) are the most compact. C stands out at 517 lines. Notably, fewer LOC does not imply faster/cheaper generation — OCaml and Haskell are compact but mid-to-low in speed.

![Time vs LOC](./artifacts/gemini/minigit/figures/total_time_vs_loc.png)

### v1 (New Project)

![v1 time](./artifacts/gemini/minigit/figures/v1_time.png)

Python (32.9s) and Ruby (33.2s) lead, followed by JavaScript (36.0s). Ruby/Steep takes 105.0s — 3.2× slower than plain Ruby. v1 starts from an empty directory, so languages requiring project config files (`Cargo.toml`, `package.json`, etc.) incur additional overhead.

### v2 (Feature Extension)

![v2 time](./artifacts/gemini/minigit/figures/v2_time.png)

The gap narrows in v2. The top 3 remain Ruby (40.0s), Python (41.8s), JavaScript (45.1s). Perl (45.7s), OCaml (47.1s), and Lua (47.2s) follow closely. Haskell is the slowest at 99.6s despite having the fewest LOC.

Type-checker overhead: Python/mypy is 1.6–1.7× slower than Python; Ruby/Steep is 2.0–3.2× slower than Ruby.

## Discussion

> The author is a Ruby committer, so take interpretations with a grain of salt. Data and code are available in this repository — verify for yourself if you're skeptical.

### What causes the speed/cost differences?

No single factor explains the results. Likely contributors:

- **Type system**: In this benchmark, dynamic languages are consistently faster and more stable.
- **Conciseness**: Shorter code generally means faster generation, but OCaml/Haskell are compact yet slow (high thinking-token usage).
- **Procedural vs. functional**: Excluding the top 3, there isn't a large gap between procedural and functional languages. OCaml notably achieved 47.1s in v2, rivaling JavaScript.
- **Language difficulty**: C's memory management, Rust's ownership model, and Haskell's monads/purity may add overhead for the AI.
- **AI familiarity**: Python/Ruby/JavaScript likely have more training data available. Ruby/Steep's larger overhead vs. Python/mypy may reflect lower AI familiarity with Steep.

### Does lack of types mean more bugs?

Possibly — tests pass, but untested paths may have type errors. That said, the only failures in 600 runs were in Rust and Haskell (both statically typed, both relatively "difficult" languages).

### Does a 2× difference matter?

Personally, yes. In iterative development ("prompt → wait → think → prompt"), I find the difference between 30s and 60s significantly impacts flow and focus.

### Isn't this too small-scale?

Yes — static typing may shine at larger scales. A fair large-scale cross-language benchmark would be valuable. Contributions welcome.

### What about ecosystems and runtime performance?

For real projects, framework availability matters — and if runtime speed is essential, a compiled language may be the better choice. This benchmark intentionally avoids external libraries to isolate language-level differences (using a custom hash instead of SHA-256).

## Reproducing

```bash
ruby benchmark.rb                                # Run all languages × 3 trials (default: Claude)
ruby benchmark.rb --lang python --trials 1       # Single language quick test
ruby benchmark.rb --codex gemini --trials 5      # Use Gemini instead of Claude
ruby benchmark.rb --codex gemini --problem minigit   # Write to artifacts/gemini/minigit/
ruby benchmark.rb --help                         # Show all options
ruby report.rb                                   # Generate artifacts/<codex>/<problem>/results/report.md
python3 plot.py                                  # Generate artifacts/<codex>/<problem>/figures/*.png
```

Structured outputs by codex + problem:

```bash
bash scripts/run-benchmark.sh gemini minigit --lang python --trials 1
bash scripts/generate-report.sh gemini minigit
bash scripts/generate-figures.sh gemini minigit
bash scripts/run-all.sh gemini minigit --lang python --trials 1
```

These commands write under:

```text
artifacts/<codex>/<problem>/
  generated/
  logs/
  results/
  figures/
```

Problem definitions live under:

```text
problems/<problem>/
  problem.json
  SPEC-v1.txt
  SPEC-v2.txt
  test-v1.sh
  test-v2.sh
```

Requirements: Ruby, and the target language toolchains.

### Multi-Codex Support

This benchmark now supports multiple AI code generation systems:

- **Claude Code** (default): Uses the `claude` CLI tool
- **Gemini**: Uses Google Gemini API (requires `GOOGLE_API_KEY` environment variable)

To configure codexes, edit `config/codexes.yml`:

```yaml
codexes:
  claude:
    enabled: true
    # ...
  gemini:
    enabled: true  # Change to true to enable
    config:
      api_key: "${GOOGLE_API_KEY}"  # Or set directly
```

Run with a specific codex:

```bash
ruby benchmark.rb --codex claude --lang python
ruby benchmark.rb --codex gemini --lang python
```

Adding new codexes is straightforward — create an adapter in `lib/codexes/` implementing the `BaseCodex` interface.

See **[CODEX_COMPARISON.md](./CODEX_COMPARISON.md)** for detailed comparison of different AI coding assistants.

### Repository Structure

```
.
├── benchmark.rb              # Main benchmark runner
├── report.rb                 # Report generator
├── plot.py                   # Graph generator
├── problems/
│   └── minigit/
│       ├── problem.json      # Problem-specific prompt + asset config
│       ├── SPEC-v1.txt       # MiniGit v1 specification
│       ├── SPEC-v2.txt       # MiniGit v2 specification
│       ├── test-v1.sh        # v1 test suite
│       └── test-v2.sh        # v2 test suite
├── lib/
│   ├── codexes/
│   │   ├── base_codex.rb    # Abstract base class
│   │   ├── claude_codex.rb  # Claude Code adapter
│   │   └── gemini_codex.rb  # Gemini adapter
│   └── codex_loader.rb      # Configuration loader
├── config/
│   └── codexes.yml          # Codex configuration
├── artifacts/               # Namespaced outputs: <codex>/<problem>/...
│   └── gemini/
│       └── minigit/
│           ├── generated/
│           ├── logs/
│           ├── results/
│           └── figures/
├── scripts/                 # Helper scripts for namespaced benchmark/report/figures
├── QUICK_START.md          # Quick start guide
├── ROADMAP.md              # Multi-codex roadmap
└── CODEX_COMPARISON.md     # Detailed codex comparison
```

**Branches:**
- **`main` branch**: Benchmark tools, specs, tests, results, and figures
- **`data` branch** (orphan): Generated source code and logs for verification

## Summary

At least for prototyping-scale tasks, Ruby, Python, and JavaScript (not TypeScript) appear to be the best fit for Claude Code.

Static typing may become advantageous at larger scales — someone should test this.

The classic strategy — start with a dynamic language, then migrate to a static one as the project matures — may still be the right call. Coding agents seem very capable at cross-language migration (needs verification), making this an increasingly realistic option.

## Notes

- Evaluated in March 2026. Given the pace of AI progress, results may look different in a few months.
- This experiment was supported by [the Claude for Open Source Program](https://www.anthropic.com/open-source-program). Thanks Anthropic for 6 months of free Claude Max 20x!
