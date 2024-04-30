## Code Packager for LLMs

**Bridging the Gap Between Code and AI**

Package your codebase into a JSON file, ready to be analyzed and understood by large language models (LLMs) like GPT-4, Claude, Command R, and Gemini.**

This project provides a bash script, `code-packager.sh`, that simplifies the process of preparing your code for interaction with LLMs. By converting your code into a structured format, you unlock the potential for advanced analysis, code generation, and insightful interactions with AI.

### Features

* **Comprehensive Code Packaging:**  Handles various file types and sizes, allowing you to include or exclude specific extensions and respect `.gitignore` rules.
* **Customizable Output:**  Control the level of detail and structure of the generated JSON file, tailoring it to your specific LLM and use case.
* **Efficient Processing:**  Optimized for speed and efficiency, ensuring a smooth experience even with large codebases.
* **Easy Integration:**  Simple command-line interface and clear instructions make it easy to incorporate into your workflow.


**Note**: The contents of binary files are automatically omitted for efficiency.

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/your-username/code-packager.git
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

### Usage

```bash
./code-packager.sh -t <directory_path> -o <output_file> [options]
```

**Options:**

* `-t <directory_path>`: **(Required)** Path to the directory containing the code you want to package.
* `-o <output_file>`: **(Required)** Path to the output JSON file.
* `-i <include_extension>`: Include files with the specified extension (e.g., `.py`, `.js`).
* `-e <exclude_extension>`: Exclude files with the specified extension.
* `-s <max_size_in_kb>`: Include files up to the specified size in kilobytes.
* `-g <respect_gitignore>`: Set to `1` to respect `.gitignore`, `0` to ignore (default: `1`).
* `-d <include_dot_files>`: Set to `1` to include dot files and folders, `0` to exclude (default: `0`).
* `-z <zip_output>`: Set to `1` to zip the output JSON file, `0` to leave uncompressed (default: `0`).

### Example

```bash
./code-packager.sh -t ~/myproject -o code.json -i .py -e .txt -s 5120
```

This command packages the code from the `~/myproject` directory, including only Python files (`.py`) and excluding text files (`.txt`). It limits the file size to 5MB and outputs the result to `code.json`.

### Acknowledgements

This project was inspired by Simon Willison's `files-to-prompt` (https://github.com/simonw/files-to-prompt) and aims to provide a similar functionality with additional features and customization options.

### Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for any bugs or feature requests.

### License

This project is licensed under the MIT License. See the `LICENSE` file for details. 

### Author

Yoichiro Hasebe (yohasebe@gmail.com)


