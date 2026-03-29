import subprocess
import os
import shutil

def run_cmd(args):
    # Yazdigimiz kodu terminalde calistirip ciktisini alir
    result = subprocess.run(["python", "solution_v0.py"] + args, capture_output=True, text=True)
    return result.stdout.strip()

def setup_function():
    # Her testten once ortami temizler
    if os.path.exists(".minipool"):
        shutil.rmtree(".minipool")

def test_init_klasor_olusturur():
    run_cmd(["init"])
    assert os.path.exists(".minipool/state.dat"), "Dosya olusmadi!"

def test_init_ikinci_kez_calisirsa_uyarir():
    run_cmd(["init"])
    cikti = run_cmd(["init"])
    assert "Already initialized" in cikti

def test_init_olmadan_move_calismaz():
    cikti = run_cmd(["move"])
    assert "Not initialized" in cikti
    # --- KALAN 7 TEST ---

def test_move_basariyla_calisir():
    run_cmd(["init"])
    cikti = run_cmd(["move"])
    assert "Ball moved to" in cikti

def test_status_henuz_eklenmedi_mesaji_verir():
    cikti = run_cmd(["status"])
    assert "will be implemented" in cikti

def test_yanlis_komut_hata_verir():
    cikti = run_cmd(["sacma_sapan_komut"])
    assert "Unknown command" in cikti

def test_hic_komut_girilmezse_kullanim_uyarisi_verir():
    cikti = run_cmd([])
    assert "Usage: python" in cikti

def test_move_sonrasi_dosya_guncellenir():
    run_cmd(["init"])
    run_cmd(["move"])
    dosya = open(".minipool/state.dat", "r")
    veri = dosya.read()
    dosya.close()
    # Ilk degerler x=100 ve hiz=10 oldugu icin move sonrasi x=110 olmali
    assert "110.0" in veri

def test_art_arda_iki_kere_move_calisir():
    run_cmd(["init"])
    run_cmd(["move"])
    cikti = run_cmd(["move"])
    assert "Ball moved to" in cikti

def test_komutlar_buyuk_kucuk_harfe_duyarlidir():
    # 'init' yerine 'INIT' yazilirsa sistem bunu tanimamalidir
    cikti = run_cmd(["INIT"]) 
    assert "Unknown command" in cikti