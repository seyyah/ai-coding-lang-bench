#!/usr/bin/env bash
# Student: Elvan Negiş (251478063)
# Project: mini-inventory v2 (Enhanced)
# Date: 2026-03-20
set -e

# Sayaçlar
PASS_COUNT=0
FAIL_COUNT=0

# Yardımcı Fonksiyonlar
pass() {
  echo -e "[+] PASS: $1"
  PASS_COUNT=$((PASS_COUNT+1))
}

fail() {
  echo -e "[-] FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT+1))
}

cleanup() {
  # Test ortamını ve gizli dizini temizle
  rm -rf test_v2_env
}

# Kurulum
cleanup
mkdir test_v2_env
cp inventory.py test_v2_env/
cd test_v2_env

echo "===================================================="
echo " Running Inventory V2 Tests (With Category & Summary)"
echo "===================================================="

# --- Test 1: Init (v2) ---
# [cite: 17, 18]
python3 inventory.py init > /dev/null
if [ -d ".inventory" ] && [ -f ".inventory/items.dat" ]; then
  pass "V2 initialization successful."
else
  fail "Init failed to create storage."
fi

# --- Test 2: Add with Category ---
# [cite: 19, 27]
OUT=$(python3 inventory.py add "Apple" 50 10 "Fruit")
if [[ "$OUT" == *"Added product #1: Apple"* ]]; then
  pass "Add with Category works."
else
  fail "Add product output mismatch or category error."
fi

# --- Test 3: Numerical Validation (New in V2) ---
# 
OUT=$(python3 inventory.py add "Banana" "abc" "ten" "Fruit")
if [[ "$OUT" == *"Error: Quantity and Price must be numbers."* ]]; then
  pass "Input validation for numbers is working."
else
  fail "System accepted non-numeric quantity/price!"
fi

# --- Test 4: Insufficient Stock Logic (New in V2) ---
# 
# Apple stoğu 50, biz 60 çıkarmaya çalışıyoruz
OUT=$(python3 inventory.py remove "Apple" 60)
if [[ "$OUT" == *"Error: Insufficient stock. Current: 50"* ]]; then
  pass "Insufficient stock check is working."
else
  fail "System allowed removing more than available stock."
fi

# --- Test 5: List with Category ---
# [cite: 21, 22]
OUT=$(python3 inventory.py list)
if [[ "$OUT" == *"Category: Fruit"* ]]; then
  pass "List command displays category correctly."
else
  fail "Category info missing in list output."
fi

# --- Test 6: Summary Command (New in V2) ---
# 
# Şu an içeride: 50 Apple (10 TL) -> Total: 500 TL
OUT=$(python3 inventory.py summary)
if [[ "$OUT" == *"Total Items: 50"* ]] && [[ "$OUT" == *"Total Inventory Value: 500"* ]]; then
  pass "Summary calculations are correct."
else
  fail "Summary command output or math is wrong."
fi

# --- Test 7: Pre-init Error (Global) ---
# 
rm -rf .inventory
OUT=$(python3 inventory.py summary)
if [[ "$OUT" == *"Not initialized"* ]]; then
  pass "Pre-init global check is working."
else
  fail "System allowed command without init."
fi

echo "===================================================="
echo " V2 Results: $PASS_COUNT Passed / $FAIL_COUNT Failed"
echo "===================================================="

# Temizlik
cd ..
cleanup

if [ $FAIL_COUNT -eq 0 ]; then
  exit 0
else
  exit 1
fi