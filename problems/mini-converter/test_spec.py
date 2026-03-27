"""
mini-converter SPEC test senaryolari
Ogrenci: HASAN YILMAZ 250708022
"""
import subprocess
import os
import shutil

def run_cmd(args):
    # Komutu calistirip ekran ciktisini dondurur.
    result = subprocess.run(
        ["python", "miniconverter.py"] + args,
        capture_output=True,
        text=True
    )
    return result.stdout.strip()

def setup_function():
    # Her testten once dosyaları temizler.
    if os.path.exists(".miniconv"):
        shutil.rmtree(".miniconv")

# --- TESTLER ---

def test_init_creates_folder():
    run_cmd(["init"])
    assert os.path.exists(".miniconv")

def test_init_already_exists():
    run_cmd(["init"])
    output = run_cmd(["init"])
    assert "Already initialized" in output

def test_convert_m_to_cm():
    run_cmd(["init"])
    output = run_cmd(["convert", "1", "m", "cm"])
    assert "1.0 m is 100.0 cm" in output

def test_convert_km_to_m():
    run_cmd(["init"])
    output = run_cmd(["convert", "2", "km", "m"])
    assert "2000.0 m" in output

def test_convert_unsupported_unit():
    run_cmd(["init"])
    output = run_cmd(["convert", "5", "m", "mile"])
    assert "Error" in output

def test_history_not_implemented():
    run_cmd(["init"])
    output = run_cmd(["history"])
    assert "future weeks" in output

def test_stats_not_implemented():
    run_cmd(["init"])
    output = run_cmd(["stats"])
    assert "future weeks" in output

def test_error_no_init():
    output = run_cmd(["convert", "1", "m", "cm"])
    assert "Not initialized" in output

def test_unknown_command():
    run_cmd(["init"])
    output = run_cmd(["reset"])
    assert "Unknown command" in output

def test_missing_arguments():
    run_cmd(["init"])
    output = run_cmd(["convert", "10", "m"])
    assert "Usage" in output
