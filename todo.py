"""
mini-todo v1
Ogrenci: Halimenur (251478083) [cite: 1, 2]

V1 GÖREV LİSTESİ:
1. 'list' komutunu çalışır hale getir (tasks.dat dosyasını oku ve ekrana bas). [cite: 1]
2. Görev ekleme tarihini statik yerine dinamik (date.today) hale getir. [cite: 2]
3. Dosya işlemlerini 'with open' kullanarak daha güvenli hale getir. [cite: 2]
"""
import sys
import os
from datetime import date

def initialize():
    """Proje klasörünü ve veri dosyasını oluşturur."""
    if os.path.exists(".minitodo"):
        return "Already initialized"
    
    os.mkdir(".minitodo")
    # Dosya güvenli şekilde oluşturulur [cite: 2]
    with open(".minitodo/tasks.dat", "w") as f:
        pass
    return "Project initialized in .minitodo/"

def add_task(desc):
    """Yeni bir görevi ID ve dinamik tarihle dosyaya ekler."""
    if not os.path.exists(".minitodo"):
        return "Not initialized. Run: python solution_v1.py init" [cite: 1, 2]
    
    # Mevcut satır sayısına göre ID belirlenir [cite: 2]
    with open(".minitodo/tasks.dat", "r") as f:
        lines = f.readlines()
    
    task_id = len(lines) + 1
    # Bugünün tarihi sistemden otomatik alınır (V1 özelliği) [cite: 2]
    today = date.today().strftime("%Y-%m-%d")
    
    with open(".minitodo/tasks.dat", "a") as f:
        f.write(f"{task_id}|{desc}|PENDING|{today}\n")
    
    return f"Added task #{task_id}: {desc}" [cite: 2]

def list_tasks():
    """Dosyadaki tüm görevleri okur ve kullanıcıya listeler."""
    if not os.path.exists(".minitodo"):
        return "Not initialized. Run: python solution_v1.py init" [cite: 1]
    
    if not os.path.exists(".minitodo/tasks.dat"):
        return "No tasks found."

    with open(".minitodo/tasks.dat", "r") as f:
        lines = f.readlines()
    
    if not lines:
        return "No tasks found."
    
    # V1 ile eklenen listeleme formatı [cite: 1]
    output = "--- Your Tasks ---\n"
    for line in lines:
        parts = line.strip().split("|")
        # Format: [ID] Description (Status) - Date
        output += f"[{parts[0]}] {parts[1]} ({parts[2]}) - {parts[3]}\n"
    return output

def not_implemented():
    """Henüz eklenmemiş komutlar için uyarı mesajı döner."""
    return "This command is not implemented yet in v1." [cite: 1]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python solution_v1.py <command> [args]") [cite: 2]
    else:
        komut = sys.argv[1]
        
        if komut == "init":
            print(initialize())
        elif komut == "add":
            if len(sys.argv) < 3:
                print("Usage: python solution_v1.py add <description>") [cite: 2]
            else:
                print(add_task(sys.argv[2]))
        elif komut == "list":
            # V1'de aktif edilen listeleme komutu [cite: 1]
            print(list_tasks())
        elif komut == "done" or komut == "delete":
            print(not_implemented())
        else:
            print("Unknown command: " + komut) [cite: 1]
