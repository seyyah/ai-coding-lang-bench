"""
mini-todo V1 SPEC test senaryolari
"""
import subprocess
import os
import shutil

def run_cmd(args):
    result = subprocess.run(
        ["python", "solution_v1.py"] + args,
        capture_output=True,
        text=True,
        encoding='utf-8'
    )
    if result.stderr:
        return result.stderr.strip()
    return result.stdout.strip()

def setup_function():
    if os.path.exists(".minitodo"):
        shutil.rmtree(".minitodo")

def test_init_success():
    output = run_cmd(["init"])
    assert os.path.exists(".minitodo")

def test_add_success():
    run_cmd(["init"])
    output = run_cmd(["add", "Buy milk"])
    assert "Added task #1" in output

def test_list_empty():
    run_cmd(["init"])
    output = run_cmd(["list"])
    assert "No tasks found." in output

def test_list_with_tasks():
    run_cmd(["init"])
    run_cmd(["add", "Code Python"])
    output = run_cmd(["list"])
    assert "Code Python" in output
    assert "PENDING" in output

def test_done_success():
    run_cmd(["init"])
    run_cmd(["add", "Buy milk"])
    output = run_cmd(["done", "1"])
    assert "marked as done" in output
    
    # Gercekten degisti mi kontrol et
    list_out = run_cmd(["list"])
    assert "DONE" in list_out

def test_done_not_found():
    run_cmd(["init"])
    output = run_cmd(["done", "99"])
    assert "not found" in output