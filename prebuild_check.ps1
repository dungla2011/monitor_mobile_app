# Pre-Build Checklist for Google Play Release

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Google Play Release Checklist" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true

# Check 1: Keystore exists
Write-Host "[1/8] Checking keystore..." -ForegroundColor Yellow
if (Test-Path "android\app\upload-keystore.jks") {
    Write-Host "  ✓ Keystore found" -ForegroundColor Green
} else {
    Write-Host "  ✗ Keystore NOT found!" -ForegroundColor Red
    Write-Host "    Run: .\create_keystore.ps1" -ForegroundColor Yellow
    $allPassed = $false
}

# Check 2: key.properties exists
Write-Host "[2/8] Checking key.properties..." -ForegroundColor Yellow
if (Test-Path "android\key.properties") {
    Write-Host "  ✓ key.properties found" -ForegroundColor Green
} else {
    Write-Host "  ✗ key.properties NOT found!" -ForegroundColor Red
    $allPassed = $false
}

# Check 3: Version in pubspec.yaml
Write-Host "[3/8] Checking version..." -ForegroundColor Yellow
$pubspecContent = Get-Content "pubspec.yaml" -Raw
if ($pubspecContent -match 'version:\s+([\d.]+)\+(\d+)') {
    $versionName = $matches[1]
    $versionCode = $matches[2]
    Write-Host "  ✓ Version: $versionName ($versionCode)" -ForegroundColor Green
    
    # Check if version is reasonable
    if ($versionCode -lt 1) {
        Write-Host "  ⚠ Version code should be >= 1" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✗ Could not parse version!" -ForegroundColor Red
    $allPassed = $false
}

# Check 4: AppConfig version matches
Write-Host "[4/8] Checking AppConfig version..." -ForegroundColor Yellow
$appConfigContent = Get-Content "lib\config\app_config.dart" -Raw
if ($appConfigContent -match "appVersion\s*=\s*'([^']+)'") {
    $appConfigVersion = $matches[1]
    if ($appConfigVersion -eq $versionName) {
        Write-Host "  ✓ AppConfig version matches: $appConfigVersion" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Version mismatch!" -ForegroundColor Yellow
        Write-Host "    pubspec.yaml: $versionName" -ForegroundColor White
        Write-Host "    AppConfig: $appConfigVersion" -ForegroundColor White
        Write-Host "    Please sync versions!" -ForegroundColor Yellow
    }
}

# Check 5: google-services.json exists
Write-Host "[5/8] Checking Firebase config..." -ForegroundColor Yellow
if (Test-Path "android\app\google-services.json") {
    Write-Host "  ✓ google-services.json found" -ForegroundColor Green
} else {
    Write-Host "  ✗ google-services.json NOT found!" -ForegroundColor Red
    $allPassed = $false
}

# Check 6: Application ID
Write-Host "[6/8] Checking application ID..." -ForegroundColor Yellow
$buildGradleContent = Get-Content "android\app\build.gradle.kts" -Raw
if ($buildGradleContent -match 'applicationId\s*=\s*"([^"]+)"') {
    $appId = $matches[1]
    Write-Host "  ✓ Application ID: $appId" -ForegroundColor Green
} else {
    Write-Host "  ✗ Could not parse application ID!" -ForegroundColor Red
    $allPassed = $false
}

# Check 7: Proguard rules
Write-Host "[7/8] Checking ProGuard rules..." -ForegroundColor Yellow
if (Test-Path "android\app\proguard-rules.pro") {
    Write-Host "  ✓ ProGuard rules found" -ForegroundColor Green
} else {
    Write-Host "  ⚠ ProGuard rules NOT found" -ForegroundColor Yellow
    Write-Host "    Code obfuscation will use defaults only" -ForegroundColor White
}

# Check 8: Build config
Write-Host "[8/9] Checking build configuration..." -ForegroundColor Yellow
if ($buildGradleContent -match 'isMinifyEnabled\s*=\s*true') {
    Write-Host "  ✓ Minification enabled" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Minification NOT enabled" -ForegroundColor Yellow
}
if ($buildGradleContent -match 'isShrinkResources\s*=\s*true') {
    Write-Host "  ✓ Resource shrinking enabled" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Resource shrinking NOT enabled" -ForegroundColor Yellow
}

# Check 9: Kotlin version
Write-Host "[9/9] Checking Kotlin version..." -ForegroundColor Yellow
$settingsGradleContent = Get-Content "android\settings.gradle.kts" -Raw
if ($settingsGradleContent -match 'org\.jetbrains\.kotlin\.android.*version\s+"([\d.]+)"') {
    $kotlinVersion = $matches[1]
    $kotlinMajor = [int]($kotlinVersion -split '\.')[0]
    $kotlinMinor = [int]($kotlinVersion -split '\.')[1]
    
    if ($kotlinMajor -gt 2 -or ($kotlinMajor -eq 2 -and $kotlinMinor -ge 1)) {
        Write-Host "  ✓ Kotlin version: $kotlinVersion (>= 2.1.0)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Kotlin version: $kotlinVersion (< 2.1.0)" -ForegroundColor Yellow
        Write-Host "    Consider upgrading to 2.1.0 or higher" -ForegroundColor White
    }
} else {
    Write-Host "  ⚠ Could not detect Kotlin version" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "  ✓ All critical checks PASSED" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ready to build!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Run: .\build_appbundle.ps1" -ForegroundColor White
    Write-Host "2. Upload to Google Play Console" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "  ✗ Some checks FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please fix the issues above before building!" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Show useful info
Write-Host "Build Details:" -ForegroundColor Cyan
Write-Host "  App ID: $appId" -ForegroundColor White
Write-Host "  Version: $versionName (code: $versionCode)" -ForegroundColor White
Write-Host "  Output: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor White
Write-Host ""
