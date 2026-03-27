#!/bin/bash

# --- Color Definitions ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Variables ---
DATA_DIR=".minigrades"
SOLUTION="solution.py"

# --- Helper Functions ---
run_cmd() {
    # Automatically initialize before each command to stay consistent with Python run_cmd
    python3 "$SOLUTION" init > /dev/null 2>&1
    # Execute the actual command and return trimmed output
    result=$(python3 "$SOLUTION" "$@" | xargs)
    echo "$result"
}

setup() {
    # Equivalent to setup_function()
    if [ -d "$DATA_DIR" ]; then
        rm -rf "$DATA_DIR"
    fi
}

assert_equals() {
    local test_name=$1
    local expected=$2
    local actual=$3

    if [ "$actual" == "$expected" ]; then
        echo -e "${GREEN}[PASSED]${NC} $test_name"
    else
        echo -e "${RED}[FAILED]${NC} $test_name"
        echo -e "  Expected: $expected"
        echo -e "  Actual:   $actual"
    fi
}

assert_contains() {
    local test_name=$1
    local expected=$2
    local actual=$3

    if [[ "$actual" == *"$expected"* ]]; then
        echo -e "${GREEN}[PASSED]${NC} $test_name"
    else
        echo -e "${RED}[FAILED]${NC} $test_name"
        echo -e "  Expected to contain: $expected"
        echo -e "  Actual:              $actual"
    fi
}

# --- Test Execution ---

echo "Running mini-grades test suite..."
echo "---------------------------------"

# --- add tests ---
setup
response=$(run_cmd add 101 Berke)
assert_equals "test_add_student_success" "Student added successfully." "$response"

setup
run_cmd add 101 Berke > /dev/null
response=$(run_cmd add 101 Efe)
assert_equals "test_add_student_duplicate" "Error: Student with ID 101 already exists." "$response"

setup
response=$(run_cmd add abc Berke)
assert_equals "test_add_student_non_numeric_id" "Invalid input: Please enter a numeric value." "$response"

# --- add-grade tests ---
setup
run_cmd add 101 Berke > /dev/null
response=$(run_cmd add-grade 101 80)
assert_equals "test_add_grade_success" "Grades added successfully for student 101." "$response"

setup
run_cmd add 101 Berke > /dev/null
response=$(run_cmd add-grade 101 abc)
assert_equals "test_add_grade_non_numeric_grade" "Invalid input: Please enter a numeric value." "$response"

setup
response=$(run_cmd add-grade 999 80)
assert_equals "test_add_grade_student_not_found" "Error: No student found with ID 999." "$response"

# --- delete tests ---
setup
run_cmd add 101 Berke > /dev/null
response=$(run_cmd delete 101)
assert_equals "test_delete_student_success" "Student and all grades deleted successfully." "$response"

setup
response=$(run_cmd delete 999)
assert_equals "test_delete_student_not_found" "Error: No student found with ID 999." "$response"

# --- calculate tests ---
setup
run_cmd add 101 Berke > /dev/null
response=$(run_cmd average 101)
assert_equals "test_calculate_average_success" "Average calculation will be implemented in future weeks." "$response"

setup
response=$(run_cmd average 999)
assert_equals "test_calculate_average_student_not_found" "Error: No student found with ID 999." "$response"

# --- list tests ---
setup
run_cmd add 101 Berke > /dev/null
run_cmd add 102 Efe > /dev/null
response=$(run_cmd list)
assert_contains "test_list_students_success (101)" "101 | Berke" "$response"
assert_contains "test_list_students_success (102)" "102 | Efe" "$response"

setup
response=$(run_cmd list)
assert_equals "test_list_students_empty" "Error: No students found in the system. Operation aborted." "$response"

# --- report tests ---
setup
run_cmd add 101 Berke > /dev/null
run_cmd add 102 Efe > /dev/null
response=$(run_cmd report)
assert_equals "test_generate_report_success" "Report saved to .minigrades/report.txt" "$response"
if [ -f "$DATA_DIR/report.txt" ]; then
    echo -e "${GREEN}[PASSED]${NC} test_generate_report_file_exists"
else
    echo -e "${RED}[FAILED]${NC} test_generate_report_file_exists"
fi

setup
response=$(run_cmd report)
assert_equals "test_generate_report_empty" "Error: No data available to generate a report." "$response"

# --- unknown-command test ---
setup
response=$(run_cmd hello)
assert_contains "test_unknown_command" "Unknown command: hello. Please select from the menu." "$response"

echo "---------------------------------"
echo "Test execution completed."