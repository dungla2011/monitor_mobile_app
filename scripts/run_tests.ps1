# PowerShell script to run all tests and generate coverage report
# Run Tests Script for Monitor App

Write-Host "🚀 Starting test automation..." -ForegroundColor Green

# Check if Flutter is installed
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter not found. Please install Flutter first." -ForegroundColor Red
    exit 1
}

Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error installing dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "🔧 Generating mocks..." -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Warning: Could not generate mocks" -ForegroundColor Yellow
}

Write-Host "📝 Checking code formatting..." -ForegroundColor Yellow
dart format --output=none --set-exit-if-changed .

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Code formatting issues. Run 'dart format .' to fix." -ForegroundColor Yellow
}

Write-Host "🔍 Analyzing code..." -ForegroundColor Yellow
flutter analyze

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Code analysis issues found" -ForegroundColor Yellow
}

Write-Host "🧪 Running unit tests..." -ForegroundColor Yellow
flutter test --coverage

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Unit tests failed" -ForegroundColor Red
    exit 1
}

Write-Host "🎯 Running widget tests..." -ForegroundColor Yellow
flutter test test/widget/

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Widget tests failed" -ForegroundColor Red
    exit 1
}

Write-Host "🔗 Running integration tests..." -ForegroundColor Yellow
flutter test integration_test/

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Integration tests failed" -ForegroundColor Red
    exit 1
}

# Generate HTML coverage report if lcov is available
Write-Host "📊 Generating coverage report..." -ForegroundColor Yellow
if (Test-Path "coverage/lcov.info") {
    Write-Host "✅ Coverage data generated at: coverage/lcov.info" -ForegroundColor Green
    
    # Try to generate HTML report if genhtml is available
    if (Get-Command genhtml -ErrorAction SilentlyContinue) {
        genhtml coverage/lcov.info -o coverage/html
        Write-Host "📊 HTML coverage report: coverage/html/index.html" -ForegroundColor Green
    } else {
        Write-Host "💡 To generate HTML report, install lcov: choco install lcov" -ForegroundColor Cyan
    }
} else {
    Write-Host "⚠️ Coverage data not found" -ForegroundColor Yellow
}

Write-Host "✅ All tests completed successfully!" -ForegroundColor Green
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "  - Unit tests: ✅" -ForegroundColor Green
Write-Host "  - Widget tests: ✅" -ForegroundColor Green  
Write-Host "  - Integration tests: ✅" -ForegroundColor Green
Write-Host "  - Coverage report: coverage/lcov.info" -ForegroundColor Cyan

# Optional: Open coverage report in browser
$openCoverage = Read-Host "Do you want to open the coverage report? (y/n)"
if ($openCoverage -eq "y") {
    if (Test-Path "coverage/html/index.html") {
        Start-Process "coverage/html/index.html"
    } else {
        Write-Host "HTML coverage report not found" -ForegroundColor Yellow
    }
}