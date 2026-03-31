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
chmod +x mini-timer 2>/dev/null || true

######################################
# Setup
######################################

cleanup
mkdir testdir
cd testdir

######################################
# Test 1: init creates directory
######################################

if ../mini-timer init && [ -d .minitimer ] && [ -f .minitimer/timer.dat ]; then
  pass "init creates .minitimer directory and timer.dat"
else
  fail "init creates .minitimer directory and timer.dat"
fi

######################################
# Test 2: init duplicate
######################################

if ../mini-timer init 2>&1 | grep -q "Already initialized"; then
  pass "init duplicate prints message"
else
  fail "init duplicate prints message"
fi

######################################
# Test 3: start task
######################################

if ../mini-timer start "Math Study" | grep -q "Started task: Math Study. Focus!" && grep -q "Math Study|RUNNING" .minitimer/timer.dat; then
  pass "start creates a running task"
else
  fail "start creates a running task"
fi

######################################
# Test 4: start while running error
######################################

if ../mini-timer start "Read Book" 2>&1 | grep -q "Error: A task is already running"; then
  pass "start while running fails with message"
else
  fail "start while running fails with message"
fi

######################################
# Test 5: pause task
######################################

if ../mini-timer pause | grep -q "Task paused" && grep -q "Math Study|PAUSED" .minitimer/timer.dat; then
  pass "pause updates task status to PAUSED"
else
  fail "pause updates task status to PAUSED"
fi

######################################
# Test 6: resume task
######################################

if ../mini-timer resume | grep -q "Task resumed" && grep -q "Math Study|RUNNING" .minitimer/timer.dat; then
  pass "resume updates task status to RUNNING"
else
  fail "resume updates task status to RUNNING"
fi

######################################
# Test 7: stop task
######################################

if ../mini-timer stop | grep -q "Task stopped" && grep -q "Math Study|DONE" .minitimer/timer.dat; then
  pass "stop marks task as DONE"
else
  fail "stop marks task as DONE"
fi

######################################
# Test 8: log shows tasks
######################################

if ../mini-timer log | grep -q "Math Study" && ../mini-timer log | grep -q "DONE"; then
  pass "log prints the completed task"
else
  fail "log prints the completed task"
fi

######################################
# Test 9: log with no tasks
######################################

mkdir -p ../emptytest && cd ../emptytest
../mini-timer init >/dev/null 2>&1
if ../mini-timer log | grep -q "No timer logs found."; then
  pass "log with no tasks prints empty message"
else
  fail "log with no tasks prints empty message"
fi
cd ../testdir
rm -rf ../emptytest

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
