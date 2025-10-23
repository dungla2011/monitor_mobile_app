# Fix NDK Symbol Stripping Issue

## Problem
`Release app bundle failed to strip debug symbols from native libraries`

## Solution Options

### Option 1: Quick Fix - Disable Symbol Stripping (Recommended)
Use the simple build script that skips symbol stripping:

```powershell
.\build_appbundle_simple.ps1
```

**Pros:** Fast, works immediately
**Cons:** Larger file size (~1-2 MB bigger), no code obfuscation

### Option 2: Install Android NDK
1. Open **Android Studio**
2. Go to **Tools > SDK Manager**
3. Click **SDK Tools** tab
4. Check ☑️ **NDK (Side by side)**
5. Click **Apply** and wait for download
6. Restart terminal and run:
```powershell
.\build_appbundle.ps1
```

### Option 3: Update build.gradle.kts
Edit `android/app/build.gradle.kts`:

```kotlin
android {
    // ... existing config
    
    // Add this to specify NDK version
    ndkVersion = "27.0.12077973"  // or your installed version
}
```

Then rebuild:
```powershell
.\build_appbundle.ps1
```

### Option 4: Use APK Instead
APK build works fine:
```powershell
flutter build apk --release
```

Output: `build\app\outputs\flutter-apk\app-release.apk`

## Recommended Approach

For **first upload** to Google Play:
```powershell
.\build_appbundle_simple.ps1
```

For **production releases** (after NDK is installed):
```powershell
.\build_appbundle.ps1
```

## Check Current NDK
```powershell
# Check if NDK is installed
Get-ChildItem "$env:LOCALAPPDATA\Android\Sdk\ndk" -ErrorAction SilentlyContinue
```

If empty or missing, install NDK (Option 2 above).
