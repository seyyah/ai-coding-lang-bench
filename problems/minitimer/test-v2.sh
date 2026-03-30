#!/bin/bash
set -e

echo "Running test-v2.sh for MiniTimer..."

# Clean start
rm -rf .minitimer
python3 minitimer.py init
python3 minitimer.py start "Study Physics"

# Test stopping the task
python3 minitimer.py stop 1

# Test the edge-case (trying to stop an already stopped task)
python3 minitimer.py stop 1

# Test viewing statistics
python3 minitimer.py stats

# Test the log command
python3 minitimer.py log

echo "Test v2 passed successfully!"
