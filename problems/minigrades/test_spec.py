"""
mini-grades SPEC test senaryolari
Ogrenci: M_Yemin Mevaldi (9251478112)
Proje: mini-grades
"""

import subprocess
import os
import shutil

# Komut calistirma fonksiyonu
def run_cmd(args):
    result = subprocess.run(
        ["python", "minigrades.py"] + args,
        capture_output=True,
        text=True
    )
    return result.stdout.strip()

# Her testten once klasoru temizle
def setup_function():
    if os.path.exists(".minigrades"):
        shutil.rmtree(".minigrades")

def test_init_creates_directory():
    run_cmd(["init"])
    assert os.path.exists(".minigrades")
    assert os.path.exists(".minigrades/grades.dat")

def test_add_grade():
    run_cmd(["init"])
    output = run_cmd(["add", "Alice", "85"])
    assert "Added grade #1" in output

def test_list_shows_grades():
    run_cmd(["init"])
    run_cmd(["add", "Alice", "85"])
    output = run_cmd(["list"])
    assert "Alice" in output
    assert "85" in output

def test_update_grade():
    run_cmd(["init"])
    run_cmd(["add", "Alice", "85"])
    output = run_cmd(["update", "1", "95"])
    assert "Updated grade #1" in output

def test_delete_grade():
    run_cmd(["init"])
    run_cmd(["add", "Alice", "85"])
    run_cmd(["delete", "1"])
    output = run_cmd(["list"])
    assert "No grades found" in output

def test_command_before_init():
    output = run_cmd(["add", "Alice", "85"])
    assert "Not initialized" in output