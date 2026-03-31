# spec-test.py (V1)
import subprocess
import os
import shutil

def run_cmd(args):
    # Programi terminalden calistirip sonucunu alir
    result = subprocess.run(["python", "minibudget.py"] + args, capture_output=True, text=True)
    return result.stdout.strip()

def test_everything():
    # Eski veriyi temizle
    if os.path.exists(".minibudget"):
        shutil.rmtree(".minibudget")
    
    # 1. Test: Init
    print("Test 1 (Init):", end=" ")
    run_cmd(["init"])
    if os.path.exists(".minibudget"):
        print("GECTI")
    else:
        print("KALDI")

    # 2. Test: Add
    print("Test 2 (Add):", end=" ")
    res = run_cmd(["add", "Kira", "5000", "Ev"])
    if "Kayit eklendi" in res:
        print("GECTI")
    else:
        print("KALDI")

    # 3. Test: List
    print("Test 3 (List):", end=" ")
    res = run_cmd(["list"])
    if "Kira" in res and "5000" in res:
        print("GECTI")
    else:
        print("KALDI")

    # 4. Test: Delete
    print("Test 4 (Delete):", end=" ")
    res = run_cmd(["delete", "Kira"])
    if "basariyla silindi" in res:
        print("GECTI")
    else:
        print("KALDI")

if __name__ == "__main__":
    test_everything()
