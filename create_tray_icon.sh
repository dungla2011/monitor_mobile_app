# Script to convert PNG to ICO for Windows tray icon
# Requires ImageMagick

# Usage: Run this in Git Bash or PowerShell after installing ImageMagick
# Download ImageMagick: https://imagemagick.org/script/download.php#windows

# Convert logo.png to tray_icon.ico with multiple sizes
magick convert assets/icon/logo.png -define icon:auto-resize=256,128,64,48,32,16 assets/icon/tray_icon.ico

echo "✅ Tray icon created: assets/icon/tray_icon.ico"
