#!/bin/bash
# mini-todo SPEC v2 - Clear Command Test

echo "[TEST] Ortam hazirlaniyor..."
python3 todo.py init

echo "[TEST] Gorevler ekleniyor..."
python3 todo.py add "Silinecek tamamlanmis gorev" 1
python3 todo.py add "Kalacak aktif gorev" 2

echo "[TEST] Ilk gorev DONE yapiliyor..."
python3 todo.py done 1

echo "[TEST] Temizlik oncesi liste:"
python3 todo.py list

echo "[TEST] CLEAR komutu calistiriliyor..."
python3 todo.py clear

echo "[TEST] Temizlik sonrasi son durum:"
python3 todo.py list
