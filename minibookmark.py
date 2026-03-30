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

# Veri saklama yolları [cite: 2, 6]
DB_DIR = ".minibookmark"
DB_FILE = os.path.join(DB_DIR, "links.dat")


def init():
    """Projeyi başlatır ve gerekli dosyayı oluşturur[cite: 3]."""
    if os.path.exists(DB_DIR):
        print("Already initialized.")
    else:
        os.makedirs(DB_DIR)
        open(DB_FILE, "w").close()
        print("Project initialized.")


def add(title, url):
    """Yeni bir bookmark ekler[cite: 4]."""
    if not os.path.exists(DB_DIR):
        print("Not initialized. Run: python minibookmark.py init")
    else:
        try:
            with open(DB_FILE, "r") as f:
                new_id = len(f.readlines()) + 1
        except FileNotFoundError:
            new_id = 1

        date_str = "2026-03-16"  # SPEC'teki sabit tarih formatı [cite: 6]
        entry = f"{new_id}|{title}|{url}|{date_str}\n"

        with open(DB_FILE, "a") as f:
            f.write(entry)
        print(f"Added bookmark #{new_id}: {title}")


def search(keyword):
    """BONUS: Codex ile üretilen arama fonksiyonu[cite: 42]."""
    if not os.path.exists(DB_FILE):
        print("Not initialized.")
        return
    with open(DB_FILE, "r") as f:
        found = False
        for line in f:
            if keyword.lower() in line.split('|')[1].lower():
                print(line.strip())
                found = True
        if not found:
            print("No bookmarks found.")


def main():
    args = sys.argv[1:]

    if not args:
        print("Usage: python minibookmark.py <command> [args]")
        return

    command = args[0]

    if command == "init":
        init()
    elif command == "add":
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
        # Gelecek haftalar için yer tutucu mesaj
        print("This feature will be implemented in future weeks.")
    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()