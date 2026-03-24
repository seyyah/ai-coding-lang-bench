# Quick Start

This guide is for getting from **fresh checkout** to **first working benchmark run** with the least confusion.

## Before you begin

You need:

1. **Ruby**
2. the toolchains for the languages you want to run
3. at least one configured codex

Examples:

- Claude Code CLI for `claude`
- a Gemini API key for `gemini`
- an OpenAI API key for `openai`

## Step 1: work from the repository root

Run all commands below from the repository root:

```bash
pwd
```

You should be inside the cloned `ai-coding-lang-bench` directory.

## Step 2: configure a codex

### Recommended pattern: use `config/codexes.local.yml`

Do **not** put secrets or local enablement changes in the shared config if you can avoid it.

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
export GOOGLE_API_KEY="your-api-key"
```

This local file is gitignored.

### Claude Code

`claude` is enabled by default in `config/codexes.yml`, so if the CLI is already installed and authenticated, you can use it immediately.

### Gemini

If Gemini says it is not enabled, create the local override above instead of editing the shared config.

### OpenAI

Use the same local override pattern for `openai`:

```yaml
codexes:
  openai:
    enabled: true
    config:
      api_key: "${OPENAI_API_KEY}"
      model: "gpt-4.1"
```

Then export your key:

```bash
export OPENAI_API_KEY="your-key"
```

## Step 3: run a safe dry-run first

Recommended:

```bash
bash scripts/run-all.sh gemini minigit --dry-run --lang python --trials 1
```

This checks the full pipeline without making a paid API call:

- benchmark orchestration
- problem loading
- namespaced outputs
- report generation
- figure generation

Dry-run artifacts go to:

```text
artifacts/<codex>/<model>/<problem>/dry-run/
```

## Step 4: run your first real benchmark

### Single codex, single problem, single language

```bash
bash scripts/run-all.sh gemini minigit --lang python --trials 1
```

### With Claude

```bash
bash scripts/run-all.sh claude minigit --lang python --trials 1
```

### OpenAI end-to-end example

If you want the full pipeline for OpenAI in one command (benchmark + report + figures):

```bash
bash scripts/run-all.sh openai minigit --lang python --trials 1
```

That helper script runs these stages for you:

1. `benchmark.rb`
2. `report.rb`
3. `plot.py`

If you want to run the same flow step by step, use:

```bash
ruby benchmark.rb --codex openai --problem minigit --lang python --trials 1
ruby report.rb \
  --results artifacts/openai/gpt-4.1/minigit/results/results.json \
  --meta artifacts/openai/gpt-4.1/minigit/results/meta.json \
  --output artifacts/openai/gpt-4.1/minigit/results/report.md
python3 plot.py artifacts/openai/gpt-4.1/minigit/results/results.json
```

For dry-run validation without a paid API call:

```bash
bash scripts/run-all.sh openai minigit --dry-run --lang python --trials 1
```

## Step 5: inspect the outputs

After a real run, the canonical outputs live under:

```text
artifacts/<codex>/<model>/<problem>/
  generated/
  logs/
  results/
  figures/
```

Most useful files:

- `results/results.json` — raw benchmark records
- `results/meta.json` — environment and version metadata
- `results/report.md` — generated markdown report
- `figures/` — PNG graphs

## Common workflows

### Compare two codexes on the same problem/language

```bash
bash scripts/run-all.sh claude minigit --lang python --trials 3
bash scripts/run-all.sh gemini minigit --lang python --trials 3
```

### Compare several languages with one codex

```bash
bash scripts/run-all.sh gemini minigit --lang python,ruby,javascript --trials 3
```

### Continue with later trial numbers

```bash
bash scripts/run-all.sh gemini minigit --lang python --trials 5 --start 6
```

### Use the raw runner directly

```bash
ruby benchmark.rb --codex gemini --problem minigit --lang python --trials 1
```

`benchmark.rb` now defaults to the same namespaced artifact layout as the helper scripts.

## How to choose between helper scripts and raw commands

### Prefer helper scripts when you want

- a clean default path layout
- report generation after the run
- figures after the run

### Prefer raw commands when you want

- tighter control
- custom automation
- to generate only one part of the pipeline

Useful raw commands:

```bash
ruby benchmark.rb --help
ruby report.rb --help
python3 plot.py --help
```

## Supported language groups

- Dynamic: `python`, `ruby`, `javascript`, `perl`, `lua`
- Static: `rust`, `go`, `c`, `typescript`, `java`
- Functional: `scheme`, `ocaml`, `haskell`
- Typed variants: `python/mypy`, `ruby/steep`

## Adding things later

### Add a new problem

Create:

```text
problems/<problem>/
  problem.json
  SPEC-v1.txt
  SPEC-v2.txt
  test-v1.sh
  test-v2.sh
```

### Add a new codex

1. Create an adapter in `lib/codexes/`
2. Extend `BaseCodex`
3. Add config/template entry in `config/codexes.yml`
4. Enable it locally in `config/codexes.local.yml`

### Add a new language

Edit the `LANGUAGES` hash in `benchmark.rb`.

## Troubleshooting

### “Codex 'gemini' is not enabled”

Create or fix `config/codexes.local.yml`.

### “GOOGLE_API_KEY not configured”

Export it before running:

```bash
export GOOGLE_API_KEY="your-key"
```

### “OPENAI_API_KEY not configured”

Export it before running:

```bash
export OPENAI_API_KEY="your-key"
```

### “Unknown language”

Check the exact keys listed in `benchmark.rb --help` or in the `LANGUAGES` hash.

### Tests fail immediately

Check that the target toolchain exists:

```bash
python3 --version
ruby --version
node --version
gcc --version
```

## Where to go next

- Overview and architecture: [README.md](./README.md)
- Documentation map: [INDEX.md](./INDEX.md)
- Technical internals: [CLAUDE.md](./CLAUDE.md)
