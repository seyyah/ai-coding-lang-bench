# Multi-Codex Support Roadmap

This document tracks the implementation status and plans for supporting various AI coding assistants in the benchmark.

## Current Status

### ✅ Implemented

| Codex | Provider | Type | Status | Notes |
|-------|----------|------|--------|-------|
| **Claude Code** | Anthropic | CLI | ✅ Complete | Default codex, full integration with Opus/Sonnet models |
| **Gemini** | Google | API | ✅ Complete | Gemini 3.1 Flash-Lite/Pro, 1M context, free tier: 1000 req/day |
| **OpenAI Codex** | OpenAI | API | ✅ Complete | Responses API adapter with configurable model, headers, and cost accounting |

## Planned Implementations

### High Priority (Cloud APIs)

| Codex | Provider | Type | Priority | Notes |
|-------|----------|------|----------|-------|
| **DeepSeek** | DeepSeek | API | 🔴 High | V3.2 (685B), R1 (671B), cheapest powerful model $0.27/1M token |
| **Qwen Code** | Alibaba | API | 🟡 Medium | Qwen 3 Coder (480B), Qwen 3.5 (397B), SWE-Bench Pro 38.7% |

### Medium Priority (Open Source CLI Tools)

| Tool | Maintainer | Models Supported | Priority | Notes |
|------|-----------|------------------|----------|-------|
| **Aider** | Open Source | 75+ models | 🟡 Medium | Claude, GPT, DeepSeek, Ollama support |
| **Cline** | Open Source | Multiple | 🟡 Medium | VS Code + CLI + JetBrains, 4M+ installations |
| **Goose** | Block/Square | Multiple | 🟡 Medium | Autonomous agent, MCP support |
| **OpenCode** | Open Source | 75+ providers | 🟢 Low | Multi-session, local model support |
| **Plandex** | Open Source | Multiple | 🟢 Low | Multi-step planning, branch/version management |
| **Kilo Code** | Open Source | 500+ models | 🟢 Low | CLI + IDE, 1.5M+ users |
| **Crush** | Open Source | Multiple | 🟢 Low | TUI-based, configurable |
| **Forge Code** | Open Source | Multiple | 🟢 Low | Agentic CLI, multi-file editing |
| **Droid** | Factory | Claude + OpenAI | 🟢 Low | Free trial available |

### Open Source Models (Self-Hosted/API)

#### Chinese Models (Leading in Coding Benchmarks)

| Model | Provider | Size | SWE-Bench Score | License | Priority |
|-------|----------|------|-----------------|---------|----------|
| **Qwen 3 Coder** | Alibaba | 480B | Pro: 38.7% | Open Source | 🟡 Medium |
| **Qwen 3.5** | Alibaba | 397B | Verified: 76.4% | Open Source | 🟡 Medium |
| **DeepSeek V3.2** | DeepSeek | 685B | - | Open Source | 🔴 High |
| **DeepSeek R1** | DeepSeek | 671B | - (reasoning) | Open Source | 🟡 Medium |
| **GLM-4.7 Thinking** | Zhipu AI | 355B | LiveCodeBench: 89% | MIT | 🟡 Medium |
| **Kimi K2.5 Thinking** | Moonshot AI | - | 83.1% | Open Source | 🟢 Low |
| **MiniMax M2.5** | MiniMax | - | - (thinking) | Open Source | 🟢 Low |
| **Step-3.5-Flash** | StepFun | 196B | - | Open Source | 🟢 Low |

#### Western Models

| Model | Provider | Size | SWE-Bench Score | License | Priority |
|-------|----------|------|-----------------|---------|----------|
| **Grok 3** | xAI | 314B | 79.4% | Open Weight | 🟡 Medium |
| **GPT-oss 120B** | OpenAI | 120B | - | MIT | 🟡 Medium |
| **Llama 4 Maverick** | Meta | 400B | - | Open Source | 🟡 Medium |
| **Mistral Large 3** | Mistral | 675B | - | Open Weight | 🟢 Low |
| **Devstral 2** | Mistral | 123B | - (code-focused) | Open Source | 🟢 Low |

#### Cloud-Only Models

| Model | Provider | Context | Cost | Priority | Notes |
|-------|----------|---------|------|----------|-------|
| **Gemini 3 Pro** | Google | 1M | - | 🟡 Medium | SWE-Bench Pro: 43.3% |
| **Gemini 2.5 Flash** | Google | - | $0.003 | 🟡 Medium | Cheapest cloud, 97.1% quality |

## Implementation Priority Ranking

### Phase 1: Major Cloud APIs (Q2 2026)
1. ✅ Claude Code (Complete)
2. ✅ Gemini (Complete)
3. ✅ OpenAI (Responses API)
4. 🔴 DeepSeek (V3.2, R1)

### Phase 2: High-Performance Models (Q3 2026)
5. 🟡 Qwen 3.5 (SWE-Bench leader)
6. 🟡 Grok 3 (Open weight)
7. 🟡 GLM-4.7 Thinking (LiveCodeBench leader)

### Phase 3: Popular CLI Tools (Q4 2026)
8. 🟡 Aider (75+ model support)
9. 🟡 Cline (4M+ users)
10. 🟡 Goose (MCP support)

### Phase 4: Meta-Analysis (2027)
11. Multi-codex comparison reports
12. Cost-performance analysis
13. Language-specific codex recommendations

## Technical Implementation Notes

### Adapter Requirements

Each codex adapter must implement:

```ruby
class YourCodex < BaseCodex
  def run_generation(prompt, dir:, log_path: nil)
    # Generate code
  end

  def version
    # Return version string
  end

  def parse_metrics(raw_output)
    # Extract tokens, cost, etc. (optional)
  end
end
```

### Configuration Template

```yaml
your_codex:
  enabled: false
  class: YourCodex
  config:
    api_key: "${YOUR_API_KEY}"
    model: "model-name"
    # ... other config
```

## Model Categorization

### By Deployment Type
- **Cloud API**: Gemini, Claude, OpenAI, DeepSeek API
- **Self-Hosted**: Qwen, Llama, Mistral (via Ollama/vLLM)
- **CLI Tool**: Aider, Cline, Goose (wrap other models)

### By License
- **Open Source**: Qwen, DeepSeek, GLM, Llama
- **Open Weight**: Grok, Mistral
- **Proprietary**: Claude, GPT, Gemini

### By Specialization
- **Reasoning**: DeepSeek R1, GLM-4.7 Thinking, MiniMax M2.5
- **Code-Focused**: Qwen Coder, Devstral, Codex
- **General + Code**: GPT-4o, Claude Opus, Gemini Pro

## Benchmark Metrics

For each codex, we measure:
- ⏱️ **Generation Time** (v1 + v2, seconds)
- 💰 **Cost** (USD per task)
- 📏 **Lines of Code** (generated)
- ✅ **Test Pass Rate** (%)
- 🎯 **Token Efficiency** (output tokens / test passed)

## Contributing

To add a new codex:

1. Create adapter: `lib/codexes/your_codex.rb`
2. Add config: `config/codexes.yml`
3. Test: `ruby benchmark.rb --codex your_codex --lang python --trials 1 --dry-run`
4. Submit PR with:
   - Adapter implementation
   - Configuration template
   - Documentation update
   - At least 1 successful test run

## References

### Benchmark Sources
- **SWE-Bench**: https://www.swebench.com/
- **LiveCodeBench**: https://livecodebench.github.io/
- **HumanEval**: https://github.com/openai/human-eval

### Model Documentation
- **Claude Code**: https://docs.anthropic.com/en/docs/claude-code
- **Gemini**: https://ai.google.dev/
- **OpenAI**: https://platform.openai.com/docs
- **DeepSeek**: https://www.deepseek.com/
- **Qwen**: https://github.com/QwenLM/Qwen
- **Aider**: https://aider.chat/
- **Cline**: https://github.com/cline/cline

## Notes

- Evaluated as of March 2026
- Benchmark focuses on **code generation quality** for full implementations
- Different from HumanEval (single function) or SWE-Bench (bug fixing)
- Tests **iterative development** capability (v1 → v2 extension)
- Language-agnostic comparison (same task, different languages)

---

**Last Updated**: 2026-03-15
**Maintained By**: Community Contributors
