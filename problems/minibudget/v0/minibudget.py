# minibudget.py (V0)
import sys
import os

def baslat():
    """Programin calismasi icin gerekli klasoru ve dosyayi acar."""
    if os.path.exists(".minibudget"):
        return "Zaten baslatilmis."
    os.mkdir(".minibudget")
    f = open(".minibudget/budget.dat", "w")
    f.close()
    return "Basariyla baslatildi."

def ekle(aciklama, miktar, kategori):
    """Yeni bir gelir veya gider kaydi ekler."""
    if not os.path.exists(".minibudget"):
        return "Hata: Once 'init' komutuyla baslatin."
    
    # Veriyi dosyaya ekliyoruz (döngüsüz, basit yazım)
    f = open(".minibudget/budget.dat", "a")
    f.write(aciklama + "|" + miktar + "|" + kategori + "\n")
    f.close()
    return "Eklendi: " + aciklama

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Kullanim: python minibudget.py <komut>")
    elif sys.argv[1] == "init":
        print(baslat())
    elif sys.argv[1] == "add":
        # add komutu icin 3 tane arguman lazim: aciklama miktar kategori
        if len(sys.argv) < 5:
            print("Eksik bilgi! Kullanim: add <aciklama> <miktar> <kategori>")
        else:
            print(ekle(sys.argv[2], sys.argv[3], sys.argv[4]))
    else:
        print("Gelecek haftalarda eklenecek komut: " + sys.argv[1])
