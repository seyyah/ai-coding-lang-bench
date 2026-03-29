"""
mini-grades v1 - Basitlestirilmis implementasyon
Ogrenci: Davud Kılıç - 251478023

V1 Degisiklikleri:
  - listele komutu eklendi (while dongusu ile dosyadan satir satir okuma)

Kapsam: init, ogrenci-ekle, not-gir, listele komutlari.
  - ortalama/rapor/ogrenci-sil henuz implemente edilmedi
  - ID hesabi dosyadaki STUDENT satiri sayisina gore yapiliyor
"""

# V1 Görev Listesi:
# 1. listele komutu eklendi (while ile satır satır okuma)
# 2. Bilinmeyen komut hatası eklendi
# 3. SPEC v1 olarak güncellendi

import os
import sys

DATA_FILE = "grades.txt"


def init():  # İlgili ".txt" dosyası yoksa oluşturur, varsa uyarır.

    if os.path.exists(DATA_FILE):
        return "Already initialized"
    f = open(DATA_FILE, "x", encoding="utf-8")
    f.close()
    return "Initialized. grades.txt created."


def add_student(name):  # Öğrenci ad-soyad bilgisi alır. Türkçe karakterlerde sorun çıkmaz.

    if not os.path.exists(DATA_FILE):
        return "Not initialized. Run: python mini-grades-v1.py init"

    f = open(DATA_FILE, "r", encoding="utf-8")
    content = f.read()
    f.close()

    student_count = content.count("STUDENT|")
    new_id = student_count + 1

    f = open(DATA_FILE, "a", encoding="utf-8")
    f.write(f"STUDENT|{new_id}|{name}\n")
    f.close()
    return f"Added student #{new_id}: {name}"


def add_grade(ids, grade_str):  # Öğrenciye not ekler. Geçerlilik kontrolü yapar, dosyaya yazar.

    if not os.path.exists(DATA_FILE):
        return "Not initialized. Run: python mini-grades-v1.py init"

    if not grade_str.lstrip("-").isdigit():
        return f"Invalid grade: {grade_str}. Must be an integer."

    grade = int(grade_str)

    if not 0 <= grade <= 100:
        return f"Invalid grade: {grade_str}. Must be between 0 and 100."

    f = open(DATA_FILE, "r", encoding="utf-8")
    content = f.read()
    f.close()

    if f"STUDENT|{ids}|" not in content:
        return f"Student #{ids} not found."

    f = open(DATA_FILE, "a", encoding="utf-8")
    f.write(f"GRADE|{ids}|{grade}\n")
    f.close()

    return f"Grade {grade} added for student #{ids}."


def list_students():  # Tüm öğrencileri sırayla ekrana basar.

    if not os.path.exists(DATA_FILE):
        return "Not initialized. Run: python mini-grades-v1.py init"

    f = open(DATA_FILE, "r", encoding="utf-8")
    lines = f.readlines()
    f.close()

    result = ""
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith("STUDENT|"):
            parts = line.split("|")
            result += f"#{parts[1]} - {parts[2]}\n"
        i += 1

    if result == "":
        return "No students found."

    return result.strip()


def average():
    return "Command 'ortalama' will be implemented in future weeks."


def del_student():
    return "Command 'ogrenci-sil' will be implemented in future weeks."


def rapor():
    return "Command 'rapor' will be implemented in future weeks."


#-----------------------------------------------------------------------#

if len(sys.argv) < 2:
    print("Usage: python mini-grades-v1.py <command> [args]")
elif sys.argv[1] == "init":
    print(init())
elif sys.argv[1] == "ogrenci-ekle":
    if len(sys.argv) < 3:
        print("Usage: python mini-grades-v1.py ogrenci-ekle <name>")
    else:
        print(add_student(sys.argv[2]))
elif sys.argv[1] == "not-gir":
    if len(sys.argv) < 4:
        print("Usage: python mini-grades-v1.py not-gir <id> <grade>")
    else:
        print(add_grade(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "listele":
    print(list_students())
else:
    print(f"Unknown command: {sys.argv[1]}")