#!/usr/bin/env bash
# V3 Test Suite for miniscoreboard

BINARY="./miniscore.py"
DB_DIR=".miniscore"
DB_FILE="$DB_DIR/matches.dat"

# Helper for cleanup
cleanup() {
    rm -rf "$DB_DIR"
}

# Helper for reporting
pass_count=0
fail_count=0

assert_output() {
    local cmd=$1
    local expected=$2
    local name=$3
    
    output=$($cmd 2>&1)
    if [[ "$output" == *"$expected"* ]]; then
        echo "PASS: $name"
        pass_count=$((pass_count + 1))
    else
        echo "FAIL: $name"
        echo "  Expected: $expected"
        echo "  Actual:   $output"
        fail_count=$((fail_count + 1))
    fi
}

cleanup

echo "--- Testing V1 Core ---"
assert_output "python3 $BINARY init" "Created .miniscore/ directory" "Init success"
assert_output "python3 $BINARY init" "Already initialized" "Init idempotency"

echo "--- Testing V1 add-match ---"
python3 $BINARY add-match SuperLig W1 2026-04-01 GS 2 FB 1 > /dev/null
python3 $BINARY add-match SuperLig W1 2026-04-01 BJK 0 TS 0 > /dev/null
assert_output "python3 $BINARY add-match SuperLig W2 2026-04-08 FB 1 BJK 0" "Added match #3" "Add match #3"

echo "--- Testing V2 history & team ---"
assert_output "python3 $BINARY history" "[1] GS 2 - 1 FB" "History check"
assert_output "python3 $BINARY team FB" "GS 2 - 1 FB" "Team filter GS"
assert_output "python3 $BINARY team FB" "FB 1 - 0 BJK" "Team filter FB"

echo "--- Testing V3 leaderboard ---"
# GS: 1W (3pts), 2GF, 1GA, +1
# FB: 1W, 1L (3pts), 2GF, 2GA, 0
# TS: 1D (1pts), 0GF, 0GA, 0
# BJK: 1D, 1L (1pts), 0GF, 1GA, -1
assert_output "python3 $BINARY leaderboard" "[1] GS: 3 pts" "Leaderboard Rank 1"
assert_output "python3 $BINARY leaderboard" "[2] FB: 3 pts" "Leaderboard Rank 2"

echo "--- Testing V3 summary ---"
assert_output "python3 $BINARY summary" "Total Teams: 4" "Summary Teams"
assert_output "python3 $BINARY summary" "Total Matches: 3" "Summary Matches"
assert_output "python3 $BINARY summary" "Total Goals: 4" "Summary Goals"

echo "--- Testing V3 export ---"
assert_output "python3 $BINARY export" "Exported 3 matches" "Export command"
if [ -f "$DB_DIR/matches.json" ]; then
    echo "PASS: Export file exists"
    pass_count=$((pass_count + 1))
else
    echo "FAIL: Export file missing"
    fail_count=$((fail_count + 1))
fi

echo ""
echo "PASSED: $pass_count"
echo "FAILED: $fail_count"
echo "TOTAL:  $((pass_count + fail_count))"

if [ $fail_count -eq 0 ]; then
    exit 0
else
    exit 1
fi
