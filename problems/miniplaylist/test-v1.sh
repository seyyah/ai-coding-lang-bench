#!/usr/bin/env bash

# mini-playlist SPEC test script
# Project: mini-playlist

set -e

PASS_COUNT=0
FAIL_COUNT=0

fail() {
  echo "FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT+1))
}

pass() {
  echo "PASS: $1"
  PASS_COUNT=$((PASS_COUNT+1))
}

cleanup() {
  cd "$(dirname "$0")"
  rm -rf testenv
}

######################################
# Setup
######################################
cleanup

# Build step integration for compiled languages
if [ -f "build.sh" ]; then
  bash build.sh
elif [ -f "Makefile" ] || [ -f "makefile" ]; then
  make
fi

chmod +x minipl 2>/dev/null || true

mkdir testenv
cd testenv

# Alias to the binary in the parent directory
MINIPL="../minipl"

######################################
# Test 1: init creates directory
######################################
$MINIPL init >/dev/null 2>&1
if [ -d .miniplaylist ]; then
  pass "init creates .miniplaylist directory"
else
  fail "init creates .miniplaylist directory"
fi

######################################
# Test 2: init duplicate
######################################
if $MINIPL init | grep -q "Already initialized"; then
  pass "init duplicate prints message"
else
  fail "init duplicate prints message"
fi

######################################
# Test 3: add song
######################################
if $MINIPL add "Dark Red" "Steve Lacy" "Dark Red" | grep -q "Successfully"; then
  pass "add song appends to list"
else
  fail "add song appends to list"
fi

######################################
# Test 4: show songs
######################################
if $MINIPL show | grep -q "Dark Red"; then
  pass "show displays added songs"
else
  fail "show displays added songs"
fi

######################################
# Test 5: remove song
######################################
$MINIPL remove 1 >/dev/null 2>&1
output=$($MINIPL show) || true
if echo "$output" | grep -q "List is empty"; then
  pass "remove deletes the song"
else
  fail "remove deletes the song"
fi

######################################
# Cleanup & Summary
######################################
cd ..
rm -rf testenv

echo ""
echo "========================"
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo "TOTAL:  $((PASS_COUNT + FAIL_COUNT))"
echo "========================"

if [ "$FAIL_COUNT" -eq 0 ]; then
  exit 0
else
  exit 1
fi