"""
mini-bookmark SPEC test cases
Student:Hüdanur Şener (251478066)
Project: mini-bookmark
"""
import subprocess
import os
import shutil

# --- Helper Function ---
def run_cmd(args):
    """Runs the script and returns the output."""
    result = subprocess.run(
        ["python", "minibookmark.py"] + args,
        capture_output=True,
        text=True
    )
    return result.stdout.strip()

def setup_function():
    """Clean start for each test."""
    if os.path.exists(".minibookmark"):
        shutil.rmtree(".minibookmark")

# --- 1. init COMMAND TESTS ---
def test_init_creates_directory():
    # Normal durum: İlk kez init yapilir
    run_cmd(["init"])
    assert os.path.exists(".minibookmark") == True

def test_init_already_initialized():
    # Hata durumu: Zaten init yapilmisken tekrar yapilir
    run_cmd(["init"])
    output = run_cmd(["init"])
    assert "Already initialized" in output

# --- 2. add COMMAND TESTS ---
def test_add_single_bookmark():
    # Normal durum: Bir link basariyla eklenir
    run_cmd(["init"])
    output = run_cmd(["add", "Google", "https://google.com"])
    assert "Added bookmark #1" in output

def test_add_multiple_bookmarks():
    # Normal durum: İkinci link eklenir ve ID artar
    run_cmd(["init"])
    run_cmd(["add", "A", "a.com"])
    output = run_cmd(["add", "B", "b.com"])
    assert "#2" in output

def test_add_missing_arguments():
    # Hata durumu: Eksik arguman (sadece isim)
    run_cmd(["init"])
    output = run_cmd(["add", "OnlyName"])
    assert "Usage" in output

# --- 3. ERROR HANDLING & FLOW TESTS ---
def test_command_before_init():
    # Hata durumu: Klasor yokken add komutu calismaz
    output = run_cmd(["add", "Test", "test.com"])
    assert "Not initialized" in output

def test_unknown_command_error():
    # Hata durumu: SPEC'te olmayan bir komut
    run_cmd(["init"])
    output = run_cmd(["jump"])
    assert "Unknown command" in output

# --- 4. FUTURE IMPLEMENTATION TESTS (SPEC Status) ---
def test_list_not_implemented_yet():
    # SPEC Uyumu: list komutu henuz hazir degil mesaji vermeli
    run_cmd(["init"])
    output = run_cmd(["list"])
    assert "future weeks" in output

def test_delete_not_implemented_yet():
    # SPEC Uyumu: delete komutu henuz hazir degil mesaji vermeli
    run_cmd(["init"])
    output = run_cmd(["delete", "1"])
    assert "future weeks" in output

# --- 5. USAGE TESTS ---
def test_no_arguments_usage():
    # Hata durumu: Hicbir arguman girilmezse kullanim kilavuzu basilir
    output = run_cmd([])
    assert "Usage" in output