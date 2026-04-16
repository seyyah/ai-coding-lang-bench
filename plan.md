# Iteration Plan

> Living document. Updated by human + AI contributors at the end of each session.
> See [AGENT.md](./AGENT.md) for update protocol.

**Last updated**: 2026-03-28
**Current phase**: Phase 1 — Major Cloud APIs + Framework Stabilization

---

## Active experiments

| # | Task | Status | Owner | Notes |
|---|------|--------|-------|-------|
| 1 | Groq adapter validation (3+ trials, multi-language) | [ ] | — | Adapter exists, needs systematic benchmark data |
| 2 | Aider adapter validation (end-to-end test) | [ ] | — | Adapter exists (`aider_codex.rb`), needs testing |
| 3 | MiniGrades problem validation | [ ] | — | Problem dir exists, needs benchmark runs |

## Backlog

### Phase 1: Major Cloud APIs (current)

- [ ] DeepSeek V3.2 adapter — 685B, **$0.27/1M tokens** (cheapest powerful model)
- [ ] DeepSeek R1 adapter — 671B, reasoning model
- [ ] Cross-codex comparison report (Claude vs Gemini vs OpenAI vs Groq on minigit/python)

### Phase 2: High-Performance Models

- [ ] Qwen 3.5 adapter — 397B, **SWE-Bench Verified: 76.4%** (leader)
- [ ] Qwen 3 Coder adapter — 480B, SWE-Bench Pro: 38.7%
- [ ] Grok 3 adapter — 314B, SWE-Bench: 79.4%, open weight
- [ ] GLM-4.7 Thinking adapter — 355B, LiveCodeBench: 89%, MIT license
- [ ] Gemini 2.5 Flash — $0.003, 97.1% quality

### Phase 3: Popular CLI Tools

- [ ] Cline CLI adapter — VS Code + CLI + JetBrains, 4M+ users
- [ ] Goose adapter — Block/Square, MCP support
- [ ] OpenCode adapter — 75+ providers
- [ ] Plandex adapter — multi-step planning

### Phase 4: Self-Hosted & Meta-Analysis

- [ ] Self-hosted model support (Ollama/vLLM) — Llama 4 Maverick, Mistral Large 3, Devstral 2
- [ ] Multi-codex comparison reports
- [ ] Cost-performance analysis script
- [ ] Language-specific codex recommendation engine

### Other

- [ ] Add mini-playlist problem (listed in README but missing from problems/)
- [ ] Fix README.md broken markdown (unclosed code block in Installation section)
- [ ] Multi-codex ensemble experiments
- [ ] Add `config/languages.local.yml` override support documentation for end-users

## Open questions

1. Is the two-phase (v1 → v2) model sufficient, or do we need v3+ for complex problems?
2. How to handle rate limiting across codex APIs in large benchmark runs?

## Benchmark metrics (per codex)

- ⏱️ **Generation Time** (v1 + v2, seconds)
- 💰 **Cost** (USD per task)
- 📏 **Lines of Code** (generated)
- ✅ **Test Pass Rate** (%)
- 🎯 **Token Efficiency** (output tokens / test passed)

## Completed

- [x] Claude Code adapter (original implementation)
- [x] Gemini adapter (API integration, Flash-Lite/Pro)
- [x] OpenAI adapter (Responses API, cost accounting)
- [x] Groq adapter (API adapter, robust parsing)
- [x] Aider adapter (code exists, needs validation)
- [x] MiniGit problem (canonical, well-tested)
- [x] MiniGrades problem (exists in problems/)
- [x] Multi-codex architecture refactor
- [x] Documentation infrastructure (program.md, AGENT.md, plan.md, walkthrough.md)
- [x] DRY consolidation (merged ROADMAP, INDEX, QUICK_START, CODEX_COMPARISON)
- [x] Clean Architecture refactor: `src/` migration, `bin/which-language` unified CLI, `config/languages.yml` extraction, bash scripts removed

## References

- [SWE-Bench](https://www.swebench.com/)
- [LiveCodeBench](https://livecodebench.github.io/)
- [AutoCodeBench](https://autocodebench.github.io/)

