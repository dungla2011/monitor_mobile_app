# 🔊 QUAN TRỌNG - ĐỌC TRƯỚC KHI TEST!

## ⚠️ BẮT BUỘC: Uninstall App Cũ

Android **cache notification channels**. Nếu không uninstall app cũ:
- ❌ Custom sound KHÔNG hoạt động
- ❌ Vẫn dùng âm thanh cũ

**Giải pháp:**

### Option 1: Uninstall qua ADB (Khuyến nghị)
```bash
adb uninstall com.example.monitor_app
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Option 2: Uninstall thủ công trên điện thoại
1. Giữ icon app → **Uninstall**
2. Hoặc: Settings → Apps → Monitor App → **Uninstall**
3. Sau đó install file APK mới

### Option 3: Clear App Data (Ít hiệu quả hơn)
Settings → Apps → Monitor App → Storage → **Clear Data**

---

## 🚀 Các bước test đúng

### 1. Build APK mới
```bash
flutter clean
flutter pub get
flutter build apk
```

### 2. Uninstall app cũ hoàn toàn
```bash
adb uninstall com.example.monitor_app
```

### 3. Install app mới
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 4. Mở app và config
- Vào **Settings** → **Cài đặt Thông báo**
- Chọn **Âm thanh thông báo** → Chọn âm thanh (VD: Cảnh báo)
- Tap **"Nghe thử"** để kiểm tra âm thanh hoạt động

### 5. Test Foreground (App đang mở)
```bash
cd _php
php send_notification.php
```

**Mong đợi:**
- ✅ Nghe thấy âm thanh "Cảnh báo"
- ✅ Notification hiện lên
- ✅ Chỉ phát âm thanh 1 lần (không duplicate)

### 6. Test Background (App minimize)
- Press **Home button** để minimize app
- Gửi notification:
```bash
cd _php
php send_notification.php
```

**Mong đợi:**
- ✅ Nghe thấy âm thanh "Cảnh báo" (KHÔNG phải default)
- ✅ Notification trong notification tray
- ✅ Rung (nếu đã bật)

### 7. Test thay đổi âm thanh
- Mở app → Settings → Đổi sang "Nhẹ nhàng"
- Gửi notification lại
- **Mong đợi:** Nghe âm thanh mới

---

## ✅ Đã fix

| Issue | Status |
|-------|--------|
| Không có âm thanh foreground | ✅ Fixed |
| Background vẫn dùng default sound | ✅ Fixed |
| Path âm thanh sai | ✅ Fixed |
| Android raw resources thiếu | ✅ Added |
| Âm thanh phát 2 lần | ✅ Fixed |

**Files changed:**
- ✅ `notification_settings.dart` - Fixed path
- ✅ `notification_sound_service.dart` - Use correct path
- ✅ `firebase_messaging_service.dart` - Prevent double sound + fix Android sound
- ✅ `android/app/src/main/res/raw/` - Added 3 MP3 files

---

## 🐛 Nếu vẫn không work

### Kiểm tra logs:
```bash
# Run app và xem logs
flutter run

# Hoặc xem Android logs
adb logcat | grep -i flutter
```

### Tìm dòng:
```
✅ Notification channel created: high_importance_channel
Playing custom sound: sounds/notification_alert.mp3
Foreground message received: ...
```

### Common mistakes:

1. ❌ **Chưa uninstall app cũ**
   - Solution: `adb uninstall com.example.monitor_app`

2. ❌ **File MP3 không có trong raw/**
   - Check: `ls android/app/src/main/res/raw/`
   - Should see: `notification_alert.mp3`, etc.

3. ❌ **Không rebuild sau khi thay đổi**
   - Solution: `flutter clean && flutter build apk`

4. ❌ **Volume điện thoại = 0**
   - Solution: Tăng volume lên

---

## 📝 Quick Commands

```bash
# Full rebuild và reinstall
flutter clean
flutter pub get
flutter build apk
adb uninstall com.example.monitor_app
adb install build/app/outputs/flutter-apk/app-release.apk

# Test notification
cd _php
php send_notification.php
```

---

**Chi tiết đầy đủ:** Xem file `FIX_NOTIFICATION_SOUNDS.md`
