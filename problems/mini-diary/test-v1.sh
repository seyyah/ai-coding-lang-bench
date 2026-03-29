#!/bin/bash

# --- RENKLER VE AYARLAR ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Renk Yok

# Test baslangicinda temizlik yap
setup() {
    if [ -d ".minidiary" ]; then
        rm -rf .minidiary
    fi
}

# Komut calistirma yardimcisi
run_cmd() {
    python solution.py "$@"
}

echo "=== Mini-Diary v1.0 Test Suite Starting ==="

# --- 10 TEST SENARYOSU ---

# Test 1: Directory creation
setup
run_cmd init > /dev/null
if [ -d ".minidiary" ]; then
    echo -e "${GREEN}[PASS]${NC} Test 1: Directory created."
else
    echo -e "${RED}[FAIL]${NC} Test 1: Directory not found."
fi

# Test 2: Double initialization warning
run_cmd init | grep -q "Already initialized"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Test 2: Double init warning works."
else
    echo -e "${RED}[FAIL]${NC} Test 2: Double init check failed."
fi

# Test 3: First entry ID 1
setup
run_cmd init > /dev/null
run_cmd write "Hello Diary" | grep -q "ID: 1"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Test 3: First entry assigned ID 1."
else
    echo -e "${RED}[FAIL]${NC} Test 3: ID 1 assignment failed."
fi

# Test 4: Second entry ID 2
run_cmd write "Second Entry" | grep -q "ID: 2"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Test 4: Second entry assigned ID 2."
else
    echo -e "${RED}[FAIL]${NC} Test 4: ID 2 increment failed."
fi

# Test 5: List command v0 constraint check
run_cmd list | grep -iq "implemented"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Test 5: List command restricted in v0."
else
    echo -e "${RED}[FAIL]${NC} Test 5: List command constraint failed."
fi

# Test 6: Read command placeholder
run_cmd read 1 | grep -iq "implemented"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Test 6: Read command restricted in v0."
else
    echo -e "${RED}[FAIL]${NC} Test 6: Read command constraint failed."
fi

# Test 7: Delete command placeholder
run_cmd delete 1 | grep -iq "implemented"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Test 7: Delete command restricted in v0."
else
    echo -e "${RED}[FAIL]${NC} Test 7: Delete command constraint failed."
fi

# Test 8: Error when no init
setup
run_cmd write "Test" | grep -iq "Error: Initialize first"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Test 8: No-init error caught."
else
    echo -e "${RED}[FAIL]${NC} Test 8: No-init error check failed."
fi

# Test 9: Unknown command error
run_cmd fly | grep -iq "Unknown command"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Test 9: Unknown command error caught."
else
    echo -e "${RED}[FAIL]${NC} Test 9: Unknown command check failed."
fi

# Test 10: Usage help on empty args
run_cmd | grep -iq "Usage:"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[PASS]${NC} Test 10: Usage help displayed."
else
    echo -e "${RED}[FAIL]${NC} Test 10: Usage help check failed."
fi

echo "=== Test Suite Completed ==="
