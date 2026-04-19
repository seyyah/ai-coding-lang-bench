#!/usr/bin/env bash
# Student: Elvan Negiş (251478063)
# Project: ministock v2
# Date: 2026-03-20
set -e

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  echo -e "[+] PASS: $1"
  PASS_COUNT=$((PASS_COUNT+1))
}

fail() {
  echo -e "[-] FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT+1))
}

cleanup() {
  rm -rf test_v2_env
}

cleanup
mkdir test_v2_env
cp ministock.py test_v2_env/
cd test_v2_env

echo "===================================================="
echo " Running Stock V2 Tests"
echo "===================================================="

python3 ministock.py init > /dev/null
if [ -d ".inventory" ] && [ -f ".inventory/items.dat" ]; then
  pass "V2 initialization successful."
else
  fail "Init failed to create storage."
fi

OUT=$(python3 ministock.py add "Apple" 50 10 "Fruit")
if [[ "$OUT" == *"Added product #1: Apple"* ]]; then
  pass "Add with Category works."
else
  fail "Add product output mismatch or category error."
fi

OUT=$(python3 ministock.py add "Banana" "abc" "ten" "Fruit")
if [[ "$OUT" == *"Error: Quantity and Price must be numbers."* ]]; then
  pass "Input validation for numbers is working."
else
  fail "System accepted non-numeric quantity/price!"
fi

OUT=$(python3 ministock.py add "Orange" -10 5 "Fruit")
if [[ "$OUT" == *"Error: Quantity and Price cannot be negative."* ]]; then
  pass "Negative input validation working."
else
  fail "System accepted negative stock."
fi

OUT=$(python3 ministock.py remove "Apple" 60)
if [[ "$OUT" == *"Error: Insufficient stock. Current: 50"* ]]; then
  pass "Insufficient stock check is working."
else
  fail "System allowed removing more than available stock."
fi

python3 ministock.py discount "Apple" 10 > /dev/null
OUT=$(python3 ministock.py list)
if [[ "$OUT" == *"Category: Fruit"* ]]; then
  pass "List command displays category correctly."
else
  fail "Category info missing in list output."
fi

python3 ministock.py export > /dev/null
if [ -f "inventory_export.csv" ]; then
  pass "Export created CSV file."
else
  fail "Export failed to create CSV."
fi

OUT=$(python3 ministock.py summary)
if [[ "$OUT" == *"Total Items: 50"* ]]; then
  pass "Summary calculations are correct."
else
  fail "Summary command output or math is wrong."
fi

echo "===================================================="
echo " V2 Results: $PASS_COUNT Passed / $FAIL_COUNT Failed"
echo "===================================================="

cd ..
cleanup

if [ $FAIL_COUNT -eq 0 ]; then
  exit 0
else
  exit 1
fi
