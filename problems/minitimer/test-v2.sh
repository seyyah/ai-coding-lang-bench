#!/bin/bash
# test-v2.sh - Testing edge-cases and new features (stop, stats)

echo "--- Running test-v2.sh ---"

# Clean up any existing test data to start fresh
rm -rf .minitimer

# Initialize and start a task
python3 minitimer.py init
python3 minitimer.py start "Study Physics"

# Test stopping the task
python3 minitimer.py stop 1

# Test the edge-case (trying to stop an already stopped task)
python3 minitimer.py stop 1

# Test viewing statistics
python3 minitimer.py stats

echo "--- Test v2 completed successfully ---"
