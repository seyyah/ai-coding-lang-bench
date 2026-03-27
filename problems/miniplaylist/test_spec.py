"""" 
mini-playlist SPEC test script
Author: Ahmet TANGAZ
Project: mini-playlist
"""
import os
import subprocess
import shutil

# ---Yardimci fonksiyonlar---
def run_command(command):
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result.stdout.strip()

def setup_function():
    if os.path.exists(".miniplaylist"):
        shutil.rmtree(".miniplaylist")

# ---init testleri---
def test_init_creates_directory():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    assert os.path.exists(".miniplaylist"), "Error: .miniplaylist directory was not created."

def test_init_already_exists():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    output = run_command(["python", "minipl.py", "init"])
    assert "Already initialized" in output

# ---add testleri---
def test_add_one_song():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    output = run_command(["python", "minipl.py", "add", "song", "artist", "album"])
    assert "Song Added Successfully" in output
    assert "song" in output

def test_add_multiple_songs():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    run_command(["python", "minipl.py", "add", "song1", "artist1", "album1"])
    output = run_command(["python", "minipl.py", "add", "song2", "artist2", "album2"])
    assert "Song Added Successfully" in output
    assert "song2" in output

# ---list testleri---
def test_list_no_songs():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    output = run_command(["python", "minipl.py", "show"])
    assert "List is empty" in output

def test_list_one_song():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    run_command(["python", "minipl.py", "add", "song", "artist" ,"album"])
    output = run_command(["python", "minipl.py", "show"])
    assert "1" in output
    assert "song" in output
    assert "artist" in output
    assert "album" in output

def test_list_songs():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    run_command(["python", "minipl.py", "add", "song1", "artist1", "album1"])
    run_command(["python", "minipl.py", "add", "song2", "artist2", "album2"])
    output = run_command(["python", "minipl.py", "show"])
    assert "1" in output
    assert "2" in output
    assert "song1" in output
    assert "song2" in output
    assert "artist1" in output
    assert "artist2" in output
    assert "album1" in output
    assert "album2" in output

# ---remove testleri---
def test_remove_song():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    run_command(["python", "minipl.py", "add", "song", "artist", "album"])
    output = run_command(["python", "minipl.py", "remove", "1"])
    assert "Song Successfully Removed" in output
    assert "song" in output

def test_remove_nonexistent_song():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    output = run_command(["python", "minipl.py", "remove", "1"])
    assert "You don't have song to remove" in output

# ---hata testleri---
def test_command_without_init():
    setup_function()
    output = run_command(["python", "minipl.py", "add", "song", "artist", "album"])
    assert "Not initialized. Run: python minipl.py init" in output

def test_invalid_command():
    setup_function()
    output = run_command(["python", "minipl.py", "invalid"])
    assert "Unknown command: invalid" in output

# ---search testleri---
def test_search_song():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    run_command(["python", "minipl.py", "add", "song", "artist", "album"])
    output = run_command(["python", "minipl.py", "search", "song"])
    assert "song" in output
    assert "artist" in output
    assert "album" in output

def test_search_nonexistent_song():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    output = run_command(["python", "minipl.py", "search", "song"])
    assert "No matches found" in output

def test_search_remove_then_search():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    run_command(["python", "minipl.py", "add", "song", "artist", "album"])
    run_command(["python", "minipl.py", "remove", "1"])
    output = run_command(["python", "minipl.py", "search", "song"])
    assert "No matches found" in output

def test_search_case_insensitive():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    run_command(["python", "minipl.py", "add", "song", "artist", "album"])
    output = run_command(["python", "minipl.py", "search", "ART"])
    assert "song" in output
    assert "artist" in output
    assert "album" in output

def test_search_no_match():
    setup_function()
    run_command(["python", "minipl.py", "init"])
    run_command(["python", "minipl.py", "add", "song", "artist", "album"])
    output = run_command(["python", "minipl.py", "search", "dong"])
    assert "No matches found" in output

