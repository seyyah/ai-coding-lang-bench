#!/bin/bash
set -e

echo "Running test-v1.sh for MiniTimer..."

# Temiz bir başlangıç yap
rm -rf .minitimer

# Init komutunu test et
python3 minitimer.py init

# Start komutunu test et
python3 minitimer.py start "Study Physics"
python3 minitimer.py start "Coding Project"

# Dosyanın oluştuğunu doğrula
if [ ! -f ".minitimer/timers.dat" ]; then
    echo "Error: timers.dat not found!"
    exit 1
fi

echo "Test v1 passed successfully!"
