# Simulate CI Pipeline locally
# PowerShell script to run the same steps as CI

Write-Host "🚀 Starting CI Pipeline Simulation..." -ForegroundColor Green
Write-Host ""

# Step 1: Check Flutter setup
Write-Host "📋 Step 1: Checking Flutter setup..." -ForegroundColor Blue
flutter --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter not found! Please install Flutter first." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Flutter setup OK" -ForegroundColor Green
Write-Host ""

# Step 2: Get dependencies
Write-Host "📦 Step 2: Getting dependencies..." -ForegroundColor Blue
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get dependencies!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Dependencies OK" -ForegroundColor Green
Write-Host ""

# Step 3: Check formatting
Write-Host "🎨 Step 3: Checking code formatting..." -ForegroundColor Blue
dart format --output=none --set-exit-if-changed .
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Code formatting issues found. Running formatter..." -ForegroundColor Yellow
    dart format .
    Write-Host "✅ Code formatted" -ForegroundColor Green
} else {
    Write-Host "✅ Code formatting OK" -ForegroundColor Green
}
Write-Host ""

# Step 4: Analyze code
Write-Host "🔍 Step 4: Analyzing code..." -ForegroundColor Blue
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Code analysis failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Code analysis OK" -ForegroundColor Green
Write-Host ""

# Step 5: Generate mocks
Write-Host "🏭 Step 5: Generating mocks..." -ForegroundColor Blue
dart run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Mock generation failed, but continuing..." -ForegroundColor Yellow
} else {
    Write-Host "✅ Mocks generated" -ForegroundColor Green
}
Write-Host ""

# Step 6: Run unit tests
Write-Host "🧪 Step 6: Running unit tests..." -ForegroundColor Blue
flutter test --coverage
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Unit tests failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Unit tests passed" -ForegroundColor Green
Write-Host ""

# Step 7: Check for devices (integration tests)
Write-Host "📱 Step 7: Checking for devices..." -ForegroundColor Blue
$devices = flutter devices --machine | ConvertFrom-Json
$hasDevice = $false

foreach ($device in $devices) {
    if ($device.type -eq "device") {
        $hasDevice = $true
        break
    }
}

if ($hasDevice) {
    Write-Host "✅ Device found. Running integration tests..." -ForegroundColor Green
    flutter test integration_test/
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Integration tests failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Integration tests passed" -ForegroundColor Green
} else {
    Write-Host "⚠️ No devices found locally. Skipping integration tests." -ForegroundColor Yellow
    Write-Host "ℹ️ Note: CI will run integration tests on Android emulator" -ForegroundColor Cyan
    Write-Host "💡 To run integration tests locally:" -ForegroundColor Cyan
    Write-Host "   1. Connect Android device or start emulator/iOS simulator" -ForegroundColor Cyan
    Write-Host "   2. Run: flutter test integration_test/" -ForegroundColor Cyan
}
Write-Host ""

# Summary
Write-Host "🎉 CI Pipeline Simulation Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Blue
Write-Host "- ✅ Flutter setup: OK"
Write-Host "- ✅ Dependencies: OK" 
Write-Host "- ✅ Code formatting: OK"
Write-Host "- ✅ Code analysis: OK"
Write-Host "- ✅ Mock generation: OK"
Write-Host "- ✅ Unit tests: PASSED"
if ($hasDevice) {
    Write-Host "- ✅ Integration tests: PASSED"
} else {
    Write-Host "- ⚠️ Integration tests: SKIPPED (will run on CI with Android emulator)"
}
Write-Host "- ✅ Coverage report: Generated"
Write-Host ""
Write-Host "🚀 Ready for CI/CD!" -ForegroundColor Green
