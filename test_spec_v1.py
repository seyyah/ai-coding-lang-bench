"""
mini-library V1 Test Suite
Author: [Nazlı Karagöz] ([251478051])
"""
import subprocess
import os
import shutil

#  Helper Function 
def run_code(args, input_data=None):
    """Runs the solution_v1.py file and returns the output."""

    process = subprocess.run(
        ["python", "solution_v1.py"] + args,
        input=input_data,
        capture_output=True,
        text=True,
        encoding="utf-8"
    )
    return process.stdout.strip()

def setup_clean_env():
    """Removes .minilib to start with a fresh state for each test."""
    if os.path.exists(".minilib"):
        shutil.rmtree(".minilib")

#  V1 TESTS 

def test_v1_init_and_list_empty():
    setup_clean_env()
    run_code(["init"])
    result = run_code(["list"])
    # FR5: Check if it shows empty library message
    assert "empty" in result.lower() or "not initialized" in result.lower()

def test_v1_add_and_list():
    setup_clean_env()
    run_code(["init"])
    run_code(["add", "The Hobbit"])
    result = run_code(["list"])
    # FR5: Check if the book and its status appear in the list
    assert "The Hobbit" in result
    assert "AVAILABLE" in result

def test_v1_borrow_flow():
    setup_clean_env()
    run_code(["init"])
    run_code(["add", "1984"])
    # Perform borrow
    borrow_result = run_code(["borrow", "1"])
    assert "borrowed" in borrow_result.lower()
    
    # Check if list is updated
    list_result = run_code(["list"])
    assert "BORROWED" in list_result

def test_v1_return_flow():
    setup_clean_env()
    run_code(["init"])
    run_code(["add", "Hamlet"])
    run_code(["borrow", "1"])
    # Perform return
    return_result = run_code(["return", "1"])
    assert "returned" in return_result.lower()
    
    # Check if list is back to available
    list_result = run_code(["list"])
    assert "AVAILABLE" in list_result

def test_v1_invalid_id_error():
    setup_clean_env()
    run_code(["init"])
    # FR3: Testing invalid ID error message
    result = run_code(["borrow", "99"])
    assert "Error" in result or "not found" in result.lower()

def test_v1_suggest_feature():
    setup_clean_env()
    # FR1 & FR2: Testing the interactive suggest command
    # Simulating user typing "2" (Data Science)
    result = run_code(["suggest"], input_data="2")
    assert "Python" in result or "Recommendation" in result

#  EXECUTION 

if __name__ == "__main__":
    print("Starting V1 Tests...")
    tests = [
        test_v1_init_and_list_empty,
        test_v1_add_and_list,
        test_v1_borrow_flow,
        test_v1_return_flow,
        test_v1_invalid_id_error,
        test_v1_suggest_feature
    ]
    
    passed = 0
    for test in tests:
        try:
            test()
            print(f"{test.__name__} passed!")
            passed += 1
        except AssertionError as e:
            print(f"{test.__name__} failed!")
            
    print(f"\nSummary: {passed}/{len(tests)} tests passed.")
