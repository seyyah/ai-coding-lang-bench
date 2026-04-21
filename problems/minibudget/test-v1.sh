#!/usr/bin/env bash
set -e

# Setup
rm -rf testrepo && mkdir testrepo && cd testrepo
../minibudget init >/dev/null

# Test Add & List
../minibudget add 100 "Salary" >/dev/null
../minibudget add -20 "Coffee" >/dev/null

if ../minibudget list | grep -q "100: Salary" && ../minibudget list | grep -q "-20: Coffee"; then
  echo "PASS: add and list"
else
  echo "FAIL: add and list"
  exit 1
fi
