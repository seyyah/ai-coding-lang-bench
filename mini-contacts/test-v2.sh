import subprocess, os, shutil

def run(args):
    return subprocess.run(["python", "solution_v2.py"] + args, capture_output=True, text=True).stdout.strip()

def setup():
    if os.path.exists(".minicontacts"): shutil.rmtree(".minicontacts")

def test_full_flow():
    setup()
    run(["init"])
    run(["add", "Esmanur", "555", "esma@test.com"])
    run(["add", "Zeynep", "444", "z@test.com"])
    
    # Check if listing loop works
    assert "[1] Esmanur" in run(["list"])
    # Check if search is accurate
    assert "Esmanur" in run(["search", "esma"])
    # Check placeholder for planned features
    assert "future weeks" in run(["export", "data.txt"])
    # Check clear functionality
    run(["clear"])
    assert "No contacts found" in run(["list"])
    print("All v2 test scenarios passed!")

if __name__ == "__main__": test_full_flow()