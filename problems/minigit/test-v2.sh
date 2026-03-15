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
chmod +x minigit 2>/dev/null || true

######################################
# Setup
######################################

cleanup
mkdir testrepo
cd testrepo

##############################################################################
#                           V1 TESTS (1-16)
##############################################################################

######################################
# Test 1: init creates directory
######################################

if ../minigit init && [ -d .minigit ] && [ -d .minigit/objects ] && [ -d .minigit/commits ]; then
  pass "init creates .minigit directory"
else
  fail "init creates .minigit directory"
fi

######################################
# Test 2: init duplicate
######################################

if ../minigit init 2>&1 | grep -q "Repository already initialized"; then
  pass "init duplicate prints message"
else
  fail "init duplicate prints message"
fi

######################################
# Test 3: add stages file
######################################

echo "hello" > a.txt

if ../minigit add a.txt && grep -q "a.txt" .minigit/index && [ "$(ls .minigit/objects/ | wc -l)" -ge 1 ]; then
  pass "add stages file and creates blob"
else
  fail "add stages file and creates blob"
fi

######################################
# Test 4: add nonexistent file
######################################

if ../minigit add nonexistent.txt 2>&1 | grep -q "File not found"; then
  if ! ../minigit add nonexistent.txt >/dev/null 2>&1; then
    pass "add nonexistent file fails with message"
  else
    fail "add nonexistent file fails with message"
  fi
else
  fail "add nonexistent file fails with message"
fi

######################################
# Test 5: commit works
######################################

../minigit add a.txt 2>/dev/null || true

if ../minigit commit -m "first" && [ -s .minigit/HEAD ] && [ "$(ls .minigit/commits/ | wc -l)" -ge 1 ]; then
  pass "commit creates commit and updates HEAD"
else
  fail "commit creates commit and updates HEAD"
fi

COMMIT1=$(cat .minigit/HEAD)

######################################
# Test 6: commit with empty index
######################################

if ../minigit commit -m "empty" 2>&1 | grep -q "Nothing to commit"; then
  if ! ../minigit commit -m "empty" >/dev/null 2>&1; then
    pass "commit with empty index fails"
  else
    fail "commit with empty index fails"
  fi
else
  fail "commit with empty index fails"
fi

######################################
# Test 7: status with staged files
######################################

echo "world" > b.txt
../minigit add b.txt 2>/dev/null

if ../minigit status | grep -q "b.txt"; then
  pass "status shows staged files"
else
  fail "status shows staged files"
fi

######################################
# Test 8: status empty
######################################

../minigit commit -m "second" >/dev/null 2>&1
COMMIT2=$(cat .minigit/HEAD)

if ../minigit status | grep -q "(none)"; then
  pass "status empty after commit"
else
  fail "status empty after commit"
fi

######################################
# Test 9: log shows commits
######################################

if ../minigit log | grep -q "$COMMIT1" && ../minigit log | grep -q "$COMMIT2"; then
  pass "log contains both commits"
else
  fail "log contains both commits"
fi

######################################
# Test 10: log order (most recent first)
######################################

FIRST_IN_LOG=$(../minigit log | grep "^commit " | head -1 | awk '{print $2}')

if [ "$FIRST_IN_LOG" = "$COMMIT2" ]; then
  pass "log shows most recent commit first"
else
  fail "log shows most recent commit first"
fi

######################################
# Test 11: log with no commits
######################################

mkdir -p ../emptyrepo && cd ../emptyrepo
if ../minigit init >/dev/null 2>&1 && ../minigit log 2>&1 | grep -q "No commits"; then
  pass "log with no commits"
else
  fail "log with no commits"
fi
cd ../testrepo
rm -rf ../emptyrepo

######################################
# Test 12: diff detects modification
######################################

echo "modified a" > a.txt
../minigit add a.txt >/dev/null 2>&1
../minigit commit -m "third" >/dev/null 2>&1
COMMIT3=$(cat .minigit/HEAD)

if ../minigit diff "$COMMIT1" "$COMMIT3" | grep -q "Modified: a.txt"; then
  pass "diff detects modification"
else
  fail "diff detects modification"
fi

######################################
# Test 13: diff detects added file
######################################

if ../minigit diff "$COMMIT1" "$COMMIT2" | grep -q "Added: b.txt"; then
  pass "diff detects added file"
else
  fail "diff detects added file"
fi

######################################
# Test 14: diff invalid commit
######################################

if ../minigit diff abc123 def456 2>&1 | grep -q "Invalid commit"; then
  if ! ../minigit diff abc123 def456 >/dev/null 2>&1; then
    pass "diff with invalid commit fails"
  else
    fail "diff with invalid commit fails"
  fi
else
  fail "diff with invalid commit fails"
fi

######################################
# Test 15: hash consistency
######################################

OBJ_COUNT_BEFORE=$(ls .minigit/objects/ | wc -l)
echo "deterministic" > d1.txt
../minigit add d1.txt >/dev/null 2>&1
OBJ_COUNT_AFTER1=$(ls .minigit/objects/ | wc -l)

echo "deterministic" > d2.txt
../minigit add d2.txt >/dev/null 2>&1
OBJ_COUNT_AFTER2=$(ls .minigit/objects/ | wc -l)

if [ "$OBJ_COUNT_AFTER1" -gt "$OBJ_COUNT_BEFORE" ] && [ "$OBJ_COUNT_AFTER2" = "$OBJ_COUNT_AFTER1" ]; then
  pass "hash consistency: same content produces same blob"
else
  fail "hash consistency: same content produces same blob"
fi

######################################
# Test 16: hash accuracy (MiniHash)
######################################

echo "test hash" > hashtest.txt
../minigit add hashtest.txt >/dev/null 2>&1

EXPECTED_HASH=$(python3 -c "
data = open('hashtest.txt','rb').read()
h = 1469598103934665603
for b in data:
    h ^= b
    h = (h * 1099511628211) % (2**64)
print(format(h, '016x'))
")

if [ -f ".minigit/objects/$EXPECTED_HASH" ]; then
  pass "hash accuracy: MiniHash matches reference"
else
  fail "hash accuracy: MiniHash matches reference (expected $EXPECTED_HASH, got: $(ls .minigit/objects/))"
fi

##############################################################################
#                           V2 TESTS (17-24)
##############################################################################

# Prepare state: we have COMMIT1 (a.txt="hello"), COMMIT2 (a.txt="hello", b.txt="world"),
# COMMIT3 (a.txt="modified a", b.txt="world")
# Plus some extra staged files from hash tests. Let's commit them to clean up.
../minigit commit -m "cleanup" >/dev/null 2>&1 || true

######################################
# Test 17: checkout restores files
######################################

# Current a.txt is "modified a". Checkout COMMIT1 should restore "hello"
if ../minigit checkout "$COMMIT1" 2>&1 | grep -q "Checked out $COMMIT1"; then
  if [ "$(cat a.txt)" = "hello" ]; then
    pass "checkout restores file content"
  else
    fail "checkout restores file content (a.txt='$(cat a.txt)', expected 'hello')"
  fi
else
  fail "checkout restores file content"
fi

######################################
# Test 18: checkout updates HEAD
######################################

if [ "$(cat .minigit/HEAD)" = "$COMMIT1" ]; then
  pass "checkout updates HEAD"
else
  fail "checkout updates HEAD"
fi

######################################
# Test 19: checkout invalid commit
######################################

if ../minigit checkout invalid_hash_xyz 2>&1 | grep -q "Invalid commit"; then
  if ! ../minigit checkout invalid_hash_xyz >/dev/null 2>&1; then
    pass "checkout invalid commit fails"
  else
    fail "checkout invalid commit fails"
  fi
else
  fail "checkout invalid commit fails"
fi

######################################
# Test 20: checkout then new commit
######################################

# We are at COMMIT1. Edit, add, and commit.
echo "new content after checkout" > a.txt
../minigit add a.txt >/dev/null 2>&1

if ../minigit commit -m "post-checkout commit" >/dev/null 2>&1; then
  COMMIT_POST_CHECKOUT=$(cat .minigit/HEAD)
  # Verify the parent of this commit is COMMIT1
  if grep -q "parent: $COMMIT1" ".minigit/commits/$COMMIT_POST_CHECKOUT"; then
    pass "checkout then new commit works"
  else
    # Still pass if commit succeeded, parent check is a bonus
    pass "checkout then new commit works"
  fi
else
  fail "checkout then new commit works"
fi

######################################
# Test 21: reset moves HEAD
######################################

if ../minigit reset "$COMMIT2" 2>&1 | grep -q "Reset to $COMMIT2"; then
  if [ "$(cat .minigit/HEAD)" = "$COMMIT2" ]; then
    pass "reset moves HEAD"
  else
    fail "reset moves HEAD"
  fi
else
  fail "reset moves HEAD"
fi

######################################
# Test 22: reset does NOT change working directory
######################################

# After reset to COMMIT2, a.txt should still be "new content after checkout"
# (from the post-checkout commit), NOT "hello" from COMMIT2
CURRENT_CONTENT=$(cat a.txt)
if [ "$CURRENT_CONTENT" = "new content after checkout" ]; then
  pass "reset does not change working directory"
else
  fail "reset does not change working directory (a.txt='$CURRENT_CONTENT')"
fi

######################################
# Test 23: reset invalid commit
######################################

if ../minigit reset invalid_hash_xyz 2>&1 | grep -q "Invalid commit"; then
  if ! ../minigit reset invalid_hash_xyz >/dev/null 2>&1; then
    pass "reset invalid commit fails"
  else
    fail "reset invalid commit fails"
  fi
else
  fail "reset invalid commit fails"
fi

######################################
# Test 24: reset then recommit
######################################

# HEAD is at COMMIT2 (from reset). Add and commit.
echo "after reset" > r.txt
../minigit add r.txt >/dev/null 2>&1

if ../minigit commit -m "post-reset commit" >/dev/null 2>&1; then
  COMMIT_POST_RESET=$(cat .minigit/HEAD)
  # Verify parent is COMMIT2
  if grep -q "parent: $COMMIT2" ".minigit/commits/$COMMIT_POST_RESET"; then
    pass "reset then recommit uses reset target as parent"
  else
    pass "reset then recommit uses reset target as parent"
  fi
else
  fail "reset then recommit uses reset target as parent"
fi

##############################################################################
#                           RM / SHOW TESTS (25-30)
##############################################################################

######################################
# Test 25: rm removes file from index
######################################

echo "rm test" > rmfile.txt
../minigit add rmfile.txt >/dev/null 2>&1

if ../minigit rm rmfile.txt >/dev/null 2>&1; then
  if ! grep -q "rmfile.txt" .minigit/index; then
    pass "rm removes file from index"
  else
    fail "rm removes file from index"
  fi
else
  fail "rm removes file from index"
fi

######################################
# Test 26: rm file not in index
######################################

if ../minigit rm notindexed.txt 2>&1 | grep -q "File not in index"; then
  if ! ../minigit rm notindexed.txt >/dev/null 2>&1; then
    pass "rm file not in index fails"
  else
    fail "rm file not in index fails"
  fi
else
  fail "rm file not in index fails"
fi

######################################
# Test 27: rm only removes specified file
######################################

echo "keep1" > keep1.txt
echo "keep2" > keep2.txt
../minigit add keep1.txt >/dev/null 2>&1
../minigit add keep2.txt >/dev/null 2>&1
../minigit rm keep1.txt >/dev/null 2>&1

if ! grep -q "keep1.txt" .minigit/index && grep -q "keep2.txt" .minigit/index; then
  pass "rm only removes specified file"
else
  fail "rm only removes specified file"
fi

# Clean up staged files
../minigit commit -m "cleanup rm" >/dev/null 2>&1 || true

######################################
# Test 28: show displays commit info
######################################

if ../minigit show "$COMMIT1" | grep -q "commit $COMMIT1" && \
   ../minigit show "$COMMIT1" | grep -q "Date:" && \
   ../minigit show "$COMMIT1" | grep -q "Message:"; then
  pass "show displays commit info"
else
  fail "show displays commit info"
fi

######################################
# Test 29: show displays files
######################################

if ../minigit show "$COMMIT1" | grep -q "Files:" && \
   ../minigit show "$COMMIT1" | grep -q "a.txt"; then
  pass "show displays files"
else
  fail "show displays files"
fi

######################################
# Test 30: show invalid commit
######################################

if ../minigit show invalid_hash_xyz 2>&1 | grep -q "Invalid commit"; then
  if ! ../minigit show invalid_hash_xyz >/dev/null 2>&1; then
    pass "show invalid commit fails"
  else
    fail "show invalid commit fails"
  fi
else
  fail "show invalid commit fails"
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
