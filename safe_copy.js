#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// 1. Parse and validate arguments
const args = process.argv.slice(2);
if (args.length < 2 || args.length > 3) {
    console.error("Error: Invalid number of arguments.");
    console.error(`Usage: node ${path.basename(process.argv[1])} <source_directory> <destination_directory> [overwrite]`);
    process.exit(1);
}

const srcDir = path.resolve(args[0]);
const destDir = path.resolve(args[1]);
const overwrite = args[2] === 'true';

// 2. Setup timestamped log file
const timestamp = new Date().toISOString().replace(/T/, '_').replace(/\..+/, '').replace(/:/g, '-');
const logFile = path.join(process.cwd(), `copy_log_${timestamp}.log`);

function logMessage(message) {
    const time = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
    const logLine = `[${time}] ${message}\n`;
    process.stdout.write(logLine);
    fs.appendFileSync(logFile, logLine);
}

// 3. Pre-flight validations
if (!fs.existsSync(srcDir) || !fs.statSync(srcDir).isDirectory()) {
    console.error(`Error: Source directory '${srcDir}' does not exist.`);
    process.exit(1);
}

try {
    fs.accessSync(srcDir, fs.constants.R_OK);
} catch (e) {
    console.error(`Error: Missing read permissions on source directory '${srcDir}'.`);
    process.exit(1);
}

if (!fs.existsSync(destDir) || !fs.statSync(destDir).isDirectory()) {
    console.error(`Error: Destination directory '${destDir}' does not exist.`);
    process.exit(1);
}

try {
    fs.accessSync(destDir, fs.constants.W_OK);
} catch (e) {
    console.error(`Error: Missing write permissions on destination directory '${destDir}'.`);
    process.exit(1);
}

const files = fs.readdirSync(srcDir).filter(file => {
    return fs.statSync(path.join(srcDir, file)).isFile();
});

if (files.length === 0) {
    console.error(`Error: Source directory '${srcDir}' is empty.`);
    process.exit(1);
}

// 4. Execute file copying
logMessage(`Starting file copy from '${srcDir}' to '${destDir}'`);
let successCount = 0;
let skipCount = 0;
let failCount = 0;

for (const file of files) {
    const srcFile = path.join(srcDir, file);
    const destFile = path.join(destDir, file);

    if (fs.existsSync(destFile)) {
        if (!overwrite) {
            logMessage(`Skipped: ${file} already exists in destination`);
            skipCount++;
            continue;
        }
    }

    try {
        // copyFileSync preserves fundamental contents; native Node limits direct metadata adjustments 
        fs.copyFileSync(srcFile, destFile, fs.constants.COPYFILE_FICLONE);
        
        // Preserve modification and access timestamps
        const stat = fs.statSync(srcFile);
        fs.utimesSync(destFile, stat.atime, stat.mtime);
        
        logMessage(`Copied: ${file}`);
        successCount++;
    } catch (err) {
        logMessage(`Failed to copy: ${file}`);
        failCount++;
    }
}

logMessage("File copy operation completed.");
logMessage(`Summary -> Successful: ${successCount} | Skipped: ${skipCount} | Failed: ${failCount}`);

process.exit(failCount > 0 ? 1 : 0);
