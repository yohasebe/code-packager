#!/bin/bash

# Test script for code-unpackager

# Function to run the code-unpackager with given options and compare the output
run_test() {
    local test_name="$1"
    local options="$2"
    local expected_output_pattern="$3"

    echo "Running test: $test_name"

    output=$(./code-unpackager $options 2>&1)

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

# Function to create a test JSON file
create_test_json() {
    cat << EOF > test.json
{
  "files": [
    {
      "filename": "test.txt",
      "content": "This is a test file.",
      "path": "/"
    },
    {
      "filename": "binary.bin",
      "content": null,
      "path": "/subdir/"
    }
  ]
}
EOF
}

# Function to cleanup test files and directories
cleanup() {
    rm -f test.json
    rm -rf test_output
}

# Test case 1: Basic functionality
test_basic_functionality() {
    create_test_json
    local options="-j test.json -d test_output -s"
    local expected_output_pattern="Folder structure restored to: test_output"
    run_test "Basic functionality" "$options" "$expected_output_pattern"

    echo "Debug: Content of test.json:"
    cat test.json

    # Verify the created files
    if [[ -f "test_output/test.txt" ]]; then
        echo "test.txt created successfully."
    else
        echo "Failed to create test.txt"
    fi

    if [[ -f "test_output/subdir/binary.bin" ]]; then
        echo "binary.bin created successfully."
    else
        echo "Failed to create binary.bin"
    fi

    if [[ -f "test_output/test.txt" && -f "test_output/subdir/binary.bin" ]]; then
        echo "File structure verified."
    else
        echo "File structure verification failed."
    fi

    # Display the contents of the test_output directory
    echo "Contents of test_output directory:"
    ls -R test_output
}

# Test case 2: Missing required parameters
test_missing_parameters() {
    local options=""
    local expected_output_pattern="Error: Both JSON file path and destination directory are required."
    run_test "Missing required parameters" "$options" "$expected_output_pattern"
}

# Test case 3: Non-existent JSON file
test_nonexistent_json() {
    local options="-j nonexistent.json -d test_output"
    local expected_output_pattern="Error: JSON file 'nonexistent.json' does not exist."
    run_test "Non-existent JSON file" "$options" "$expected_output_pattern"
}

# Test case 4: Displaying version information
test_version_info() {
    local options="-v"
    local expected_output_pattern="Code Unpackager for Language Models - Version"
    run_test "Displaying version information" "$options" "$expected_output_pattern"
}

# Test case 5: Displaying help information
test_help_info() {
    local options="-h"
    local expected_output_pattern="Usage: ./code-unpackager -j <json_file> -d <destination_directory> \[options\]"
    run_test "Displaying help information" "$options" "$expected_output_pattern"
}

# Clean up before running tests
cleanup

# Run all test cases
test_basic_functionality
test_missing_parameters
test_nonexistent_json
test_version_info
test_help_info

# Clean up after running tests
cleanup

echo "Tests completed. All test files and directories have been removed."
