#!/bin/bash
# test-v1.sh - Testing core functionality (init, start, log)

echo "--- Running test-v1.sh ---"

# Clean up any existing test data to start fresh
rm -rf .minitimer

# Test initializing the timer
python3 solution_v1.py init

# Test starting tasks
python3 solution_v1.py start "Math Study"

# Test viewing logs
python3 solution_v1.py log

echo "--- Test v1 completed successfully ---"
