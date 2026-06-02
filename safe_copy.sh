#!/bin/bash

# safe_copy.sh: Robust script to copy files from one directory to another

set -euo pipefail

# === CONFIGURATION ===
SOURCE_DIR="$1"
DEST_DIR="$2"
OVERWRITE=${3:-false}   # optional third argument: "true" or "false"
LOG_FILE="./copy_log_$(date +%F_%T).log"

# === FUNCTIONS ===

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# === CHECKS ===

[[ $# -lt 2 ]] && error_exit "Usage: $0 <source_dir> <dest_dir> [overwrite:true|false]"

[[ ! -d "$SOURCE_DIR" ]] && error_exit "Source directory '$SOURCE_DIR' does not exist"
[[ ! -d "$DEST_DIR" ]] && error_exit "Destination directory '$DEST_DIR' does not exist"
[[ ! -r "$SOURCE_DIR" ]] && error_exit "No read permission on source directory"
[[ ! -w "$DEST_DIR" ]] && error_exit "No write permission on destination directory"

log "Starting file copy from '$SOURCE_DIR' to '$DEST_DIR'"
log "Overwrite existing files: $OVERWRITE"

# === COPY LOOP ===

shopt -s nullglob
FILES=("$SOURCE_DIR"/*)

if [[ ${#FILES[@]} -eq 0 ]]; then
    log "No files to copy."
    exit 0
fi

for file in "${FILES[@]}"; do
    filename=$(basename "$file")
    dest_file="$DEST_DIR/$filename"

    if [[ -e "$dest_file" && "$OVERWRITE" != "true" ]]; then
        log "Skipped: '$filename' already exists in destination"
        continue
    fi

    if cp -p "$file" "$dest_file"; then
        log "Copied: '$filename'"
    else
        log "Failed to copy: '$filename'"
    fi
done

log "File copy operation completed."
exit 0