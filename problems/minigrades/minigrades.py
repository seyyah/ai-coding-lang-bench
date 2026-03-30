"""
mini-grades v4.2
Ogrenci: M_Yemin Mevaldi (9251478112)
Tarih: 2026-03-30

Bu program basit bir ogrenci not sistemi icin yazilmistir.
Su anda sadece init ve add komutlari calismaktadir.
Diger komutlar ilerleyen haftalarda eklenecektir.
"""
"""
V1 GÖREV LÝSTESÝ (TASK LIST):
1. Veri formatýna SPEC ile uyumlu 'date' alaný eklendi ve otomatik tarih kaydý saðlandý. [cite: 6, 13]
2. Kayýt silindiðinde ID'lerin çakýþmasýný önlemek için 'en yüksek ID + 1' mantýðýna geçildi.
3. Baþlatýlmamýþ sistem hatasý SPEC dokümanýndaki "Not initialized." mesajýyla eþitlendi. 
"""

import sys
import os
from datetime import date

# Bu fonksiyon .minigrades klasorunu ve grades.dat dosyasini olusturur
def initialize():
    if os.path.exists(".minigrades"):
        return "Already initialized" [cite: 5]

    os.mkdir(".minigrades") [cite: 4]
    f = open(".minigrades/grades.dat", "w")
    f.close()
    return "Initialized empty grade system in .minigrades/" [cite: 5]

# Bu fonksiyon yeni bir ogrenci notu ekler
def add_grade(name, grade):
    if not os.path.exists(".minigrades"):
        return "Not initialized.\nRun: python minigrades.py init" [cite: 15]

    # Mevcut en yuksek ID'yi bularak çakýþmayý önler
    f = open(".minigrades/grades.dat", "r")
    lines = f.readlines()
    f.close()
    
    if not lines:
        grade_id = 1
    else:
        last_line = lines[-1]
        grade_id = int(last_line.split("|")[0]) + 1

    # SPEC formatý: id|student_name|grade|date [cite: 6, 13]
    today = str(date.today())
    f = open(".minigrades/grades.dat", "a")
    f.write(str(grade_id) + "|" + name + "|" + grade + "|" + today + "\n")
    f.close()

    return "Added grade #" + str(grade_id) + " for " + name [cite: 7]

def list_grades():
    if not os.path.exists(".minigrades"):
        return "Not initialized.\nRun: python minigrades.py init" [cite: 15]

    f = open(".minigrades/grades.dat", "r")
    lines = f.readlines()
    f.close()

    if len(lines) == 0:
        return "No grades found." [cite: 8]

    result = ""
    for i in range(len(lines)):
        parts = lines[i].strip().split("|")
        result += "[" + parts[0] + "] " + parts[1] + " - " + parts[2] [cite: 8]
        if i != len(lines) - 1:
            result += "\n"

    return result

def update_grade(grade_id, new_grade):
    if not os.path.exists(".minigrades"):
        return "Not initialized.\nRun: python minigrades.py init" [cite: 15]

    f = open(".minigrades/grades.dat", "r")
    lines = f.readlines()
    f.close()

    found = False
    for i in range(len(lines)):
        parts = lines[i].strip().split("|")
        if parts[0] == grade_id:
            parts[2] = new_grade
            lines[i] = "|".join(parts) + "\n"
            found = True
            break

    if not found:
        return "Grade #" + grade_id + " not found." [cite: 10]

    f = open(".minigrades/grades.dat", "w")
    f.writelines(lines)
    f.close()

    return "Updated grade #" + grade_id + " to " + new_grade [cite: 10]

def delete_grade(grade_id):
    if not os.path.exists(".minigrades"):
        return "Not initialized.\nRun: python minigrades.py init" [cite: 15]

    f = open(".minigrades/grades.dat", "r")
    lines = f.readlines()
    f.close()

    new_lines = []
    found = False
    for line in lines:
        parts = line.strip().split("|")
        if parts[0] == grade_id:
            found = True
            continue
        new_lines.append(line)

    if not found:
        return "Grade #" + grade_id + " not found." [cite: 12]

    f = open(".minigrades/grades.dat", "w")
    f.writelines(new_lines)
    f.close()

    return "Deleted grade #" + grade_id [cite: 12]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python minigrades.py <command> [args]")
    elif sys.argv[1] == "init":
        print(initialize())
    elif sys.argv[1] == "add":
        if len(sys.argv) < 4:
            print("Usage: python minigrades.py add <name> <grade>")
        else:
            print(add_grade(sys.argv[2], sys.argv[3]))
    elif sys.argv[1] == "list":
        print(list_grades())
    elif sys.argv[1] == "update":
        if len(sys.argv) < 4:
            print("Usage: python minigrades.py update <id> <new_grade>")
        else:
            print(update_grade(sys.argv[2], sys.argv[3]))
    elif sys.argv[1] == "delete":
        if len(sys.argv) < 3:
            print("Usage: python minigrades.py delete <id>")
        else:
            print(delete_grade(sys.argv[2]))
    else:
        print("Unknown command: " + sys.argv[1])