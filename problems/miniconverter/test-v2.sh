#!/usr/bin/env bash
# miniconverter v2 Full Regression Test Script
# Ogrenci: HASAN YILMAZ (250708022)
# Guncelleme: V0, V1 ve V2 ozelliklerinin tamamı denetlenmektedir.
set -e

PASS_COUNT=0
FAIL_COUNT=0

# Yardımcı Fonksiyonlar
fail() {
  echo "FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT+1))
}

pass() {
  echo "PASS: $1"
  PASS_COUNT=$((PASS_COUNT+1))
}

cleanup() {
  # Her testten once klasoru temizleyerek izole bir ortam saglıyoruz
  rm -rf .miniconv
}

# [KRITIK] problem.json ile uyumlu ikili dosya ismi
BIN="python3 solution_v2.py"

######################################
# SETUP & INITIALIZATION
######################################
cleanup

######################################
# TEST 1: V0 - Init Creates Directory
######################################
# Program ilk kez calıstıgında dizin olusturmalı
if $BIN init > /dev/null && [ -d .miniconv ]; then
  pass "v0: init creates .miniconv directory"
else
  fail "v0: init creates .miniconv directory"
fi

######################################
# TEST 2: V0 - Basic Conversion (m to cm)
######################################
# Temel donusum dogru calısmalı
if $BIN convert 10 m cm | grep -q "10.0 m is 1000.00 cm"; then
  pass "v0: basic convert (10m to cm) works"
else
  fail "v0: basic convert (10m to cm) works"
fi

######################################
# TEST 3: V1 - Case Insensitivity (KM to M)
######################################
# Buyuk harf girisleri kucuk harf gibi islenmeli
if $BIN convert 1 KM M | tr '[:upper:]' '[:lower:]' | grep -q "1.0 km is 1000.00 m"; then
  pass "v1: case insensitivity works (KM -> M)"
else
  fail "v1: case insensitivity works (KM -> M)"
fi

######################################
# TEST 4: V1 - Decimal Precision (Float Support)
######################################
# Ondalık sayılar 2 basamak hassasiyetle gosterilmeli
if $BIN convert 1.234 m cm | grep -q "123.40"; then
  pass "v1: decimal precision (1.234m -> 123.40cm) works"
else
  fail "v1: decimal precision (1.234m -> 123.40cm) works"
fi

######################################
# TEST 5: V2 - Invalid Value Validation
######################################
# Sayı yerine metin girildiginde program cokmemeli
if $BIN convert elma m cm | grep -q "Error: elma is not a valid number."; then
  pass "v2: non-numeric value error handling (elma test) works"
else
  fail "v2: non-numeric value error handling (elma test) works"
fi

######################################
# TEST 6: V2 - Unknown Command Handling
######################################
# Bilinmeyen bir komut girildiginde kullanıcı uyarılmalı
if $BIN reset | grep -q "Unknown command: reset"; then
  pass "v2: unknown command handling works"
else
  fail "v2: unknown command handling works"
fi

######################################
# TEST 7: Global - Unsupported Unit Error
######################################
# Desteklenmeyen birimler hata dondurmeli
if $BIN convert 5 m mile | grep -q "Error"; then
  pass "global: unsupported unit returns Error"
else
  fail "global: unsupported unit returns Error"
fi

######################################
# TEST 8: Global - Error No Init
######################################
cleanup
# Init yapılmadan islemlere izin verilmemeli
if $BIN convert 1 m cm | grep -q "Not initialized"; then
  pass "global: error when running convert without init"
else
  fail "global: error when running convert without init"
fi

######################################
# SUMMARY REPORT
######################################
echo ""
echo "========================================"
echo "      MINICONVERTER V2 TEST RESULTS     "
echo "========================================"
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo "TOTAL TESTS: $((PASS_COUNT + FAIL_COUNT))"
echo "========================================"

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo ">>> ALL V0, V1 AND V2 TESTS PASSED <<<"
  exit 0
else
  echo ">>> SOME TESTS FAILED <<<"
  exit 1
fi