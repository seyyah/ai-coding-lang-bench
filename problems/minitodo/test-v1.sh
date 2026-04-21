#!/usr/bin/env bash
set -e

PASS_COUNT=0
FAIL_COUNT=0

fail() {
  echo "FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT+1))
}

pass() {
  echo "PASS: $1"
  PASS_COUNT=$((PASS_COUNT+1))
}

cleanup() {
  cd "$(dirname "$0")"
  rm -rf testdir
}

# Build if needed
cd "$(dirname "$0")"

if [ -f Makefile ] || [ -f makefile ]; then
  make -s 2>/dev/null || true
fi
if [ -f build.sh ]; then
  bash build.sh 2>/dev/null || true
fi
chmod +x minitodo 2>/dev/null || true

######################################
# Setup
######################################

cleanup
mkdir testdir
cd testdir

######################################
# Tests
######################################

# Test 1: Handle uninitialized environment
if ../minitodo add "test task" 1 2>&1 | grep -q '\[FATAL\] Data environment not found'; then
  pass "Uninitialized add fails appropriately"
else
  fail "Uninitialized add fails appropriately"
fi

# Test 2: init command
if ../minitodo init | grep -q '\[SYSTEM\] New data environment created in .todo_data/' && [ -d .todo_data ] && [ -f .todo_data/registry.txt ]; then
  pass "init creates files"
else
  fail "init creates files"
fi

# Test 3: double init output
if ../minitodo init | grep -q '\[SYSTEM\] Environment is already active.'; then
  pass "double init warning"
else
  fail "double init warning"
fi

# Test 4: add empty list log
if ../minitodo list | grep -q '\[LOG\] Storage is currently empty.'; then
  pass "list logs when empty"
else
  fail "list logs when empty"
fi

# Test 5: add task
if ../minitodo add "First task" 1 | grep -q '\[SUCCESS\] Entry #1 has been registered.' && grep -q '^1|ACTIVE|1|.*|First task' .todo_data/registry.txt; then
  pass "add first task"
else
  fail "add first task"
fi

# Test 6: add second task
../minitodo add "Second task" 2 >/dev/null
if grep -q '^2|ACTIVE|2|.*|Second task' .todo_data/registry.txt; then
  pass "add second task"
else
  fail "add second task"
fi

# Test 7: list tasks
if ../minitodo list | grep -q 'First task' && ../minitodo list | grep -q '--- ACTIVE ---'; then
  pass "list shows tasks"
else
  fail "list shows tasks"
fi

# Test 8: done updates status
if ../minitodo done 1 | grep -q '\[UPDATE\] Entry #1 is now marked as CLOSED.' && grep -q '^1|CLOSED|1|.*|First task' .todo_data/registry.txt; then
  pass "done command updates status"
else
  fail "done command updates status"
fi

# Test 9: delete task
if ../minitodo delete 2 | grep -q '\[REMOVED\] Entry #2 has been permanently erased.' && ! grep -q 'Second task' .todo_data/registry.txt; then
  pass "delete command removes entry"
else
  fail "delete command removes entry"
fi

# Test 10: non-existent ID handled
if ../minitodo done 999 2>&1 | grep -i -E '(\[FATAL\]|\[ERROR\]).*999' >/dev/null || ../minitodo done 999 2>&1 | grep -q 'not be located' >/dev/null; then
  pass "non-existent ID handles properly"
else
  fail "non-existent ID handles properly"
fi

# Test 11: unknown command
if ../minitodo bad_command 2>&1 | grep -q '\[ERROR\] Unknown command: bad_command'; then
  pass "invalid command error"
else
  fail "invalid command error"
fi

# Test 12: missing arguments
if ../minitodo add 2>&1 | grep -q '\[USAGE\] Syntax error'; then
  pass "missing arguments error"
else
  fail "missing arguments error"
fi

######################################
# Cleanup & Summary
######################################

cd ..
rm -rf testdir

echo ""
echo "========================"
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo "TOTAL:  $((PASS_COUNT + FAIL_COUNT))"
echo "========================"

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo "ALL TESTS PASSED"
  exit 0
else
  exit 1
fi
