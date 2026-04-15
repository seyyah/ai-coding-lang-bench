#!/bin/bash
# Test V1 Specifications for minibudget

# Clean up before testing
rm -rf .minibudget

# Test initialization
python3 minibudget.py init

# Test adding transactions
python3 minibudget.py add INCOME 5000 "Salary"
python3 minibudget.py add EXPENSE 150 "Groceries"

# Test listing transactions
OUTPUT=$(python3 minibudget.py list)

if [[ "$OUTPUT" == *"Salary"* ]] && [[ "$OUTPUT" == *"Groceries"* ]]; then
    echo "V1 Tests Passed successfully."
    exit 0
else
    echo "V1 Tests Failed."
    exit 1
fi
