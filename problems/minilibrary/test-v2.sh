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
chmod +x minilibrary 2>/dev/null || true

######################################
# Setup
######################################

cleanup
mkdir testrepo
cd testrepo

######################################
# Test 1: init creates directory
######################################

if ../minilibrary init 2>&1 | grep -q "Initialized empty mini-library" && [ -d .minilibrary ] && [ -f .minilibrary/books.dat ] && [ -f .minilibrary/requests.dat ]; then
  pass "init creates .minilibrary directory, books.dat, and requests.dat"
else
  fail "init creates .minilibrary directory, books.dat, and requests.dat"
fi

######################################
# Test 2: init duplicate
######################################

if ../minilibrary init 2>&1 | grep -q "Already initialized"; then
  pass "init duplicate prints message"
else
  fail "init duplicate prints message"
fi

######################################
# Test 3: add single book
######################################

OUTPUT=$(../minilibrary add "The Little Prince" "Antoine de Saint-Exupery" 2>&1)
if echo "$OUTPUT" | grep -q "Added book #1" && echo "$OUTPUT" | grep -q "The Little Prince"; then
  pass "add single book"
else
  fail "add single book (got: $OUTPUT)"
fi

######################################
# Test 4: add multiple books
######################################

OUTPUT=$(../minilibrary add "Clean Code" "Robert C. Martin" 2>&1)
if echo "$OUTPUT" | grep -q "#2"; then
  pass "add multiple books assigns incremental ID"
else
  fail "add multiple books assigns incremental ID (got: $OUTPUT)"
fi

######################################
# Test 5: list empty library
######################################

rm -rf .minilibrary
../minilibrary init > /dev/null 2>&1
OUTPUT=$(../minilibrary list 2>&1)
if echo "$OUTPUT" | grep -q "No books found"; then
  pass "list empty library"
else
  fail "list empty library (got: $OUTPUT)"
fi

######################################
# Test 6: list shows books
######################################

../minilibrary add "The Little Prince" "Antoine de Saint-Exupery" > /dev/null 2>&1
OUTPUT=$(../minilibrary list 2>&1)
if echo "$OUTPUT" | grep -q "The Little Prince" && echo "$OUTPUT" | grep -q "AVAILABLE"; then
  pass "list shows books with status"
else
  fail "list shows books with status (got: $OUTPUT)"
fi

######################################
# Test 7: list shows multiple books
######################################

../minilibrary add "Clean Code" "Robert C. Martin" > /dev/null 2>&1
OUTPUT=$(../minilibrary list 2>&1)
if echo "$OUTPUT" | grep -q "The Little Prince" && echo "$OUTPUT" | grep -q "Clean Code"; then
  pass "list shows multiple books"
else
  fail "list shows multiple books (got: $OUTPUT)"
fi

######################################
# Test 8: borrow marks book
######################################

OUTPUT=$(../minilibrary borrow 1 2>&1)
if echo "$OUTPUT" | grep -q "borrowed" && echo "$OUTPUT" | grep -q "Due date"; then
  pass "borrow marks book as borrowed with due date"
else
  fail "borrow marks book as borrowed with due date (got: $OUTPUT)"
fi

######################################
# Test 9: borrow already borrowed
######################################

OUTPUT=$(../minilibrary borrow 1 2>&1)
if echo "$OUTPUT" | grep -q "already borrowed"; then
  pass "borrow already borrowed book shows message"
else
  fail "borrow already borrowed book shows message (got: $OUTPUT)"
fi

######################################
# Test 10: borrow nonexistent
######################################

OUTPUT=$(../minilibrary borrow 99 2>&1)
if echo "$OUTPUT" | grep -q "not found"; then
  pass "borrow nonexistent book"
else
  fail "borrow nonexistent book (got: $OUTPUT)"
fi

######################################
# Test 11: list shows borrowed status
######################################

OUTPUT=$(../minilibrary list 2>&1)
if echo "$OUTPUT" | grep -q "BORROWED" && echo "$OUTPUT" | grep -q "Due:"; then
  pass "list shows borrowed book with due date"
else
  fail "list shows borrowed book with due date (got: $OUTPUT)"
fi

######################################
# Test 12: return borrowed book
######################################

OUTPUT=$(../minilibrary return 1 2>&1)
if echo "$OUTPUT" | grep -q "returned"; then
  pass "return borrowed book"
else
  fail "return borrowed book (got: $OUTPUT)"
fi

######################################
# Test 13: return not borrowed book
######################################

OUTPUT=$(../minilibrary return 1 2>&1)
if echo "$OUTPUT" | grep -q "not borrowed"; then
  pass "return not borrowed book"
else
  fail "return not borrowed book (got: $OUTPUT)"
fi

######################################
# Test 14: return nonexistent book
######################################

OUTPUT=$(../minilibrary return 99 2>&1)
if echo "$OUTPUT" | grep -q "not found"; then
  pass "return nonexistent book"
else
  fail "return nonexistent book (got: $OUTPUT)"
fi

######################################
# Test 15: delete removes book
######################################

OUTPUT=$(../minilibrary delete 1 2>&1)
if echo "$OUTPUT" | grep -q "Deleted"; then
  LIST_OUTPUT=$(../minilibrary list 2>&1)
  if echo "$LIST_OUTPUT" | grep -q "The Little Prince"; then
    fail "delete removes book (book still in list)"
  else
    pass "delete removes book"
  fi
else
  fail "delete removes book (got: $OUTPUT)"
fi

######################################
# Test 16: delete nonexistent book
######################################

OUTPUT=$(../minilibrary delete 99 2>&1)
if echo "$OUTPUT" | grep -q "not found"; then
  pass "delete nonexistent book"
else
  fail "delete nonexistent book (got: $OUTPUT)"
fi

######################################
# Test 17: command before init
######################################

rm -rf .minilibrary
OUTPUT=$(../minilibrary add "Some Book" "Some Author" 2>&1)
if echo "$OUTPUT" | grep -q "Not initialized"; then
  pass "command before init shows error"
else
  fail "command before init shows error (got: $OUTPUT)"
fi

######################################
# Test 18: unknown command
######################################

../minilibrary init > /dev/null 2>&1
OUTPUT=$(../minilibrary fly 2>&1)
if echo "$OUTPUT" | grep -q "Unknown command"; then
  pass "unknown command"
else
  fail "unknown command (got: $OUTPUT)"
fi

######################################
# Test 19: request new book (1/3)
######################################

rm -rf .minilibrary
../minilibrary init > /dev/null 2>&1
OUTPUT=$(../minilibrary request "Clean Code" "Robert C. Martin" 2>&1)
if echo "$OUTPUT" | grep -q "Request recorded" && echo "$OUTPUT" | grep -q "1/3"; then
  pass "request new book shows 1/3"
else
  fail "request new book shows 1/3 (got: $OUTPUT)"
fi

######################################
# Test 20: request increment (2/3)
######################################

OUTPUT=$(../minilibrary request "Clean Code" "Robert C. Martin" 2>&1)
if echo "$OUTPUT" | grep -q "2/3"; then
  pass "request increment shows 2/3"
else
  fail "request increment shows 2/3 (got: $OUTPUT)"
fi

######################################
# Test 21: request triggers order (3/3)
######################################

OUTPUT=$(../minilibrary request "Clean Code" "Robert C. Martin" 2>&1)
if echo "$OUTPUT" | grep -q "Order placed"; then
  pass "request triggers order at 3/3"
else
  fail "request triggers order at 3/3 (got: $OUTPUT)"
fi

######################################
# Test 22: request existing book
######################################

../minilibrary add "Dune" "Frank Herbert" > /dev/null 2>&1
OUTPUT=$(../minilibrary request "Dune" "Frank Herbert" 2>&1)
if echo "$OUTPUT" | grep -q "already exists"; then
  pass "request existing book shows error"
else
  fail "request existing book shows error (got: $OUTPUT)"
fi

######################################
# Test 23: listrequests empty
######################################

rm -rf .minilibrary
../minilibrary init > /dev/null 2>&1
OUTPUT=$(../minilibrary listrequests 2>&1)
if echo "$OUTPUT" | grep -q "No pending requests"; then
  pass "listrequests empty"
else
  fail "listrequests empty (got: $OUTPUT)"
fi

######################################
# Test 24: listrequests shows requests
######################################

../minilibrary request "Clean Code" "Robert C. Martin" > /dev/null 2>&1
OUTPUT=$(../minilibrary listrequests 2>&1)
if echo "$OUTPUT" | grep -q "Clean Code" && echo "$OUTPUT" | grep -q "1/3"; then
  pass "listrequests shows pending requests"
else
  fail "listrequests shows pending requests (got: $OUTPUT)"
fi

######################################
# Test 25: listrequests multiple
######################################

../minilibrary request "The Pragmatic Programmer" "David Thomas" > /dev/null 2>&1
OUTPUT=$(../minilibrary listrequests 2>&1)
if echo "$OUTPUT" | grep -q "Clean Code" && echo "$OUTPUT" | grep -q "The Pragmatic Programmer"; then
  pass "listrequests shows multiple requests"
else
  fail "listrequests shows multiple requests (got: $OUTPUT)"
fi

######################################
# Test 26: request removed after order
######################################

../minilibrary request "Clean Code" "Robert C. Martin" > /dev/null 2>&1
../minilibrary request "Clean Code" "Robert C. Martin" > /dev/null 2>&1
OUTPUT=$(../minilibrary listrequests 2>&1)
if echo "$OUTPUT" | grep -q "Clean Code"; then
  fail "request removed from list after order placed"
else
  pass "request removed from list after order placed"
fi

######################################
# Test 27: request before init
######################################

rm -rf .minilibrary
OUTPUT=$(../minilibrary request "Some Book" "Some Author" 2>&1)
if echo "$OUTPUT" | grep -q "Not initialized"; then
  pass "request before init shows error"
else
  fail "request before init shows error (got: $OUTPUT)"
fi

######################################
# Test 28: listrequests before init
######################################

OUTPUT=$(../minilibrary listrequests 2>&1)
if echo "$OUTPUT" | grep -q "Not initialized"; then
  pass "listrequests before init shows error"
else
  fail "listrequests before init shows error (got: $OUTPUT)"
fi

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
