"""
mini-grades v2 - Basitlestirilmis implementasyon
Ogrenci: Davud Kılıç - 251478023

V2 Degisiklikleri:
  - ara komutu eklendi (string icinde arama, for dongusu ile)
  - ortalama komutu eklendi (for dongusu ile not toplama)
  - not-listele komutu eklendi (belirli bir ogrencinin notlarini listeler)

Kapsam: init, ogrenci-ekle, not-gir, listele, ara, ortalama, not-listele komutlari.
  - rapor/ogrenci-sil henuz implemente edilmedi
  - ID hesabi dosyadaki STUDENT satiri sayisina gore yapiliyor
"""

# V2 Görev Listesi:
# 1. ara komutu: isim araması (string in / for döngüsü ile)
# 2. ortalama komutu: öğrenci notlarının ortalaması (for döngüsü ile)
# 3. not-listele komutu: bir öğrencinin tüm notlarını listeler (for döngüsü ile)

import os
import sys

DATA_FILE = "grades.txt"


def init():
    if os.path.exists(DATA_FILE):
        return "Already initialized"
    f = open(DATA_FILE, "x", encoding="utf-8")
    f.close()
    return "Initialized. grades.txt created."


def add_student(name):
    if not os.path.exists(DATA_FILE):
        return "Not initialized. Run: python mini-grades-v2.py init"

    f = open(DATA_FILE, "r", encoding="utf-8")
    content = f.read()
    f.close()

    student_count = content.count("STUDENT|")
    new_id = student_count + 1

    f = open(DATA_FILE, "a", encoding="utf-8")
    f.write(f"STUDENT|{new_id}|{name}\n")
    f.close()
    return f"Added student #{new_id}: {name}"


def add_grade(ids, grade_str):
    if not os.path.exists(DATA_FILE):
        return "Not initialized. Run: python mini-grades-v2.py init"

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


def list_students():
    if not os.path.exists(DATA_FILE):
        return "Not initialized. Run: python mini-grades-v2.py init"

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


def search_student(keyword):
    """İsim araması. for döngüsü + string 'in' operatörü kullanır."""
    if not os.path.exists(DATA_FILE):
        return "Not initialized. Run: python mini-grades-v2.py init"

    f = open(DATA_FILE, "r", encoding="utf-8")
    lines = f.readlines()
    f.close()

    result = ""
    for line in lines:
        line = line.strip()
        if line.startswith("STUDENT|"):
            parts = line.split("|")
            name = parts[2]
            if keyword.lower() in name.lower():
                result += f"#{parts[1]} - {name}\n"

    if result == "":
        return f"No students found matching '{keyword}'."

    return result.strip()


def average(ids):
    """Bir öğrencinin not ortalamasını hesaplar. for döngüsü ile not toplama."""
    if not os.path.exists(DATA_FILE):
        return "Not initialized. Run: python mini-grades-v2.py init"

    f = open(DATA_FILE, "r", encoding="utf-8")
    lines = f.readlines()
    f.close()

    student_name = None
    grades = []

    for line in lines:
        line = line.strip()
        if line.startswith(f"STUDENT|{ids}|"):
            parts = line.split("|")
            student_name = parts[2]
        elif line.startswith(f"GRADE|{ids}|"):
            parts = line.split("|")
            grades.append(int(parts[2]))

    if student_name is None:
        return f"Student #{ids} not found."

    if len(grades) == 0:
        return f"Student #{ids} has no grades yet."

    total = 0
    for g in grades:
        total += g
    avg = round(total / len(grades), 2)

    return f"Student #{ids} ({student_name}) average: {avg}"


def list_grades(ids):
    """Bir öğrencinin tüm notlarını listeler. for döngüsü ile filtreleme."""
    if not os.path.exists(DATA_FILE):
        return "Not initialized. Run: python mini-grades-v2.py init"

    f = open(DATA_FILE, "r", encoding="utf-8")
    lines = f.readlines()
    f.close()

    student_name = None
    grades = []

    for line in lines:
        line = line.strip()
        if line.startswith(f"STUDENT|{ids}|"):
            parts = line.split("|")
            student_name = parts[2]
        elif line.startswith(f"GRADE|{ids}|"):
            parts = line.split("|")
            grades.append(parts[2])

    if student_name is None:
        return f"Student #{ids} not found."

    if len(grades) == 0:
        return f"Student #{ids} ({student_name}) has no grades yet."

    result = f"Student #{ids} ({student_name}) grades:\n"
    for i, g in enumerate(grades):
        result += f"  {i + 1}. {g}\n"

    return result.strip()


def del_student():
    return "Command 'ogrenci-sil' will be implemented in future weeks."


def rapor():
    return "Command 'rapor' will be implemented in future weeks."


#-----------------------------------------------------------------------#

if len(sys.argv) < 2:
    print("Usage: python mini-grades-v2.py <command> [args]")
elif sys.argv[1] == "init":
    print(init())
elif sys.argv[1] == "ogrenci-ekle":
    if len(sys.argv) < 3:
        print("Usage: python mini-grades-v2.py ogrenci-ekle <name>")
    else:
        print(add_student(sys.argv[2]))
elif sys.argv[1] == "not-gir":
    if len(sys.argv) < 4:
        print("Usage: python mini-grades-v2.py not-gir <id> <grade>")
    else:
        print(add_grade(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "listele":
    print(list_students())
elif sys.argv[1] == "ara":
    if len(sys.argv) < 3:
        print("Usage: python mini-grades-v2.py ara <keyword>")
    else:
        print(search_student(sys.argv[2]))
elif sys.argv[1] == "ortalama":
    if len(sys.argv) < 3:
        print("Usage: python mini-grades-v2.py ortalama <id>")
    else:
        print(average(sys.argv[2]))
elif sys.argv[1] == "not-listele":
    if len(sys.argv) < 3:
        print("Usage: python mini-grades-v2.py not-listele <id>")
    else:
        print(list_grades(sys.argv[2]))
else:
    print(f"Unknown command: {sys.argv[1]}")
