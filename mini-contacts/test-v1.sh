import subprocess, os, shutil

def run_cmd(args):
    return subprocess.run(["python", "solution_v1.py"] + args, capture_output=True, text=True).stdout.strip()

def test_v1():
    if os.path.exists(".minicontacts"): shutil.rmtree(".minicontacts")
    print("Testing v1 init:", "OK" if "Initialized" in run_cmd(["init"]) else "FAIL")
    print("Testing v1 add:", "OK" if "#1" in run_cmd(["add", "Esma", "123", "e@t.com"]) else "FAIL")
    print("Testing v1 placeholder:", "OK" if "future weeks" in run_cmd(["list"]) else "FAIL")

if __name__ == "__main__": test_v1()