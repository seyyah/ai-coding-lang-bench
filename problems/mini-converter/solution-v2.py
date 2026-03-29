# mini-converter v1
# Ogrenci: HASAN YILMAZ (250708022)
# Guncelleme: Buyuk/Kucuk harf duyarliligi ve 2 basamak yuvarlama eklendi.

import sys
import os

# Klasor ve dosya hazırlama islemi
def initialize():
    if os.path.exists(".miniconv"):
        return "Already initialized."
    os.mkdir(".miniconv")
    f = open(".miniconv/history.dat", "w")
    f.close()
    return "Conversion storage initialized."

# Birim donusumu ve kaydetme islemi
def perform_conversion(value_str, from_unit, to_unit):
    if not os.path.exists(".miniconv"):
        return "Error: Not initialized. Run: python miniconverter.py init"
    
    # [YENI - SPEC v1.1] Birimleri kucuk harfe cevirerek duyarliligi ortadan kaldiriyoruz
    from_unit = from_unit.lower()
    to_unit = to_unit.lower()
    
    value = float(value_str)

    # 1. ADIM: Metreye cevirme
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

    # 2. ADIM: Hedef birime cevirme
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

    # [YENI - SPEC v1.1] Sonucu virgulden sonra tam 2 basamaga yuvarliyoruz
    result = round(result, 2)

    # 3. ADIM: Dosyaya yazma
    f = open(".miniconv/history.dat", "a")
    f.write(str(value) + "|" + from_unit + "|" + to_unit + "|" + str(result) + "|2026-03-27\n")
    f.close()

    return str(value) + " " + from_unit + " is " + str(result) + " " + to_unit

# --- Ana Program Akisi ---
if len(sys.argv) < 2:
    print("Usage: python miniconverter.py <command>")
else:
    command = sys.argv[1]
    if command == "init":
        print(initialize())
    elif command == "convert":
        if len(sys.argv) < 5:
            print("Usage: python miniconverter.py convert <value> <from> <to>")
        else:
            print(perform_conversion(sys.argv[2], sys.argv[3], sys.argv[4]))
    else:
        print("Command '" + command + "' will be implemented in future weeks.")
