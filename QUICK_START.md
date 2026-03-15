# Quick Start Guide

## Multi-Codex AI Coding Language Benchmark

This benchmark tests different AI coding assistants on the same task across multiple programming languages.

## Prerequisites

1. **Ruby** (for running the benchmark)
2. **Target language toolchains** (for the languages you want to test)
3. **AI Codex** (at least one):
   - Claude Code CLI (`claude`)
   - Google Gemini API key

## Setup

### 1. Clone the repository

```bash
cd /home/seyyah/works/engiz/ai-coding-lang-bench
```

### 2. Configure AI Codexes

#### Option A: Using Claude Code (Default)

Install Claude Code CLI:
```bash
# Follow instructions at https://docs.anthropic.com/en/docs/claude-code
```

Claude is enabled by default, no additional configuration needed.

#### Option B: Using Google Gemini

1. Get an API key from https://ai.google.dev/
2. Set the environment variable:
   ```bash
   export GOOGLE_API_KEY="your-api-key-here"
   ```
3. Enable Gemini in `config/codexes.yml`:
   ```yaml
   gemini:
     enabled: true  # Change from false to true
   ```

#### Option C: Using Both (Local Config)

Create `config/codexes.local.yml`:
```yaml
codexes:
  gemini:
    enabled: true
    config:
      api_key: "your-actual-api-key"
```

This file is gitignored and won't be committed.

## Running the Benchmark

### Quick Test (1 trial, 1 language)

```bash
# Claude
ruby benchmark.rb --lang python --trials 1

# Gemini
ruby benchmark.rb --codex gemini --lang python --trials 1
```

### Full Benchmark (Default: 3 trials, all languages)

```bash
ruby benchmark.rb
```

### Compare Multiple Languages

```bash
ruby benchmark.rb --lang python,ruby,javascript --trials 5
```

### Compare Codexes

```bash
# Run Claude
ruby benchmark.rb --codex claude --lang python --trials 3

# Run Gemini
ruby benchmark.rb --codex gemini --lang python --trials 3
```

### Dry Run (Test without actually running AI)

```bash
ruby benchmark.rb --dry-run --lang python
```

## Understanding Results

After running with the helper scripts, outputs are saved under:
- `artifacts/<codex>/<problem>/results/results.json` - Raw data
- `artifacts/<codex>/<problem>/results/meta.json` - Metadata (codex version, timestamps, etc.)
- `artifacts/<codex>/<problem>/logs/` - Detailed logs from each trial

Generate reports:
```bash
bash scripts/generate-report.sh gemini minigit
bash scripts/generate-figures.sh gemini minigit
```

## Available Options

```bash
ruby benchmark.rb --help
```

- `--lang, -l LANGS` - Comma-separated languages (e.g., `python,ruby,go`)
- `--trials, -t NUM` - Number of trials per language
- `--start, -s NUM` - Starting trial number (for continuation)
- `--codex, -c NAME` - AI codex to use (`claude`, `gemini`)
- `--dry-run` - Test run without executing AI
- `--help, -h` - Show help

## Supported Languages

- **Dynamic**: python, ruby, javascript, perl, lua
- **Static**: typescript, go, rust, c, java
- **Functional**: scheme, ocaml, haskell
- **With Type Checkers**: python/mypy, ruby/steep

## Troubleshooting

### "Codex 'gemini' is not enabled"
Enable Gemini in `config/codexes.yml` or create `config/codexes.local.yml`.

### "GOOGLE_API_KEY not configured"
Set the environment variable:
```bash
export GOOGLE_API_KEY="your-key"
```

### Tests fail
Ensure the target language toolchain is installed:
```bash
python3 --version
ruby --version
node --version
# etc.
```

## Adding a New Codex

1. Create `lib/codexes/my_codex.rb` extending `BaseCodex`
2. Implement required methods:
   - `run_generation(prompt, dir:, log_path:)`
   - `version`
   - `parse_metrics(raw_output)` (optional)
3. Add to `config/codexes.yml`:
   ```yaml
   my_codex:
     enabled: true
     class: MyCodex
     config:
       api_key: "${MY_API_KEY}"
   ```
4. Run: `ruby benchmark.rb --codex my_codex`

## Examples

```bash
# Compare Python vs Ruby with Claude
ruby benchmark.rb --lang python,ruby --trials 10

# Compare Claude vs Gemini on Python
ruby benchmark.rb --codex claude --lang python --trials 5
ruby benchmark.rb --codex gemini --lang python --trials 5

# Test static vs dynamic languages
ruby benchmark.rb --lang python,typescript --trials 5

# Run subset of languages (4-15)
ruby benchmark.rb --trials 12 --start 4
```

## Next Steps

- Check `CLAUDE.md` for detailed technical documentation
- See `README.md` for benchmark results and analysis
- Explore `lib/codexes/` to see adapter implementations
