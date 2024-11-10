#!/bin/bash

# Test script for code-packager

# Function to run the code-packager with given options and compare the output
run_test() {
    local test_name="$1"
    local options="$2"
    local expected_output_pattern="$3"

    echo "Running test: $test_name"

    output=$(./code-packager $options 2>&1) 

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

# Function to validate JSON structure
validate_json() {
    local json_file="$1"
    if ! jq empty "$json_file" > /dev/null; then
        echo "Error: Invalid JSON structure in '$json_file'."
        exit 1
    fi
}

# Get the current directory
current_dir=$(pwd)

# Test case 1: Including multiple file types
test_include_multiple_types() {
    local options="-t $current_dir -o code.json -i .sh -i .md -s 2048 -z 1"
    local expected_output_pattern=$'Output file zipped: code.zip\nJSON output saved to: code.json\nDirectory tree:'
    run_test "Including multiple file types" "$options" "$expected_output_pattern"
    validate_json "code.json"
}

# Test case 2: Excluding specific file types (without inclusion)
test_exclude_specific_types() {
    local options="-t $current_dir -o code.json -e .txt -e .md -d 1"
    local expected_output_pattern=$'JSON output saved to: code.json\nDirectory tree:'
    run_test "Excluding specific file types (without inclusion)" "$options" "$expected_output_pattern"
    validate_json "code.json"
}

# Test case 3: Packaging all file types
test_package_all_types() {
    local options="-t $current_dir -o code.json -s 10240 -g 0"
    local expected_output_pattern=$'JSON output saved to: code.json\nDirectory tree:'
    run_test "Packaging all file types" "$options" "$expected_output_pattern"
    validate_json "code.json"
}

# Test case 4: Missing required parameters
test_missing_parameters() {
    local options=""
    local expected_output_pattern=$'Directory path is required.\nUsage: ./code-packager -t <directory_path> -o <output_file> \\[options\\]'
    run_test "Missing required parameters" "$options" "$expected_output_pattern"
}

# Test case 5: Displaying version information
test_version_info() {
    local options="-v"
    local expected_output_pattern="Code Packager for Language Models - Version"
    run_test "Displaying version information" "$options" "$expected_output_pattern"
}

# Test case 6: Displaying help information
test_help_info() {
    local options="-h"
    local expected_output_pattern="Usage: ./code-packager -t <directory_path> -o <output_file> \\[options\\]"
    run_test "Displaying help information" "$options" "$expected_output_pattern"
}

# Test case 7: Empty directory
test_empty_dir() {
    local temp_dir=$(mktemp -d)
    local options="-t $temp_dir -o empty_dir.json"
    local expected_output_pattern=$'JSON output saved to: empty_dir.json\nDirectory tree:'
    run_test "Empty directory" "$options" "$expected_output_pattern"
    validate_json "empty_dir.json"
    rm -rf "$temp_dir" # Cleanup
}

# Test case 8: Respecting .gitignore
test_gitignore() {
    local temp_dir=$(mktemp -d)
    touch "$temp_dir/ignored.txt"
    echo "ignored.txt" > "$temp_dir/.gitignore"
    local options="-t $temp_dir -o gitignore_test.json"
    local expected_output_pattern=$'JSON output saved to: gitignore_test.json\nDirectory tree:'
    run_test "Respecting .gitignore" "$options" "$expected_output_pattern"
    validate_json "gitignore_test.json"
    rm -rf "$temp_dir" # Cleanup
}

# Test case 9: Invalid input option
test_invalid_option() {
    local options="-t . -o output.json -x invalid_option"
    local expected_output_pattern="^.*: illegal option -- x"
    run_test "Invalid input option" "$options" "$expected_output_pattern"
}

# Test case 10: Output directory specified
test_output_directory() {
    local temp_dir=$(mktemp -d)
    local options="-t $current_dir -o $temp_dir"
    local expected_output_pattern=$'JSON output saved to: '"$temp_dir/$(basename "$current_dir").json"$'\nDirectory tree:'
    run_test "Output directory specified" "$options" "$expected_output_pattern"
    validate_json "$temp_dir/$(basename "$current_dir").json"
    rm -rf "$temp_dir" # Cleanup
}

# Test case 11: Limiting search depth
test_max_depth() {
    local options="-t $current_dir -o code.json -m 1"
    local expected_output_pattern=$'JSON output saved to: code.json\nDirectory tree:'
    run_test "Limiting search depth" "$options" "$expected_output_pattern"
    validate_json "code.json"
}

# Test case 12: Including specific filenames
test_include_specific_filenames() {
    local temp_dir=$(mktemp -d)
    touch "$temp_dir/README.md" "$temp_dir/LICENSE"
    local options="-t $temp_dir -o code.json -I README.md -I LICENSE"
    local expected_output_pattern=$'JSON output saved to: code.json\nDirectory tree:'
    run_test "Including specific filenames" "$options" "$expected_output_pattern"
    validate_json "code.json"
    rm -rf "$temp_dir"
}

# Test case 13: Excluding specific filenames
test_exclude_specific_filenames() {
    local temp_dir=$(mktemp -d)
    touch "$temp_dir/README.md" "$temp_dir/LICENSE" "$temp_dir/test.txt"
    local options="-t $temp_dir -o code.json -E README.md -E LICENSE"
    local expected_output_pattern=$'JSON output saved to: code.json\nDirectory tree:'
    run_test "Excluding specific filenames" "$options" "$expected_output_pattern"
    validate_json "code.json"
    rm -rf "$temp_dir"
}

# Test case 14: Combining extensions and filenames
test_combine_extensions_and_filenames() {
    local temp_dir=$(mktemp -d)
    touch "$temp_dir/test.py" "$temp_dir/README.md" "$temp_dir/LICENSE"
    local options="-t $temp_dir -o code.json -i .py -I README.md -E LICENSE"
    local expected_output_pattern=$'JSON output saved to: code.json\nDirectory tree:'
    run_test "Combining extensions and filenames" "$options" "$expected_output_pattern"
    validate_json "code.json"
    rm -rf "$temp_dir"
}

# Test case 15: Case sensitivity test
test_case_sensitivity() {
    local temp_dir=$(mktemp -d)
    touch "$temp_dir/README.md" "$temp_dir/readme.md"
    local options="-t $temp_dir -o code.json -I README.md"
    local expected_output_pattern=$'JSON output saved to: code.json\nDirectory tree:'
    run_test "Case sensitivity" "$options" "$expected_output_pattern"
    validate_json "code.json"
    rm -rf "$temp_dir"
}

# Test case 16: Non-existent filename
test_nonexistent_filename() {
    local temp_dir=$(mktemp -d)
    local options="-t $temp_dir -o code.json -I NONEXISTENT"
    local expected_output_pattern=$'JSON output saved to: code.json\nDirectory tree:'
    run_test "Non-existent filename" "$options" "$expected_output_pattern"
    validate_json "code.json"
    rm -rf "$temp_dir"
}

# Cleanup function to remove generated files
cleanup() {
    rm -f code.json code.zip empty_dir.json gitignore_test.json output.json
}

# Run all test cases
test_include_multiple_types
test_exclude_specific_types
test_package_all_types
test_missing_parameters
test_version_info
test_help_info
test_empty_dir
test_gitignore
test_invalid_option
test_output_directory
test_max_depth
test_include_specific_filenames
test_exclude_specific_filenames
test_combine_extensions_and_filenames
test_case_sensitivity
test_nonexistent_filename

# Cleanup generated files
cleanup
