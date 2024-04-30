# Code Packager for LLMs

**Bridging the Gap Between Code and AI**

Package your codebase into a JSON file, ready to be analyzed and understood by large language models (LLMs) like GPT-4, Claude, Command R, and Gemini.

This project provides a bash script, `code-packager.sh`, that simplifies the process of preparing your code for interaction with LLMs. By converting your code into a structured format, you unlock the potential for advanced analysis, code generation, and insightful interactions with AI.

### Features

- **Comprehensive Code Packaging:**
  - Handles various file types and sizes, allowing you to include or exclude specific extensions, respect `.gitignore` rules, and optionally zip archive the resulting JSON file for efficient storage and sharing.
- **Customizable Output:**
   - Control the level of detail and structure of the generated JSON file by including or excluding files of particular extensions, tailoring the output to your specific Language Model (LLM) and use case requirements.
- **Structured JSON Output for LLM Interpretation:**
   - Formats the packaged codebase into JSON, enabling easy interpretation by Language Models (LLMs) for advanced analysis and code-related tasks. The structured organization facilitates seamless integration with various LLMs.
- **Single Bash Script for Easy Integration:**
   - Consists of a single bash script with a simple command-line interface, making it easy to use in various environments. Clear instructions ensure straightforward incorporation into your workflow for efficient code packaging, including the option to zip archive the output file.

**Note**: The contents of binary files are automatically omitted for efficiency.

## Installation

1. **Clone the repository:**

```bash
git clone https://github.com/yohasebe/code-packager.git
```

2. **Install dependencies:**

* **macOS:**

   If you have Homebrew installed, you can use it to install the dependencies:

   ```bash
   brew install jq tree
   ```

* **Linux (Ubuntu/Debian):**

   ```bash
   sudo apt install jq tree
   ```

3. **Make the script executable:**

```bash
cd code-packager
chmod +x code-packager.sh
```

## Usage

```bash
./code-packager.sh -t <directory_path> -o <output_file> [options]
```

**Options:**

*   `-t <directory_path>`: **(Required)** Path to the directory containing the code you want to package.
*   `-o <output_file>`: **(Required)** Path to the output JSON file.
*   `-i <include_extension>`: Include files with the specified extension (e.g., `.py`, `.js`). You can use this option multiple times to include files with different extensions.
*   `-e <exclude_extension>`: Exclude files with the specified extension. You can use this option multiple times to exclude files with different extensions. (**Note:** This option is redundant if you are already using the `-i` option to specify included extensions.)
*   `-s <max_size_in_kb>`: Include files up to the specified size in kilobytes.
*   `-g <respect_gitignore>`: Set to `1` to respect `.gitignore`, `0` to ignore (default: `1`).
*   `-d <include_dot_files>`: Set to `1` to include dot files and folders, `0` to exclude (default: `0`).
*   `-z <zip_output>`: Set to `1` to zip the output JSON file, `0` to leave uncompressed (default: `0`).
*   `-v, --version`: Display the version of the script and exit.
*   `-h, --help`: Display this help message and exit.

## Examples

**1. Including Multiple File Types:**

```bash
./code-packager.sh -t ~/myproject -o code.json -i .py -i .js -s 2048 -z 1
```

This command packages the code from the `~/myproject` directory, including only Python (`.py`) and JavaScript (`.js`) files. It limits the file size to 2MB and zips the output file (`code.json`). 

**2. Excluding Specific File Types (Without Inclusion):**

```bash
./code-packager.sh -t ~/myproject -o code.json -e .txt -e .md -d 1
```

This command packages the code from the `~/myproject` directory, excluding text (`.txt`) and markdown (`.md`) files. It includes dot files and folders and does not zip the output file.

**3. Packaging All File Types:**

```bash
./code-packager.sh -t ~/myproject -o code.json -s 10240 -g 0
```

This command packages all files from the `~/myproject` directory, regardless of file type. It limits the file size to 10MB, ignores the `.gitignore` file, and does not zip the output file. 

**Directory Tree Example:**

The script will also print a directory tree of the processed files, similar to this:

```
├── data
│   └── sample.csv
├── main.py
└── utils
    ├── __init__.py
    ├── data_loader.py
    └── model.py

```

## Acknowledgements

This project was inspired by Simon Willison's [`files-to-prompt`](https://github.com/simonw/files-to-prompt). While `files-to-prompt` uses horizontal bars (`---`) to separate file paths and their contents, **Code Packager for LLMs** takes a different approach by utilizing the JSON format. This choice makes the resulting text more structured, unambiguous, and versatile, allowing for enhanced interpretation and interaction with Language Models (LLMs). Additionally, Code Packager for LLMs offers additional features and customization options to further enhance the code packaging process.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for any bugs or feature requests.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details. 

## Author

Yoichiro Hasebe (yohasebe@gmail.com)
