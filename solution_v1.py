"""
mini-todo v1 — V1 Gelistirmeleri
Ogrenci: [ilayda dinçer] ([251478050])

--- V1 GOREVLERI (TASKS) ---
1. 'list' komutunu implemente et: Dosyayi while dongusuyle satir satir okuyup ekrana bas.
2. 'done' komutunu implemente et: Istenen ID'yi bul, 'PENDING' durumunu 'DONE' yap.
3. 'list' komutu calistirildiginda dosya bossa "No tasks found" hatasini ver.
----------------------------
"""

import sys
import os

def initialize():
    if os.path.exists(".minitodo"):
        return "Already initialized"
    os.mkdir(".minitodo")
    f = open(".minitodo/tasks.dat", "w")
    f.close()
    return "Initialized empty minitodo in .minitodo/"

def add_task(description):
    if not os.path.exists(".minitodo"):
        return "Not initialized. Run: python solution_v1.py init"

    f_read = open(".minitodo/tasks.dat", "r")
    content = f_read.read()
    f_read.close()

    task_id = content.count("\n") + 1

    f_append = open(".minitodo/tasks.dat", "a")
    f_append.write(str(task_id) + "|" + description + "|PENDING|2026-04-06\n")
    f_append.close()

    return "Added task #" + str(task_id) + ": " + description

def list_tasks():
    """Gorevleri listeler. V1 Gorevi #1 ve #3"""
    if not os.path.exists(".minitodo/tasks.dat"):
        return "Not initialized. Run: python solution_v1.py init"

    f = open(".minitodo/tasks.dat", "r")
    line = f.readline()

    if not line: # Dosya bossa
        f.close()
        return "No tasks found."

    output = ""
    # Listeler yasak oldugu icin while dongusu ile satir satir okuyoruz
    while line:
        output += line
        line = f.readline()

    f.close()
    return output.strip()

def mark_done(task_id):
    """Belirtilen ID'deki gorevi DONE yapar. V1 Gorevi #2"""
    if not os.path.exists(".minitodo/tasks.dat"):
        return "Not initialized. Run: python solution_v1.py init"

    f_read = open(".minitodo/tasks.dat", "r")
    new_content = ""
    found = False

    line = f_read.readline()
    while line:
        # Satir "1|" gibi istenen ID ile basliyorsa durumu degistir
        if line.startswith(str(task_id) + "|"):
            line = line.replace("PENDING", "DONE")
            found = True
        new_content += line
        line = f_read.readline()
    f_read.close()

    if not found:
        return "Task #" + str(task_id) + " not found."

    f_write = open(".minitodo/tasks.dat", "w")
    f_write.write(new_content)
    f_write.close()

    return "Task #" + str(task_id) + " marked as done."

# --- Ana Program Akisi ---
if len(sys.argv) < 2:
    print("Usage: python solution_v1.py <command> [args]")
else:
    command = sys.argv[1]

    if command == "init":
        print(initialize())
    elif command == "add":
        if len(sys.argv) < 3:
            print("Usage: python solution_v1.py add \"Task description\"")
        else:
            print(add_task(sys.argv[2]))
    elif command == "list":
        print(list_tasks())
    elif command == "done":
        if len(sys.argv) < 3:
            print("Usage: python solution_v1.py done <id>")
        else:
            print(mark_done(sys.argv[2]))
    elif command == "delete":
        print("Command 'delete' will be implemented in future weeks.")
    else:
        print("Unknown command: " + command)