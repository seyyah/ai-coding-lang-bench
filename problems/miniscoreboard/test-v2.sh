#!/bin/bash

# miniscoreboard v2 test script

rm -rf .miniscore
python3 miniscore.py init > /dev/null
python3 miniscore.py add-match SuperLig W1 2026-03-31 GS 2 FB 1 > /dev/null
python3 miniscore.py add-match SuperLig W2 2026-04-07 BJK 3 TS 0 > /dev/null

# Test 1: History Command
HIST_OUT=$(python3 miniscore.py history)
if [[ "$HIST_OUT" != *"GS"* ]] || [[ "$HIST_OUT" != *"BJK"* ]]; then
    echo "FAIL: History command did not list all matches."
    exit 1
fi

# Test 2: Team Filter Command
TEAM_OUT=$(python3 miniscore.py team BJK)
if [[ "$TEAM_OUT" != *"TS"* ]] || [[ "$TEAM_OUT" == *"GS"* ]]; then
    echo "FAIL: Team command filtering is broken."
    exit 1
fi

echo "All V2 tests passed."
exit 0
