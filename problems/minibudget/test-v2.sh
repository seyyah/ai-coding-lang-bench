#!/usr/bin/env bash
set -e

# Setup (reuse v1 state if possible)
cd testrepo

# Test Summary
if ../minibudget summary | grep -q "Total Balance: 80"; then
  echo "PASS: summary"
else
  echo "FAIL: summary"
  exit 1
fi

# Test Delete
../minibudget delete 1 >/dev/null
if ../minibudget summary | grep -q "Total Balance: -20"; then
  echo "PASS: delete"
else
  echo "FAIL: delete"
  exit 1
fi
