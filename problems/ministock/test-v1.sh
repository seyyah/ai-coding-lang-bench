#!/usr/bin/env bash
# Student: Elvan Negiş (251478063)
# Project: ministock
set -e

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  echo "[OK] PASS: $1"
  PASS_COUNT=$((PASS_COUNT+1))
}

fail() {
  echo "[X] FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT+1))
}

cleanup() {
  rm -rf test_folder
}

cleanup
mkdir test_folder
cp ministock.py test_folder/
cd test_folder

echo "========================================"
echo " Starting Mini Stock System Tests..."
echo "========================================"

python3 ministock.py init > /dev/null
if [ -d ".inventory" ] && [ -f ".inventory/items.dat" ]; then
  pass "System initialized successfully."
else
  fail "Init command failed to create files."
fi

OUT=$(python3 ministock.py init)
if [[ "$OUT" == *"Already initialized"* ]]; then
  pass "Duplicate init check works."
else
  fail "Duplicate init didn't show warning."
fi

OUT=$(python3 ministock.py add "Apple" 50 10)
if [[ "$OUT" == *"Added product #1: Apple"* ]]; then
  pass "Item 'Apple' added correctly."
else
  fail "Add product output format is wrong."
fi

OUT=$(python3 ministock.py list)
if [[ "$OUT" == *"[1] Apple"* ]]; then
  pass "List format matches specification."
else
  fail "List display is incorrect."
fi

OUT=$(python3 ministock.py search "Banana")
if [[ "$OUT" == *"Product not found"* ]]; then
  pass "Search handles missing items correctly."
else
  fail "Search should have returned 'Product not found'."
fi

python3 ministock.py add "Milk" 5 3 > /dev/null
OUT=$(python3 ministock.py lowstock)
if [[ "$OUT" == *"WARNING: Low stock for Milk"* ]]; then
  pass "Low stock warning triggered correctly."
else
  fail "Low stock warning failed."
fi

rm -rf .inventory
OUT=$(python3 ministock.py list)
if [[ "$OUT" == *"Not initialized"* ]]; then
  pass "Pre-init error handling is active."
else
  fail "System allowed command before init."
fi

echo "========================================"
echo " Final Result: $PASS_COUNT Passed / $FAIL_COUNT Failed"
echo "========================================"

cd ..
cleanup

if [ $FAIL_COUNT -eq 0 ]; then
  exit 0
else
  exit 1
fi
