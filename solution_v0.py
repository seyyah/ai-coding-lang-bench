"""
mini-bookmark v0 — Basitlestirilmis implementasyon
Ogrenci: Hüdanur Şener (251478066)
Proje: mini-bookmark

Kapsam: Sadece init ve add komutlari.
Sinirlamalar: Dongu (for/while) ve liste ([]) kesinlikle kullanilmadi.
"""
import sys
import os


def initialize():
    """Bookmark dizini ve bos veri dosyasini olusturur."""
    if os.path.exists(".minibookmark"):
        return "Already initialized."

    os.mkdir(".minibookmark")
    # Bos bir dosya acip kapatmak onu olusturmak demektir
    f = open(".minibookmark/links.dat", "w")
    f.close()
    return "Initialized empty bookmark folder."


def add_bookmark(title, url):
    """Yeni bir link ekler. ID tespiti satir sayilarini sayarak yapilir."""
    # Klasor yoksa hata dondur
    if not os.path.exists(".minibookmark"):
        return "Not initialized. Run: python minibookmark.py init"

    # Mevcut dosyayi oku (ID tespiti icin)
    f = open(".minibookmark/links.dat", "r")
    content = f.read()
    f.close()

    # YASAK: Dongu ve liste kullanmadan satir sayisi bulma:
    # Dosyadaki her '\n' (yeni satir) karakteri bir kaydi temsil eder.
    bookmark_id = content.count("\n") + 1

    # Dosyaya ekleme yap (Append modu)
    f = open(".minibookmark/links.dat", "a")
    f.write(str(bookmark_id) + "|" + title + "|" + url + "|2026-03-16\n")
    f.close()

    return "Added bookmark #" + str(bookmark_id) + ": " + title


def show_not_implemented(command_name):
    """Henuz kodlanmamis ozellikler icin standart bir mesaj dondurur."""
    return "Command '" + command_name + "' will be implemented in future weeks."


# --- Ana Program Akisi ---

# Kullanici hicbir sey yazmadan programi calistirirsa
if len(sys.argv) < 2:
    print("Usage: python minibookmark.py <command> [args]")

# init komutu
elif sys.argv[1] == "init":
    print(initialize())

# add komutu
elif sys.argv[1] == "add":
    # Eger title veya url eksikse (python + dosya_adi + komut + 2 arguman = 4)
    if len(sys.argv) < 4:
        print("Usage: python minibookmark.py add <title> <url>")
    else:
        # Argumanlari fonksiyonumuza gonderiyoruz
        print(add_bookmark(sys.argv[2], sys.argv[3]))

# list komutu (Henuz implemente edilmedi)
elif sys.argv[1] == "list":
    print(show_not_implemented("list"))

# delete komutu (Henuz implemente edilmedi)
elif sys.argv[1] == "delete":
    print(show_not_implemented("delete"))

# Gecersiz bir komut girilirse
else:
    print("Unknown command: " + sys.argv[1])