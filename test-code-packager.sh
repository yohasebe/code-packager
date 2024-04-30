#!/bin/bash

# Test script for code-packager.sh

# Function to run the code-packager.sh with given options and compare the output
run_test() {
    local test_name=$1
    local options=$2
    local expected_output_pattern=$3

    echo "Running test: $test_name"
    output=$(./code-packager.sh $options 2>&1)

    if [[ "$output" =~ $expected_output_pattern ]]; then
        echo "Test passed: $test_name"
    else
        echo "Test failed: $test_name"
        echo "Expected output pattern:"
        echo "$expected_output_pattern"
        echo "Actual output:"
        echo "$output"
    fi
    echo "------------------------"
}

# Get the current directory
current_dir=$(pwd)

# Test case 1: Including multiple file types
test_case_1() {
    local test_name="Including multiple file types"
    local options="-t $current_dir -o code.json -i .sh -i .md -s 2048 -z 1"
    local expected_output_pattern="Output file zipped: code.zip
JSON output saved to: code.json
Directory tree:"
    run_test "$test_name" "$options" "$expected_output_pattern"
}

# Test case 2: Excluding specific file types (without inclusion)
test_case_2() {
    local test_name="Excluding specific file types (without inclusion)"
    local options="-t $current_dir -o code.json -e .txt -e .md -d 1"
    local expected_output_pattern="JSON output saved to: code.json
Directory tree:"
    run_test "$test_name" "$options" "$expected_output_pattern"
}

# Test case 3: Packaging all file types
test_case_3() {
    local test_name="Packaging all file types"
    local options="-t $current_dir -o code.json -s 10240 -g 0"
    local expected_output_pattern="JSON output saved to: code.json
Directory tree:"
    run_test "$test_name" "$options" "$expected_output_pattern"
}

# Test case 4: Missing required parameters
test_case_4() {
    local test_name="Missing required parameters"
    local options=""
    local expected_output_pattern="Directory path is required.
Usage: ./code-packager.sh -t <directory_path> -o <output_file> \[options\]"
    run_test "$test_name" "$options" "$expected_output_pattern"
}

# Test case 5: Displaying version information
test_case_5() {
    local test_name="Displaying version information"
    local options="-v"
    local expected_output_pattern="Code Packager for Language Models - Version 0.1.0"
    run_test "$test_name" "$options" "$expected_output_pattern"
}

# Test case 6: Displaying help information
test_case_6() {
    local test_name="Displaying help information"
    local options="-h"
    local expected_output_pattern="Usage: ./code-packager.sh -t <directory_path> -o <output_file> \[options\]"
    run_test "$test_name" "$options" "$expected_output_pattern"
}

# Test case 7: Empty directory
test_case_7() {
    local test_name="Empty directory"
    local temp_dir=$(mktemp -d)
    local options="-t $temp_dir -o empty_dir.json"
    # Expected output for empty directory (no files processed)
    local expected_output_pattern="JSON output saved to: empty_dir.json
Directory tree:
$temp_dir
"
    run_test "$test_name" "$options" "$expected_output_pattern"
    rm -rf "$temp_dir" # Cleanup
}

# Test case 8: Respecting .gitignore
test_case_8() {
    local test_name="Respecting .gitignore"
    local temp_dir=$(mktemp -d)
    touch "$temp_dir/ignored.txt"
    echo "ignored.txt" > "$temp_dir/.gitignore"
    local options="-t $temp_dir -o gitignore_test.json"
    local expected_output_pattern="JSON output saved to: gitignore_test.json
Directory tree:
$temp_dir
"
    run_test "$test_name" "$options" "$expected_output_pattern"
    rm -rf "$temp_dir" # Cleanup
}

# Cleanup function to remove generated files
cleanup() {
    rm -f code.json code.zip
}

# Run all test cases
test_case_1
test_case_2
test_case_3
test_case_4
test_case_5
test_case_6
test_case_7
test_case_8

# Cleanup generated files
cleanup
