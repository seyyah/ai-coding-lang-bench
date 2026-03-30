# [UPDATE 2 - v0]: Smart Entry System
# - Automatic ID counting and dynamic timestamp added without loops/lists (No-Loop).
# - Data safety ensured with 'encoding="utf-8"' and '.replace("\n", " ")'.
# [UPDATE 3 - v1]: Recursive Listing
# - Added feature to read all entries line by line using 'for line in f' loop.
# - ID, Date and Message parsed via '.split("|")' and presented in table format.
# [UPDATE 4 - v1]: Keyword Search
# - Word-based scanning (Keyword Search) engine built for entire diary content.
# - Case-insensitive, flexible search support provided with '.lower()' method.
"""
Mini-Diary v1.0 — Final Implementation
Developer: Kadir Enes (Samsun University)
Features: init, write (v0) | list, search (v1 - Revised)
"""
import sys
import os
import time
def initialize():
    """Creates hidden folder and empty diary file."""
    if os.path.exists(".minidiary"):
        return "[!] Already initialized."
    
    os.mkdir(".minidiary")
    f = open(".minidiary/diary.dat", "w", encoding="utf-8")
    f.close()
    return "[+] Initialized empty diary in .minidiary/"
def write_entry(content):
    """Adds a new entry. (v0 Logic: No loops/lists)"""
    if not os.path.exists(".minidiary/diary.dat"):
        return "[❌] Error: Initialize first using 'init'"
    
    # ID Calculation: Count lines (No-Loop)
    f = open(".minidiary/diary.dat", "r", encoding="utf-8")
    full_text = f.read()
    f.close()
    
    entry_id = full_text.count("\n") + 1
    date_str = time.strftime("%Y-%m-%d") # Dynamic date
    
    # Clean newlines in message to avoid breaking ID calculation
    clean_msg = content.replace("\n", " ")
    
    # Write Operation (Append mode)
    f = open(".minidiary/diary.dat", "a", encoding="utf-8")
    f.write(str(entry_id) + "|" + date_str + "|" + clean_msg + "\n")
    f.close()
    
    return f"[✅] Entry saved with ID: {entry_id}"
# --- REVISED FEATURES (v1 - Loop Used) ---
def list_entries():
    """Lists all diary entries. (v1 Logic: Using For-Loop)"""
    if not os.path.exists(".minidiary/diary.dat"):
        return "[❌] Diary is empty or not initialized."
    
    print("\n" + "="*30)
    print("      YOUR DIARY LOGS")
    print("="*30)
    
    f = open(".minidiary/diary.dat", "r", encoding="utf-8")
    # Loop kicks in here
    for line in f:
        parts = line.strip().split("|")
        if len(parts) == 3:
            print(f"[{parts[0]}] {parts[1]} >> {parts[2]}")
    f.close()
    return "="*30
def search_entries(keyword):
    """Searches within content. (v1 Logic: Using For-Loop)"""
    print(f"\n[🔍] Searching for: '{keyword}'...")
    found = False
    
    f = open(".minidiary/diary.dat", "r", encoding="utf-8")
    for line in f:
        if keyword.lower() in line.lower():
            parts = line.strip().split("|")
            print(f"-> Found in ID [{parts[0]}]: {parts[2]}")
            found = True
    f.close()
    
    if not found:
        return "[!] No matches found."
    return "[✔] Search complete."
# --- Main Program (CLI Manager) ---
if len(sys.argv) < 2:
    print("\n--- Mini-Diary CLI ---")
    print("Commands: init, write \"msg\", list, search \"keyword\"")
elif sys.argv[1] == "init":
    print(initialize())
elif sys.argv[1] == "write":
    if len(sys.argv) < 3:
        print("Usage: python diary.py write \"Your message\"")
    else:
        print(write_entry(sys.argv[2]))
elif sys.argv[1] == "list":
    print(list_entries())
elif sys.argv[1] == "search":
    if len(sys.argv) < 3:
        print("Usage: python diary.py search \"keyword\"")
    else:
        print(search_entries(sys.argv[2]))
else:
    print(f"Unknown command: {sys.argv[1]}")
