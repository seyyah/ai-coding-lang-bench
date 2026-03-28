# mini-timer (VERSION: v1)
A command-line Pomodoro and time-tracking application designed for deep focus.

## 🚀 V1 Features
This version upgrades the prototype into a functional tool:
* **Active Controls:** Implemented `pause`, `resume`, and `stop` commands.
* **Focus Guard:** A strict limit of **3 pauses** per task to prevent distractions.
* **Human-Readable Time:** All durations are displayed in `MM:SS` (or `HH:MM:SS`) format instead of raw seconds (Requirement 6).
* **Smart Tracking:** Real-time timestamp calculation using Python's `time` module.

## 🛠 Commands
1. `python solution_v1.py init` - Initialize the system.
2. `python solution_v1.py start "Task Name"` - Start focusing on a new task.
3. `python solution_v1.py pause` - Take a break (Max 3 pauses allowed).
4. `python solution_v1.py resume` - Resume your active task.
5. `python solution_v1.py stop` - Finish the task and display the total duration.

## 👨‍💻 Author
Ömer Faruk Aksoy (251478060)
*Developed as part of the V1 Project Milestone.*

# PROJECT: mini-timer
# VERSION: v1
# 
# V1 TASKS:
# 1. Implement pause/resume logic with a 3-pause limit.
# 2. Implement stop command to calculate total time and mark task as DONE.
# 3. Add MM:SS time formatting for all user outputs.
#
# ---------------------------------------------------------
"""
mini-timer v1 — Basitleştirilmiş implementasyon
Öğrenci: Ömer Faruk Aksoy (251478060)

Kapsam: Sadece init ve start komutları.
Sınırlamalar: Döngü ve liste henüz kullanılmadı.
  - pause, resume, stop ve log henüz implemente edilmedi.
"""
import sys
import os
import time

def format_time(seconds):
    """Saniyeyi MM:SS veya HH:MM:SS formatına çevirir."""
    seconds = int(seconds)
    if seconds < 3600:
        minutes = seconds // 60
        secs = seconds % 60
        return f"{minutes:02d}:{secs:02d}"
    else:
        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"

def initialize():
    """minitimer dizini ve boş timer.dat dosyasını oluşturur."""
    # Eğer klasör zaten varsa, işlem yapmadan uyarı ver
    if os.path.exists(".minitimer"):
        return "Already initialized"
    
    # Klasörü oluştur
    os.mkdir(".minitimer")
    # Dosyayı yazma (w) modunda açıp hemen kapatarak boş bir dosya yarat
    f = open(".minitimer/timer.dat", "w")
    f.close()
    
    return "Initialized empty minitimer in .minitimer/"

def start_task(description):
    if not os.path.exists(".minitimer"):
        return "Not initialized. Run: python minitimer.py init"
    
    current_time = int(time.time()) # Gerçek zamanı aldık
    
    f = open(".minitimer/timer.dat", "r")
    lines = f.readlines()
    f.close()
    
    task_id = len(lines) + 1
    
    f = open(".minitimer/timer.dat", "a")
    # SPEC'e uygun format: id|desc|status|elapsed|pauses|timestamp
    satir = f"{task_id}|{description}|RUNNING|0|0|{current_time}\n"
    f.write(satir)
    f.close()
    
    return f"Started task: {description}. Focus!"

def pause_task():
    if not os.path.exists(".minitimer/timer.dat"):
        return "Not initialized."

    f = open(".minitimer/timer.dat", "r")
    lines = f.readlines()
    f.close()

    if not lines:
        return "Error: No tasks found."

    # Son satırı alıp parçalıyoruz
    last_line = lines[-1].strip()
    parts = last_line.split("|")
    
    # [id, desc, status, elapsed, pauses, timestamp]
    t_id, desc, status, elapsed, pauses, timestamp = parts
    pauses = int(pauses)

    if status != "RUNNING":
        return "Error: No active task to pause."
    if pauses >= 3:
        return "Error: Pause limit reached! Keep focusing."

    # Güncelleme: Status PAUSED oldu, mola sayısı 1 arttı
    new_pauses = pauses + 1
    now = int(time.time())
    new_line = f"{t_id}|{desc}|PAUSED|{elapsed}|{new_pauses}|{now}\n"
    
    lines[-1] = new_line # Son satırı değiştirdik
    
    f = open(".minitimer/timer.dat", "w")
    f.writelines(lines)
    f.close()

    return f"Task paused. {3 - new_pauses} pauses remaining."

def resume_task():
    if not os.path.exists(".minitimer/timer.dat"):
        return "Not initialized."

    f = open(".minitimer/timer.dat", "r")
    lines = f.readlines()
    f.close()

    if not lines:
        return "No tasks found."

    last_line = lines[-1].strip()
    parts = last_line.split("|")
    t_id, desc, status, elapsed, pauses, timestamp = parts

    # Sadece PAUSED olan bir görev devam ettirilebilir
    if status != "PAUSED":
        return "Error: No paused task to resume."

    # Güncelleme: Status tekrar RUNNING oluyor
    now = int(time.time())
    new_line = f"{t_id}|{desc}|RUNNING|{elapsed}|{pauses}|{now}\n"
    
    lines[-1] = new_line
    f = open(".minitimer/timer.dat", "w")
    f.writelines(lines)
    f.close()

    return "Task resumed. Get back to work!"

def stop_task():
    if not os.path.exists(".minitimer/timer.dat"):
        return "Not initialized."

    f = open(".minitimer/timer.dat", "r")
    lines = f.readlines()
    f.close()

    if not lines:
        return "No tasks found."

    last_line = lines[-1].strip()
    parts = last_line.split("|")
    # id|desc|status|elapsed|pauses|timestamp
    t_id, desc, status, elapsed, pauses, start_timestamp = parts

    if status == "DONE":
        return "Error: Last task is already completed."

    # --- ZAMAN HESABI (V1'in kalbi) ---
    now = int(time.time())
    # Geçen saniye = Şu anki zaman - Başlangıç zamanı
    total_seconds = now - int(start_timestamp)
    
    # MM:SS Formatına çeviriyoruz (Yeni SPEC kuralımız)
    formatted_time = format_time(total_seconds)

    # Güncelleme: Durum DONE oluyor
    new_line = f"{t_id}|{desc}|DONE|{total_seconds}|{pauses}|{now}\n"
    
    lines[-1] = new_line
    f = open(".minitimer/timer.dat", "w")
    f.writelines(lines)
    f.close()

    return f"Task stopped. Total time: {formatted_time}. Good job!"

def start_task(description):
    """Yeni görev başlatır. Sadece 1. komut çalıştığı için basit versiyondur."""
    # Önce sistem kurulu mu diye bakıyoruz
    if not os.path.exists(".minitimer"):
        return "Not initialized. Run: python minitimer.py init"
    
    # Yeni eklenecek görevin ID'sini bulmak için dosyayı okuyoruz
    f = open(".minitimer/timer.dat", "r")
    content = f.read()
    f.close()
    
    task_id = content.count("\n") + 1
    
    # Dosyayı ekleme (a - append) modunda açıyoruz
    f = open(".minitimer/timer.dat", "a")
    # SPEC'teki formata göre veriyi birleştirip yazıyoruz. Zaman şimdilik sabit.
    satir = str(task_id) + "|" + description + "|RUNNING|0|0|1710345600\n"
    f.write(satir)
    f.close()
    
    return "Started task: " + description + ". Focus!"

def show_not_implemented(command_name):
    return "Command '" + command_name + "' will be implemented in future weeks."


# === ANA PROGRAM AKIŞI ===

# Eğer hiç komut girilmediyse (sadece python minitimer.py yazıldıysa)
if len(sys.argv) < 2:
    print("Usage: python minitimer.py <command> [args]")

# Eğer 1. komut "init" ise
elif sys.argv[1] == "init":
    print(initialize())

# Eğer 1. komut "start" ise
elif sys.argv[1] == "start":
    # Görev adı girilmiş mi diye kontrol et
    if len(sys.argv) < 3:
        print("Usage: python minitimer.py start <description>")
    else:
        # sys.argv[2] kullanıcının yazdığı görev adıdır (örn: "Math Study")
        print(start_task(sys.argv[2]))
elif sys.argv[1] == "pause":
    print(pause_task())

elif sys.argv[1] == "resume":
        print(resume_task())

elif sys.argv[1] == "stop":
        print(stop_task())

# Diğer tüm komutları şimdilik "sonra eklenecek" fonksiyonuna gönderiyoruz
elif sys.argv[1] == "log":
    print(show_not_implemented("log"))

# Bilinmeyen bir komut yazılırsa
else:
    print("Unknown command: " + sys.argv[1])
