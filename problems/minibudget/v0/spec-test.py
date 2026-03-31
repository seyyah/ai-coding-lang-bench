# spec-test.py (V0)
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
    
    # 1. Test: Init klasor aciyor mu?
    print("Test 1 (Init):", end=" ")
    res = run_cmd(["init"])
    if os.path.exists(".minibudget"):
        print("GECTI")
    else:
        print("KALDI")

    # 2. Test: Veri eklenebiliyor mu?
    print("Test 2 (Add):", end=" ")
    res = run_cmd(["add", "Yemek", "100", "Gida"])
    if "Eklendi" in res:
        print("GECTI")
    else:
        print("KALDI")

if __name__ == "__main__":
    test_everything()
