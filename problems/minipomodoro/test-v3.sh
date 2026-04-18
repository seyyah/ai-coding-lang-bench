#!/bin/bash
# test-v3.sh - Testing Daily Goals and Progress Bar

echo "--- Running test-v3.sh ---"
rm -rf .minipomodoro

# Sistemi başlat ve günlük hedefi 3 olarak belirle
python3 minipomodoro.py init
python3 minipomodoro.py goal 3

# İlk görevi yap ve bitir
python3 minipomodoro.py start "Math Study"
python3 minipomodoro.py stop

# İkinci görevi başlat, duraklat, devam et ve bitir
python3 minipomodoro.py start "Read Book"
python3 minipomodoro.py pause
python3 minipomodoro.py resume
python3 minipomodoro.py stop

# İlerleme çubuğunu (Progress Bar) görmek için logları bas
python3 minipomodoro.py log

echo "--- Test v3 completed successfully ---"
