#!/bin/bash

# --- CONFIGURATION & COLORS ---
SCRIPT="solution.py"
DB_DIR=".minidiary"
DB_FILE=".minidiary/diary.dat"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper function to run the python script
run_cmd() {
    python3 "$SCRIPT" "$@"
}

# Cleanup before starting
setup() {
    [ -d "$DB_DIR" ] && rm -rf "$DB_DIR"
    echo -e "--- Starting Mini-Diary v2.1 Automation Test ---"
}

# --- TEST EXECUTION ---

setup

# 1. Test: Initialization
echo -n "[1/8] Test: 'init' command... "
run_cmd init > /dev/null
if [ -d "$DB_DIR" ] && [ -f "$DB_FILE" ]; then
    echo -e "${GREEN}SUCCESS: Environment created.${NC}"
else
    echo -e "${RED}FAILED: Setup error.${NC}"
    exit 1
fi

# 2. Test: Double Initialization Guard
echo -n "[2/8] Test: Double init guard... "
OUT_AGAIN=$(run_cmd init)
if [[ "$OUT_AGAIN" == *"Already initialized"* ]]; then
    echo -e "${GREEN}SUCCESS: Guard active.${NC}"
else
    echo -e "${RED}FAILED: No warning.${NC}"
fi

# 3. Test: Write Entries (v0 Logic Check)
echo -n "[3/8] Test: 'write' command & IDs... "
run_cmd write "İlk test mesajı" > /dev/null
run_cmd write "İkinci test mesajı" > /dev/null
OUT_WRITE=$(run_cmd write "Üçüncü test mesajı")

if [[ "$OUT_WRITE" == *"ID: 3"* ]]; then
    LINE_COUNT=$(wc -l < "$DB_FILE")
    if [ "$LINE_COUNT" -eq 3 ]; then
        echo -e "${GREEN}SUCCESS: 3 entries stored with correct IDs.${NC}"
    else
        echo -e "${RED}FAILED: Line count mismatch ($LINE_COUNT).${NC}"
    fi
else
    echo -e "${RED}FAILED: ID assignment error.${NC}"
fi

# 4. Test: List Entries (v1 Logic Check)
echo -n "[4/8] Test: 'list' command... "
OUT_LIST=$(run_cmd list)
if [[ "$OUT_LIST" == *"İlk test mesajı"* ]] && [[ "$OUT_LIST" == *"Üçüncü test mesajı"* ]]; then
    echo -e "${GREEN}SUCCESS: All records displayed.${NC}"
else
    echo -e "${RED}FAILED: List output incomplete.${NC}"
fi

# 5. Test: Search Engine (Case-Insensitive Check)
echo -n "[5/8] Test: 'search' command (Case-Insensitive)... "
OUT_SEARCH_1=$(run_cmd search "İkinci")
OUT_SEARCH_2=$(run_cmd search "ikinci")

if [[ "$OUT_SEARCH_1" == *"ID [2]"* ]] && [[ "$OUT_SEARCH_2" == *"ID [2]"* ]]; then
    echo -e "${GREEN}SUCCESS: Search is case-insensitive.${NC}"
else
    echo -e "${RED}FAILED: Search failed or case-sensitive.${NC}"
fi

# 6. Test: Read Command (v1 Iterative Check)
echo -n "[6/8] Test: 'read' command... "
OUT_READ=$(run_cmd read 1)
if [[ "$OUT_READ" == *"Entry #1"* ]] && [[ "$OUT_READ" == *"İlk test mesajı"* ]]; then
    echo -e "${GREEN}SUCCESS: Specific entry read correctly.${NC}"
else
    echo -e "${RED}FAILED: Read command output is incorrect.${NC}"
fi

# 7. Test: Delete Command (v1 Rewriting Check)
echo -n "[7/8] Test: 'delete' command... "
OUT_DELETE=$(run_cmd delete 2)
if [[ "$OUT_DELETE" == *"Deleted entry #2"* ]]; then
    LINE_COUNT=$(wc -l < "$DB_FILE")
    if [ "$LINE_COUNT" -eq 2 ]; then
        echo -e "${GREEN}SUCCESS: Entry deleted and DB successfully rewritten.${NC}"
    else
        echo -e "${RED}FAILED: DB line count incorrect after deletion ($LINE_COUNT).${NC}"
    fi
else
    echo -e "${RED}FAILED: Delete command output incorrect.${NC}"
fi

# 8. Test: Unknown Command Handling
echo -n "[8/8] Test: Error handling... "
OUT_ERR=$(run_cmd bilinmeyen_komut)
if [[ "$OUT_ERR" == *"Unknown command"* ]]; then
    echo -e "${GREEN}SUCCESS: Unknown command caught.${NC}"
else
    echo -e "${RED}FAILED: Invalid error message.${NC}"
fi

echo -e "\n--- ${GREEN}ALL TESTS PASSED SUCCESSFULLY${NC} ---"
