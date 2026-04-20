"""
mini-recipe SPEC test scenarios (V2)
Ogrenci: Merve Zeynep Beyazal (251478115)
Proje: mini-recipe
"""

import subprocess
import os
import shutil

def run_cmd(args):
    """Komutu calistirir ve stdout dondurur. V2 dosyasini hedefler."""
    result = subprocess.run(
        ["python", "solution_v2.py"] + args,
        capture_output=True,
        text=True
    )
    return result.stdout.strip()

def setup_function(function):
    """Her testten once temiz baslangic saglar."""
    if os.path.exists(".minirecipe"):
        shutil.rmtree(".minirecipe")

# --- init testleri ---
def test_init_creates_directory():
    output = run_cmd(["init"])
    assert os.path.exists(".minirecipe")
    assert os.path.exists(".minirecipe/recipes.dat")
    assert "Initialized empty mini-recipe in .minirecipe/" in output

# --- add testleri ---
def test_add_single_recipe():
    run_cmd(["init"])
    output = run_cmd(["add", "Pancakes", "Flour,Milk,Eggs", "4"])
    assert "Added recipe #1: Pancakes" in output

# --- list testleri ---
def test_list_shows_recipes():
    run_cmd(["init"])
    run_cmd(["add", "Pancakes", "Flour,Milk,Eggs", "4"])
    output = run_cmd(["list"])
    assert "[1] Pancakes" in output
    assert "Portions: 4" in output

# --- search testleri (V2 YENI OZELLIKLER) ---
def test_search_finds_by_ingredient():
    run_cmd(["init"])
    run_cmd(["add", "Pancakes", "Flour,Milk,Eggs", "4"])
    run_cmd(["add", "Omelette", "Eggs,Cheese,Butter", "2"])
    output = run_cmd(["search", "Eggs"])
    assert "[1] Pancakes" in output
    assert "[2] Omelette" in output

def test_search_finds_by_name():
    # V2: Artik isimde de arama yapabiliyor
    run_cmd(["init"])
    run_cmd(["add", "Pancakes", "Flour,Milk,Eggs", "4"])
    output = run_cmd(["search", "Pancake"])
    assert "[1] Pancakes" in output

# --- portion testleri ---
def test_portion_existing_recipe():
    run_cmd(["init"])
    run_cmd(["add", "Pancakes", "Flour,Milk,Eggs", "4"])
    output = run_cmd(["portion", "1", "8"])
    assert "Recipe #1 (Pancakes) scaled to 8" in output

# --- delete testleri (V2 YENI KOMUT) ---
def test_delete_existing_recipe():
    run_cmd(["init"])
    run_cmd(["add", "Pancakes", "Flour,Milk,Eggs", "4"])
    output = run_cmd(["delete", "1"])
    assert "Recipe #1 deleted successfully." in output
    # Silindikten sonra listede gorunmemeli
    list_output = run_cmd(["list"])
    assert "No recipes found." in list_output

def test_delete_nonexistent_recipe():
    run_cmd(["init"])
    output = run_cmd(["delete", "99"])
    assert "Recipe #99 not found." in output
