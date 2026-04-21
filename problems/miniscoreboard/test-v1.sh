#!/bin/bash

rm -rf .miniscore

# Test 1: Init
INIT_OUT=$(python3 miniscore.py init)
echo "$INIT_OUT" | grep -E "Initialized|Created" || exit 1

# Test 2: Add Match
ADD_OUT=$(python3 miniscore.py add-match SuperLig W1 2026-03-31 GS 2 FB 1)
echo "$ADD_OUT" | grep "Added match #1" || exit 1

# Test 3: Validation (same team)
CLONE_OUT=$(python3 miniscore.py add-match SuperLig W1 2026-03-31 GS 2 GS 1)
echo "$CLONE_OUT" | grep "Error" || exit 1

echo "All V1 tests passed"
exit 0