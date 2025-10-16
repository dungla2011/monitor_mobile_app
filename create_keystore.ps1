# Create Android Keystore for Ping365 Monitor

# This script creates a keystore file for signing Android app releases
# Run this ONCE and keep the keystore file safe!

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Create Android Keystore" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will create a keystore file for signing your Android app." -ForegroundColor Yellow
Write-Host "You will be asked to enter:" -ForegroundColor Yellow
Write-Host "  - Keystore password (remember this!)" -ForegroundColor Yellow
Write-Host "  - Your name, organization, city, state, country" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Enter to continue or Ctrl+C to cancel..." -ForegroundColor Cyan
Read-Host

$KeystorePath = "android\app\upload-keystore.jks"
$KeyAlias = "ping365"

Write-Host "Creating keystore at: $KeystorePath" -ForegroundColor Green
Write-Host ""

# Create keystore
keytool -genkey -v -keystore $KeystorePath -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias $KeyAlias

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Keystore created successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "IMPORTANT: Keep these files safe!" -ForegroundColor Red
    Write-Host "  - Keystore: $KeystorePath" -ForegroundColor Yellow
    Write-Host "  - Password: (what you just entered)" -ForegroundColor Yellow
    Write-Host "  - Alias: $KeyAlias" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next step: Create key.properties file" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "Error creating keystore!" -ForegroundColor Red
    exit 1
}
