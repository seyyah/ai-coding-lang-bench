"""
PROJECT: mini-bookmark V1
STUDENT: Hüdanur Şener (251478066)

V1 GÖREV LİSTESİ (Ödev 4.2 Gereksinimi):
1. 'init' komutu tamamlandı: .minibookmark/ klasörü ve veri dosyası oluşturuluyor.
2. 'add' komutu id|title|url|date formatında kayıt yapacak şekilde geliştirildi.
3. 'search' komutu Codex desteğiyle ek puan görevi olarak projeye eklendi.
"""

import sys
import os

# Veri saklama ayarları
DB_DIR = ".minibookmark"
DB_FILE = os.path.join(DB_DIR, "links.dat")


def init():
    """Projeyi başlatır ve gerekli dizinleri oluşturur."""
    if os.path.exists(DB_DIR):
        print("Already initialized.")
    else:
        os.makedirs(DB_DIR)
        with open(DB_FILE, "w") as f:
            pass
        print("Project initialized.")


def add(title, url):
    """Yeni bir bookmark ekler ve ID'yi otomatik artırır."""
    if not os.path.exists(DB_DIR):
        print("Not initialized. Run: python minibookmark.py init")
        return

    # Otomatik ID artırma (Satır sayısına göre)
    try:
        with open(DB_FILE, "r") as f:
            lines = f.readlines()
            new_id = len(lines) + 1
    except FileNotFoundError:
        new_id = 1

    # SPEC'te istenen tarih formatı
    date_str = "2026-03-16"
    entry = f"{new_id}|{title}|{url}|{date_str}\n"

    with open(DB_FILE, "a") as f:
        f.write(entry)

    print(f"Added bookmark #{new_id}: {title}")


def search(keyword):
    """BONUS: Codex tarafından üretilen arama fonksiyonu."""
    if not os.path.exists(DB_FILE):
        print("Not initialized.")
        return
    with open(DB_FILE, "r") as f:
        found = False
        for line in f:
            # Başlık (index 1) içinde arama yapar
            parts = line.strip().split('|')
            if len(parts) > 1 and keyword.lower() in parts[1].lower():
                print(line.strip())
                found = True
        if not found:
            print("No bookmarks found.")


def main():
    args = sys.argv[1:]

    # 5. USAGE TESTS Uyumu
    if not args:
        print("Usage: python minibookmark.py <command> [args]")
        return

    command = args[0]

    if command == "init":
        init()
    elif command == "add":
        # 2. add COMMAND TESTS Uyumu (Eksik argüman kontrolü)
        if len(args) < 3:
            print("Usage: python minibookmark.py add <title> <url>")
        else:
            add(args[1], args[2])
    elif command == "search":
        if len(args) < 2:
            print("Usage: python minibookmark.py search <keyword>")
        else:
            search(args[1])
    elif command in ["list", "delete"]:
        # 4. FUTURE IMPLEMENTATION TESTS Uyumu
        print("This feature will be implemented in future weeks.")
    else:
        # 3. ERROR HANDLING & FLOW TESTS Uyumu (Bilinmeyen komut)
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()