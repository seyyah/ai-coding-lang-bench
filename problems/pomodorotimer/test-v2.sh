#!/bin/bash
# test-v2.sh - Testing edge-cases and new features (pause, resume, stop)

echo "--- Running test-v2.sh ---"
rm -rf .pomodorotimer

python3 pomodorotimer.py init
python3 pomodorotimer.py start "Math Study"
python3 pomodorotimer.py pause
python3 pomodorotimer.py resume
python3 pomodorotimer.py stop
python3 pomodorotimer.py pause
python3 pomodorotimer.py log

echo "--- Test v2 completed successfully ---"
