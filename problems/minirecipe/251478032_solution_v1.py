# V1 Görevleri:
# 1. 'update' komutu ile mevcut tarifleri güncelleyebilme
# 2. 'list' komutu ile tüm tarifleri görüntüleyebilme
# 3. 'delete' ve 'find' komutlarını işlevsel hale getirme
import sys
import os

def yardim_mesaji():
    print("\nKomutlar: open, add, list, delete, find, update")

def sistem_baslat():
    if not os.path.exists(".minirecipe"):
        os.mkdir(".minirecipe")
        print("Sistem başlatıldı. .minirecipe klasörü oluşturuldu.")
    else:
        print("Already initialized")

def tarif_ekle():
    if not os.path.exists(".minirecipe"):
        print("Not initialized, run: python minirecipe.py open")
        return

    tarif_adi = input("Title (Tarif Adı): ")
    malzemeler = input("Ingredients (Malzemeler): ")
    aciklama = input("Description (Açıklama): ")

    # Title|Ingredients|Description formatında kaydeder
    veri = tarif_adi + "|" + malzemeler + "|" + aciklama + "\n"

    dosya = open(".minirecipe/recipes.dat", "a", encoding="utf-8")
    dosya.write(veri)
    dosya.close()
    print("Tarif başarıyla kaydedildi.")

def tarif_listele():
    if os.path.exists(".minirecipe/recipes.dat"):
        dosya = open(".minirecipe/recipes.dat", "r", encoding="utf-8")
        print("\n--- Tüm Tarifler ---")
        print(dosya.read())
        dosya.close()
    else:
        print("Henüz hiç tarif eklenmemiş.")

def tarif_bul():
    if not os.path.exists(".minirecipe/recipes.dat"):
        print("Dosya bulunamadı.")
        return
        
    aranan = input("Aranacak tarif adı: ")
    dosya = open(".minirecipe/recipes.dat", "r", encoding="utf-8")
    icerik = dosya.read()
    dosya.close()
    
    if aranan in icerik:
        # Döngü kullanmadan satırı bulma hilesi:
        # Aranan kelimeden sonrasını al ve ilk satır sonuna kadar kes
        satir_devami = icerik.split(aranan)[1].split("\n")[0]
        tam_satir = aranan + satir_devami
        
        # Parçalara ayırıp (Title|Ingredients|Description) güzelce yazdırıyoruz
        detaylar = tam_satir.split("|")
        print("\n--- Tarif Bulundu ---")
        print(f"Başlık: {detaylar[0]}")
        print(f"Malzemeler: {detaylar[1]}")
        print(f"Açıklama: {detaylar[2]}")
    else:
        print("Eşleşen tarif bulunamadı.")

def tarif_sil():
    if not os.path.exists(".minirecipe/recipes.dat"):
        print("Dosya bulunamadı.")
        return

    silinecek = input("Silinecek tarifin adını tam olarak girin: ")
    dosya = open(".minirecipe/recipes.dat", "r", encoding="utf-8")
    icerik = dosya.read()
    dosya.close()

    if silinecek in icerik:
        # Orijinal içeriği bozmadan ilgili kısmı "SİLİNDİ" olarak işaretler
        yeni_icerik = icerik.replace(silinecek, f"[SİLİNDİ: {silinecek}]")
        dosya = open(".minirecipe/recipes.dat", "w", encoding="utf-8")
        dosya.write(yeni_icerik)
        dosya.close()
        print(f"'{silinecek}' kaydı silindi olarak işaretlendi.")
    else:
        print("Tarif bulunamadı.")

def tarif_guncelle():
    if not os.path.exists(".minirecipe/recipes.dat"):
        print("Dosya bulunamadı.")
        return

    eski_ad = input("Güncellemek istediğiniz tarifin adını girin: ")
    dosya = open(".minirecipe/recipes.dat", "r", encoding="utf-8")
    icerik = dosya.read()
    dosya.close()

    if eski_ad in icerik:
        yeni_ad = input("Yeni Başlık: ")
        yeni_malzeme = input("Yeni Malzemeler: ")
        yeni_aciklama = input("Yeni Açıklama: ")
        yeni_satir = yeni_ad + "|" + yeni_malzeme + "|" + yeni_aciklama
        
        # replace metodu ile döngüsüz güncelleme
        yeni_toplam_icerik = icerik.replace(eski_ad, yeni_satir)
        
        dosya = open(".minirecipe/recipes.dat", "w", encoding="utf-8")
        dosya.write(yeni_toplam_icerik)
        dosya.close()
        print("Tarif başarıyla güncellendi.")
    else:
        print("Güncellenecek tarif bulunamadı.")

def ana_program():
    print("\n--- Project: Mini-Recipe V1 ---")
    komut = input("Komutunuzu girin (open, add, list, find, delete, update): ")

    if komut == "open":
        sistem_baslat()
    elif komut == "add":
        tarif_ekle()
    elif komut == "list":
        tarif_listele()
    elif komut == "find":
        tarif_bul()
    elif komut == "delete":
        tarif_sil()
    elif komut == "update":
        tarif_guncelle()
    else:
        print("Invalid Command, please enter a valid one")

if __name__ == "__main__":
    ana_program()