#!/bin/bash

# miniscoreboard v2 test script (Includes V1 + V2 capabilities)

rm -rf .miniscore

# --- V1 COMMAND TESTS ---

# Test 1: Init Command
INIT_OUT=$(python3 miniscore.py init)
if [[ "$INIT_OUT" != *"Initialized"* ]]; then
    echo "FAIL: Init command did not work."
    exit 1
fi

# Test 2: Add Match Command
ADD_OUT=$(python3 miniscore.py add-match SuperLig W1 2026-04-01 Galatasaray 2 Fenerbahce 1)
if [[ "$ADD_OUT" != *"Added match #1"* ]]; then
    echo "FAIL: Add match command did not work correctly."
    exit 1
fi

# Test 3: Validation (Clone Match)
CLONE_OUT=$(python3 miniscore.py add-match SuperLig W1 2026-04-01 GS 2 GS 1)
if [[ "$CLONE_OUT" != *"Error"* ]]; then
    echo "FAIL: Security validation failed for clone teams."
    exit 1
fi

# --- V2 COMMAND TESTS ---

# Add more data for V2 filtering tests
python3 miniscore.py add-match SuperLig W2 2026-04-07 BJK 3 TS 0 > /dev/null

# Test 4: History Command
HIST_OUT=$(python3 miniscore.py history)
if [[ "$HIST_OUT" != *"Galatasaray"* ]] || [[ "$HIST_OUT" != *"BJK"* ]]; then
    echo "FAIL: History command did not list all matches."
    exit 1
fi

# Test 5: Team Filter Command
TEAM_OUT=$(python3 miniscore.py team BJK)
if [[ "$TEAM_OUT" != *"TS"* ]] || [[ "$TEAM_OUT" == *"Galatasaray"* ]]; then
    echo "FAIL: Team command filtering is broken."
    exit 1
fi

echo "All V1 and V2 tests passed."
exit 0