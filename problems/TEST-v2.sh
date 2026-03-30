#!/bin/bash
# test-v2.sh - Testing SPEC2 functionality (init, add, clear, error handling)

echo "--- Running test-v2.sh (SPEC2 v2.0) ---"

# Step 1: Start fresh by removing any existing data environment
rm -rf .todo_data

# Step 2: Initialize the environment
# Expected Output: [SYSTEM] New data environment created in .todo_data/.
echo "[TEST 1] Initializing SPEC2 Environment..."
python3 todo.py init

# Step 3: Add tasks to populate the registry
# Each task follows the priority 1-3 rule
echo "[TEST 2] Adding Sample Data..."
python3 todo.py add "Buy groceries" 2
python3 todo.py add "Study for Calculus exam" 1
python3 todo.py add "Update GitHub profile" 3

# Step 4: Verify the list contains 3 items
echo "[TEST 3] Listing Current Tasks..."
python3 todo.py list

# Step 5: Test the NEW 'clear' command (SPEC2 Feature)
# Behavior: Wipes all entries but keeps the .todo_data structure
# Expected Output: [CLEANUP] All entries have been purged. Registry is now empty.
echo "[TEST 4] Purging Registry with CLEAR Command..."
python3 todo.py clear

# Step 6: Verify the registry is empty after clear
# Expected Output: [LOG] Storage is currently empty.
echo "[TEST 5] Final List Verification (Expected Empty)..."
python3 todo.py list

# Step 7: Test Error Handling for Invalid Commands
# Expected Output: [ERROR] Unknown command: <input_command>.
echo "[TEST 6] Testing Invalid Command Handling..."
python3 todo.py unknown_action

echo "--- Test v2 completed successfully ---"
