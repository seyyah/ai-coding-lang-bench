# Walkthrough - V3 Implementation Details

This document provides a technical overview of the changes introduced in the V3 upgrade of `miniscoreboard`.

## Technical Achievements

### 1. Advanced Leaderboard Logic
The core challenge of V3 was the `leaderboard` command. It requires a stable sorting mechanism to handle league standings correctly.
- **Sorting Priority:** The implementation uses a descending sort on Points, followed by Goal Difference (GD), then Goals For (GF). 
- **Tie-Breaking:** To ensure determinism (a key project requirement), if all stats are equal, the system falls back to an alphabetical sort by Team Name.
- **Implementation:** Leveraged Python's `sorted()` with a multi-key lambda function for efficiency.

### 2. Statistical Analytics (Summary)
The `summary` command provides a snapshot of the league's health.
- It dynamically calculates the number of unique teams and total goals.
- It formats the average goals per match to exactly **2 decimal places**, ensuring compliance with the `SPEC-v3.txt` requirements.

### 3. Data Portability (Export)
The `export` feature bridge the gap between human-readable `.dat` files and machine-readable `.json` formats.
- All match data is serialized into a structured JSON array.
- The output is stored in `.miniscore/matches.json`, facilitating easy import into web dashboards or spreadsheets.

## Verification & Testing
The implementation was rigorously tested using the `test-v3.sh` suite.
- **Test Results:** 7/7 Tests Passed.
- **Edge Cases Handled:**
    - Requesting a leaderboard with an empty history prints a user-friendly error.
    - Handling ties in the leaderboard shows consistent ranking orders.
    - JSON export overwrites previous exports to keep data fresh.

## Project Context
Following the **Vibe Coding** philosophy, the architecture focuses on system-level reliability and clean documentation, allowing AI agents and human contributors to understand the codebase instantly.
