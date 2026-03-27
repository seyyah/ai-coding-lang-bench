"""
mini-converter v0
Ogrenci: HASAN YILMAZ 250708022
"""
import sys
import os

def initialize():
    # Gerekli dizini ve bos veri dosyasini olusturur.
    if os.path.exists(".miniconv"):
        return "Already initialized."
    os.mkdir(".miniconv")
    f = open(".miniconv/history.dat", "w")
    f.close()
    return "Conversion storage initialized."

def perform_conversion(value_str, from_unit, to_unit):
    # Birim donusumu yapar ve history.dat dosyasina kaydeder.
    if not os.path.exists(".miniconv"):
        return "Error: Not initialized. Run: python miniconverter.py init"
    
    # Kullanicinin sayi girdigi varsayilmistir.
    value = float(value_str)

    # 1. ADIM: Girilen birimi metreye cevir.
    meters = 0.0
    if from_unit == "m":
        meters = value
    elif from_unit == "km":
        meters = value * 1000
    elif from_unit == "cm":
        meters = value / 100
    elif from_unit == "mm":
        meters = value / 1000
    else:
        return "Error: Unsupported unit " + from_unit

    # 2. ADIM: Metreyi istenen birime cevir.
    result = 0.0
    if to_unit == "m":
        result = meters
    elif to_unit == "km":
        result = meters / 1000
    elif to_unit == "cm":
        result = meters * 100
    elif to_unit == "mm":
        result = meters * 1000
    else:
        return "Error: Unsupported unit " + to_unit

    # 3. ADIM: Dosyaya yaz.
    f = open(".miniconv/history.dat", "a")
    f.write(str(value) + "|" + from_unit + "|" + to_unit + "|" + str(result) + "\n")
    f.close()

    return str(value) + " " + from_unit + " is " + str(result) + " " + to_unit

def show_future_message(cmd_name):
    # Henuz hazir olmayan komutlar icin uyari dondurur.
    return "Command '" + cmd_name + "' will be implemented in future weeks."

# --- ANA PROGRAM AKISI ---

# sys.argv terminalden girilen kelimeleri tutar.
if len(sys.argv) < 2:
    print("Usage: python miniconverter.py <command> [args]")
else:
    command = sys.argv[1]

    if command == "init":
        print(initialize())
    elif command == "convert":
        if len(sys.argv) < 5:
            print("Usage: python miniconverter.py convert <value> <from> <to>")
        else:
            print(perform_conversion(sys.argv[2], sys.argv[3], sys.argv[4]))
    elif command == "history":
        print(show_future_message("history"))
    elif command == "stats":
        print(show_future_message("stats"))
    else:
        print("Unknown command: " + command)
