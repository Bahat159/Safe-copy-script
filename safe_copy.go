package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"
)

func main() {
	// 1. Parse and validate arguments
	args := os.Args[1:]
	if len(args) < 2 || len(args) > 3 {
		fmt.Fprintf(os.Stderr, "Error: Invalid number of arguments.\n")
		fmt.Fprintf(os.Stderr, "Usage: %s <source_directory> <destination_directory> [overwrite]\n", os.Args[0])
		os.Exit(1)
	}

	srcDir := filepath.Clean(args[0])
	destDir := filepath.Clean(args[1])
	overwrite := false
	if len(args) == 3 && args[2] == "true" {
		overwrite = true
	}

	// 2. Setup log file
	logFileName := fmt.Sprintf("copy_log_%s.log", time.Now().Format("2006-01-02_15-04-05"))
	logFile, err := os.OpenFile(logFileName, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error creating log file: %v\n", err)
		os.Exit(1)
	}
	defer logFile.Close()

	logMessage := func(message string) {
		logLine := fmt.Sprintf("[%s] %s\n", time.Now().Format("2006-01-02 15:04:05"), message)
		fmt.Print(logLine)
		logFile.WriteString(logLine)
	}

	// 3. Pre-flight validations
	srcInfo, err := os.Stat(srcDir)
	if os.IsNotExist(err) || !srcInfo.IsDir() {
		fmt.Fprintf(os.Stderr, "Error: Source directory '%s' does not exist.\n", srcDir)
		os.Exit(1)
	}

	destInfo, err := os.Stat(destDir)
	if os.IsNotExist(err) || !destInfo.IsDir() {
		fmt.Fprintf(os.Stderr, "Error: Destination directory '%s' does not exist.\n", destDir)
		os.Exit(1)
	}

	// Read directory entries
	entries, err := os.ReadDir(srcDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading source directory: %v\n", err)
		os.Exit(1)
	}

	var files []os.DirEntry
	for _, entry := range entries {
		if !entry.IsDir() {
			files = append(files, entry)
		}
	}

	if len(files) == 0 {
		fmt.Fprintf(os.Stderr, "Error: Source directory '%s' is empty.\n", srcDir)
		os.Exit(1)
	}

	// 4. File Copy Logic
	logMessage(fmt.Sprintf("Starting file copy from '%s' to '%s'", srcDir, destDir))
	successCount, skipCount, failCount := 0, 0, 0

	for _, file := range files {
		filename := file.Name()
		srcFile := filepath.Join(srcDir, filename)
		destFile := filepath.Join(destDir, filename)

		if _, err := os.Stat(destFile); err == nil {
			if !overwrite {
				logMessage(fmt.Sprintf("Skipped: %s already exists in destination", filename))
				skipCount++
				continue
			}
		}

		// Perform safe low-level file write
		if err := copyFilePreservingAttributes(srcFile, destFile); err != nil {
			logMessage(fmt.Sprintf("Failed to copy: %s", filename))
			failCount++
		} else {
			logMessage(fmt.Sprintf("Copied: %s", filename))
			successCount++
		}
	}

	logMessage("File copy operation completed.")
	logMessage(fmt.Sprintf("Summary -> Successful: %d | Skipped: %d | Failed: %d", successCount, skipCount, failCount))

	if failCount > 0 {
		os.Exit(1)
	}
}

func copyFilePreservingAttributes(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()

	if _, err = io.Copy(out, in); err != nil {
		return err
	}

	srcInfo, err := os.Stat(src)
	if err != nil {
		return err
	}

	// Preserve permissions
	if err := os.Chmod(dst, srcInfo.Mode()); err != nil {
		return err
	}

	// Preserve timestamps
	return os.Chtimes(dst, time.Now(), srcInfo.ModTime())
}
