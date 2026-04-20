#!/bin/bash
# 1. Projeyi baslatma testi
python solution.py init | grep -qi "init" || exit 1

# 2. Gorev ekleme testi
python solution.py add "First Task" | grep -qi "Added task #1" || exit 1

# 3. Listeleme testi (Basit)
python solution.py list | grep -qi "First Task" || exit 1
