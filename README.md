# monitor_app

# Monitor App - Flutter với Firebase Cloud Messaging

Ứng dụng Flutter với tích hợp Firebase Cloud Messaging để nhận push notification từ web server PHP.

## Tính năng

- ✅ Flutter app cơ bản với left menu (drawer)
- ✅ Firebase Cloud Messaging integration
- ✅ Hỗ trợ Android và iOS
- ✅ PHP server script để gửi notification
- ✅ Quản lý FCM tokens và topics
- ✅ Handle foreground/background notifications

## Cấu trúc project

```
monitor_app/
├── lib/
│   ├── main.dart                 # Main app với drawer menu
│   └── services/
│       └── firebase_messaging_service.dart  # Firebase service
├── php_server/                   # PHP scripts cho web server
│   ├── firebase_messaging.php    # Main PHP script với web interface
│   ├── send_test.php            # Simple test script
│   └── README.md                # Hướng dẫn PHP server
├── FIREBASE_SETUP.md            # Hướng dẫn cấu hình Firebase
└── README.md                    # File này
```

## Quick Start

### 1. Cài đặt dependencies

```bash
cd monitor_app
flutter pub get
```

### 2. Cấu hình Firebase

Làm theo hướng dẫn trong `FIREBASE_SETUP.md`:

1. Tạo Firebase project
2. Thêm Android/iOS app
3. Download `google-services.json` và `GoogleService-Info.plist`
4. Copy vào đúng thư mục
5. Enable Cloud Messaging

### 3. Chạy app

```bash
# Android
flutter run

# iOS  
flutter run -d ios

# Web (không hỗ trợ FCM đầy đủ)
flutter run -d chrome
```

### 4. Test notification từ PHP

1. Vào thư mục `php_server/`
2. Làm theo hướng dẫn trong `php_server/README.md`
3. Cấu hình Server Key và FCM Token
4. Chạy test:

```bash
php send_test.php
```

## Cách sử dụng

### Trong Flutter App

1. **Màn hình Thông báo**: Xem FCM token, đăng ký/hủy topics
2. **Home**: Màn hình chính
3. **Profile**: Thông tin người dùng
4. **Settings**: Cài đặt ứng dụng
5. **About**: Thông tin ứng dụng

### Gửi notification từ PHP

#### Option 1: Web Interface
- Mở `firebase_messaging.php` trong browser
- Nhập thông tin và gửi

#### Option 2: API Call
```php
include 'firebase_messaging.php';
$fcm = new FirebaseMessaging($serverKey);

// Gửi đến device cụ thể
$result = $fcm->sendToDevice($token, $title, $body, $data);

// Gửi đến topic
$result = $fcm->sendToTopic($topic, $title, $body, $data);
```

#### Option 3: HTTP Request
```bash
curl -X POST http://your-domain.com/firebase_messaging.php \
  -H "Content-Type: application/json" \
  -d '{
    "action": "send_to_device",
    "token": "FCM_TOKEN_HERE",
    "title": "Test Title",
    "body": "Test Message"
  }'
```

## Firebase Messaging Features

### Notification Types

1. **Notification Messages**: Hiển thị notification tự động
2. **Data Messages**: Chỉ gửi data, không hiển thị notification
3. **Mixed Messages**: Có cả notification và data

### Delivery Options

1. **To Device**: Gửi đến FCM token cụ thể
2. **To Topic**: Gửi đến tất cả devices đăng ký topic
3. **To Multiple Devices**: Gửi đến danh sách tokens

### App States Handling

- **Foreground**: App đang mở → Hiển thị local notification
- **Background**: App ở background → System notification
- **Terminated**: App đã đóng → System notification, handle khi mở app

## Development Notes

### Firebase Configuration Files

**Android**: `android/app/google-services.json`
**iOS**: `ios/Runner/GoogleService-Info.plist`

⚠️ **Không commit** các file này lên git (đã có trong .gitignore)

### Testing

1. **Debug Mode**: FCM token sẽ được in ra console
2. **Release Mode**: Token chỉ lấy được qua app interface
3. **Device Testing**: Test trên device thật để đảm bảo notification hoạt động đúng

### Topics

- `general`: Topic chung cho tất cả users
- `news`: Topic cho tin tức
- Có thể tạo thêm topic tùy ý

## Troubleshooting

### Flutter App

1. **Build lỗi**: 
   - Kiểm tra `google-services.json` và `GoogleService-Info.plist`
   - Chạy `flutter clean && flutter pub get`

2. **Không nhận notification**:
   - Kiểm tra quyền notification
   - Test với foreground trước, sau đó background
   - Xem console logs

3. **Token null**:
   - Đảm bảo Firebase đã được khởi tạo
   - Kiểm tra device có kết nối internet

### PHP Server

1. **HTTP 401**: Server Key sai
2. **HTTP 400**: FCM Token sai hoặc expired
3. **cURL errors**: Kiểm tra PHP cURL extension

### Platform Specific

**Android**:
- Minimum SDK: 21 (Android 5.0)
- Google Play Services cần được cập nhật

**iOS**:
- Cần Apple Developer Account cho push notifications
- Test trên device thật (simulator không hỗ trợ push)

## Production Deployment

### Flutter App

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

### PHP Server

1. Upload scripts lên web server
2. Cấu hình HTTPS
3. Bảo mật Server Key (environment variables)
4. Setup logging và monitoring
5. Rate limiting cho API endpoints

## Next Steps

- [ ] Add user authentication
- [ ] Store notification history
- [ ] Advanced notification scheduling
- [ ] Rich notifications (images, actions)
- [ ] Analytics và reporting
- [ ] Multi-language support

## Support

Nếu gặp vấn đề:

1. Kiểm tra console logs
2. Xem file `FIREBASE_SETUP.md`
3. Xem file `php_server/README.md`
4. Test từng bước một theo hướng dẫn

## License

MIT License - Feel free to use and modify.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
