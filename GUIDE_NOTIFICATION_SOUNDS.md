# Hướng dẫn Cài đặt Âm thanh Thông báo

Tính năng cho phép người dùng chọn âm thanh thông báo Firebase trong Settings.

## ✨ Tính năng

1. **Chọn âm thanh thông báo:**
   - Âm thanh mặc định của hệ điều hành
   - Không có âm thanh
   - 3 âm thanh custom: Cảnh báo, Nhẹ nhàng, Khẩn cấp

2. **Bật/Tắt thông báo:**
   - Toggle để bật/tắt hoàn toàn thông báo

3. **Bật/Tắt rung:**
   - Toggle để bật/tắt rung khi có thông báo

4. **Nghe thử âm thanh:**
   - Nút "Nghe thử" để preview âm thanh trước khi chọn

## 📁 Cấu trúc Files

### 1. Models
- `lib/models/notification_settings.dart` - Model quản lý cài đặt thông báo

### 2. Services
- `lib/services/notification_sound_service.dart` - Service quản lý âm thanh
- `lib/services/firebase_messaging_service.dart` - Tích hợp âm thanh với FCM

### 3. UI
- `lib/screens/settings_screen.dart` - UI Settings với section Notification

### 4. Assets
- `assets/sounds/` - Thư mục chứa file âm thanh MP3
- `assets/sounds/README.md` - Hướng dẫn thêm âm thanh

## 🎵 Thêm File Âm thanh

### Bước 1: Tải âm thanh
Tải các file MP3 từ:
- https://mixkit.co/free-sound-effects/notification/
- https://freesound.org/
- https://notificationsounds.com/

### Bước 2: Đặt tên file
Đặt tên file theo format:
- `notification_alert.mp3` - Âm thanh cảnh báo
- `notification_gentle.mp3` - Âm thanh nhẹ nhàng
- `notification_urgent.mp3` - Âm thanh khẩn cấp

### Bước 3: Copy vào thư mục
Copy các file MP3 vào thư mục:
```
assets/sounds/
├── notification_alert.mp3
├── notification_gentle.mp3
└── notification_urgent.mp3
```

### Bước 4: Rebuild app
```bash
flutter clean
flutter pub get
flutter build apk  # hoặc flutter run
```

## 💾 Lưu trữ Settings

Settings được lưu trong **SharedPreferences** với các key:
- `notification_sound` - Loại âm thanh đã chọn
- `notification_enabled` - Bật/tắt thông báo
- `notification_vibrate` - Bật/tắt rung

## 🔧 Cách sử dụng trong Code

### Lấy settings hiện tại:
```dart
import 'package:monitor_app/services/notification_sound_service.dart';

final settings = await NotificationSoundService.getSettings();
print('Sound: ${settings.notificationSound}');
print('Enabled: ${settings.notificationEnabled}');
print('Vibrate: ${settings.notificationVibrate}');
```

### Lưu settings mới:
```dart
final updated = settings.copyWith(
  notificationSound: 'notification_alert',
  notificationEnabled: true,
  notificationVibrate: true,
);
await NotificationSoundService.saveSettings(updated);
```

### Phát âm thanh thông báo:
```dart
// Tự động phát âm thanh theo settings
await NotificationSoundService.playNotificationSound();

// Preview âm thanh (không phụ thuộc settings)
await NotificationSoundService.previewSound('notification_alert');
```

## 📱 UI Settings

### Vào Settings:
1. Mở app
2. Vào **Drawer** → **Settings**
3. Scroll xuống section **"Cài đặt Thông báo"**

### Chọn âm thanh:
1. Tap vào **"Âm thanh thông báo"**
2. Dialog hiện ra với danh sách âm thanh
3. Tap **"Nghe thử"** để preview (chỉ custom sounds)
4. Chọn âm thanh muốn dùng
5. Tap **"Lưu"**

### Bật/Tắt thông báo:
- Toggle switch **"Bật thông báo"** ON/OFF

### Bật/Tắt rung:
- Toggle switch **"Rung"** ON/OFF (chỉ khi notification enabled)

## 🔊 Các loại âm thanh

### 1. Mặc định (Hệ điều hành)
- Key: `default`
- Mô tả: Sử dụng âm thanh thông báo mặc định của Android/iOS
- File: Không cần file, hệ điều hành tự xử lý

### 2. Không có âm thanh
- Key: `none`
- Mô tả: Im lặng, không phát âm thanh
- File: Không cần file

### 3. Cảnh báo
- Key: `notification_alert`
- Mô tả: Âm thanh cảnh báo rõ ràng
- File: `assets/sounds/notification_alert.mp3`

### 4. Nhẹ nhàng
- Key: `notification_gentle`
- Mô tả: Âm thanh nhẹ nhàng, dịu dàng
- File: `assets/sounds/notification_gentle.mp3`

### 5. Khẩn cấp
- Key: `notification_urgent`
- Mô tả: Âm thanh khẩn cấp, quan trọng
- File: `assets/sounds/notification_urgent.mp3`

## 🔄 Flow hoạt động

### Khi nhận Firebase Notification:

1. **Firebase Cloud Messaging** nhận notification
2. **FirebaseMessagingService** xử lý:
   - Load **NotificationSettings** từ SharedPreferences
   - Kiểm tra `notificationEnabled`
   - Nếu enabled:
     - Phát âm thanh qua **NotificationSoundService**
     - Hiển thị notification với âm thanh đã chọn
     - Rung (nếu `notificationVibrate` = true)

### Khi user thay đổi settings:

1. User chọn âm thanh trong **Settings Screen**
2. **NotificationSoundService** lưu vào SharedPreferences
3. Lần nhận notification tiếp theo sẽ dùng âm thanh mới

## 🧪 Testing

### Test trên Emulator/Device:

1. **Cài đặt app:**
   ```bash
   flutter build apk
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Vào Settings:**
   - Chọn âm thanh khác nhau và tap "Nghe thử"

3. **Gửi test notification:**
   ```bash
   cd _php
   php send_notification.php
   ```

4. **Kiểm tra:**
   - Notification hiện ra
   - Âm thanh đã chọn được phát
   - Rung (nếu bật)

## 🐛 Troubleshooting

### Không nghe thấy âm thanh custom:

1. **Kiểm tra file tồn tại:**
   ```
   assets/sounds/notification_alert.mp3
   assets/sounds/notification_gentle.mp3
   assets/sounds/notification_urgent.mp3
   ```

2. **Rebuild app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Kiểm tra pubspec.yaml:**
   ```yaml
   flutter:
     assets:
       - assets/sounds/
   ```

### Âm thanh không phát khi nhận notification:

1. **Kiểm tra settings:**
   ```dart
   final settings = await NotificationSoundService.getSettings();
   print(settings.toString());
   ```

2. **Kiểm tra notification permission:**
   - Vào Settings của Android
   - App → Ping365 → Notifications
   - Đảm bảo đã bật

3. **Kiểm tra Firebase logs:**
   - Xem terminal khi chạy app
   - Tìm log: "Playing custom sound: ..."

### Lỗi "Cannot preview system default or no sound":

- Bình thường! Âm thanh "Mặc định" và "Không có âm thanh" không thể preview
- Chỉ custom sounds mới có nút "Nghe thử"

## 📦 Dependencies

```yaml
dependencies:
  audioplayers: ^6.1.0          # Phát âm thanh custom
  shared_preferences: ^2.3.2    # Lưu settings
  flutter_local_notifications: ^18.0.1  # Local notifications
  firebase_messaging: ^15.1.3   # FCM
```

## 🎨 UI Screenshot Flow

```
Settings Screen
│
├── Language Section
│   └── Radio buttons cho ngôn ngữ
│
├── Notification Settings Section ⭐ MỚI
│   ├── Switch: Bật thông báo (ON/OFF)
│   ├── ListTile: Âm thanh thông báo → Dialog chọn âm thanh
│   │   └── Dialog:
│   │       ├── Radio: Mặc định (Hệ điều hành)
│   │       ├── Radio: Không có âm thanh
│   │       ├── Radio: Cảnh báo [Nghe thử]
│   │       ├── Radio: Nhẹ nhàng [Nghe thử]
│   │       └── Radio: Khẩn cấp [Nghe thử]
│   └── Switch: Rung (ON/OFF)
│
└── App Info Section
    ├── App Name
    └── Version
```

## 🔐 Security & Privacy

- Settings chỉ lưu trên local device (SharedPreferences)
- Không đồng bộ lên server
- Không ảnh hưởng đến user khác
- User có thể reset bằng cách xóa app data

## 🚀 Tính năng mở rộng (Future)

1. **Upload custom sounds:**
   - Cho phép user upload file MP3 của riêng họ

2. **Download sound packs:**
   - Tải các bộ âm thanh từ server

3. **Sound per notification type:**
   - Âm thanh khác nhau cho từng loại thông báo
   - VD: Alert type = urgent sound, Info type = gentle sound

4. **Volume control:**
   - Slider để điều chỉnh âm lượng thông báo

5. **Time-based settings:**
   - Silent mode vào ban đêm (22:00 - 7:00)
   - Khác âm thanh theo giờ trong ngày

## 📚 References

- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Audioplayers](https://pub.dev/packages/audioplayers)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
