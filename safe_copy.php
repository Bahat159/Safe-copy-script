#!/usr/bin/env php
<?php

// 1. Parse and validate arguments
if ($argc < 3 || $argc > 4) {
    fwrite(STDERR, "Error: Invalid number of arguments.\n");
    fwrite(STDERR, "Usage: php {$argv[0]} <source_directory> <destination_directory> [overwrite]\n");
    exit(1);
}

$srcDir = rtrim($argv[1], '/');
$destDir = rtrim($argv[2], '/');
$overwrite = isset($argv[3]) && strtolower($argv[3]) === 'true';

// 2. Setup timestamped log file
$logFile = "copy_log_" . date('Y-m-%d_H:i:s') . ".log";

function logMessage($message, $logFile) {
    $timestamp = date('Y-m-%d H:i:s');
    $logLine = "[$timestamp] $message\n";
    echo $logLine;
    file_put_contents($logFile, $logLine, FILE_APPEND);
}

// 3. Pre-flight validations
if (!is_dir($srcDir)) {
    fwrite(STDERR, "Error: Source directory '{$srcDir}' does not exist.\n");
    exit(1);
}

if (!is_readable($srcDir)) {
    fwrite(STDERR, "Error: Missing read permissions on source directory '{$srcDir}'.\n");
    exit(1);
}

if (!is_dir($destDir)) {
    fwrite(STDERR, "Error: Destination directory '{$destDir}' does not exist.\n");
    exit(1);
}

if (!is_writable($destDir)) {
    fwrite(STDERR, "Error: Missing write permissions on destination directory '{$destDir}'.\n");
    exit(1);
}

// Read and isolate files only
$allItems = scandir($srcDir);
$files = [];
foreach ($allItems as $item) {
    if ($item === '.' || $item === '..') continue;
    if (is_file($srcDir . '/' . $item)) {
        $files[] = $item;
    }
}

if (count($files) === 0) {
    fwrite(STDERR, "Error: Source directory '{$srcDir}' is empty.\n");
    exit(1);
}

// 4. File Copy Logic
logMessage("Starting file copy from '{$srcDir}' to '{$destDir}'", $logFile);
$successCount = 0;
$skipCount = 0;
$failCount = 0;

foreach ($files as $file) {
    $srcFile = $srcDir . '/' . $file;
    $destFile = $destDir . '/' . $file;

    if (file_exists($destFile)) {
        if (!$overwrite) {
            logMessage("Skipped: $file already exists in destination", $logFile);
            $skipCount++;
            continue;
        }
    }

    if (copy($srcFile, $destFile)) {
        // Touch to preserve modification time mapping
        touch($destFile, filemtime($srcFile));
        logMessage("Copied: $file", $logFile);
        $successCount++;
    } else {
        logMessage("Failed to copy: $file", $logFile);
        $failCount++;
    }
}

logMessage("File copy operation completed.", $logFile);
logMessage("Summary -> Successful: $successCount | Skipped: $skipCount | Failed: $failCount", $logFile);

exit($failCount > 0 ? 1 : 0);
