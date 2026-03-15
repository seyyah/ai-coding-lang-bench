# Documentation Index

Quick navigation for the AI Coding Language Benchmark project.

## 🚀 Getting Started

**New here? Start with:**
1. 📖 [README.md](./README.md) - Project overview and results
2. ⚡ [QUICK_START.md](./QUICK_START.md) - Setup and first run (5 minutes)

## 📚 Main Documentation

### For Users

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **[README.md](./README.md)** | Overview, results, motivation | First time visiting |
| **[QUICK_START.md](./QUICK_START.md)** | Setup instructions, examples | Before running benchmark |
| **[ROADMAP.md](./ROADMAP.md)** | Planned features, 20+ codexes | Curious about future |
| **[CODEX_COMPARISON.md](./CODEX_COMPARISON.md)** | Detailed codex specs | Choosing a codex |

### For Developers

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **[CLAUDE.md](./CLAUDE.md)** | Technical architecture | Understanding internals |
| **[config/codexes.yml](./config/codexes.yml)** | Configuration examples | Adding/configuring codexes |
| **[lib/codexes/base_codex.rb](./lib/codexes/base_codex.rb)** | Adapter interface | Implementing new codex |

## 📊 Current Status

### ✅ Implemented Codexes
- **Claude Code** (Anthropic) - CLI integration
- **Gemini** (Google) - API integration

### 🚧 High Priority (Next)
- **OpenAI** (GPT-4o, o3, o4-mini)
- **DeepSeek** (V3.2, R1) - Cheapest powerful model
- **Qwen** (3.5 Coder) - SWE-Bench leader

### 📋 Full Roadmap
See [ROADMAP.md](./ROADMAP.md) for 20+ planned integrations.

## 🎯 Common Tasks

### Running Benchmarks

```bash
# Quick test (Python, 1 trial, Claude)
ruby benchmark.rb --lang python --trials 1

# Compare codexes (requires Gemini setup)
ruby benchmark.rb --codex claude --lang python
ruby benchmark.rb --codex gemini --lang python

# Full benchmark (all languages, 3 trials)
ruby benchmark.rb

# See all options
ruby benchmark.rb --help
```

**More examples**: [QUICK_START.md](./QUICK_START.md#examples)

### Configuration

```bash
# View current config
cat config/codexes.yml

# Create local override (gitignored)
cp config/codexes.yml config/codexes.local.yml
# Edit config/codexes.local.yml

# Set API keys
export GOOGLE_API_KEY="your-key"
# Or add to config/codexes.local.yml
```

**Configuration guide**: [QUICK_START.md](./QUICK_START.md#configure-ai-codexes)

### Adding a New Codex

1. Read: [CODEX_COMPARISON.md](./CODEX_COMPARISON.md#integration-checklist)
2. Create: `lib/codexes/your_codex.rb` (extend `BaseCodex`)
3. Configure: Add to `config/codexes.yml`
4. Test: `ruby benchmark.rb --codex your_codex --dry-run`

**Architecture details**: [CLAUDE.md](./CLAUDE.md#multi-codex-architecture)

## 📖 Documentation by Topic

### Understanding the Benchmark

- **What it does**: [README.md](./README.md#experiment)
- **Why it matters**: [README.md](./README.md#motivation)
- **How it works**: [CLAUDE.md](./CLAUDE.md#how-it-works)
- **MiniGit spec**: [problems/minigit/SPEC-v1.txt](./problems/minigit/SPEC-v1.txt), [problems/minigit/SPEC-v2.txt](./problems/minigit/SPEC-v2.txt)

### Supported Languages

- **Full list**: [CLAUDE.md](./CLAUDE.md#supported-languages-languages-hash-in-benchmarkrb)
- **Categories**: Dynamic, Static, Functional, Type-checked
- **Adding languages**: Edit `LANGUAGES` hash in [benchmark.rb](./benchmark.rb)

### AI Codexes

- **Comparison table**: [CODEX_COMPARISON.md](./CODEX_COMPARISON.md#quick-comparison)
- **Cost analysis**: [CODEX_COMPARISON.md](./CODEX_COMPARISON.md#1-cost-efficiency)
- **Speed analysis**: [CODEX_COMPARISON.md](./CODEX_COMPARISON.md#2-speed)
- **Quality metrics**: [CODEX_COMPARISON.md](./CODEX_COMPARISON.md#3-quality-test-pass-rate)

### Results & Analysis

- **Original results**: [README.md](./README.md#results)
- **Discussion**: [README.md](./README.md#discussion)
- **Generated reports**: `artifacts/<codex>/<problem>/results/report.md` (after running)
- **Raw data**: `artifacts/<codex>/<problem>/results/results.json` (after running)

## 🗂️ File Structure

```
.
├── README.md                 # 👈 Start here
├── QUICK_START.md           # 👈 Then read this
├── ROADMAP.md               # Future plans
├── CODEX_COMPARISON.md      # Codex details
├── CLAUDE.md                # Technical docs
├── INDEX.md                 # This file
│
├── benchmark.rb             # Main runner
├── report.rb                # Report generator
├── plot.py                  # Graph generator
│
├── problems/
│   └── minigit/
│       ├── problem.json    # Problem-specific asset config
│       ├── SPEC-v1.txt     # MiniGit v1 spec
│       ├── SPEC-v2.txt     # MiniGit v2 spec
│       ├── test-v1.sh      # v1 tests
│       └── test-v2.sh      # v2 tests
│
├── lib/                    # Core library
│   ├── codexes/           # Codex adapters
│   │   ├── base_codex.rb
│   │   ├── claude_codex.rb
│   │   └── gemini_codex.rb
│   └── codex_loader.rb
│
├── config/                 # Configuration
│   ├── codexes.yml        # Main config
│   └── codexes.local.yml  # Local override (gitignored)
│
├── artifacts/             # Namespaced output roots
│   └── <codex>/<problem>/
│       ├── generated/
│       ├── logs/
│       ├── results/
│       └── figures/
```

## ❓ FAQ

### How do I...

**...run my first benchmark?**
→ [QUICK_START.md](./QUICK_START.md#quick-test-1-trial-1-language)

**...use Gemini instead of Claude?**
→ [QUICK_START.md](./QUICK_START.md#option-b-using-google-gemini)

**...compare multiple codexes?**
→ [QUICK_START.md](./QUICK_START.md#compare-codexes)

**...add a new language?**
→ Edit `LANGUAGES` hash in [benchmark.rb](./benchmark.rb#L19)

**...add a new codex?**
→ [CODEX_COMPARISON.md](./CODEX_COMPARISON.md#integration-checklist)

**...understand the results?**
→ [README.md](./README.md#results) and [CODEX_COMPARISON.md](./CODEX_COMPARISON.md#benchmark-methodology)

### Why...

**...does Gemini require an API key but Claude doesn't?**
→ Claude Code uses a CLI tool (local auth), Gemini uses a cloud API

**...are some languages faster/cheaper than others?**
→ [README.md](./README.md#what-causes-the-speedcost-differences)

**...is DeepSeek a high priority?**
→ It's **50-100x cheaper** than Claude/GPT with comparable quality

**...focus on MiniGit?**
→ It's a non-trivial, real-world task that tests full implementation ability (not just single functions)

## 🔗 External Links

- **Claude Code**: https://docs.anthropic.com/en/docs/claude-code
- **Gemini**: https://ai.google.dev/
- **Original Blog Post**: https://dev.to/mame/which-programming-language-is-best-for-claude-code-508a
- **Japanese Version**: https://zenn.dev/mametter/articles/3e8580ec034201

## 🤝 Contributing

We welcome:
- **New codex adapters** (see [CODEX_COMPARISON.md](./CODEX_COMPARISON.md#integration-checklist))
- **Benchmark results** (run and submit data)
- **Bug reports** (via issues)
- **Documentation improvements** (this index, for example!)

## 📝 License & Attribution

- Original benchmark by @mame (https://github.com/mame/claude-code-bench)
- Multi-codex support added 2026-03
- See individual files for specific attributions

---

**Last Updated**: 2026-03-15

**Quick Links**:
- New User → [QUICK_START.md](./QUICK_START.md)
- Developer → [CLAUDE.md](./CLAUDE.md)
- Researcher → [CODEX_COMPARISON.md](./CODEX_COMPARISON.md)
- Curious → [ROADMAP.md](./ROADMAP.md)
