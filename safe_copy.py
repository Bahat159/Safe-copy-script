#!/usr/bin/env python3
import sys
import os
import shutil
from datetime import datetime

# 1. Parse and validate arguments
if len(sys.argv) < 3 or len(sys.argv) > 4:
    print("Error: Invalid number of arguments.", file=sys.stderr)
    print(f"Usage: {sys.argv[0]} <source_directory> <destination_directory> [overwrite]", file=sys.stderr)
    sys.exit(1)

src_dir = os.path.abspath(sys.argv[1])
dest_dir = os.path.abspath(sys.argv[2])
overwrite = sys.argv[3].lower() == 'true' if len(sys.argv) == 4 else False

# 2. Setup timestamped log file
log_filename = f"copy_log_{datetime.now().strftime('%Y-%m-%d_%H:%M:%S')}.log"

def log_message(message):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_line = f"[{timestamp}] {message}\n"
    sys.stdout.write(log_line)
    with open(log_filename, "a", encoding="utf-8") as log_file:
        log_file.write(log_line)

# 3. Pre-flight validations
if not os.path.isdir(src_dir):
    print(f"Error: Source directory '{src_dir}' does not exist.", file=sys.stderr)
    sys.exit(1)

if not os.access(src_dir, os.R_OK):
    print(f"Error: Missing read permissions on source directory '{src_dir}'.", file=sys.stderr)
    sys.exit(1)

if not os.path.isdir(dest_dir):
    print(f"Error: Destination directory '{dest_dir}' does not exist.", file=sys.stderr)
    sys.exit(1)

if not os.access(dest_dir, os.W_OK):
    print(f"Error: Missing write permissions on destination directory '{dest_dir}'.", file=sys.stderr)
    sys.exit(1)

# Extract only files
files = [f for f in os.listdir(src_dir) if os.path.isfile(os.path.join(src_dir, f))]

if not files:
    print(f"Error: Source directory '{src_dir}' is empty.", file=sys.stderr)
    sys.exit(1)

# 4. File Copy Execution
log_message(f"Starting file copy from '{src_dir}' to '{dest_dir}'")
success_count = 0
skip_count = 0
fail_count = 0

for file in files:
    src_file = os.path.join(src_dir, file)
    dest_file = os.path.join(dest_dir, file)

    if os.path.exists(dest_file):
        if not overwrite:
            log_message(f"Skipped: {file} already exists in destination")
            skip_count += 1
            continue

    try:
        # copy2 preserves permissions, modifications, metadata attributes
        shutil.copy2(src_file, dest_file)
        log_message(f"Copied: {file}")
        success_count += 1
    except Exception:
        log_message(f"Failed to copy: {file}")
        fail_count += 1

log_message("File copy operation completed.")
log_message(f"Summary -> Successful: {success_count} | Skipped: {skip_count} | Failed: {fail_count}")

sys.exit(1 if fail_count > 0 else 0)
