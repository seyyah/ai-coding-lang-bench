#!/bin/bash
# test-v1.sh - Testing core functionality (init, start, log)

echo "--- Running test-v1.sh ---"
rm -rf .pomodorotimer

python3 pomodorotimer.py init
python3 pomodorotimer.py start "Math Study"
python3 pomodorotimer.py log

echo "--- Test v1 completed successfully ---"
