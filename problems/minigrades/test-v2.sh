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
  rm -rf testrepo
}

# Build if needed
cd "$(dirname "$0")"

if [ -f Makefile ] || [ -f makefile ]; then
  make -s 2>/dev/null || true
fi
if [ -f build.sh ]; then
  bash build.sh 2>/dev/null || true
fi
chmod +x minigrades 2>/dev/null || true

######################################
# Setup
######################################

cleanup
mkdir testrepo
cd testrepo

######################################
# Test 1: init creates directory
######################################

if ../minigrades init && [ -d .minigrades ]; then
  pass "init creates .minigrades directory"
else
  fail "init creates .minigrades directory"
fi

######################################
# Test 2: init duplicate
######################################

if ../minigrades init 2>&1 | grep -q "Already initialized"; then
  pass "init duplicate prints message"
else
  fail "init duplicate prints message"
fi

######################################
# Test 3: add student
######################################

if ../minigrades add 101 Berke 2>&1 | grep -q "Student added successfully"; then
  pass "add student success"
else
  fail "add student success"
fi

######################################
# Test 4: add duplicate student
######################################

if ../minigrades add 101 Efe 2>&1 | grep -q "Error: Student with ID 101 already exists"; then
  pass "add duplicate student fails"
else
  fail "add duplicate student fails"
fi

######################################
# Test 5: add student non-numeric id
######################################

if ../minigrades add abc Berke 2>&1 | grep -q "Invalid input: Please enter a numeric value"; then
  pass "add student non-numeric id fails"
else
  fail "add student non-numeric id fails"
fi

######################################
# Test 6: add-grade success
######################################

if ../minigrades add-grade 101 80 2>&1 | grep -q "Grades added successfully for student 101"; then
  pass "add-grade success"
else
  fail "add-grade success"
fi

######################################
# Test 7: add-grade out of range
######################################

if ../minigrades add-grade 101 105 2>&1 | grep -q "Invalid grade: Grades must be between 0 and 100"; then
  pass "add-grade out of range fails"
else
  fail "add-grade out of range fails"
fi

######################################
# Test 8: add-grade non-numeric
######################################

if ../minigrades add-grade 101 abc 2>&1 | grep -q "Invalid input: Please enter a numeric value"; then
  pass "add-grade non-numeric fails"
else
  fail "add-grade non-numeric fails"
fi

######################################
# Test 9: add-grade student not found
######################################

if ../minigrades add-grade 999 80 2>&1 | grep -q "Error: No student found with ID 999"; then
  pass "add-grade student not found"
else
  fail "add-grade student not found"
fi

######################################
# Test 10: del-grade success
######################################

../minigrades add-grade 101 70 >/dev/null 2>&1
if ../minigrades del-grade 101 70 2>&1 | grep -q "Grade 70 successfully removed"; then
  pass "del-grade success"
else
  fail "del-grade success"
fi

######################################
# Test 11: del-grade student not found
######################################

if ../minigrades del-grade 999 85 2>&1 | grep -q "Error: No student found with ID 999"; then
  pass "del-grade student not found"
else
  fail "del-grade student not found"
fi

######################################
# Test 12: del-grade grade not found
######################################

if ../minigrades del-grade 101 99 2>&1 | grep -q "Error: Grade 99 not found for this student"; then
  pass "del-grade grade not found"
else
  fail "del-grade grade not found"
fi

######################################
# Test 13: del-grade non-numeric id
######################################

if ../minigrades del-grade abc 85 2>&1 | grep -q "Invalid input: Please enter a numeric value"; then
  pass "del-grade non-numeric id"
else
  fail "del-grade non-numeric id"
fi

######################################
# Test 14: delete student (v2: with grades)
######################################

../minigrades add 102 Efe >/dev/null 2>&1
../minigrades add-grade 102 90 >/dev/null 2>&1
if ../minigrades delete 102 2>&1 | grep -q "Student and all grades deleted successfully"; then
  pass "delete student with grades (v2 message)"
else
  fail "delete student with grades (v2 message)"
fi

######################################
# Test 15: delete student not found
######################################

if ../minigrades delete 999 2>&1 | grep -q "Error: No student found with ID 999"; then
  pass "delete student not found"
else
  fail "delete student not found"
fi

######################################
# Test 16: average success
######################################

../minigrades add-grade 101 70 >/dev/null 2>&1
../minigrades add-grade 101 30 >/dev/null 2>&1
if ../minigrades average 101 2>&1 | grep -q "Average for student 101 is 50.0"; then
  pass "average calculation correct"
else
  fail "average calculation correct"
fi

######################################
# Test 17: average student not found
######################################

if ../minigrades average 999 2>&1 | grep -q "Error: No student found with ID 999"; then
  pass "average student not found"
else
  fail "average student not found"
fi

######################################
# Test 18: average no grades
######################################

../minigrades add 103 Ali >/dev/null 2>&1
if ../minigrades average 103 2>&1 | grep -q "Error: Could not calculate average for student 103"; then
  pass "average no grades error"
else
  fail "average no grades error"
fi

######################################
# Test 19: list (v2 format with grades)
######################################

OUTPUT=$(../minigrades list 2>&1)
if echo "$OUTPUT" | grep -q "101 | Berke"; then
  pass "list shows student with data"
else
  fail "list shows student with data"
fi

######################################
# Test 20: list empty
######################################

mkdir -p ../emptyrepo && cd ../emptyrepo
../minigrades init >/dev/null 2>&1
if ../minigrades list 2>&1 | grep -q "Error: No students found in the system"; then
  pass "list empty database"
else
  fail "list empty database"
fi
cd ../testrepo
rm -rf ../emptyrepo

######################################
# Test 21: report success
######################################

if ../minigrades report 2>&1 | grep -q "Report saved to .minigrades/report.txt"; then
  if [ -f .minigrades/report.txt ]; then
    pass "report generates file"
  else
    fail "report generates file"
  fi
else
  fail "report generates file"
fi

######################################
# Test 22: report content
######################################

if grep -q "101 | Berke" .minigrades/report.txt 2>/dev/null; then
  pass "report contains student data"
else
  fail "report contains student data"
fi

######################################
# Test 23: report empty
######################################

mkdir -p ../emptyrepo2 && cd ../emptyrepo2
../minigrades init >/dev/null 2>&1
if ../minigrades report 2>&1 | grep -q "Error: No data available to generate a report"; then
  pass "report empty database"
else
  fail "report empty database"
fi
cd ../testrepo
rm -rf ../emptyrepo2

######################################
# Test 24: unknown command
######################################

if ../minigrades hello 2>&1 | grep -q "Unknown command: hello"; then
  pass "unknown command"
else
  fail "unknown command"
fi

######################################
# Test 25: not initialized
######################################

mkdir -p ../noinit && cd ../noinit
if ../minigrades list 2>&1 | grep -q "Not initialized"; then
  pass "not initialized error"
else
  fail "not initialized error"
fi
cd ../testrepo
rm -rf ../noinit

######################################
# Cleanup & Summary
######################################

cd ..
rm -rf testrepo

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
