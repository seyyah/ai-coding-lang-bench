#!/bin/bash
set -e

echo "Running test-v1.sh for MiniTimer..."

# Start with a clean slate
rm -rf .minitimer

# Test the init command
python3 minitimer.py init

# Test starting tasks
python3 minitimer.py start "Study Physics"
python3 minitimer.py start "Coding Project"

# Verify that the data file is created
if [ ! -f ".minitimer/timers.dat" ]; then
    echo "Error: timers.dat not found!"
    exit 1
fi

echo "Test v1 passed successfully!"
