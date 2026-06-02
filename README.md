# 🛡️ Safe Copy Script

A robust Bash script for safely copying files from one directory to another with comprehensive error handling, logging, and optional overwrite support.

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
git clone https://github.com/yourusername/safe-copy.git
cd safe-copy
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
