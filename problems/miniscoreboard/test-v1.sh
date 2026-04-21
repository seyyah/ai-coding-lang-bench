#!/bin/bash

# miniscoreboard v1 test script

rm -rf .miniscore

# Test 1: Init Command
INIT_OUT=$(python3 miniscore.py init)
if [[ "$INIT_OUT" != *"Initialized"* ]]; then
    echo "FAIL: Init command did not work."
    exit 1
fi

# Test 2: Add Match Command
ADD_OUT=$(python3 miniscore.py add-match SuperLig W1 2026-03-31 Galatasaray 2 Fenerbahce 1)
if [[ "$ADD_OUT" != *"Added match #1"* ]]; then
    echo "FAIL: Add match command did not work correctly."
    exit 1
fi

# Test 3: Validation (Clone Match)
CLONE_OUT=$(python3 miniscore.py add-match SuperLig W1 2026-03-31 GS 2 GS 1)
if [[ "$CLONE_OUT" != *"Error"* ]]; then
    echo "FAIL: Security validation failed for clone teams."
    exit 1
fi

echo "All V1 tests passed."
exit 0
