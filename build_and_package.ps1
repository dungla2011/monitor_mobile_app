# Ping365 Monitor - Build and Package
# This script builds the Flutter app and creates a Windows installer
# It combines flutter build + installer creation

# Configuration
$AppName = "Ping365 Monitor"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  $AppName - Full Build & Package" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean previous build
Write-Host "[1/4] Cleaning previous build..." -ForegroundColor Yellow
flutter clean | Out-Null
Write-Host "Clean completed" -ForegroundColor Green

# Step 2: Get dependencies
Write-Host ""
Write-Host "[2/4] Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to get dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "Dependencies downloaded" -ForegroundColor Green

# Step 3: Build Windows release
Write-Host ""
Write-Host "[3/4] Building Windows release..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Cyan
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Flutter build failed" -ForegroundColor Red
    exit 1
}
Write-Host "Build completed" -ForegroundColor Green

# Check if build output exists
$ExePath = "build\windows\x64\runner\Release\monitor_app.exe"
if (-Not (Test-Path $ExePath)) {
    Write-Host "Error: Build output not found at: $ExePath" -ForegroundColor Red
    exit 1
}

# Get file size
$FileSize = (Get-Item $ExePath).Length / 1MB
Write-Host "Build size: $([math]::Round($FileSize, 2)) MB" -ForegroundColor Cyan

# Step 4: Create installer
Write-Host ""
Write-Host "[4/4] Creating Windows installer..." -ForegroundColor Yellow
Write-Host "Running build_installer.ps1..." -ForegroundColor Cyan

# Call the installer script
& .\build_installer.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Installer creation failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All tasks completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
