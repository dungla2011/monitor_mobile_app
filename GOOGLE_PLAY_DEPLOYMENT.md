# Google Play Store Deployment Guide

This guide explains how to build and upload your app to Google Play Store.

## Prerequisites

1. Google Play Developer Account ($25 one-time fee)
2. Java JDK installed (for keytool)
3. Flutter installed

## Step 1: Create Keystore (One-time setup)

### Option A: Using PowerShell Script
```powershell
.\create_keystore.ps1
```

### Option B: Manual Command
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias ping365
```

**Important:** 
- Remember your keystore password!
- Keep `upload-keystore.jks` file safe (DO NOT commit to Git)
- If you lose this, you can't update your app anymore!

## Step 2: Create key.properties

Create file: `android/key.properties`

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=ping365
storeFile=upload-keystore.jks
```

**Replace:**
- `YOUR_KEYSTORE_PASSWORD` with your keystore password
- `YOUR_KEY_PASSWORD` with your key password (usually same as keystore)

## Step 3: Configure build.gradle

The file `android/app/build.gradle.kts` should already be configured.

Verify it has:

```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

## Step 4: Update App Version

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+1
#         ↑   ↑
#    Version  Build
#    Name     Number
```

- Version name: `1.0.0` (what users see)
- Build number: `1` (must increase for each upload)

**For updates:**
```yaml
version: 1.0.1+2  # Version 1.0.1, Build 2
version: 1.1.0+3  # Version 1.1.0, Build 3
```

## Step 5: Build App Bundle

### Clean Build
```bash
flutter clean
flutter pub get
```

### Build for Production
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Verify Build
```bash
# Check file exists
ls -la build/app/outputs/bundle/release/app-release.aab

# File size should be 20-50 MB typically
```

## Step 6: Test Before Upload (Optional but Recommended)

### Test with bundletool
```bash
# Download bundletool
# https://github.com/google/bundletool/releases

# Generate APKs from bundle
java -jar bundletool.jar build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks --mode=universal

# Install on device
java -jar bundletool.jar install-apks --apks=app.apks
```

## Step 7: Upload to Google Play Console

1. **Go to Google Play Console**
   - https://play.google.com/console

2. **Create App (First time only)**
   - Click "Create app"
   - App name: `Ping365 Monitor`
   - Language: English (or your preferred)
   - App type: App
   - Free or Paid: Free

3. **Set up App**
   - Fill in Store listing (description, screenshots, etc.)
   - Content rating questionnaire
   - Target audience and content
   - Privacy policy URL (required)

4. **Upload App Bundle**
   - Go to: Production → Create new release
   - Upload: `build/app/outputs/bundle/release/app-release.aab`
   - Release name: `1.0.0` (or current version)
   - Release notes: 
     ```
     Initial release
     - Monitor your services with ping checks
     - Web content monitoring
     - Push notifications
     - Dark/Light theme
     ```

5. **Review and Publish**
   - Review all sections (must have green checkmarks)
   - Submit for review
   - Wait 1-7 days for Google review

## Step 8: Play App Signing (First Upload)

Google will prompt you to enroll in Play App Signing:

1. **Choose:** "Continue with existing key"
2. **Upload:** Your `upload-keystore.jks` certificate
3. **Google will:** Create and manage the release signing key

**Benefits:**
- Google manages final signing key
- You can reset upload key if lost
- Better security

## Common Issues

### Error: No linked app
- Make sure package name matches in `build.gradle` and Google Play Console
- Default: `com.galaxycloud.monitor_app`

### Error: Version code conflict
- Increase build number in `pubspec.yaml`
- Each upload must have higher build number than previous

### Error: Missing permissions
- Review `AndroidManifest.xml`
- Required permissions must be declared

### Error: 64-bit requirement
- Make sure you're building with recent Flutter (3.0+)
- 64-bit support is automatic

## Updating the App

For each new version:

1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # Increment both numbers
   ```

2. Build new bundle:
   ```bash
   flutter build appbundle --release
   ```

3. Upload to Google Play Console
   - Production → Create new release
   - Upload new `.aab` file
   - Add release notes
   - Submit

## Quick Reference

```bash
# 1. Build
flutter build appbundle --release

# 2. Find output
ls build/app/outputs/bundle/release/app-release.aab

# 3. Upload to Google Play Console
# https://play.google.com/console
```

## Security Best Practices

1. ✅ **DO:**
   - Keep keystore file safe (backup to secure location)
   - Add `*.jks` and `key.properties` to `.gitignore`
   - Use strong passwords
   - Enable Play App Signing

2. ❌ **DON'T:**
   - Commit keystore or passwords to Git
   - Share keystore with untrusted people
   - Use weak passwords
   - Lose your keystore!

## Files to Ignore in Git

Add to `.gitignore`:
```
android/key.properties
android/app/upload-keystore.jks
*.jks
```

## Support

- Google Play Console Help: https://support.google.com/googleplay/android-developer
- Flutter Deployment: https://docs.flutter.dev/deployment/android
- Issue: support@ping365.io
