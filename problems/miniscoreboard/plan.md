# Development Plan - miniscoreboard

This document outlines the evolutionary steps of the miniscoreboard project, focusing on a structured progression from basic data entry to advanced analytics.

## Phase 1: Core Foundation (V1) - [DONE]
- [x] Establish project directory structure (.miniscore/).
- [x] Implement `init` command for environment setup.
- [x] Implement `add-match` for atomic data entry.
- [x] Ensure basic file I/O operations for `matches.dat`.

## Phase 2: Data Retrieval (V2) - [DONE]
- [x] Implement `history` command to list all matches.
- [x] Implement `team` command for filtered search.
- [x] Enforce stable formatting for CLI output.

## Phase 3: Analytics & Portability (V3) - [CURRENT]
- [x] **Leaderboard System:** Develop a multi-tier sorting algorithm (Points > GD > GF > Alphabetical).
- [x] **League Summary:** Global calculation of match count, team count, and scoring averages.
- [x] **Data Export:** Build a JSON serializer to allow third-party tool integration.
- [x] **Deterministic Testing:** Ensure `test-v3.sh` yields 100% consistent results.
