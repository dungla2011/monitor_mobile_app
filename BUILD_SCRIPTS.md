# Build Scripts

## Quick Start

### 1. Install Inno Setup (One-time setup)
Download and install from: https://jrsoftware.org/isdl.php

### 2. Build Options

#### Option A: Only create installer (fastest)
```powershell
# First, build the app manually:
flutter build windows --release

# Then create installer:
.\build_installer.ps1
```

#### Option B: Full build + package (recommended)
```powershell
# Does everything: clean, build, and create installer
.\build_and_package.ps1
```

## Scripts Overview

| Script | What it does | When to use |
|--------|-------------|-------------|
| `build_installer.ps1` | Creates installer from existing build | After manual `flutter build`, or when only installer config changed |
| `build_and_package.ps1` | Clean → Build → Create installer | First time, or after code changes |

## Output

Installer will be created at:
```
installer_output/Ping365_Monitor_Setup_v1.0.0.exe
```

## Troubleshooting

### Error: Execution Policy
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: Inno Setup not found
Install from: https://jrsoftware.org/isdl.php

### Error: Must use PowerShell
Don't use Git Bash. Open Windows PowerShell or Windows Terminal instead.

## Customization

Edit version and app info in: `windows/installer/setup.iss`
