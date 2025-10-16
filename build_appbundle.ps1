# Build Android App Bundle for Google Play

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build Android App Bundle" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if keystore exists
if (-Not (Test-Path "android\app\upload-keystore.jks")) {
    Write-Host "Error: Keystore not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run: .\create_keystore.ps1 first" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Check if key.properties exists
if (-Not (Test-Path "android\key.properties")) {
    Write-Host "Error: key.properties not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create android/key.properties with your keystore info" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Clean
Write-Host "[1/3] Cleaning previous build..." -ForegroundColor Yellow
flutter clean | Out-Null
Write-Host "Clean completed" -ForegroundColor Green

# Get dependencies
Write-Host ""
Write-Host "[2/3] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error getting dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "Dependencies downloaded" -ForegroundColor Green

# Build app bundle
Write-Host ""
Write-Host "[3/3] Building app bundle..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Cyan
flutter build appbundle --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
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
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Go to https://play.google.com/console" -ForegroundColor White
    Write-Host "2. Select your app (or create new app)" -ForegroundColor White
    Write-Host "3. Go to Production > Create new release" -ForegroundColor White
    Write-Host "4. Upload: $BundlePath" -ForegroundColor White
    Write-Host ""
    
    # Ask to open folder
    $OpenFolder = Read-Host "Open output folder? (Y/N)"
    if ($OpenFolder -eq "Y" -or $OpenFolder -eq "y") {
        explorer.exe "build\app\outputs\bundle\release\"
    }
} else {
    Write-Host "Error: Bundle file not found!" -ForegroundColor Red
}

Write-Host ""
