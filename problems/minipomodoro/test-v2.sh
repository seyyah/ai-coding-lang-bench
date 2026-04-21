#!/bin/bash
# test-v2.sh - Testing edge-cases and new features (pause, resume, stop)

echo "--- Running test-v2.sh ---"
rm -rf .minipomodoro

python3 minipomodoro.py init
python3 minipomodoro.py start "Math Study"
python3 minipomodoro.py pause
python3 minipomodoro.py resume
python3 minipomodoro.py stop
python3 minipomodoro.py pause
python3 minipomodoro.py log

echo "--- Test v2 completed successfully ---"
