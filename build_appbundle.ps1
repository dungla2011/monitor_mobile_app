Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Building App Bundle for Google Play" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Clean previous builds
Write-Host "`nCleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "`nGetting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build app bundle with obfuscation
Write-Host "`nBuilding release app bundle..." -ForegroundColor Yellow
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==================================" -ForegroundColor Green
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "`nApp bundle location:" -ForegroundColor Cyan
    Write-Host "build\app\outputs\bundle\release\app-release.aab" -ForegroundColor White
} else {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    exit 1
}