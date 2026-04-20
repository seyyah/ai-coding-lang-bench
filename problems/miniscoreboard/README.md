# 🏆 miniscoreboard Benchmark Problem

A command-line sports match management system designed for benchmarking AI efficiency in data persistence, filtering, and analytical processing.

## 🚀 Version Evolution

### Version 1 (V1)
- **Focus**: Basic Persistence & Shell commands.
- **Commands**: `init`, `add-match`.
- **Infrastructure**: Data stored in `.miniscore/matches.dat` (Pipe-separated format).

### Version 2 (V2)
- **Focus**: Data Retrieval & Filtering.
- **Commands**: `history` (list all), `team <name>` (filter matches for a specific team).
- **Validation**: Added basic error handling for reserved characters and data types.

### Version 3 (V3)
- **Focus**: Analytical Logic & Data Portability.
- **Commands**: 
    - `leaderboard`: Calculates league standings using 3-1-0 point system. Complex sorting (Points > GD > GF).
    - `summary`: High-level league statistics (Average goals, match counts).
    - `export`: Serializes match data into `matches.json`.
- **Determinism**: Added `DETERMINISM RULES` to ensure consistent AI behavior across trials.

---

## 🧪 Running Benchmarks

```bash
# Dry run
bin/which-language run gemini miniscoreboard --lang python --trials 1 --dry-run

# Real trial
bin/which-language run gemini miniscoreboard --lang python --trials 1
```

## 📊 Evaluation Metrics
- **Pass Rate**: Ability to implement complex sorting logic correctly.
- **LOC**: Conciseness in handling file I/O vs processing.
- **Time/Cost**: Efficiency of the generation turns.
