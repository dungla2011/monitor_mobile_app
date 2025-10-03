# 🔧 FIX: Custom Notification Sounds

## ❌ Vấn đề đã phát hiện

1. **Foreground (app đang mở):**
   - ❌ Không có âm thanh khi nhận notification
   - Nguyên nhân: Path file âm thanh sai

2. **Background (app đóng/minimize):**
   - ❌ Vẫn dùng âm thanh hệ thống thay vì custom sound
   - Nguyên nhân: File MP3 không có trong Android resources

---

## ✅ Đã sửa

### 1. **Fixed Asset Path** (Foreground sound)

**File:** `lib/models/notification_settings.dart`

**Before:**
```dart
String? getSoundFilePath() {
  return 'assets/sounds/$fileName.mp3'; // ❌ Sai
}
```

**After:**
```dart
String? getSoundFilePath() {
  return 'sounds/$fileName.mp3'; // ✅ Đúng cho AssetSource
}
```

**Lý do:** `AssetSource` tự động thêm `assets/` prefix, nên chỉ cần `sounds/file.mp3`

---

### 2. **Added Android Raw Resources** (Background sound)

**Action:** Copy file MP3 vào Android resources

```bash
# Created folder
android/app/src/main/res/raw/

# Copied files
notification_alert.mp3   -> android/app/src/main/res/raw/
notification_gentle.mp3  -> android/app/src/main/res/raw/
notification_urgent.mp3  -> android/app/src/main/res/raw/
```

**Lý do:** Android local notifications chỉ có thể dùng file từ `res/raw/`, không dùng được từ `assets/`

---

### 3. **Fixed Sound File Name** (Background notification)

**File:** `lib/services/firebase_messaging_service.dart`

**Before:**
```dart
soundFileName = '${settings.notificationSound}.mp3'; // ❌ Sai
sound: RawResourceAndroidNotificationSound(settings.notificationSound)
```

**After:**
```dart
soundFileName = settings.notificationSound; // ✅ Không có .mp3
sound: RawResourceAndroidNotificationSound(soundFileName)
```

**Lý do:** Android `RawResourceAndroidNotificationSound` tự động thêm extension, không cần `.mp3`

---

### 4. **Prevent Double Sound** (Foreground)

**File:** `lib/services/firebase_messaging_service.dart`

**Problem:** Khi app ở foreground, phát âm thanh 2 lần:
1. `NotificationSoundService.playNotificationSound()` - qua AudioPlayer
2. `_showLocalNotification()` - qua flutter_local_notifications

**Solution:** Thêm parameter `playSound` để tắt âm thanh ở notification:

```dart
static Future<void> _handleForegroundMessage(RemoteMessage message) async {
  // Phát âm thanh thông báo custom (1 lần duy nhất)
  await NotificationSoundService.playNotificationSound();
  
  // Hiển thị notification KHÔNG phát âm thanh
  await _showLocalNotification(message, playSound: false);
}

static Future<void> _showLocalNotification(
  RemoteMessage message, {
  bool playSound = true, // Background mới phát
}) async {
  bool shouldPlaySound = playSound && 
      settings.notificationSound != NotificationSettings.soundNone;
  
  final androidSpecs = AndroidNotificationDetails(
    ...
    playSound: shouldPlaySound, // ✅ Control được
    ...
  );
}
```

---

### 5. **Updated Notification Channel**

**File:** `lib/services/firebase_messaging_service.dart`

**Added:** Enable sound và vibration ở channel level

```dart
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
  playSound: true,        // ✅ Enable sound
  enableVibration: true,  // ✅ Enable vibration
);
```

---

## 🧪 Testing

### Test Foreground (App đang mở):

1. Mở app và để ở foreground
2. Gửi notification:
   ```bash
   cd _php
   php send_notification.php
   ```
3. **Kết quả mong đợi:**
   - ✅ Nghe thấy âm thanh custom đã chọn
   - ✅ Notification hiện lên
   - ✅ Chỉ phát âm thanh 1 lần

### Test Background (App minimize):

1. Minimize app (press Home button)
2. Gửi notification:
   ```bash
   cd _php
   php send_notification.php
   ```
3. **Kết quả mong đợi:**
   - ✅ Nghe thấy âm thanh custom đã chọn
   - ✅ Notification hiện trong notification tray
   - ✅ Rung (nếu đã bật)

### Test với các âm thanh khác:

1. Vào **Settings** → **Cài đặt Thông báo**
2. Chọn **"Âm thanh thông báo"**
3. Thử từng âm thanh:
   - Cảnh báo
   - Nhẹ nhàng
   - Khẩn cấp
4. Gửi notification sau mỗi lần đổi
5. Kiểm tra âm thanh có thay đổi

---

## 🚀 Build & Deploy

### Bước 1: Clear cache (Quan trọng!)
```bash
flutter clean
```

**Lý do:** Xóa cache của notification channels cũ

### Bước 2: Rebuild app
```bash
flutter pub get
flutter build apk
```

### Bước 3: Uninstall app cũ (Quan trọng!)
```bash
adb uninstall com.example.monitor_app
```

**Lý do:** Android cache notification channels. Phải uninstall để recreate channels mới.

### Bước 4: Install app mới
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Bước 5: Test
1. Mở app và config âm thanh
2. Test foreground notification
3. Minimize app và test background notification

---

## 📊 Changes Summary

| File | Changes | Purpose |
|------|---------|---------|
| `notification_settings.dart` | Fixed `getSoundFilePath()` | Return correct path for AssetSource |
| `notification_sound_service.dart` | Use corrected path | Play sound from assets |
| `firebase_messaging_service.dart` | Add `playSound` parameter | Prevent double sound |
| `firebase_messaging_service.dart` | Fix sound file name | Remove `.mp3` extension |
| `firebase_messaging_service.dart` | Update channel config | Enable sound & vibration |
| `android/app/src/main/res/raw/` | Add MP3 files | Enable custom sound for background |

---

## ⚠️ Important Notes

### Android Notification Channels

Android **cache notification channels**. Nếu đã tạo channel với config cũ:
- ❌ Không thể update channel
- ✅ Phải **uninstall app** và install lại

**Solution:**
```bash
# Option 1: Uninstall
adb uninstall com.example.monitor_app
adb install build/app/outputs/flutter-apk/app-release.apk

# Option 2: Clear app data (Android Settings)
Settings → Apps → Monitor App → Storage → Clear Data
```

### File Naming

Android resources **không cho phép dấu gạch ngang** trong tên file:
- ❌ `notification-alert.mp3`
- ✅ `notification_alert.mp3`

File names phải:
- Lowercase
- No spaces
- No special chars (chỉ `a-z`, `0-9`, `_`)

### Asset vs Raw Resources

| Location | Use Case | Access Method |
|----------|----------|---------------|
| `assets/sounds/` | Flutter app (foreground) | `AssetSource('sounds/file.mp3')` |
| `android/.../res/raw/` | Android notifications (background) | `RawResourceAndroidNotificationSound('file')` |

**Important:** Phải có cả 2 để hoạt động đầy đủ!

---

## 🐛 Troubleshooting

### Issue: Vẫn không nghe thấy âm thanh foreground

**Check:**
```dart
// Enable debug logs
if (kDebugMode) {
  print('Playing custom sound: $soundFilePath');
}
```

**Verify:**
1. File tồn tại: `assets/sounds/notification_alert.mp3`
2. pubspec.yaml config: `- assets/sounds/`
3. Path đúng: `sounds/notification_alert.mp3` (no `assets/` prefix)

### Issue: Background vẫn dùng default sound

**Check:**
1. File có trong `android/app/src/main/res/raw/`?
2. File name đúng? (no `.mp3` extension khi gọi)
3. Đã uninstall app cũ?

**Force recreate channel:**
```bash
# Uninstall completely
adb uninstall com.example.monitor_app

# Rebuild and install
flutter clean
flutter build apk
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Issue: Âm thanh phát 2 lần (foreground)

**Check:**
```dart
// Trong _handleForegroundMessage:
await _showLocalNotification(message, playSound: false); // ✅ Phải có false
```

### Issue: App crash khi nhận notification

**Check logs:**
```bash
adb logcat | grep -i flutter
```

**Common causes:**
- File MP3 corrupt
- File name sai format
- Missing permissions

---

## ✅ Verification Checklist

- [ ] Files copied to `android/app/src/main/res/raw/`
- [ ] Path fixed in `notification_settings.dart`
- [ ] Sound file name fixed (no `.mp3`)
- [ ] `playSound` parameter added
- [ ] Notification channel updated
- [ ] `flutter clean` executed
- [ ] Old app uninstalled
- [ ] New app installed
- [ ] Foreground sound tested
- [ ] Background sound tested
- [ ] Different sounds tested
- [ ] Vibration tested

---

**Status:** ✅ All fixes applied, ready to rebuild and test!

```bash
flutter clean && flutter build apk
adb uninstall com.example.monitor_app
adb install build/app/outputs/flutter-apk/app-release.apk
```
