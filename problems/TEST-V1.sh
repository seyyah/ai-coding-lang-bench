#!/bin/bash
# test-v1.sh - Testing core functionality (init, add, list) for mini-todo v1.0

echo "--- Running test-v1.sh ---"

# Clean up any existing test data to ensure a fresh environment
# .todo_data is the hidden directory defined in SPEC1
rm -rf .todo_data

# Test 1: Initialize the data environment
# Expected Output: [SYSTEM] New data environment created in .todo_data/.
echo "[TEST 1] Initializing Environment..."
python3 todo.py init

# Test 2: Add initial tasks with different priorities (1-3)
# Expected Output: [SUCCESS] Entry #1 has been registered.
echo "[TEST 2] Adding Tasks..."
python3 todo.py add "Complete the algorithm lab" 1
python3 todo.py add "Review Python documentation" 3
python3 todo.py add "Fix the terminal prompt issue" 2

# Test 3: List all registered tasks
# Expected Behavior: Parses registry.txt and displays tasks grouped by status.
echo "[TEST 3] Listing Tasks..."
python3 todo.py list

# Test 4: Mark a task as completed
# Expected Output: [UPDATE] Entry #2 is now marked as CLOSED.
echo "[TEST 4] Marking Task #2 as Done..."
python3 todo.py done 2

# Test 5: Verify the final list after updates
echo "[TEST 5] Final List Verification..."
python3 todo.py list

echo "--- Test v1 completed successfully ---"
