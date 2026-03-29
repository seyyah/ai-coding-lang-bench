# [GÜNCELLEME 2 - v0]: Akıllı Kayıt Sistemi
# - Döngü/Liste kullanmadan (No-Loop) otomatik ID sayma ve dinamik tarih damgası eklendi.
# - 'encoding="utf-8"' ve '.replace("\n", " ")' ile veri güvenliği sağlandı.

# [GÜNCELLEME 3 - v1]: Yinelemeli Listeleme
# - 'for line in f' döngüsü ile tüm kayıtları satır satır okuma özelliği eklendi.
# - '.split("|")' yöntemiyle ID, Tarih ve Mesaj ayrıştırılarak tablo formatında sunuldu.

# [GÜNCELLEME 4 - v1]: Anahtar Kelime Arama
# - Tüm günlük içeriğinde kelime bazlı tarama (Keyword Search) motoru kuruldu.
# - '.lower()' metodu ile büyük/küçük harf duyarsız, esnek arama desteği sağlandı.

"""
Mini-Diary v1.0 — Final Implementation
Developer: Kadir Enes (Samsun University)
Features: init, write (v0) | list, search (v1 - Revised)
"""
import sys
import os
import time

def initialize():
    """Gizli klasor ve bos gunluk dosyasi olusturur."""
    if os.path.exists(".minidiary"):
        return "[!] Already initialized."
    
    os.mkdir(".minidiary")
    f = open(".minidiary/diary.dat", "w", encoding="utf-8")
    f.close()
    return "[+] Initialized empty diary in .minidiary/"

def write_entry(content):
    """Yeni bir yazi ekler. (v0 Logic: No loops/lists)"""
    if not os.path.exists(".minidiary/diary.dat"):
        return "[❌] Error: Initialize first using 'init'"
    
    # ID Hesabi: Satir sayarak (Döngüsüz)
    f = open(".minidiary/diary.dat", "r", encoding="utf-8")
    full_text = f.read()
    f.close()
    
    entry_id = full_text.count("\n") + 1
    date_str = time.strftime("%Y-%m-%d") # Dinamik tarih
    
    # Mesajdaki enter'lari temizle ki ID hesabi bozulmasin
    clean_msg = content.replace("\n", " ")
    
    # Yazma Islemi (Append mode)
    f = open(".minidiary/diary.dat", "a", encoding="utf-8")
    f.write(str(entry_id) + "|" + date_str + "|" + clean_msg + "\n")
    f.close()
    
    return f"[✅] Entry saved with ID: {entry_id}"

# --- REVIZE EDILEN OZELLIKLER (v1 - Döngü Kullanıldı) ---

def list_entries():
    """Tum gunlugu listeler. (v1 Logic: Using For-Loop)"""
    if not os.path.exists(".minidiary/diary.dat"):
        return "[❌] Diary is empty or not initialized."
    
    print("\n" + "="*30)
    print("      YOUR DIARY LOGS")
    print("="*30)
    
    f = open(".minidiary/diary.dat", "r", encoding="utf-8")
    # Döngü burada devreye giriyor
    for line in f:
        parts = line.strip().split("|")
        if len(parts) == 3:
            print(f"[{parts[0]}] {parts[1]} >> {parts[2]}")
    f.close()
    return "="*30

def search_entries(keyword):
    """Icerik icinde arama yapar. (v1 Logic: Using For-Loop)"""
    print(f"\n[🔍] Searching for: '{keyword}'...")
    found = False
    
    f = open(".minidiary/diary.dat", "r", encoding="utf-8")
    for line in f:
        if keyword.lower() in line.lower():
            parts = line.strip().split("|")
            print(f"-> Found in ID [{parts[0]}]: {parts[2]}")
            found = True
    f.close()
    
    if not found:
        return "[!] No matches found."
    return "[✔] Search complete."

# --- Ana Program (CLI Manager) ---

if len(sys.argv) < 2:
    print("\n--- Mini-Diary CLI ---")
    print("Commands: init, write \"msg\", list, search \"keyword\"")

elif sys.argv[1] == "init":
    print(initialize())

elif sys.argv[1] == "write":
    if len(sys.argv) < 3:
        print("Usage: python diary.py write \"Your message\"")
    else:
        print(write_entry(sys.argv[2]))

elif sys.argv[1] == "list":
    print(list_entries())

elif sys.argv[1] == "search":
    if len(sys.argv) < 3:
        print("Usage: python diary.py search \"keyword\"")
    else:
        print(search_entries(sys.argv[2]))

else:
    print(f"Unknown command: {sys.argv[1]}")

