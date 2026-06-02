#!/usr/bin/env bash

# Enable strict mode for robust error handling
set -euo pipefail
IFS=$'\n\t'

# Initialize global tracking variables
SUCCESS_COUNT=0
SKIP_COUNT=0
FAIL_COUNT=0

# Ensure proper arguments are provided
if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Error: Invalid number of arguments." >&2
    echo "Usage: $0 <source_directory> <destination_directory> [overwrite]" >&2
    exit 1
fi

SRC_DIR="${1%/}"
DEST_DIR="${2%/}"
OVERWRITE="${3:-false}"

# Setup the log file matching the specified format
LOG_FILE="copy_log_$(date +'%Y-%m-%d_%H:%M:%S').log"

# Setup logging function
log_message() {
    local message="$1"
    local timestamp
    timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# 1. Validate source directory existence and permissions
if [[ ! -d "$SRC_DIR" ]]; then
    echo "Error: Source directory '$SRC_DIR' does not exist." >&2
    exit 1
fi

if [[ ! -r "$SRC_DIR" ]]; then
    echo "Error: Missing read permissions on source directory '$SRC_DIR'." >&2
    exit 1
fi

# 2. Validate destination directory existence and permissions
if [[ ! -d "$DEST_DIR" ]]; then
    echo "Error: Destination directory '$DEST_DIR' does not exist." >&2
    exit 1
fi

if [[ ! -w "$DEST_DIR" ]]; then
    echo "Error: Missing write permissions on destination directory '$DEST_DIR'." >&2
    exit 1
fi

# 3. Check if source directory is empty (ignores hidden files)
# Using shopt to safely count files without expanding glob incorrectly
shopt -s nullglob
FILES=("$SRC_DIR"/*)
shopt -u nullglob

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "Error: Source directory '$SRC_DIR' is empty." >&2
    exit 1
fi

# Start the copy process
log_message "Starting file copy from '$SRC_DIR' to '$DEST_DIR'"

# Process each file found in the root of the source directory
for src_file in "${FILES[@]}"; do
    # Skip directories since recursive copying is left for future enhancement
    if [[ -d "$src_file" ]]; then
        continue
    fi

    filename=$(basename "$src_file")
    dest_file="$DEST_DIR/$filename"

    # Check if the file already exists in the destination
    if [[ -e "$dest_file" ]]; then
        if [[ "$OVERWRITE" != "true" ]]; then
            log_message "Skipped: $filename already exists in destination"
            ((SKIP_COUNT++))
            continue
        fi
    fi

    # Attempt to copy preserving file attributes (-p)
    if cp -p "$src_file" "$dest_file" 2>/dev/null; then
        log_message "Copied: $filename"
        ((SUCCESS_COUNT++))
    else
        log_message "Failed to copy: $filename"
        ((FAIL_COUNT++))
    fi
done

# Final execution summary
log_message "File copy operation completed."
log_message "Summary -> Successful: $SUCCESS_COUNT | Skipped: $SKIP_COUNT | Failed: $FAIL_COUNT"

# Determine final exit status code
if [[ $FAIL_COUNT -gt 0 ]]; then
    exit 1
else
    exit 0
fi
