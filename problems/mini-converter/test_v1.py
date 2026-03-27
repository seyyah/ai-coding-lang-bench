"""
mini-converter v1 SPEC test senaryolari
Ogrenci: HASAN YILMAZ (250708022)
"""

import subprocess
import os
import shutil

def run_cmd(args):
    # [DIKKAT] Artik solution_v1.py dosyasini test ediyoruz!
    result = subprocess.run(
        ["python", "solution_v1.py"] + args,
        capture_output=True,
        text=True
    )
    return result.stdout.strip()

def setup_function():
    if os.path.exists(".miniconv"):
        shutil.rmtree(".miniconv")

def test_case_insensitivity():
    """Buyuk harf girilse bile program kucuk harf gibi calismali."""
    run_cmd(["init"])
    # Kullanici 'KM' ve 'M' yazsa da hata almamali
    output = run_cmd(["convert", "1", "KM", "M"])
    assert "1.0 km is 1000.0 m" in output.lower()

def test_decimal_precision():
    """Sonuclar tam olarak 2 basamaga yuvarlanmali."""
    run_cmd(["init"])
    # 1.234 metre normalde 123.4 santimetredir ama biz 2 basamak kurali koyduk
    output = run_cmd(["convert", "1.234", "m", "cm"])
    # Ciktinin icinde 123.40 veya 123.4 gibi temiz bir sonuc aramaliyiz
    assert "123.4" in output

def test_init_creates_folder():
    run_cmd(["init"])
    assert os.path.exists(".miniconv")

def test_convert_m_to_cm():
    run_cmd(["init"])
    output = run_cmd(["convert", "1", "m", "cm"])
    assert "1.0 m is 100.0 cm" in output

def test_unsupported_unit():
    run_cmd(["init"])
    output = run_cmd(["convert", "5", "m", "mile"])
    assert "Error" in output

def test_error_no_init():
    output = run_cmd(["convert", "1", "m", "cm"])
    assert "Not initialized" in output
