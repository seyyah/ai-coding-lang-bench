#!/usr/bin/env bash
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
  rm -rf testrepo
}

# Build if needed
cd "$(dirname "$0")"

if [ -f Makefile ] || [ -f makefile ]; then
  make -s 2>/dev/null || true
fi
if [ -f build.sh ]; then
  bash build.sh 2>/dev/null || true
fi
chmod +x miniinventory 2>/dev/null || true

######################################
# Setup
######################################

cleanup
mkdir testrepo
cd testrepo

######################################
# Test 1: init creates directory
######################################

if ../miniinventory init && [ -d .miniinventory ] && [ -f .miniinventory/inventory.dat ]; then
  OUTPUT=$(../miniinventory init 2>&1 || true)
  if echo "$OUTPUT" | grep -q "Already initialized"; then
    pass "init creates directory and handles duplicate"
  else
    fail "init creates directory and handles duplicate (duplicate missing)"
  fi
else
  fail "init creates directory and handles duplicate (dir missing)"
fi

######################################
# Test 2: add product
######################################
rm -rf .miniinventory
../miniinventory init >/dev/null 2>&1
if ../miniinventory add Pencil 50 2>&1 | grep -q "Added product #1: Pencil (50)"; then
  pass "add single product"
else
  fail "add single product"
fi

if ../miniinventory add Notebook 20 2>&1 | grep -q "Added product #2: Notebook (20)"; then
  pass "add second product"
else
  fail "add second product"
fi

######################################
# Test 3: add before init
######################################
rm -rf .miniinventory
if ../miniinventory add Pencil 50 2>&1 | grep -q "Not initialized"; then
  pass "add before init fails"
else
  fail "add before init fails"
fi

######################################
# Test 4: add invalid quantity & missing
######################################
../miniinventory init >/dev/null 2>&1
if ../miniinventory add Pencil -5 2>&1 | grep -q "Invalid quantity"; then
  pass "add invalid quantity"
else
  fail "add invalid quantity"
fi

if ../miniinventory add Pencil 2>&1 | grep -q "Usage:"; then
  pass "add missing arguments"
else
  fail "add missing arguments"
fi

######################################
# Test 5: list placeholder
######################################
if ../miniinventory list 2>&1 | grep -q "will be implemented in future weeks"; then
  pass "list placeholder message"
else
  fail "list placeholder message"
fi

######################################
# Test 6: update placeholder
######################################
if ../miniinventory update 1 80 2>&1 | grep -q "will be implemented in future weeks"; then
  pass "update placeholder message"
else
  fail "update placeholder message"
fi

######################################
# Test 7: delete placeholder
######################################
if ../miniinventory delete 1 2>&1 | grep -q "will be implemented in future weeks"; then
  pass "delete placeholder message"
else
  fail "delete placeholder message"
fi

######################################
# Test 8: unknown command & missing
######################################
if ../miniinventory fly 2>&1 | grep -q "Unknown command: fly"; then
  pass "unknown command"
else
  fail "unknown command"
fi

if ../miniinventory 2>&1 | grep -q "Usage"; then
  pass "missing command"
else
  fail "missing command"
fi


######################################
# Cleanup & Summary
######################################

cd ..
rm -rf testrepo

echo ""
echo "========================"
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo "TOTAL:  $((PASS_COUNT + FAIL_COUNT))"
echo "========================"

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo "ALL TESTS PASSED"
  exit 0
else
  exit 1
fi
