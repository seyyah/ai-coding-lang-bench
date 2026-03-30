#!/bin/bash
set -e

echo "Running test-v2.sh for MiniTimer..."

# Temiz bir başlangıç
rm -rf .minitimer
python3 minitimer.py init
python3 minitimer.py start "Study Physics"

# Stop komutunu test et
python3 minitimer.py stop 1

# Edge-case test et (Zaten durmuş sayacı durdurma)
python3 minitimer.py stop 1

# İstatistikleri test et
python3 minitimer.py stats

# Log komutunu test et
python3 minitimer.py log

echo "Test v2 passed successfully!"
