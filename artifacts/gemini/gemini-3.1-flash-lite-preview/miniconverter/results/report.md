# AI Coding Language Benchmark Report

## Environment
- Date: 2026-04-16 21:53:40
- Codex filter: gemini
- Problem: miniconverter
- Codex version: gemini-3.1-flash-lite-preview
- Trials per language: 1
- Records in report: 1

## Language Versions
| Language | Version |
|----------|---------|
| Python | Python 3.14.4 |

## Results Summary
| Language | v1 Time | v1 Turns | v1 LOC | v1 Tests | v2 Time | v2 Turns | v2 LOC | v2 Tests | Total Time | Avg Cost | Avg TPS |
|----------|---------|----------|--------|----------|---------|----------|--------|----------|------------|----------|---------|
| Python | 3.1s±0.0s | 0.0 | 41 | 1/1 | 3.8s±0.0s | 0.0 | 36 | 0/1 | 6.9s±0.0s | $0.00 | 249.4 |

## Token Summary
| Language | Avg Input | Avg Output | Avg Cache Create | Avg Cache Read | Avg Total | Avg Cost | Avg TPS |
|----------|-----------|------------|------------------|----------------|-----------|----------|---------|
| Python | 70 | 1,721 | 0 | 0 | 1,791 | $0.0026 | 249.4 |

## Full Results
| Codex | Language | Trial | v1 Time | v1 Turns | v1 LOC | v1 Tests | v2 Time | v2 Turns | v2 LOC | v2 Tests | Total Time | Cost |
|-------|----------|-------|---------|----------|--------|----------|---------|----------|--------|----------|------------|------|
| gemini | Python | 1 | 3.1s | 0 | 41 | 0/0 PASS | 3.8s | 0 | 36 | 0/8 FAIL | 6.9s | $0.00 |

## Full Tokens
| Codex | Language | Trial | Phase | Input | Output | Cache Create | Cache Read | Total | Cost USD | TPS |
|-------|----------|-------|-------|-------|--------|--------------|------------|-------|----------|-----|
| gemini | Python | 1 | v1 | 36 | 820 | 0 | 0 | 856 | $0.0012 | 264.5 |
| gemini | Python | 1 | v2 | 34 | 901 | 0 | 0 | 935 | $0.0014 | 237.1 |

