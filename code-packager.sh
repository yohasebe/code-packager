#!/bin/bash

# Version information
VERSION="0.1.0"

# Default values
INCLUDE_EXT=()  # Array to store include extensions
EXCLUDE_EXT=()  # Array to store exclude extensions
MAX_SIZE=10240   # 10MB in KB
RESPECT_GITIGNORE=1  # Enable respecting files as per .gitignore by default
INCLUDE_DOT_FILES=0  # Exclude dot files and folders by default
DIRECTORY_PATH=""   # Initialize directory path as empty
OUTPUT_FILE=""    # Initialize output file path as empty
ZIP_OUTPUT=0     # Disable zipping the output file by default

# Function to display help
show_help() {
    echo "Usage: $0 -t <directory_path> -o <output_file> [options]"
    echo ""
    echo "Options:"
    echo ""
    echo "  -t <directory_path>     Target directory to process."
    echo "  -o <output_file>        Output file path."
    echo "  -i <include_extension>  Include files with the specified extension (with or without the leading dot)."
    echo "  -e <exclude_extension>  Exclude files with the specified extension (with or without the leading dot)."
    echo "  -s <max_size_in_kb>     Include files up to the specified size in kilobytes."
    echo "  -g <respect_gitignore>  0 to disable, 1 to enable respecting files as per .gitignore (default: enabled)."
    echo "  -d <include_dot_files>  0 to exclude, 1 to include dot files and folders (default: excluded)."
    echo "  -z <zip_output>         0 to disable, 1 to enable zipping the output file (default: disabled)."
    echo "  -v, --version           Display version information and exit."
    echo "  -h, --help              Display this help and exit."
    echo ""
    echo "Example:"
    echo ""
    echo "  $0 -t ~/project -o output.json -i .txt -i .md -s 500 -g 0 -d 1 -z 1"
    echo ""
    echo "  This command will search in '~/project' including only '.txt' and '.md' files,"
    echo "  considering files up to 500KB, not respecting files listed in .gitignore, including dot files,"
    echo "  and zipping the output file named 'output.json'."
    echo ""
    echo "Note: Information of binary files is included in the JSON output, but their contents are not stored."
}

# Function to display version
show_version() {
    echo "Code Packager for Language Models - Version $VERSION"
}

# Function to check if a file is binary
is_binary() {
    local file="$1"
    if [[ $(file --mime "$file" | grep -o 'charset=binary') ]]; then
        return 0 # It's a binary file
    else
        return 1 # It's not a binary file
    fi
}

# Check for required dependencies
check_dependencies() {
    local dependencies=("jq" "tree" "git" "file")
    local missing_deps=0
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Error: Required dependency '$dep' is not installed."
            missing_deps=1
        fi
    done
    if [ "$missing_deps" -ne 0 ]; then
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Parse command line arguments
while getopts "t:o:i:e:s:g:d:z:vh-" opt; do
    case $opt in
        t) DIRECTORY_PATH="${OPTARG}" ;;
        o) OUTPUT_FILE="${OPTARG}" ;;
        i) INCLUDE_EXT+=("${OPTARG}") ;;  # Store in INCLUDE_EXT array
        e) EXCLUDE_EXT+=("${OPTARG}") ;;  # Store in EXCLUDE_EXT array
        s) MAX_SIZE="${OPTARG}" ;;
        g) RESPECT_GITIGNORE="${OPTARG}" ;;
        d) INCLUDE_DOT_FILES="${OPTARG}" ;;
        z) ZIP_OUTPUT="${OPTARG}" ;;
        v) show_version
           exit 0 ;;
        h) show_help
           exit 0 ;;
        -) case "${OPTARG}" in
             version) show_version
                      exit 0 ;;
             help) show_help
                  exit 0 ;;
             *) echo "Invalid option --${OPTARG}" >&2
                exit 1 ;;
           esac ;;
        \\?) echo "Invalid option -${OPTARG}" >&2
            exit 1 ;;
    esac
done

# Ensure required parameters are provided
if [ -z "$DIRECTORY_PATH" ]; then
    echo "Directory path is required."
    show_help
    exit 1
fi

if [ -z "$OUTPUT_FILE" ]; then
    echo "Output file path is required."
    show_help
    exit 1
fi

# Check dependencies before proceeding
check_dependencies

# Normalize the include and exclude extensions to ensure they start with a dot
for i in "${!INCLUDE_EXT[@]}"; do
    if [[ "${INCLUDE_EXT[$i]}" != "" && "${INCLUDE_EXT[$i]:0:1}" != "." ]]; then
        INCLUDE_EXT[$i]=".${INCLUDE_EXT[$i]}"
    fi
done

for i in "${!EXCLUDE_EXT[@]}"; do
    if [[ "${EXCLUDE_EXT[$i]}" != "" && "${EXCLUDE_EXT[$i]:0:1}" != "." ]]; then
        EXCLUDE_EXT[$i]=".${EXCLUDE_EXT[$i]}"
    fi
done

# Determine OS and set the appropriate stat command
if [[ "$OSTYPE" == "darwin"* ]]; then
    STAT_CMD="stat -f%z"
else
    STAT_CMD="stat -c%s"
fi

# Function to process each file
process_file() {
    file="$1"
    if [[ "$RESPECT_GITIGNORE" -eq 1 && -d "$DIRECTORY_PATH/.git" && -n $(git --git-dir="$DIRECTORY_PATH/.git" --work-tree="$DIRECTORY_PATH" check-ignore "$file") ]]; then
        return # Skip file if it is ignored by .gitignore
    fi
    filesize=$($STAT_CMD "$file")
    if [ "$filesize" -le $((MAX_SIZE * 1024)) ]; then
        if is_binary "$file"; then
            content="null" # Do not include content for binary files
        else
            content=$(jq -Rs . < "$file")
        fi
        filename=$(basename "$file")
        dirpath=$(dirname "$file" | sed "s|^$DIRECTORY_PATH||")
        echo "{\"filename\":\"$filename\", \"content\":$content, \"path\":\"$dirpath/\"}"
    fi
}

export -f process_file is_binary
export STAT_CMD MAX_SIZE DIRECTORY_PATH RESPECT_GITIGNORE INCLUDE_DOT_FILES

# Construct the find command
find_command="find \"$DIRECTORY_PATH\" -type f -empty"

# Include extensions
if [ ${#INCLUDE_EXT[@]} -gt 0 ]; then
    find_command+=" \\( -name \"*${INCLUDE_EXT[0]}\""
    for ext in "${INCLUDE_EXT[@]:1}"; do
        find_command+=" -o -name \"*${ext}\""
    done
    find_command+=" \\)"
fi

# Exclude extensions 
# (Only if include extensions are NOT specified to avoid redundancy)
if [ ${#INCLUDE_EXT[@]} -eq 0 ] && [ ${#EXCLUDE_EXT[@]} -gt 0 ]; then
    find_command+=" \\( -not -name \"*${EXCLUDE_EXT[0]}\""
    for ext in "${EXCLUDE_EXT[@]:1}"; do
        find_command+=" -and -not -name \"*${ext}\""
    done
    find_command+=" \\)"
fi

# Process files using glob
json_array="[]"  # Initialize as an empty array
for file in "$DIRECTORY_PATH"/*; do
    if [[ -f "$file" ]]; then  # Check if it's a regular file
        json_array+=("$(process_file "$file")")
    fi
done

# Output the JSON object using jq and pretty print
echo "{\"files\":$json_array}" | jq . > "$OUTPUT_FILE"

# Zip the output file if requested
if [ "$ZIP_OUTPUT" -eq 1 ]; then
    zip_file="${OUTPUT_FILE%.*}.zip"
    zip -jq "$zip_file" "$OUTPUT_FILE"
    echo "Output file zipped: $zip_file"
fi

echo "JSON output saved to: $OUTPUT_FILE"

# Generate directory tree using tree command
echo "Directory tree:"
tree_options="-I '.git|node_modules'"
if [ "$INCLUDE_DOT_FILES" -eq 0 ]; then
    tree_options+=" -I '.*'"
else
    tree_options+=" -a"
fi
if [ -n "$EXCLUDE_EXT" ]; then
    tree_options+=" -I '*${EXCLUDE_EXT}'"
fi
tree --dirsfirst $tree_options "$DIRECTORY_PATH"
