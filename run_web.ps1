# Ping365 Monitor - Run Web on Port 8008

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ping365 Monitor - Run Web (Port 8008)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting Flutter web server on port 8008..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

flutter run -d chrome --web-port=8008
