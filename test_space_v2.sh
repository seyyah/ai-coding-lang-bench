"""
mini-inventory SPEC V2 Test Scenarios
Author: Ceren Baş (251478031) [cite: 6]
Project: mini-inventory [cite: 6]
Version: v2
"""
import subprocess
import os
import shutil
import pytest

# --- Helper Function ---
def run_cmd(args):
    """Executes the command and returns the stripped stdout."""
    result = subprocess.run(
        ["python", "inventory.py"] + args,
        capture_output=True,
        text=True
    )
    return result.stdout.strip()

def setup_function():
    """Wipes the .inventory directory before each test for a clean start."""
    if os.path.exists(".inventory"):
        shutil.rmtree(".inventory")

# --- init Tests ---
def test_init_creates_files():
    """Verifies that init creates the directory and the data file. [cite: 7]"""
    output = run_cmd(["init"])
    assert os.path.exists(".inventory"), "The .inventory directory must be created." [cite: 8]
    assert os.path.exists(".inventory/products.dat"), "The products.dat file must be created." [cite: 8]
    assert "initialized" in output.lower()

def test_init_already_exists():
    """Verifies the error message when initializing an existing warehouse. [cite: 9]"""
    run_cmd(["init"])
    output = run_cmd(["init"])
    assert "Warehouse already initialized" in output [cite: 9]

# --- add Tests ---
def test_add_product():
    """Verifies that adding a product returns the correct success message. [cite: 10]"""
    run_cmd(["init"])
    output = run_cmd(["add", "Skirt", "300", "20"])
    assert "Added product #1: Skirt" in output [cite: 10]

def test_add_multiple_products():
    """Verifies that product IDs increment correctly."""
    run_cmd(["init"])
    run_cmd(["add", "ItemA", "10", "1"])
    output = run_cmd(["add", "ItemB", "20", "2"])
    assert "#2" in output

# --- search Tests (New in V2) ---
def test_search_product_found():
    """Verifies that search finds an existing product and prints its data."""
    run_cmd(["init"])
    run_cmd(["add", "Skirt", "300", "20"])
    output = run_cmd(["search", "Skirt"])
    assert "Skirt" in output, "The product name should be in the output."
    assert "300" in output, "The product details should be in the output."

def test_search_product_not_found():
    """Verifies the message when a product is not found."""
    run_cmd(["init"])
    output = run_cmd(["search", "Sweater"])
    assert "not found" in output.lower()

# --- Error Handling Tests ---
def test_numeric_error_for_price():
    """Verifies error message when price is not a number."""
    run_cmd(["init"])
    output = run_cmd(["add", "Skirt", "abc", "20"])
    assert "Price and quantity must be numbers" in output

def test_numeric_error_for_quantity():
    """Verifies error message when quantity is not a number."""
    run_cmd(["init"])
    output = run_cmd(["add", "Skirt", "300", "xyz"])
    assert "Price and quantity must be numbers" in output

def test_no_init_error():
    """Verifies that commands fail if init hasn't been run."""
    output = run_cmd(["list"])
    assert "Run 'python inventory.py init' first" in output

def test_unknown_command():
    """Verifies error message for commands not defined in SPEC. [cite: 11]"""
    run_cmd(["init"])
    output = run_cmd(["delete"])
    assert "Unknown command" in output [cite: 11]

def test_missing_arguments():
    """Verifies usage message for missing arguments."""
    run_cmd(["init"])
    output = run_cmd(["add", "Skirt"])
    assert "Usage" in output

# --- Future Feature Tests ---
def test_update_not_implemented():
    """Verifies that update returns a placeholder message."""
    run_cmd(["init"])
    output = run_cmd(["update", "1", "5"])
    assert "implemented" in output or "v2/v3" in output
