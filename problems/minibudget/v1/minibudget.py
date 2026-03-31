# minibudget.py (V1)
import sys
import os

def baslat():
    if os.path.exists(".minibudget"):
        return "Sistem zaten hazir."
    os.mkdir(".minibudget")
    f = open(".minibudget/budget.dat", "w")
    f.close()
    return "Butce takip sistemi baslatildi."

def ekle(aciklama, miktar, kategori):
    if not os.path.exists(".minibudget"):
        return "Hata: Once 'init' yapmalisiniz."
    f = open(".minibudget/budget.dat", "a")
    f.write(aciklama + "|" + miktar + "|" + kategori + "\n")
    f.close()
    return "Kayit eklendi: " + aciklama

def listele():
    """V1 YENILIGI: Dongu kullanarak dosyadaki her seyi okur."""
    if not os.path.exists(".minibudget/budget.dat"):
        return "Henuz hic kayit yok."
    
    print("--- TUM ISLEMLER ---")
    f = open(".minibudget/budget.dat", "r")
    satir = f.readline()
    while satir:
        print("- " + satir.strip())
        satir = f.readline()
    f.close()
    return "--- Liste Sonu ---"

def ozet():
    """V1 YENILIGI: Basit bir hesaplama yapar."""
    if not os.path.exists(".minibudget/budget.dat"):
        return "Hesaplanacak veri yok."
    
    f = open(".minibudget/budget.dat", "r")
    sayac = 0
    satir = f.readline()
    while satir:
        sayac = sayac + 1
        satir = f.readline()
    f.close()
    return "Sistemde toplam " + str(sayac) + " adet islem kayitli."

def kayit_sil(silinecek_isim):
    """BONUS GOREVI: Yapay zeka yardimiyla yazilmistir. 
    Dosyadaki belirli bir harcamayi siler."""
    if not os.path.exists(".minibudget/budget.dat"):
        return "Silinecek dosya bulunamadi."

    f = open(".minibudget/budget.dat", "r")
    satirlar = f.readlines()
    f.close()

    yeni_icerik = ""
    silindi_mi = False

    # Dongu ile her satira bakiyoruz (V1 kurali)
    i = 0
    while i < len(satirlar):
        if silinecek_isim not in satirlar[i]:
            yeni_icerik = yeni_icerik + satirlar[i]
        else:
            silindi_mi = True
        i = i + 1

    # Dosyayi yeni icerikle tekrar yaziyoruz
    f = open(".minibudget/budget.dat", "w")
    f.write(yeni_icerik)
    f.close()

    if silindi_mi:
        return silinecek_isim + " basariyla silindi."
    else:
        return "Aranan kayit bulunamadi."

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Kullanim: python minibudget.py <init/add/list/summary/delete>")
    elif sys.argv[1] == "init":
        print(baslat())
    elif sys.argv[1] == "add":
        if len(sys.argv) < 5:
            print("Hata: Eksik bilgi girdiniz! (aciklama miktar kategori)")
        else:
            print(ekle(sys.argv[2], sys.argv[3], sys.argv[4]))
    elif sys.argv[1] == "list":
        print(listele())
    elif sys.argv[1] == "summary":
        print(ozet())
    elif sys.argv[1] == "delete":
        if len(sys.argv) < 3:
            print("Hata: Silinecek isim girmediniz!")
        else:
            print(kayit_sil(sys.argv[2]))
    else:
        print("Bilinmeyen komut: " + sys.argv[1])
