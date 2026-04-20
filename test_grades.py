"""
mini-grades SPEC test senaryolari
Ogrenci: Davud Kılıç 251478023
Proje: mini-grades
"""
import subprocess
import os

# --- Yardimci Fonksiyon ---
def run_cmd(args):
    """Komutu calistir, stdout dondur."""
    result = subprocess.run(
        ["python", "mini-grades-v2.py"] + args,
        capture_output=True,
        text=True
    )
    return result.stdout.strip()

def setup():
    """Her testten once grades.txt'yi sil, temiz baslangic."""
    if os.path.exists("grades.txt"):
        os.remove("grades.txt")

# --- init testleri ---
def test_init_creates_file():
    setup()
    run_cmd(["init"])
    assert os.path.exists("grades.txt"), "grades.txt olusturulmali"

def test_init_already_exists():
    setup()
    run_cmd(["init"])
    output = run_cmd(["init"])
    assert "Already initialized" in output

# --- ogrenci-ekle testleri ---
def test_add_student_success():
    setup()
    run_cmd(["init"])
    output = run_cmd(["ogrenci-ekle", "Ali Veli"])
    assert "Added student #1" in output
    assert "Ali Veli" in output

def test_add_student_id_increments():
    setup()
    run_cmd(["init"])
    run_cmd(["ogrenci-ekle", "Ali Veli"])
    output = run_cmd(["ogrenci-ekle", "Ayse Kaya"])
    assert "#2" in output

def test_add_student_saved_to_file():
    setup()
    run_cmd(["init"])
    run_cmd(["ogrenci-ekle", "Ali Veli"])
    f = open("grades.txt", "r", encoding="utf-8")
    content = f.read()
    f.close()
    assert "STUDENT|1|Ali Veli" in content

def test_add_student_turkish_chars():
    setup()
    run_cmd(["init"])
    output = run_cmd(["ogrenci-ekle", "Şükrü Çelik"])
    assert "Şükrü Çelik" in output

def test_add_student_before_init():
    setup()
    output = run_cmd(["ogrenci-ekle", "Ali Veli"])
    assert "Not initialized" in output

def test_add_student_missing_arg():
    setup()
    run_cmd(["init"])
    output = run_cmd(["ogrenci-ekle"])
    assert "Usage" in output

# --- genel hata testleri ---
def test_no_command():
    setup()
    output = run_cmd([])
    assert "Usage" in output

def test_unknown_command():
    setup()
    run_cmd(["init"])
    output = run_cmd(["ucur"])
    assert "Unknown command" in output

# --- ara testleri (v2) ---
def test_search_finds_student():
    setup()
    run_cmd(["init"])
    run_cmd(["ogrenci-ekle", "Ali Veli"])
    run_cmd(["ogrenci-ekle", "Ayse Kaya"])
    output = run_cmd(["ara", "Ali"])
    assert "Ali Veli" in output
    assert "Ayse Kaya" not in output

def test_search_case_insensitive():
    setup()
    run_cmd(["init"])
    run_cmd(["ogrenci-ekle", "Ali Veli"])
    output = run_cmd(["ara", "ali"])
    assert "Ali Veli" in output

def test_search_no_match():
    setup()
    run_cmd(["init"])
    run_cmd(["ogrenci-ekle", "Ali Veli"])
    output = run_cmd(["ara", "Zeynep"])
    assert "No students found" in output

def test_search_missing_arg():
    setup()
    run_cmd(["init"])
    output = run_cmd(["ara"])
    assert "Usage" in output

# --- ortalama testleri (v2) ---
def test_average_correct():
    setup()
    run_cmd(["init"])
    run_cmd(["ogrenci-ekle", "Ali Veli"])
    run_cmd(["not-gir", "1", "80"])
    run_cmd(["not-gir", "1", "90"])
    output = run_cmd(["ortalama", "1"])
    assert "85.0" in output

def test_average_no_grades():
    setup()
    run_cmd(["init"])
    run_cmd(["ogrenci-ekle", "Ali Veli"])
    output = run_cmd(["ortalama", "1"])
    assert "no grades" in output

def test_average_student_not_found():
    setup()
    run_cmd(["init"])
    output = run_cmd(["ortalama", "99"])
    assert "not found" in output

def test_average_missing_arg():
    setup()
    run_cmd(["init"])
    output = run_cmd(["ortalama"])
    assert "Usage" in output

# --- not-listele testleri (v2) ---
def test_list_grades_success():
    setup()
    run_cmd(["init"])
    run_cmd(["ogrenci-ekle", "Ali Veli"])
    run_cmd(["not-gir", "1", "75"])
    run_cmd(["not-gir", "1", "90"])
    output = run_cmd(["not-listele", "1"])
    assert "75" in output
    assert "90" in output

def test_list_grades_no_grades():
    setup()
    run_cmd(["init"])
    run_cmd(["ogrenci-ekle", "Ali Veli"])
    output = run_cmd(["not-listele", "1"])
    assert "no grades" in output

def test_list_grades_student_not_found():
    setup()
    run_cmd(["init"])
    output = run_cmd(["not-listele", "5"])
    assert "not found" in output

def test_list_grades_missing_arg():
    setup()
    run_cmd(["init"])
    output = run_cmd(["not-listele"])
    assert "Usage" in output
