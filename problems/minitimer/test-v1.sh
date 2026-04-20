#!/bin/bash
# test-v1.sh - Testing core functionality (init, start)

echo "--- Running test-v1.sh ---"

# Clean up any existing test data to start fresh
rm -rf .minitimer

# Test initializing the timer
python3 minitimer.py init

# Test starting tasks
python3 minitimer.py start "Study Physics"
python3 minitimer.py start "Coding Project"

echo "--- Test v1 completed successfully ---"
