#!/usr/bin/env bash
# Student: Elvan Negiş (251478063)
# Project: mini-inventory [cite: 1]
set -e

# Basit sayaçlar
PASS_COUNT=0
FAIL_COUNT=0

# Yardımcı mesaj fonksiyonları
pass() {
  echo "[OK] PASS: $1"
  PASS_COUNT=$((PASS_COUNT+1))
}

fail() {
  echo "[X] FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT+1))
}

# Temizlik fonksiyonu
cleanup() {
  rm -rf test_folder
}

# Test ortamını hazırla
cleanup
mkdir test_folder
cp inventory.py test_folder/
cd test_folder

echo "========================================"
echo " Starting Inventory System Tests..."
echo "========================================"

# --- Test 1: İlk Kurulum (Init) ---
# SPEC: .inventory dizini ve items.dat oluşmalı [cite: 5]
python3 inventory.py init > /dev/null
if [ -d ".inventory" ] && [ -f ".inventory/items.dat" ]; then
  pass "System initialized successfully." [cite: 5]
else
  fail "Init command failed to create files." [cite: 5]
fi

# --- Test 2: Tekrar Init Yapma ---
# SPEC: "Already initialized" yazmalı [cite: 6]
OUT=$(python3 inventory.py init)
if [[ "$OUT" == *"Already initialized"* ]]; then
  pass "Duplicate init check works." [cite: 6]
else
  fail "Duplicate init didn't show warning." [cite: 6]
fi

# --- Test 3: Ürün Ekleme (Add) ---
# SPEC: Added product #1: Apple [cite: 7]
OUT=$(python3 inventory.py add "Apple" 50 10)
if [[ "$OUT" == *"Added product #1: Apple"* ]]; then
  pass "Item 'Apple' added correctly." [cite: 7]
else
  fail "Add product output format is wrong." [cite: 7]
fi

# --- Test 4: Listeleme (List) ---
# SPEC: [1] Apple | Quantity: 50 | Price: 10 [cite: 9]
OUT=$(python3 inventory.py list)
if [[ "$OUT" == *"[1] Apple | Quantity: 50 | Price: 10"* ]]; then
  pass "List format matches specification." [cite: 9]
else
  fail "List display is incorrect." [cite: 9]
fi

# --- Test 5: Arama (Search) ---
# SPEC: Ürün bulunamazsa "Product not found" [cite: 11]
OUT=$(python3 inventory.py search "Banana")
if [[ "$OUT" == *"Product not found"* ]]; then
  pass "Search handles missing items correctly." [cite: 11]
else
  fail "Search should have returned 'Product not found'." [cite: 11]
fi

# --- Test 6: Kritik Stok (Lowstock) ---
# SPEC: Miktar 10'dan azsa uyarı vermeli [cite: 12]
python3 inventory.py add "Milk" 5 3 > /dev/null
OUT=$(python3 inventory.py lowstock)
if [[ "$OUT" == *"WARNING: Low stock for Milk"* ]]; then
  pass "Low stock warning triggered correctly." [cite: 12]
else
  fail "Low stock warning failed." [cite: 12]
fi

# --- Test 7: Kurulumsuz Çalıştırma Hatası ---
# SPEC: "Not initialized. Run: python inventory.py init" [cite: 13]
rm -rf .inventory
OUT=$(python3 inventory.py list)
if [[ "$OUT" == *"Not initialized"* ]]; then
  pass "Pre-init error handling is active." [cite: 13]
else
  fail "System allowed command before init." [cite: 13]
fi

echo "========================================"
echo " Final Result: $PASS_COUNT Passed / $FAIL_COUNT Failed"
echo "========================================"

# Test bitince klasörü temizle
cd ..
cleanup

# Eğer hata varsa script hata koduyla (1) kapansın
if [ $FAIL_COUNT -eq 0 ]; then
  exit 0
else
  exit 1
fi