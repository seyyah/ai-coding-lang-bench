import sys
import os

# 1. ADIM: Komutları kontrol etme
if len(sys.argv) < 2:
    print("Usage: python solution_v0.py <command> [args]")
    sys.exit()

komut = sys.argv[1]

# 2. ADIM: Kurulum (init) kısmı
if komut == "init":
    if os.path.exists(".bookmarks"):
        print("Already initialized")
    else:
        os.mkdir(".bookmarks")
        dosya = open(".bookmarks/marks.dat", "w")
        dosya.close()
        print("Sistem kuruldu.")

# 3. ADIM: Kitap ekleme (add) kısmı
elif komut == "add":
    if not os.path.exists(".bookmarks"):
        print("Once init yapmalisin!")
    elif len(sys.argv) < 4:
        print("Eksik bilgi: Kitap adi ve sayfa girin.")
    else:
        kitap = sys.argv[2]
        sayfa = sys.argv[3]
        
        # Dosyaya ekleme yapıyoruz
        f = open(".bookmarks/marks.dat", "a")
        f.write(kitap + "|" + sayfa + "|READING|2026-03-16\n")
        f.close()
        print("Kaydedildi: " + kitap)

# 4. ADIM: Henüz yapmadığımız komutlar
elif komut == "list" or komut == "last":
    print("Bu ozellik haftaya eklenecek.")

# 5. ADIM: Yanlış komut
else:
    print("Bilinmeyen komut: " + komut)