# 🛡️ Safe Copy Script

A robust, production-ready Bash script designed for secure file transfers between local directories. It prioritizes data integrity and operational safety through strict pre-flight validations, defensive error handling, structural boundary checks, and automated, timestamped logging.

---

## ✨ Features

* **Validation**: Validates source and destination directories.
* **Permissions**: Checks read/write permissions before copying.
* **Logging**: Detailed logging with timestamps.
* **Overwrites**: Optional overwrite mode.
* **Attributes**: Preserves file attributes (`cp -p`).
* **Graceful**: Handles empty source directories gracefully.
* **Safe**: Uses safe Bash practices (`set -euo pipefail`).
* **Reporting**: Reports successful and failed copy operations.

---

## 📋 Requirements

* Linux, macOS, or any Unix-like system
* Bash 4.0 or later

---

## ⚙️ Installation

Clone the repository or download the script:

```bash
git clone https://github.com/bahat159/safe-copy-script.git
cd safe-copy-script
chmod +x safe_copy.sh
```

---

## 🚀 Usage

```bash
./safe_copy.sh <source_directory> <destination_directory> [overwrite]
```

### Parameters


| Parameter | Description |
| :--- | :--- |
| `source_directory` | Directory containing files to copy |
| `destination_directory` | Directory where files will be copied |
| `overwrite` | Optional. Set to `true` to overwrite existing files. Defaults to `false`. |

### Examples

**Copy files without overwriting existing files:**
```bash
./safe_copy.sh /home/user/documents /backup/documents
```

**Copy files and overwrite existing files:**
```bash
./safe_copy.sh /home/user/documents /backup/documents true
```

---

## 📝 Logging

The script automatically generates a log file in the current directory:
`copy_log_YYYY-MM-DD_HH:MM:SS.log`

### Example log output:
```text
[2026-06-02 12:00:01] Starting file copy from '/source' to '/destination'
[2026-06-02 12:00:02] Copied: report.pdf
[2026-06-02 12:00:03] Skipped: data.csv already exists in destination
[2026-06-02 12:00:04] File copy operation completed.
```

---

## 🚨 Error Handling

The script checks for:
* Missing command-line arguments
* Non-existent source directory
* Non-existent destination directory
* Missing read permissions on source directory
* Missing write permissions on destination directory
* Empty source directory
* Copy failures

### Exit Codes


| Code | Meaning |
| :---: | :--- |
| **0** | Success |
| **1** | Error occurred |

---


## 🧪 Automated Testing & CI/CD Validation

This repository includes a rigorous automation workflow that triggers on every code push or pull request to maintain cross-language parity. 

### Local Manual Test Verification Sequence
To locally simulate the continuous integration framework and test all structural edge cases across every language variant simultaneously, run this validation chunk in your terminal:

```bash
# 1. Initialize staging sandboxes
mkdir -p test_src test_dest empty_src
echo "Alice" > test_src/doc_a.txt
echo "Bob" > test_src/doc_b.txt
echo "Charlie" > test_dest/doc_a.txt  # Creates a baseline naming conflict

# 2. Run localized cross-verification commands
./safe_copy.sh test_src test_dest false       # Bash engine check (Skips doc_a)
node safe_copy.js test_src test_dest true     # Node engine check (Overwrites doc_a)
go run main.go test_src test_dest false       # Go engine checking pass
python3 safe_copy.py test_src test_dest false # Python engine checking pass
php safe_copy.php test_src test_dest false    # PHP engine checking pass

# 3. Assert zero-state validation works (Should output errors safely)
./safe_copy.sh empty_src test_dest false
```

## 🔒 Security Considerations

* Uses strict Bash mode (`set -euo pipefail`).
* Properly quotes variables to prevent word splitting.
* Validates user input before performing operations.
* Avoids unsafe shell practices.

---

## 🔮 Future Enhancements

* Recursive directory copying
* File filtering by extension
* Dry-run mode
* Parallel file transfers
* Rsync integration
* Progress indicator
* Configuration file support

---

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome. Please open an issue or submit a pull request.

---

## 📄 License

This project is licensed under the MIT License.

---

## 👤 Author

Created as a simple and reliable utility for safe file transfers in Bash environments.
