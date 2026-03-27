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
    # Execute the actual command and return output
    # Using 'xargs' for simple strings, but keeping raw for multiline tests like 'list'
    result=$(python3 "$SOLUTION" "$@")
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
    local actual=$(echo "$3" | xargs) # Trim whitespace for single line comparison

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
        # Actual is not printed here to keep terminal clean during multiline failures
    fi
}

# --- Test Execution ---

echo "Running mini-grades (v2) test suite..."
echo "-------------------------------------"

# --- add student tests ---
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

# --- add grade tests ---
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

setup
run_cmd add 101 Berke > /dev/null
response=$(run_cmd add-grade 101 101)
assert_equals "test_add_grade_out_of_range" "Invalid grade: Grades must be between 0 and 100." "$response"

# --- delete student tests ---
setup
run_cmd add 101 Berke > /dev/null
response=$(run_cmd delete 101)
assert_equals "test_delete_student_success" "Student and all grades deleted successfully." "$response"

setup
response=$(run_cmd delete 999)
assert_equals "test_delete_student_not_found" "Error: No student found with ID 999." "$response"

# --- delete grade tests ---
setup
run_cmd add 101 Berke > /dev/null
run_cmd add-grade 101 85 > /dev/null
response=$(run_cmd del-grade 101 85)
assert_equals "test_delete_grade_success" "Grade 85 successfully removed!" "$response"

setup
run_cmd add 101 Berke > /dev/null
run_cmd add-grade 101 85 > /dev/null
response=$(run_cmd del-grade abc 85)
assert_equals "test_delete_grade_non_numeric_id" "Invalid input: Please enter a numeric value." "$response"

setup
run_cmd add 101 Berke > /dev/null
run_cmd add-grade 101 85 > /dev/null
response=$(run_cmd del-grade 101 abc)
assert_equals "test_delete_grade_non_numeric_grade" "Invalid input: Please enter a numeric value." "$response"

setup
run_cmd add 101 Berke > /dev/null
run_cmd add-grade 101 85 > /dev/null
response=$(run_cmd del-grade 101 101)
assert_equals "test_delete_grade_out_of_range" "Invalid grade: Grades must be between 0 and 100." "$response"

setup
response=$(run_cmd del-grade 999 85)
assert_equals "test_delete_grade_student_not_found" "Error: No student found with ID 999." "$response"

setup
run_cmd add 101 Berke > /dev/null
run_cmd add-grade 101 85 > /dev/null
response=$(run_cmd del-grade 101 90)
assert_equals "test_delete_grade_not_found" "Error: Grade 90 not found for this student." "$response"

# --- calculate average tests ---
setup
run_cmd add 101 Berke > /dev/null
run_cmd add-grade 101 85 > /dev/null
response=$(run_cmd calc-avg 101)
assert_equals "test_calculate_average_success" "Average for student 101 is 85.00." "$response"

setup
response=$(run_cmd calc-avg 999)
assert_equals "test_calculate_average_student_not_found" "Error: No student found with ID 999." "$response"

setup
run_cmd add 101 Berke > /dev/null
response=$(run_cmd calc-avg 101)
assert_equals "test_could_not_calculate_average" "Error: Could not calculate average for student 101." "$response"

# --- list students tests ---
setup
run_cmd add 101 Berke > /dev/null
run_cmd add 102 Efe > /dev/null
response=$(run_cmd list)
assert_contains "test_list_students_header" "=== LIST OF STUDENTS ===" "$response"
assert_contains "test_list_students_id_101" "ID: 101" "$response"
assert_contains "test_list_students_id_102" "ID: 102" "$response"
assert_contains "test_list_students_avg_error" "Error: Could not calculate average for student 101." "$response"

setup
run_cmd add 101 Berke > /dev/null
run_cmd add-grade 101 85 > /dev/null
run_cmd add 102 Eren > /dev/null
run_cmd add-grade 102 90 > /dev/null
response=$(run_cmd list)
assert_contains "test_list_with_grades_id_101" "ID: 101" "$response"
assert_contains "test_list_with_grades_val_85" "Grades: 85" "$response"
assert_contains "test_list_with_grades_avg_102" "Average for student 102 is 90.00." "$response"

setup
response=$(run_cmd list)
assert_equals "test_list_students_empty" "Error: No students found in the system. Operation aborted." "$response"

# --- generate report tests ---
setup
run_cmd add 101 Berke > /dev/null
run_cmd add 102 Efe > /dev/null
response=$(run_cmd report)
assert_equals "test_generate_report_success" "Report saved to .minigrades/report.txt" "$response"

setup
response=$(run_cmd report)
assert_equals "test_generate_report_empty" "Error: No data available to generate a report." "$response"

# --- unknown command test ---
setup
response=$(run_cmd hello)
assert_contains "test_unknown_command" "Unknown command: hello. Please select from the menu." "$response"

echo "-------------------------------------"
echo "v2 Test execution completed."