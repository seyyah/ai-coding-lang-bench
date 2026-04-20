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

# Executable check/build
cd "$(dirname "$0")"

# Python scripti çalıştırılabilir yapmak veya varsa binary'yi kullanmak
if [ -f minilibrary.py ]; then
  # Eğer python kodu minilibrary.py olarak varsa, onu çalıştırılabilir bir wrapper ile saralım
  echo '#!/usr/bin/env bash' > minilibrary
  echo 'python3 "$(dirname "$0")/minilibrary.py" "$@"' >> minilibrary
  chmod +x minilibrary
elif [ -f Makefile ] || [ -f makefile ]; then
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
# Test 1: init creates directory & files
######################################

OUTPUT=$(../minilibrary init 2>&1)
if echo "$OUTPUT" | grep -q "Initialized empty mini-library" && [ -d .minilibrary ] && [ -f .minilibrary/books.dat ] && [ -f .minilibrary/requests.dat ] && [ -f .minilibrary/borrowers.dat ] && [ -f .minilibrary/blacklist.dat ]; then
  pass "init creates .minilibrary directory and all .dat files"
else
  fail "init creates .minilibrary directory and all .dat files (got: $OUTPUT)"
fi

######################################
# Test 2: init duplicate
######################################

OUTPUT=$(../minilibrary init 2>&1)
if echo "$OUTPUT" | grep -q "Already initialized"; then
  pass "init duplicate prints message"
else
  fail "init duplicate prints message (got: $OUTPUT)"
fi

######################################
# Test 3: add single book
######################################

OUTPUT=$(../minilibrary add "The Little Prince" "Antoine de Saint-Exupery" 2>&1)
# Spesifikasyon 'Book #1 added' tarzında bir çıktı bekler.
if echo "$OUTPUT" | grep -q "Book #1" || echo "$OUTPUT" | grep -q "added"; then
  pass "add single book"
else
  fail "add single book (got: $OUTPUT)"
fi

######################################
# Test 4: list shows available book
######################################

OUTPUT=$(../minilibrary list 2>&1)
if echo "$OUTPUT" | grep -q "The Little Prince" && echo "$OUTPUT" | grep -q "AVAILABLE"; then
  pass "list shows books with AVAILABLE status"
else
  fail "list shows books with AVAILABLE status (got: $OUTPUT)"
fi

######################################
# Test 5: borrow available book
######################################

OUTPUT=$(../minilibrary borrow 1 "Ahmet" 2>&1)
if echo "$OUTPUT" | grep -q "borrowed" && echo "$OUTPUT" | grep -q "Due date"; then
  pass "borrow marks book as borrowed with due date"
else
  fail "borrow marks book as borrowed with due date (got: $OUTPUT)"
fi

######################################
# Test 6: borrow already borrowed book
######################################

OUTPUT=$(../minilibrary borrow 1 "Ayse" 2>&1 || true)
if echo "$OUTPUT" | grep -qi "already borrowed"; then
  pass "borrow already borrowed book shows message"
else
  fail "borrow already borrowed book shows message (got: $OUTPUT)"
fi

######################################
# Test 7: return borrowed book (on time)
######################################

OUTPUT=$(../minilibrary return 1 2>&1)
if echo "$OUTPUT" | grep -q "returned"; then
  pass "return borrowed book"
else
  fail "return borrowed book (got: $OUTPUT)"
fi

######################################
# Test 8: return not borrowed book
######################################

OUTPUT=$(../minilibrary return 1 2>&1 || true)
if echo "$OUTPUT" | grep -q "not borrowed"; then
  pass "return not borrowed book"
else
  fail "return not borrowed book (got: $OUTPUT)"
fi

######################################
# Test 9: request command
######################################

OUTPUT=$(../minilibrary request "Dune" "Frank Herbert" 2>&1)
if echo "$OUTPUT" | grep -q "Dune" || echo "$OUTPUT" | grep -qi "request"; then
  pass "request adds a book request"
else
  fail "request adds a book request (got: $OUTPUT)"
fi

######################################
# Test 10: listrequests command
######################################

OUTPUT=$(../minilibrary listrequests 2>&1)
if echo "$OUTPUT" | grep -q "Dune" && echo "$OUTPUT" | grep -q "Frank Herbert"; then
  pass "listrequests shows requested books"
else
  fail "listrequests shows requested books (got: $OUTPUT)"
fi

######################################
# Test 11: Late return triggers blacklist
######################################

# Sistemi manipüle ederek 3 gecikmesi olan bir kullanıcı senaryosu oluşturuyoruz.
# Kitabı 30 gün önce alınmış gibi kaydedelim.
OLD_DATE=$(date -d "30 days ago" +%Y-%m-%d 2>/dev/null || date -v-30d +%Y-%m-%d 2>/dev/null)
../minilibrary add "Test Book" "Test Author" > /dev/null 2>&1
# Kitabı ödünç al ve ardından tarihi eski bir tarihe değiştir
../minilibrary borrow 2 "KotuKullanici" > /dev/null 2>&1
sed -i.bak "s/|$(date +%Y-%m-%d)|KotuKullanici/|$OLD_DATE|KotuKullanici/g" .minilibrary/books.dat 2>/dev/null || \
perl -pi -e "s/\|$(date +%Y-%m-%d)\|KotuKullanici/|$OLD_DATE|KotuKullanici/g" .minilibrary/books.dat 

# Borrowers dosyasına kullanıcının halihazırda 2 gecikmesi olduğunu yazalım
echo "KotuKullanici|2" > .minilibrary/borrowers.dat

# Şimdi iade ettiğinde 3. gecikme olacak ve blackliste düşecek
../minilibrary return 2 > /dev/null 2>&1

OUTPUT=$(../minilibrary blacklist 2>&1)
if echo "$OUTPUT" | grep -q "KotuKullanici"; then
  pass "late return (>=3) adds user to blacklist"
else
  fail "late return (>=3) adds user to blacklist (got: $OUTPUT)"
fi

######################################
# Test 12: listborrowers command
######################################

OUTPUT=$(../minilibrary listborrowers 2>&1)
if echo "$OUTPUT" | grep -q "KotuKullanici" && echo "$OUTPUT" | grep -q "3"; then
  pass "listborrowers shows borrower late counts"
else
  fail "listborrowers shows borrower late counts (got: $OUTPUT)"
fi

######################################
# Test 13: Blacklisted user cannot borrow
######################################

../minilibrary add "Clean Architecture" "Robert C. Martin" > /dev/null 2>&1
OUTPUT=$(../minilibrary borrow 3 "KotuKullanici" 2>&1 || true)
if echo "$OUTPUT" | grep -q "User is blacklisted: KotuKullanici"; then
  pass "blacklisted user blocked from borrowing"
else
  fail "blacklisted user blocked from borrowing (got: $OUTPUT)"
fi

######################################
# Test 14: command before init
######################################

rm -rf .minilibrary
OUTPUT=$(../minilibrary add "Some Book" "Some Author" 2>&1 || true)
if echo "$OUTPUT" | grep -q "Not initialized"; then
  pass "command before init shows error"
else
  fail "command before init shows error (got: $OUTPUT)"
fi

######################################
# Cleanup & Summary
######################################

cd ..
rm -rf testrepo
rm -f minilibrary # Wrapper'ı temizle

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
