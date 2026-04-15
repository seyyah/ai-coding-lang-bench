import subprocess
import os
import shutil
import pytest

def run_cmd(args):
    result = subprocess.run(
        ["python", "inventory.py"] + args,
        capture_output=True,
        text=True
    )
    return result.stdout.strip()

def setup_function():
    if os.path.exists(".inventory"):
        shutil.rmtree(".inventory")

#Init Testleri
def test_init_creates_files():
    output = run_cmd(["init"])
    assert os.path.exists(".inventory")
    assert "initialized" in output

def test_init_twice():
    run_cmd(["init"])
    output = run_cmd(["init"])
    assert "already initialized" in output.lower()

#Add Testleri 
def test_add_product():
    run_cmd(["init"])
    output = run_cmd(["add", "Mouse", "50", "100"])
    assert "Added product #1" in output

def test_add_multiple():
    run_cmd(["init"])
    run_cmd(["add", "A", "1", "1"])
    output = run_cmd(["add", "B", "2", "2"])
    assert "#2" in output

#List Testleri
def test_list_empty():
    run_cmd(["init"])
    output = run_cmd(["list"])
    assert "empty" in output.lower()

def test_list_with_data():
    run_cmd(["init"])
    run_cmd(["add", "Monitor", "300", "5"])
    output = run_cmd(["list"])
    assert "Monitor" in output

#Hata ve Gelecek Özellik Testleri
def test_no_init_error():
    output = run_cmd(["add", "X", "1", "1"])
    assert "Run 'python inventory.py init' first" in output

def test_unknown_command():
    run_cmd(["init"])
    output = run_cmd(["jump"])
    assert "Unknown command" in output

def test_update_not_implemented():
    run_cmd(["init"])
    output = run_cmd(["update", "1", "5"])
    assert "will be implemented" in output

def test_missing_arguments():
    run_cmd(["init"])
    output = run_cmd(["add", "OnlyName"])
    assert "Usage" in output

