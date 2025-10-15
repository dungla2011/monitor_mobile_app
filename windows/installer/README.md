# Windows Installer Setup Guide

This guide explains how to create a Windows installer for the Ping365 Monitor application.

## Prerequisites

### 1. Install Inno Setup
Download and install Inno Setup (free):
- Download from: https://jrsoftware.org/isdl.php
- Install to default location: `C:\Program Files (x86)\Inno Setup 6\`
- Version required: 6.0 or higher

### 2. Verify Flutter Installation
Ensure Flutter is installed and in your PATH:
```bash
flutter --version
```

## Quick Start

### Method 1: Using PowerShell Script (Recommended)

1. Open PowerShell as Administrator (optional, but recommended)
2. Navigate to project root:
   ```powershell
   cd e:\Projects\MonitorApp2025\monitor_app
   ```
3. Run the build script:
   ```powershell
   .\build_installer.ps1
   ```

The script will:
- ✅ Check if Inno Setup is installed
- ✅ Clean previous builds
- ✅ Get Flutter dependencies
- ✅ Build Windows release (takes 2-5 minutes)
- ✅ Create installer with Inno Setup
- ✅ Show installer location and size

**Output:** `installer_output\Ping365_Monitor_Setup_v1.0.0.exe`

### Method 2: Manual Steps

1. Build Flutter app:
   ```bash
   flutter clean
   flutter pub get
   flutter build windows --release
   ```

2. Compile installer with Inno Setup:
   ```bash
   "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" windows\installer\setup.iss
   ```

3. Find installer in `installer_output\` folder

## Installer Features

The created installer includes:

✅ **Automatic Installation**
- Installs to `C:\Program Files\Ping365 Monitor\` by default
- User can choose custom installation path

✅ **Optional Components**
- Desktop shortcut (optional)
- Start with Windows (optional)

✅ **System Tray Integration**
- App minimizes to system tray
- Tray icon with menu (Open, Exit)

✅ **Auto-Start Management**
- User can enable/disable in Settings → Windows Settings
- Or choose during installation

✅ **Clean Uninstall**
- Removes all files and registry entries
- Available in Windows Settings → Apps

## Customization

### Update Version Number
Edit `windows\installer\setup.iss`:
```pascal
#define MyAppVersion "1.0.0"  ; Change this
```

### Change App Name or Publisher
Edit `windows\installer\setup.iss`:
```pascal
#define MyAppName "Ping365 Monitor"
#define MyAppPublisher "GalaxyCloud"
#define MyAppURL "https://ping365.io"
```

### Custom Installer Icon
Replace icon in setup.iss:
```pascal
SetupIconFile=..\..\assets\icon\logo.png
```

### Add License File
Ensure LICENSE file exists at project root, or update:
```pascal
LicenseFile=..\..\LICENSE
```

## Troubleshooting

### Error: Inno Setup not found
- Install Inno Setup from https://jrsoftware.org/isdl.php
- Or update `$InnoSetupPath` in `build_installer.ps1` if installed elsewhere

### Error: Flutter build failed
- Run `flutter doctor` to check Flutter installation
- Ensure all dependencies are installed: `flutter pub get`
- Try `flutter clean` then rebuild

### Error: Installer creation failed
- Check `setup.iss` syntax
- Ensure all source files exist in build output
- Check Inno Setup compiler output for specific errors

### Installer size too large
- Ensure you're building with `--release` flag
- Consider excluding unnecessary files in `setup.iss`

## Distribution

### Code Signing (Optional but Recommended)
For production distribution, sign your installer:
1. Obtain a code signing certificate
2. Use SignTool.exe to sign the .exe
3. Adds trust and prevents Windows SmartScreen warnings

### Testing the Installer
1. Test on clean Windows VM
2. Verify all features work after installation
3. Test uninstall process
4. Check auto-start functionality

## File Structure
```
monitor_app/
├── build_installer.ps1          # PowerShell build script
├── windows/
│   └── installer/
│       ├── setup.iss            # Inno Setup script
│       └── README.md            # This file
├── installer_output/            # Generated installers (git-ignored)
└── build/
    └── windows/
        └── x64/
            └── runner/
                └── Release/     # Flutter build output
                    └── monitor_app.exe
```

## CI/CD Integration

To integrate with GitHub Actions or other CI:

```yaml
- name: Install Inno Setup
  run: choco install innosetup -y

- name: Build and Create Installer
  run: |
    flutter build windows --release
    iscc windows/installer/setup.iss

- name: Upload Installer
  uses: actions/upload-artifact@v3
  with:
    name: windows-installer
    path: installer_output/*.exe
```

## Support

For issues or questions:
- GitHub: https://github.com/dungla2011/monitor_mobile_app
- Email: support@ping365.io
