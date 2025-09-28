# PHP Server for Firebase Cloud Messaging

Thư mục này chứa các PHP script để gửi push notification từ web server về Flutter app.

## Files

- `firebase_messaging.php` - Script chính với class FirebaseMessaging và giao diện web test
- `send_test.php` - Script test đơn giản để test nhanh
- `README.md` - File hướng dẫn này

## Cài đặt và cấu hình

### 1. Chuẩn bị server

Cần PHP với cURL extension:
```bash
# Kiểm tra PHP có cURL
php -m | grep curl
```

### 2. Lấy Server Key từ Firebase

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Project Settings** (biểu tượng bánh răng)
4. Tab **Cloud Messaging**
5. Copy **Server key**

### 3. Lấy FCM Token từ Flutter App

1. Chạy Flutter app
2. Vào màn hình "Thông báo" trong left menu
3. Copy FCM Token hiển thị

### 4. Cấu hình PHP scripts

Mở các file PHP và thay thế:
```php
$SERVER_KEY = 'YOUR_SERVER_KEY_HERE'; // Thay bằng Server Key
$FCM_TOKEN = 'YOUR_FCM_TOKEN_HERE';   // Thay bằng FCM Token
```

## Cách sử dụng

### Option 1: Test bằng command line

```bash
php send_test.php
```

### Option 2: Sử dụng web interface

1. Upload `firebase_messaging.php` lên web server
2. Truy cập: `http://your-domain.com/firebase_messaging.php`
3. Nhập thông tin và test

### Option 3: Gọi API từ PHP application khác

```php
include 'firebase_messaging.php';

$fcm = new FirebaseMessaging($serverKey);

// Gửi đến device cụ thể
$result = $fcm->sendToDevice(
    $fcmToken,
    'Tiêu đề',
    'Nội dung tin nhắn',
    ['key' => 'value'] // Custom data
);

// Gửi đến topic
$result = $fcm->sendToTopic(
    'general',
    'Thông báo chung',
    'Nội dung cho tất cả users'
);
```

### Option 4: AJAX/HTTP API

POST request đến `firebase_messaging.php`:

```javascript
// Gửi đến device
fetch('firebase_messaging.php', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        action: 'send_to_device',
        token: 'FCM_TOKEN_HERE',
        title: 'Tiêu đề',
        body: 'Nội dung',
        data: {custom: 'data'}
    })
});

// Gửi đến topic
fetch('firebase_messaging.php', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        action: 'send_to_topic',
        topic: 'general',
        title: 'Tiêu đề',
        body: 'Nội dung'
    })
});
```

## API Actions

### send_to_device
Gửi notification đến một device cụ thể
- `token` (required): FCM token
- `title`: Tiêu đề notification
- `body`: Nội dung notification  
- `data`: Custom data object

### send_to_topic
Gửi notification đến tất cả devices đăng ký topic
- `topic` (required): Tên topic
- `title`: Tiêu đề notification
- `body`: Nội dung notification
- `data`: Custom data object

### send_data_only
Gửi data-only message (không hiển thị notification)
- `token` (required): FCM token
- `data` (required): Data object

## Troubleshooting

### Lỗi thường gặp

1. **HTTP 401 Unauthorized**
   - Kiểm tra Server Key có đúng không
   - Đảm bảo Cloud Messaging đã được enable

2. **HTTP 400 Bad Request**
   - Kiểm tra FCM Token có đúng không
   - Kiểm tra format JSON có hợp lệ không

3. **Success: 0, Failure: 1**
   - FCM Token có thể đã expired hoặc invalid
   - Device có thể đã uninstall app

### Debug

Bật debug trong PHP:
```php
// Thêm vào đầu file
error_reporting(E_ALL);
ini_set('display_errors', 1);
```

## Bảo mật

- **Không commit Server Key** lên git
- Lưu Server Key trong environment variables
- Sử dụng HTTPS cho production
- Validate input data
- Rate limiting cho API endpoints

## Integration với hệ thống khác

### Database example
```php
// Lưu notification log
$pdo->prepare("INSERT INTO notifications (user_id, title, body, sent_at) VALUES (?, ?, ?, NOW())")
    ->execute([$userId, $title, $body]);

// Lấy danh sách tokens từ DB
$stmt = $pdo->prepare("SELECT fcm_token FROM users WHERE active = 1");
$stmt->execute();
$tokens = $stmt->fetchAll(PDO::FETCH_COLUMN);

// Gửi đến nhiều users
$fcm->sendToMultipleDevices($tokens, $title, $body);
```

### Cron job example
```bash
# Gửi thông báo hàng ngày lúc 9:00
0 9 * * * php /path/to/daily_notification.php
```