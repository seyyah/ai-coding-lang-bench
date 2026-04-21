#!/usr/bin/env bash
# mini-converter v0 Bash Test Script
# Ogrenci: HASAN YILMAZ 250708022
set -e

PASS_COUNT=0
FAIL_COUNT=0

#
fail() {
  echo "FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT+1))
}

pass() {
  echo "PASS: $1"
  PASS_COUNT=$((PASS_COUNT+1))
}

cleanup() {
  # Her testten once klasoru temizle
  rm -rf .miniconv
}

# Calistirilacak ana komut
BIN="python3 solution_v0.py"

######################################
# Setup
######################################
cleanup

######################################
# Test 1: init creates directory
######################################
if $BIN init > /dev/null && [ -d .miniconv ]; then
  pass "init creates .miniconv directory"
else
  fail "init creates .miniconv directory"
fi

######################################
# Test 2: init already exists
######################################
if $BIN init | grep -q "Already initialized"; then
  pass "init already exists prints correct message"
else
  fail "init already exists prints correct message"
fi

######################################
# Test 3: convert m to cm
######################################
if $BIN convert 1 m cm | grep -q "1.0 m is 100.0 cm"; then
  pass "convert 1 m to cm works"
else
  fail "convert 1 m to cm works"
fi

######################################
# Test 4: convert km to m
######################################
if $BIN convert 2 km m | grep -q "2000.0 m"; then
  pass "convert 2 km to m works"
else
  fail "convert 2 km to m works"
fi

######################################
# Test 5: unsupported unit
######################################
if $BIN convert 5 m mile | grep -q "Error"; then
  pass "unsupported unit returns Error"
else
  fail "unsupported unit returns Error"
fi

######################################
# Test 6: future weeks commands (history/stats)
######################################
if $BIN history | grep -q "future weeks" && $BIN stats | grep -q "future weeks"; then
  pass "history/stats show future weeks message"
else
  fail "history/stats show future weeks message"
fi

######################################
# Test 7: error no init
######################################
cleanup
if $BIN convert 1 m cm | grep -q "Not initialized"; then
  pass "error when running convert without init"
else
  fail "error when running convert without init"
fi

######################################
# Test 8: unknown command
######################################
$BIN init > /dev/null
if $BIN reset | grep -q "Unknown command"; then
  pass "unknown command returns correct message"
else
  fail "unknown command returns correct message"
fi

######################################
# Test 9: missing arguments
######################################
if $BIN convert 10 m | grep -q "Usage"; then
  pass "missing arguments shows Usage message"
else
  fail "missing arguments shows Usage message"
fi

######################################
# Summary
######################################
echo ""
echo "========================"
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo "TOTAL:  $((PASS_COUNT + FAIL_COUNT))"
echo "========================"

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo "ALL V1 TESTS PASSED"
  exit 0
else
  exit 1
fi
