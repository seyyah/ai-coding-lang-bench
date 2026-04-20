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
# Test 1: init 
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
# Test 2: before init errors
######################################
rm -rf .miniinventory
if ../miniinventory add Pencil 50 2>&1 | grep -q "Not initialized"; then pass "add before init"; else fail "add before init"; fi
if ../miniinventory list 2>&1 | grep -q "Not initialized"; then pass "list before init"; else fail "list before init"; fi
if ../miniinventory update 1 80 2>&1 | grep -q "Not initialized"; then pass "update before init"; else fail "update before init"; fi
if ../miniinventory delete 1 2>&1 | grep -q "Not initialized"; then pass "delete before init"; else fail "delete before init"; fi

######################################
# Test 3: add and duplicate check
######################################
../miniinventory init >/dev/null 2>&1
../miniinventory add Pencil 50 >/dev/null 2>&1
if ../miniinventory add Pencil 30 2>&1 | grep -q "Product already exists"; then
  pass "add duplicate product fails"
else
  fail "add duplicate product fails"
fi

if ../miniinventory add "   " 10 2>&1 | grep -q "Invalid product name"; then
  pass "add invalid name fails"
else
  fail "add invalid name fails"
fi

if ../miniinventory add Pencil 2>&1 | grep -q "Usage"; then
  pass "add missing arguments"
else
  fail "add missing arguments"
fi

######################################
# Test 4: list products
######################################
../miniinventory add Notebook 20 >/dev/null 2>&1
OUTPUT=$(../miniinventory list 2>&1)
if echo "$OUTPUT" | grep -q "\[1\] Pencil - Quantity: 50" && echo "$OUTPUT" | grep -q "\[2\] Notebook - Quantity: 20"; then
  pass "list shows products"
else
  fail "list shows products"
fi

######################################
# Test 5: list empty
######################################
rm -rf .miniinventory
../miniinventory init >/dev/null 2>&1
if ../miniinventory list 2>&1 | grep -q "No products found"; then
  pass "list empty inventory"
else
  fail "list empty inventory"
fi

######################################
# Test 6: update product
######################################
../miniinventory add Pencil 50 >/dev/null 2>&1
if ../miniinventory update 1 80 2>&1 | grep -q "Product #1 updated to quantity 80"; then
  pass "update product success"
else
  fail "update product success"
fi

if ../miniinventory update 1 -1 2>&1 | grep -q "Invalid quantity"; then
  pass "update invalid quantity fails"
else
  fail "update invalid quantity fails"
fi

if ../miniinventory update 99 80 2>&1 | grep -q "Product #99 not found"; then
  pass "update missing product fails"
else
  fail "update missing product fails"
fi

if ../miniinventory update 1 2>&1 | grep -q "Usage"; then
  pass "update missing arguments"
else
  fail "update missing arguments"
fi

######################################
# Test 7: delete product & ID reuse
######################################
../miniinventory add Notebook 20 >/dev/null 2>&1
if ../miniinventory delete 1 2>&1 | grep -q "Deleted product #1"; then
  pass "delete product success"
else
  fail "delete product success"
fi

if ../miniinventory delete 99 2>&1 | grep -q "Product #99 not found"; then
  pass "delete missing product fails"
else
  fail "delete missing product fails"
fi

if ../miniinventory delete 2>&1 | grep -q "Usage"; then
  pass "delete missing arguments"
else
  fail "delete missing arguments"
fi

# ID check (new product should be #3 since 1 was deleted, 2 exists)
if ../miniinventory add Eraser 10 2>&1 | grep -q "Added product #3: Eraser (10)"; then
  pass "deleted IDs are not reused"
else
  fail "deleted IDs are not reused"
fi

######################################
# Test 8: unknown/missing command
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
