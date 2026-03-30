#---open testleri---
import os
import subprocess

def run_cmd(args):
    result = subprocess.run(["python", "solution_v0.py"] + args, capture_output=True, text=True)
    return result.stdout.strip()

def test_open_creates_directory():
    run_cmd(["open"])

    assert os.path.exists(".minirecipe"), ".minirecipe dizini olusturulmali"
    
   
    assert os.path.exists(".minirecipe/recipes.dat"), "recipes.dat dosyasi olusturulmali"
    

def test_open_already_exists():
    # 1. Adım: Önce bir kere çalıştırıp her şeyi kuruyoruz
    run_cmd(["open"]) 
    
    # 2. Adım: Her şey varken BİR KEZ DAHA 'open' diyoruz
    output = run_cmd(["open"]) 
    
    # 3. Adım: Çıktıda "Already initialized" yazıyor mu diye bakıyoruz
    assert "Already initialized" in output    
#=====================================================================================================
#=====================================================================================================    
#---add testleri---


def test_add_single_recipe():#eklenen ilk tarife bir ID'si atanıp atanmadığını kontrol eder
    
    run_cmd(["open"])#önce kütüphaneyi açıyoruz.
   
    output = run_cmd(["add", "Menemen", "Yumurta", "Pisir"])
    assert "Added recipe #1" in output 

def test_add_multiple_recipes():#birinciden sonra eklenen tariflerin ID değerinin artıp artmadığını kontrol eder.
   
    run_cmd(["open"])
    # Birinciyi ekle
    run_cmd(["add", "Cay", "Su, Cay", "Demle"])
    # İkinciyi ekle ve çıktıyı yakala
    output = run_cmd(["add", "Kahve", "Su, Kahve", "Kaynat"])
    assert "#2" in output, "İkinci tarifin ID'si #2 olmalı!"

def test_add_duplicate_recipe():
    """Aynı isimli tarifin tekrar eklenmesini engellediğini test eder."""
    # 1. Adım: Önce kütüphaneyi aç ve ilk tarifi ekle
    run_cmd(["open"])
    run_cmd(["add", "Menemen", "Yumurta", "Pisir"])
    
    # 2. Adım: Aynı isimli (Menemen) tarifi tekrar eklemeye çalış
    output = run_cmd(["add", "Menemen", "Yumurta", "Pisir"])
    
    # 3. Adım: Programın uyarı verip vermediğini kontrol et 
    assert "already exists" in output.lower(), "Aynı isimli tarif eklendiğinde uyarı vermeli"    
#===========================================================================================================
#======================================================================================================
#---list testleri---


def test_list_empty():#tariflerin listelenmesi istendiğinde tarif bulunmuyorsa böyle demeli.
    run_cmd(["open"])
    output = run_cmd(["list"])
    # Boşken bu mesajı vermeli
    assert "no recipes found" in output.lower()

def test_list_shows_recipes():#Eklenen tarifin ekranda gösterilip gösterilmediğini kontrol eder.
    run_cmd(["open"])
    run_cmd(["add", "Menemen", "Yumurta", "Pisir"])
    output = run_cmd(["list"])
    
    # Listenin içinde tarifin başlığı olmalı
    assert "Menemen" in output
    # İsteğe bağlı: Listenin içinde malzemelerden bir kesit de görünebilir
    assert "Yumurta" in output
#=======================================================================================================
#=====================================================================================================
#---delete testleri---

def test_delete_verification():#Bir tarifin silinip silinmediğini kontrol eden test
    # 1. Hazırlık: Önce dosyayı aç ve bir tarif ekle (ID 1 olsun)
    run_cmd(["open"])
    run_cmd(["add", "Menemen", "Yumurta", "Pisir"])
    
    # 2. Silme: 1 numaralı tarifi siliyoruz
    run_cmd(["delete", "1"])
    
    # 3. KONTROL: Listeyi çekiyoruz
    output = run_cmd(["list"])
    
    # Eğer "Menemen" listede YOKSA (not in), assert TRUE döner ve test geçer.
    assert "Menemen" not in output, "Hata: Menemen silinmedi, hala listede duruyor!"


def test_delete_non_existent_id():#Var olmayan bir ID silinmeye çalışıldığında hata mesajı vermeli.
    
    run_cmd(["open"])
    # Hiçbir şey eklemeden 99 nolu ID'yi silmeye çalışalım
    output = run_cmd(["delete", "99"])
    
    # "Bulunamadı" (not found) uyarısı veriyor mu?
    assert "not found" in output.lower(), "Var olmayan ID için hata uyarısı verilmedi!"
#=====================================================================================================
#==========================================================================================================
#---find testleri---


def test_find_recipe_success():# bir tarifin ismiyle arandığında detaylarının geldiğini test eder.
   
    run_cmd(["open"])
    run_cmd(["add", "Menemen", "Yumurta", "Pisir"])
    
    # "Menemen" kelimesini aratıyoruz
    output = run_cmd(["find", "Menemen"])
    
    # Kontrol: Ekranda tarifin adı ve malzemesi görünüyor mu?
    assert "Menemen" in output, "Arama sonucunda tarif başlığı bulunamadı!"
    assert "Yumurta" in output, "Arama sonucunda tarif detayları eksik geldi!"

def test_find_recipe_not_found():
    """Var olmayan bir tarif arandığında uygun hata mesajı verildiğini test eder."""
    run_cmd(["open"])
    
    # Olmayan bir "kebap" tarifini aratıyoruz
    output = run_cmd(["find", "kebap"])
    
    # Kontrol: "Bulunamadı" uyarısı veriyor mu? 
    assert "not found" in output.lower(), "Olmayan tarif arandığında hata mesajı gelmedi!"
