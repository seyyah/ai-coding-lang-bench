#!/bin/bash
# test-v2.sh - mini-quiz v2 test script
# Tests: all commands including ask, delete, full error handling

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
python miniquiz.py init > /dev/null
python miniquiz.py add "What is the capital of France?" "Paris" > /dev/null
python miniquiz.py add "What is 2+2?" "4" > /dev/null

# list formatted
check "list formatted output" "$(python miniquiz.py list)" "\[1\]"
check "list shows arrow" "$(python miniquiz.py list)" "Paris"

# ask correct
OUT=$(python3 -c "
import subprocess
r = subprocess.run(['python','miniquiz.py','ask','1'],capture_output=True,text=True,input='Paris\n')
print(r.stdout)
")
check "ask correct answer" "$OUT" "Correct"

# ask wrong
OUT=$(python3 -c "
import subprocess
r = subprocess.run(['python','miniquiz.py','ask','1'],capture_output=True,text=True,input='London\n')
print(r.stdout)
")
check "ask wrong answer" "$OUT" "Wrong"

# ask case insensitive
OUT=$(python3 -c "
import subprocess
r = subprocess.run(['python','miniquiz.py','ask','1'],capture_output=True,text=True,input='paris\n')
print(r.stdout)
")
check "ask case insensitive" "$OUT" "Correct"

# ask not found
OUT=$(python3 -c "
import subprocess
r = subprocess.run(['python','miniquiz.py','ask','99'],capture_output=True,text=True,input='\n')
print(r.stdout)
")
check "ask not found" "$OUT" "not found"

# delete
check "delete confirmation" "$(python miniquiz.py delete 1)" "Deleted"
check "delete removes question" "$(python miniquiz.py list)" "What is 2"
check "delete not found" "$(python miniquiz.py delete 99)" "not found"
check "id gap preserved" "$(python miniquiz.py list)" "\[2\]"

# errors
check "ask missing id" "$(python miniquiz.py ask)" "Usage"
check "delete missing id" "$(python miniquiz.py delete)" "Usage"
rm -rf .miniquiz
check "ask before init" "$(python3 -c "
import subprocess
r = subprocess.run(['python','miniquiz.py','ask','1'],capture_output=True,text=True,input='\n')
print(r.stdout)
")" "Not initialized"

rm -rf .miniquiz

echo ""
echo "Results: $PASS passed, $FAIL failed"
