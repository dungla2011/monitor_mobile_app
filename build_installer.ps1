# Ping365 Monitor - Create Windows Installer
# This script packages the already-built Flutter app into a Windows installer using Inno Setup
# Note: Run "flutter build windows --release" first before using this script

# Configuration
$InnoSetupPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
$InnoSetupScript = "windows\installer\setup.iss"
$AppName = "Ping365 Monitor"
$ExePath = "build\windows\x64\runner\Release\monitor_app.exe"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  $AppName - Create Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if Inno Setup is installed
Write-Host "[1/3] Checking Inno Setup installation..." -ForegroundColor Yellow
if (-Not (Test-Path $InnoSetupPath)) {
    Write-Host "Error: Inno Setup not found at: $InnoSetupPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Inno Setup from: https://jrsoftware.org/isdl.php" -ForegroundColor Yellow
    Write-Host "Default installation path: C:\Program Files (x86)\Inno Setup 6\" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
Write-Host "Inno Setup found" -ForegroundColor Green

# Step 2: Check if build output exists
Write-Host ""
Write-Host "[2/3] Checking build output..." -ForegroundColor Yellow
if (-Not (Test-Path $ExePath)) {
    Write-Host "Error: Build output not found at: $ExePath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run 'flutter build windows --release' first!" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Get file size
$FileSize = (Get-Item $ExePath).Length / 1MB
Write-Host "Build found: $([math]::Round($FileSize, 2)) MB" -ForegroundColor Green

# Step 3: Create installer with Inno Setup
Write-Host ""
Write-Host "[3/3] Creating Windows installer..." -ForegroundColor Yellow

# Create output directory if it doesn't exist
$OutputDir = "installer_output"
if (-Not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Run Inno Setup Compiler
& $InnoSetupPath $InnoSetupScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Installer creation failed" -ForegroundColor Red
    exit 1
}

Write-Host "Installer created successfully" -ForegroundColor Green

# Find the created installer
Write-Host ""
$InstallerFiles = Get-ChildItem -Path $OutputDir -Filter "*.exe" | Sort-Object LastWriteTime -Descending

if ($InstallerFiles.Count -gt 0) {
    $InstallerPath = $InstallerFiles[0].FullName
    $InstallerSize = $InstallerFiles[0].Length / 1MB
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Installer created:" -ForegroundColor Green
    Write-Host "Location: $InstallerPath" -ForegroundColor Cyan
    Write-Host "Size: $([math]::Round($InstallerSize, 2)) MB" -ForegroundColor Cyan
    Write-Host ""
    
    # Ask if user wants to open the folder
    $OpenFolder = Read-Host "Open installer folder? (Y/N)"
    if ($OpenFolder -eq "Y" -or $OpenFolder -eq "y") {
        explorer.exe $OutputDir
    }
    
    # Ask if user wants to run the installer
    Write-Host ""
    $RunInstaller = Read-Host "Run the installer now? (Y/N)"
    if ($RunInstaller -eq "Y" -or $RunInstaller -eq "y") {
        Start-Process $InstallerPath
    }
} else {
    Write-Host "Warning: Installer file not found in output directory" -ForegroundColor Yellow
}

Write-Host ""
