#!/bin/bash
# test-v1.sh - mini-quiz v1 test script
# Tests: init, add, list (basic), error handling

PASS=0
FAIL=0

check() {
    local name="$1"
    local result="$2"
    local expected="$3"
    if echo "$result" | grep -q "$expected"; then
        echo "PASS: $name"
        PASS=$((PASS+1))
    else
        echo "FAIL: $name | got: '$result'"
        FAIL=$((FAIL+1))
    fi
}

rm -rf .miniquiz

# init
check "init creates directory" "$(python miniquiz.py init && echo dir_ok)" "dir_ok"
check "init already exists" "$(python miniquiz.py init)" "Already initialized"

# add
check "add question #1" "$(python miniquiz.py add 'What is 2+2?' '4')" "Added question #1"
check "add question #2" "$(python miniquiz.py add 'Capital of France?' 'Paris')" "Added question #2"
check "add missing answer" "$(python miniquiz.py add 'Only question')" "Usage"

# list
check "list shows question" "$(python miniquiz.py list)" "What is 2"
check "list before init" "$(rm -rf .miniquiz && python miniquiz.py list)" "Not initialized"

# errors
python miniquiz.py init > /dev/null
check "unknown command" "$(python miniquiz.py fly)" "Unknown command"
check "no arguments" "$(python miniquiz.py)" "Usage"

rm -rf .miniquiz

echo ""
echo "Results: $PASS passed, $FAIL failed"
