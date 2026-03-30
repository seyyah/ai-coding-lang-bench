import sys
import os

def yardim_mesaji():
    # Kullanıcıya geçerli komutları gösterir
    print("\nKomutlar: open, add, list, delete, find")

def sistem_baslat():
    # OPEN komutu: .minirecipe klasörünü oluşturur (Sistemi başlatır)
    if not os.path.exists(".minirecipe"):
        os.mkdir(".minirecipe")
        print("Sistem başlatıldı. .minirecipe klasörü oluşturuldu.")
    else:
        # Klasör zaten varsa dökümandaki hatayı basar
        print("Already initialized")

def tarif_ekle():
    # ADD komutu: Sadece Başlık, Malzeme ve Açıklama bilgilerini pipe (|) ile kaydeder
    
    # Klasör kontrolü (Sistem başlatılmamışsa hata verir)
    if not os.path.exists(".minirecipe"):
        print("Not initialized, run: python minirecipe.py open")
        return

    # Kullanıcıdan sadece istenen 3 bilgiyi alıyoruz
    tarif_adi = input("Title (Tarif Adı): ")
    malzemeler = input("Ingredients (Malzemeler): ")
    aciklama = input("Description (Açıklama): ")

    # Veriyi formatlıyoruz: Title|Ingredients|Description
    veri = tarif_adi + "|" + malzemeler + "|" + aciklama + "\n"

    # Veriyi .minirecipe/recipes.dat dosyasına ekliyoruz
    dosya = open(".minirecipe/recipes.dat", "a", encoding="utf-8")
    dosya.write(veri)
    dosya.close()
    
    print("Tarif başarıyla kaydedildi.")

def implemente_edilmemis():
    # Henüz hazır olmayan komutlar için kural mesajını basar
    print("will be implemented")

def ana_program():
    #ana program ve komut bölümü
    print("\n--- Project: Mini-Recipe ---")
    komut = input("Komutunuzu girin (open, add, list, find, delete): ")

    if komut == "open":
        sistem_baslat()
    elif komut == "add":
        tarif_ekle()
    elif komut == "list":
        implemente_edilmemis()
    elif komut == "find":
        implemente_edilmemis()
    elif komut == "delete":
        implemente_edilmemis()
    else:
        # Geçersiz komutlar için dökümandaki hata mesajı
        print("Invalid Command, please enter a valid one")

if __name__ == "__main__":
    
    ana_program()