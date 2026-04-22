#!/bin/bash
set -e

rm -rf .miniscore

# --- SETUP ---
python3 miniscore.py init

python3 miniscore.py add-match SuperLig W1 2026-04-01 GS 2 FB 1 > /dev/null
python3 miniscore.py add-match SuperLig W2 2026-04-07 BJK 3 TS 0 > /dev/null
python3 miniscore.py add-match SuperLig W3 2026-04-10 FB 1 BJK 1 > /dev/null

# --- V1 TESTS ---
ADD_CHECK=$(python3 miniscore.py add-match SuperLig W4 2026-04-11 TS 2 GS 0)
echo "$ADD_CHECK" | grep "Added match #4" >/dev/null || exit 1

# --- V2 TESTS ---

# History
HIST=$(python3 miniscore.py history)
echo "$HIST" | grep "GS" >/dev/null || exit 1
echo "$HIST" | grep "BJK" >/dev/null || exit 1

# Team filter
TEAM=$(python3 miniscore.py team BJK)
echo "$TEAM" | grep "TS" >/dev/null || exit 1

# Validation
INVALID=$(python3 miniscore.py add-match SuperLig W5 2026-04-12 GS 2 GS 1)
echo "$INVALID" | grep "Error" >/dev/null || exit 1

# --- ADVANCED ---

# Leaderboard
LB=$(python3 miniscore.py leaderboard)
echo "$LB" | grep "\[1\]" >/dev/null || exit 1

# Summary
SUM=$(python3 miniscore.py summary)
echo "$SUM" | grep "Total Matches" >/dev/null || exit 1

# Export
EXP=$(python3 miniscore.py export)
echo "$EXP" | grep "Exported" >/dev/null || exit 1

# File check
[ -f ".miniscore/matches.json" ] || exit 1

echo "All V1 + V2 (enhanced) tests passed"
exit 0