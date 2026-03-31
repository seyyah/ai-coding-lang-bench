#!/bin/bash
# test-v2.sh - Testing edge-cases and new features (pause, resume, stop)

echo "--- Running test-v2.sh ---"

# Clean up any existing test data to start fresh
rm -rf .minitimer

# Initialize and start a task
python3 solution_v1.py init
python3 solution_v1.py start "Math Study"

# Test pausing and resuming
python3 solution_v1.py pause
python3 solution_v1.py resume

# Test stopping the task
python3 solution_v1.py stop

# Test edge-case: trying to pause a stopped task (should give an error based on SPEC)
python3 solution_v1.py pause

# Test viewing the final log
python3 solution_v1.py log

echo "--- Test v2 completed successfully ---"
