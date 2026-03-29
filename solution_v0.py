import sys
import os

def initialize():
    # Klasor varsa uyar, yoksa yarat ve icine baslangic degerlerini yaz
    if os.path.exists(".minipool"):
        return "Already initialized"
    
    os.mkdir(".minipool")
    dosya = open(".minipool/state.dat", "w")
    dosya.write("100.0|100.0|10.0|10.0")
    dosya.close()
    return "Initialized mini-pool in .minipool/"

def move_ball():
    # Sistem kurulu degilse hata ver
    if not os.path.exists(".minipool"):
        return "Not initialized. Run: python solution_v0.py init"
    
    # Mevcut konumu dosyadan oku
    dosya = open(".minipool/state.dat", "r")
    veri = dosya.read()
    dosya.close()
    
    # String'i parcalayip float'a cevir (dongu veya liste yok, manuel yapiyoruz)
    parcalar = veri.split("|")
    x = float(parcalar[0])
    y = float(parcalar[1])
    vx = float(parcalar[2])
    vy = float(parcalar[3])
    
    # Yeni konumu hesapla
    yeni_x = x + vx
    yeni_y = y + vy
    
    # Yeni konumu dosyaya geri yaz
    dosya = open(".minipool/state.dat", "w")
    dosya.write(str(yeni_x) + "|" + str(yeni_y) + "|" + str(vx) + "|" + str(vy))
    dosya.close()
    
    return "Ball moved to (" + str(yeni_x) + ", " + str(yeni_y) + ")"

def status_komutu():
    return "Command 'status' will be implemented in future weeks."

# --- PROGRAMIN ANA GOVDESI ---
if len(sys.argv) < 2:
    print("Usage: python solution_v0.py <command>")
elif sys.argv[1] == "init":
    print(initialize())
elif sys.argv[1] == "move":
    print(move_ball())
elif sys.argv[1] == "status":
    print(status_komutu())
else:
    print("Unknown command: " + sys.argv[1])