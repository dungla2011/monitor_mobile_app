# Simple Build Script - No symbol stripping

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build Android App Bundle (Simple)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check keystore
if (-Not (Test-Path "android\app\upload-keystore.jks")) {
    Write-Host "Error: Keystore not found!" -ForegroundColor Red
    exit 1
}

# Clean and build
Write-Host "[1/2] Cleaning..." -ForegroundColor Yellow
flutter clean | Out-Null

Write-Host "[2/2] Building..." -ForegroundColor Yellow
Write-Host "Building without symbol stripping (faster, larger file)..." -ForegroundColor Cyan

# Build without obfuscation and symbol splitting
flutter build appbundle --release

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try installing Android NDK:" -ForegroundColor Yellow
    Write-Host "1. Open Android Studio" -ForegroundColor White
    Write-Host "2. Tools > SDK Manager" -ForegroundColor White
    Write-Host "3. SDK Tools tab" -ForegroundColor White
    Write-Host "4. Check 'NDK (Side by side)'" -ForegroundColor White
    Write-Host "5. Click Apply" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Success
$BundlePath = "build\app\outputs\bundle\release\app-release.aab"
if (Test-Path $BundlePath) {
    $FileSize = (Get-Item $BundlePath).Length / 1MB
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "App bundle created:" -ForegroundColor Green
    Write-Host "Location: $BundlePath" -ForegroundColor Cyan
    Write-Host "Size: $([math]::Round($FileSize, 2)) MB" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Note: This build does NOT include:" -ForegroundColor Yellow
    Write-Host "  - Code obfuscation" -ForegroundColor White
    Write-Host "  - Debug symbol splitting" -ForegroundColor White
    Write-Host "Use build_appbundle.ps1 for production builds" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Upload to: https://play.google.com/console" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "Error: Bundle file not found!" -ForegroundColor Red
}
