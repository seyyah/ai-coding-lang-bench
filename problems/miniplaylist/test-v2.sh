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

MINIPL="../minipl"

######################################
# Prepare Environment
######################################
$MINIPL init >/dev/null 2>&1
$MINIPL add "Song A" "Artist A" "Album A" >/dev/null 2>&1
$MINIPL add "Shape of You" "Ed Sheeran" "Divide" >/dev/null 2>&1

######################################
# Test 1: search finds match
######################################
if $MINIPL search "Ed Sheeran" | grep -q "Shape of You"; then
  pass "search finds exact match"
else
  fail "search finds exact match"
fi

######################################
# Test 2: search case insensitive
######################################
if $MINIPL search "sheeran" | grep -q "Shape of You"; then
  pass "search is case insensitive"
else
  fail "search is case insensitive"
fi

######################################
# Test 3: search no match
######################################
if $MINIPL search "Tarkan" | grep -q "No matches found"; then
  pass "search handles no matches"
else
  fail "search handles no matches"
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