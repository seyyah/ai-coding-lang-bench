# miniconverter v2
# AUTHOR: HASAN YILMAZ (250708022)
#
# V2 TASKS:
# 1. Validate that <value> is a numeric float to prevent runtime crashes.
# 2. Implement 'Unknown command' error handling for unrecognized CLI inputs.
# 3. Standardize 2-decimal precision for both console output and log files.
#
# DATE: 2026-04-16

import sys
import os

# Klasör ve dosya hazırlama işlemi
def initialize():
    if os.path.exists(".miniconv"):
        return "Already initialized."
    os.mkdir(".miniconv")
    # Dosyayı "w" modunda açıp kapatmak, boş bir dosya oluşturur
    f = open(".miniconv/history.dat", "w")
    f.close()
    return "Conversion storage initialized."

# Birim dönüşümü ve kaydetme işlemi
def perform_conversion(value_str, from_unit, to_unit):
    if not os.path.exists(".miniconv"):
        return "Error: Not initialized. Run: python miniconverter.py init"
    
    # TASK 1: Sayısal Değer Doğrulaması (V2)
    try:
        value = float(value_str)
    except ValueError:
        return f"Error: {value_str} is not a valid number."
    
    # V1: Harf Duyarlılığını Kaldırma
    from_unit = from_unit.lower()
    to_unit = to_unit.lower()
    
    # Birim oranları (Metre bazlı)
    ratios = {"m": 1.0, "km": 1000.0, "cm": 0.01, "mm": 0.001}
    
    if from_unit not in ratios:
        return f"Error: Unsupported unit {from_unit}. Use m, km, cm, or mm."
    if to_unit not in ratios:
        return f"Error: Unsupported unit {to_unit}. Use m, km, cm, or mm."

    # Dönüşüm Hesaplama
    meters = value * ratios[from_unit]
    result = meters / ratios[to_unit]

    # TASK 3: 2 Ondalık Basamak ve Tarih Standardizasyonu (V1/V2)
    formatted_result = "{:.2f}".format(result)
    current_date = "2026-04-16" # Günlük güncellemeler için sabit tarih

    # Dosyaya Kayıt
    f = open(".miniconv/history.dat", "a")
    f.write(f"{value}|{from_unit}|{to_unit}|{formatted_result}|{current_date}\n")
    f.close()

    return f"{value} {from_unit} is {formatted_result} {to_unit}"

# --- Ana Program Akışı ---
if len(sys.argv) < 2:
    print("Usage: python miniconverter.py <command> [args]")
else:
    command = sys.argv[1]
    
    if command == "init":
        print(initialize())
        
    elif command == "convert":
        if len(sys.argv) < 5:
            print("Usage: python miniconverter.py <command> [args]")
        else:
            print(perform_conversion(sys.argv[2], sys.argv[3], sys.argv[4]))
            
    elif command == "history":
        print("Command 'history' will be implemented in future weeks.")
        
    elif command == "stats":
        print("Command 'stats' will be implemented in future weeks.")
        
    # TASK 2: Bilinmeyen Komut Yönetimi (V2)
    else:
        print(f"Unknown command: {command}")