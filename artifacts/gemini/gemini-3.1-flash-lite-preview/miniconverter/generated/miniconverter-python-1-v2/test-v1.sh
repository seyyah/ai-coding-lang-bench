#!/usr/bin/env bash
# mini-converter v1 Bash Test Script
# Ogrenci: HASAN YILMAZ (250708022)
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
  # Her testten once klasoru temizle [cite: 18]
  rm -rf .miniconv
}

# [DIKKAT] Artik solution_v1.py dosyasini test ediyoruz! [cite: 18]
BIN="python3 solution_v1.py"

######################################
# Setup
######################################
cleanup

######################################
# Test 1: Case Insensitivity (KM to M) 
######################################
$BIN init > /dev/null
# Kullanici 'KM' ve 'M' yazsa da hata almamali ve dogru sonuc donmeli 
if $BIN convert 1 KM M | tr '[:upper:]' '[:lower:]' | grep -q "1.0 km is 1000.0 m"; then
  pass "v2: case insensitivity works (KM -> M)"
else
  fail "v2: case insensitivity works (KM -> M)"
fi

######################################
# Test 2: Decimal Precision (2 digits) 
######################################
# 1.234 metre, 123.4 (veya 123.40) olarak yuvarlanmali 
if $BIN convert 1.234 m cm | grep -q "123.4"; then
  pass "v2: decimal precision (2 digits) works"
else
  fail "v2: decimal precision (2 digits) works"
fi

######################################
# Test 3: init creates folder 
######################################
cleanup
if $BIN init > /dev/null && [ -d .miniconv ]; then
  pass "init creates .miniconv directory"
else
  fail "init creates .miniconv directory"
fi

######################################
# Test 4: convert m to cm 
######################################
if $BIN convert 1 m cm | grep -q "1.0 m is 100.0 cm"; then
  pass "convert 1 m to cm works"
else
  fail "convert 1 m to cm works"
fi

######################################
# Test 5: unsupported unit [cite: 20]
######################################
if $BIN convert 5 m mile | grep -q "Error"; then
  pass "unsupported unit returns Error"
else
  fail "unsupported unit returns Error"
fi

######################################
# Test 6: error no init [cite: 20]
######################################
cleanup
if $BIN convert 1 m cm | grep -q "Not initialized"; then
  pass "error when running convert without init"
else
  fail "error when running convert without init"
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
  echo "ALL V2 TESTS PASSED"
  exit 0
else
  exit 1
fi