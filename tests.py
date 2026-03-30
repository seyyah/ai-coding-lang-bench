import subprocess
import os
import shutil

def run_cmd(args):
    result = subprocess.run(["python3", "todo.py"] + args, capture_output=True, text=True)
    return result.stdout.strip()

def setup_function():
    if os.path.exists(".todo_data"):
        shutil.rmtree(".todo_data")

def test_init():
    run_cmd(["init"])
    assert os.path.exists(".todo_data")

def test_add_and_clear():
    run_cmd(["init"])
    run_cmd(["add", "Task 1", "1"])
    run_cmd(["done", "1"])
    output = run_cmd(["clear"])
    assert "removed" in output.lower()
