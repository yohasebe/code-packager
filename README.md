# Code Packager for LLMs 📦

**Bridging the Gap Between Complex Codebase 🖥️ and AI 🤖**

Package your codebase into a single JSON file, ready to be analyzed and understood by large language models (LLMs) like GPT-4, Claude, Command R, and Gemini.

This project provides a bash script, `code-packager`, that simplifies the process of preparing your code for interaction with LLMs. By converting your code into a structured format, you unlock the potential for advanced analysis, code generation, and insightful interactions with AI.

### Change Log

- [Jun 22, 2024] `max_depth` option added
- [May 01, 2024] initial commit

### Features

- 📦 **Comprehensive Code Packaging:**
  - Handles various file types and sizes, allowing you to include or exclude specific extensions, respect `.gitignore` rules, and optionally zip archive the resulting JSON file for efficient storage and sharing.
- ⚙️ **Customizable Output:**
   - Control the level of detail and structure of the generated JSON file by including or excluding files of particular extensions, tailoring the output to your specific Language Model (LLM) and use case requirements.
- 🤖 **Structured JSON Output for LLM Interpretation:**
   - Formats the packaged codebase into JSON, enabling easy interpretation by Language Models (LLMs) for advanced analysis and code-related tasks. The structured organization facilitates seamless integration with various LLMs.
- 😀 **Easy Installation and Usage:**
   - Available as a Homebrew formula for macOS users and supports manual installation on various platforms. The script offers a range of options to customize the code packaging process, providing flexibility and control over the output.
- 🖼️ **Binary File Handling:**
   - Automatically omits the contents of binary files for efficiency, ensuring that only relevant code is included in the packaged output. This feature streamlines the code packaging process and enhances the usability of the resulting JSON file.

## Installation

### Homebrew (Recommended for macOS Users)

Run the following commands:

```bash
brew tap yohasebe/code-packager
brew install code-packager 
```

That's it! The `code-packager` command should now be available in your terminal.

### Manual Installation

1. Install the following dependencies:

- `git`
- `jq`
- `file`

On a Debian-based Linux distribution, you can install these dependencies with:

```bash
sudo apt-get install git jq file
```

2. Identify a directory in your system's PATH variable where you want to place the script. You can check the directories in your PATH variable by running the following command:

```bash
echo $PATH
```

3. Move the `code-packager` script to the chosen directory. For example, if you want to move it to `/usr/local/bin`, run the following command:

```bash
mv code-packager /usr/local/bin
```

4. Make sure the script is executable by running the following command:

```bash
chmod +x /usr/local/bin/code-packager
```

## Usage

```bash
code-packager -t <directory_path> -o <output_file> [options]
```

**Options:**

*   `-t <directory_path>`: **(Required)** Path to the directory containing the code you want to package.
*   `-o <output_file>`: **(Required)** Path to the output JSON file. If a directory path is specified, the output file will be named based on the target directory.
*   `-i <include_extension>`: Include files with the specified extension (e.g., `.py`, `.js`). You can use this option multiple times to include files with different extensions.
*   `-e <exclude_extension>`: Exclude files with the specified extension. You can use this option multiple times to exclude files with different extensions. (**Note:** This option is useful if you are including most files but want to exclude specific types.)
*   `-s <max_size_in_kb>`: Include files up to the specified size in kilobytes.
*   `-g <respect_gitignore>`: Set to `1` to respect `.gitignore`, `0` to ignore (default: `1`).
*   `-d <include_dot_files>`: Set to `1` to include dot files and folders, `0` to exclude (default: `0`).
*   `-z <zip_output>`: Set to `1` to zip the output JSON file, `0` to leave uncompressed (default: `0`).
*   `-m <max_depth>`: Limit the maximum depth of the search (default: unlimited).
*   `-v, --version`: Display the version of the script and exit.
*   `-h, --help`: Display this help message and exit.

## Examples

**1. Including Multiple File Types:**

```bash
code-packager -t ~/myproject -o code.json -i .py -i .js -s 2048 -z 1
```

This command packages the code from the `~/myproject` directory, including only Python (`.py`) and JavaScript (`.js`) files. It limits the file size to 2MB and zips the output file (`code.json`). 

**2. Excluding Specific File Types (Without Inclusion):**

```bash
code-packager -t ~/myproject -o code.json -e .txt -e .md -d 1
```

This command packages the code from the `~/myproject` directory, excluding text (`.txt`) and markdown (`.md`) files. It includes dot files and folders and does not zip the output file.

**3. Packaging All File Types:**

```bash
code-packager -t ~/myproject -o code.json -s 10240 -g 0
```

This command packages all files from the `~/myproject` directory, regardless of file type. It limits the file size to 10MB, ignores the `.gitignore` file, and does not zip the output file. 

**4. Specifying Output Directory:**

```bash
code-packager -t ~/myproject -o ~/output_dir -s 10240 -g 0
```

This command packages all files from the `~/myproject` directory, regardless of file type. It limits the file size to 10MB, ignores the `.gitignore` file, and saves the output JSON file as `~/output_dir/myproject.json`.

**5. Limiting Search Depth:**

```bash
code-packager -t ~/myproject -o code.json -m 2
```

This command packages the code from the `~/myproject` directory, including files up to a depth of 2 levels.

### Example Output

The resulting JSON output may look similar to the following structure:

```json
{
  "files": [
    {
      "filename": "main.py",
      "content": "from utils.data_loader import load_data\n\nfile_path = 'data/sample.csv'\ndata = load_data(file_path)\nprint(data.head())\n",
      "path": "/"
    },
    {
      "filename": "sample.csv",
      "content": "name, age, city\nAlice, 30, New York\nBob, 25, Los Angeles\nCharlie, 35, Chicago\n",
      "path": "/data/"
    },
    {
      "filename": "__init__.py",
      "content": "class Example:\n    def __init__(this):\n        this.data = []\n\n    def add_data(this, new_data):\n        this.data.append(new_data)\n",
      "path": "/utils/"
    },
    {
      "filename": "data_loader.py",
      "content": "import pandas as pd\n\ndef load_data(file_path):\n    data = pd.read_csv(file_path)\n    return data\n",
      "path": "/utils/"
    },
    {
      "filename": "model.py",
      "content": "class Model:\n    def __init__(this):\n        this.weights = {}\n\n    def train(this, data):\n        # Training logic here\n        pass\n",
      "path": "/utils/"
    }
  ]
}
```

### File/Directory Structure Example

The script will also print a list of files and directories that were processed, similar to this:

```
File/Directory Structure:
-------------------------
main.py
data/sample.csv
utils/__init__.py
utils/data_loader.py
utils/model.py
```

## Troubleshooting

### Changes to `.gitignore` Not Taking Effect

If you find that changes made to your `.gitignore` file are not being respected (e.g., files that should be ignored are still being processed), you may need to clear your Git cache. This issue can occur because Git continues to track files that were previously committed before they were added to `.gitignore`.

To resolve this issue, you can use the following commands to clear the Git cache:

```bash
# Navigate to your repository root
cd path/to/your/repository

# Remove cached files from the index
git rm -r --cached .

# Re-add all the files to the index
git add .

# Commit the changes to your repository
git commit -m "Cleared cache to respect .gitignore changes"
```

## Acknowledgements

This project was inspired by Simon Willison's [`files-to-prompt`](https://github.com/simonw/files-to-prompt). While `files-to-prompt` uses horizontal bars (`---`) to separate file paths and their contents, **Code Packager for LLMs** takes a different approach by utilizing the JSON format. This choice makes the resulting text more structured, unambiguous, and versatile, allowing for enhanced interpretation and interaction with Language Models (LLMs). Additionally, Code Packager for LLMs offers additional features and customization options to further enhance the code packaging process.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for any bugs or feature requests.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details. 

## Author

Yoichiro Hasebe (yohasebe@gmail.com)
