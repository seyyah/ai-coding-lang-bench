#!/bin/bash
# test-v1.sh - Testing core functionality (init, start, log)

echo "--- Running test-v1.sh ---"
rm -rf .minipomodoro

python3 minipomodoro.py init
python3 minipomodoro.py start "Math Study"
python3 minipomodoro.py log

echo "--- Test v1 completed successfully ---"
