# Hướng dẫn cấu hình Firebase cho Monitor App

## 1. Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" (Thêm dự án)
3. Nhập tên project: `monitor-app-2025`
4. Chọn "Continue" → "Continue" → "Create project"

## 2. Thêm Android App

1. Trong Firebase Console, click biểu tượng Android
2. **Android package name**: `com.example.monitor_app`
3. **App nickname**: `Monitor App Android`
4. **Debug signing certificate SHA-1**: (tùy chọn, có thể bỏ qua)
5. Click "Register app"

### Download google-services.json
1. Download file `google-services.json`
2. Copy file này vào thư mục: `android/app/google-services.json`

## 3. Thêm Web App (nếu cần chạy trên web)

1. Trong Firebase Console, click biểu tượng Web (`</>`)
2. **App nickname**: `Monitor App Web`
3. **Also set up Firebase Hosting**: Có thể bỏ qua
4. Click "Register app"

### Lấy Web Firebase Config
Sau khi đăng ký, bạn sẽ thấy code config như sau:
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyBCHpCDZoONPpwsiBurfvKqOqSMbzFlkio",
  authDomain: "monitorv2-dcf5b.firebaseapp.com",
  projectId: "monitorv2-dcf5b",
  storageBucket: "monitorv2-dcf5b.firebasestorage.app",
  messagingSenderId: "916524608033",
  appId: "1:916524608033:web:XXXXXXXXXXXXXXXXXXXXXX", // <-- CẦN THAY ĐỔI
  measurementId: "G-XXXXXXXXXX" // Optional
};
```

**Quan trọng:** Copy giá trị `appId` từ Firebase Console và thay thế trong 2 file:

1. **`lib/firebase_options.dart`**:
```dart
appId: '1:916524608033:web:XXXXXXXXXXXXXXXXXXXXXX', // Thay bằng appId thật
```

2. **`web/firebase-messaging-sw.js`**:
```javascript
appId: '1:916524608033:web:XXXXXXXXXXXXXXXXXXXXXX', // Thay bằng appId thật
```

### Download Web Config Files
Sau khi đăng ký web app, Firebase Console sẽ hiển thị code config JavaScript. Copy các giá trị sau:

```javascript
const firebaseConfig = {
  apiKey: "...",
  authDomain: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "1:916524608033:web:XXXXXXXXXXXXXXXXXXXXXX", // ← Đây là appId cần thiết
  measurementId: "..."
};
```

**Quan trọng:** Thay thế `YOUR_WEB_APP_ID_HERE` trong 2 file bằng giá trị `appId` thật:

1. **`lib/firebase_options.dart`** (dòng appId của web)
2. **`web/firebase-messaging-sw.js`** (dòng appId)

### Service Worker
File `web/firebase-messaging-sw.js` đã được tạo tự động để xử lý background messages trên web.

## 4. Enable Cloud Messaging

Firebase Console có thể có giao diện khác nhau tùy theo thời điểm. Hãy thử các cách sau:

### Cách 4: Kiểm tra trực tiếp
1. Vào **Project Settings** (biểu tượng bánh răng ⚙️)
2. Tab **Cloud Messaging** 
3. Nếu thấy "Server key", tức là đã được kích hoạt

## 5. Lấy Server Key (cho PHP)

### Lấy Server Key (Legacy)
1. Vào **Project Settings** (biểu tượng bánh răng ⚙️ ở góc trên bên trái)
2. Chọn tab **Cloud Messaging**
3. Tìm phần **Cloud Messaging API (Legacy)**
4. Copy **Server key** - sẽ dùng trong PHP script

### Nếu không thấy Server Key
Nếu không thấy Server Key, có thể Firebase đã chuyển sang sử dụng Firebase Admin SDK:

1. **Option A - Enable Legacy API:**
   - Trong tab Cloud Messaging
   - Tìm "Cloud Messaging API (Legacy)" 
   - Click "Enable" nếu có
   - Server key sẽ xuất hiện

2. **Option B - Sử dụng Service Account (Khuyên dùng):**
   - Vào tab **Service accounts**
   - Click "Generate new private key"
   - Download file JSON
   - Sử dụng Firebase Admin SDK thay vì Server Key

### Lưu ý quan trọng
- **Server Key (Legacy)**: Đơn giản hơn, dùng cho PHP script hiện tại
- **Service Account**: Bảo mật hơn, cần sửa PHP script để sử dụng Admin SDK

## 6. Cấu hình iOS (nếu cần)

### Thêm Push Notification capability
1. Mở `ios/Runner.xcworkspace` trong Xcode
2. Select project "Runner" → Target "Runner"
3. Tab **Signing & Capabilities**
4. Click **+ Capability** → Tìm "Push Notifications" → Add
5. Click **+ Capability** → Tìm "Background Modes" → Add
6. Check "Background processing" và "Remote notifications"

## 7. Troubleshooting - Không tìm thấy Cloud Messaging

### Vấn đề phổ biến:

1. **Không thấy menu "Cloud Messaging"**:
   - Thử tìm "Messaging" thay vì "Cloud Messaging"
   - Kiểm tra trong menu "Engage" 
   - Hoặc "Build" → "Messaging"

2. **Không thấy Server Key**:
   - Đảm bảo đã thêm ít nhất 1 app (Android/iOS)
   - Legacy API có thể cần được enable
   - Thử refresh trang và đợi vài phút

3. **Giao diện Firebase Console khác**:
   - Firebase thường cập nhật giao diện
   - Tìm kiếm "messaging" hoặc "notification" 
   - Hoặc truy cập trực tiếp: `https://console.firebase.google.com/project/YOUR_PROJECT_ID/messaging`

### Cách khác để kiểm tra:
1. Vào **Project Overview**
2. Scroll xuống phần "Get started by adding Firebase to your app"
3. Nếu thấy Android/iOS app đã được thêm → Cloud Messaging đã sẵn sàng

## 8. Test cấu hình

Sau khi hoàn thành các bước trên:

1. Copy `google-services.json` vào `android/app/`
2. Copy `GoogleService-Info.plist` vào iOS project qua Xcode
3. Chạy lệnh: `flutter pub get`
4. Build và test app: `flutter run`
5. Kiểm tra FCM token trong màn hình "Thông báo" của app

## 9. Giải pháp thay thế nếu không có Server Key

Nếu không thể lấy được Server Key, bạn có thể:

### Option A: Test trực tiếp trong Firebase Console
1. Vào Firebase Console → **Messaging** (hoặc **Engage** → **Messaging**)
2. Click **"Send your first message"** hoặc **"New campaign"**
3. Nhập title, body
4. Target: Chọn **"Single device"** 
5. Nhập FCM token từ Flutter app
6. Send test message

### Option B: Sử dụng Firebase Admin SDK
1. Vào **Project Settings** → **Service accounts**
2. Click **"Generate new private key"**
3. Download file JSON
4. Sử dụng file `php_server/firebase_admin_alternative.php`

### Option C: Tạo Cloud Function
1. Tạo Firebase Cloud Function để gửi notification
2. Gọi function từ PHP qua HTTP request
3. Function sẽ handle việc gửi FCM

### Option D: Test với Postman/cURL
```bash
# Sử dụng Server Key khi có
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN_HERE",
    "notification": {
      "title": "Test",
      "body": "Test message"
    }
  }'
```

## Lưu ý quan trọng

- **Đừng commit** các file config này lên Git (đã có trong .gitignore)
- Server key cần được bảo mật, không để lộ ra ngoài
- FCM token sẽ được in ra console khi app khởi chạy (debug mode)
- Nếu không có Server Key, vẫn có thể test bằng Firebase Console

## File cần tạo/sửa

- ✅ `pubspec.yaml` - Đã thêm dependencies
- ✅ `android/build.gradle.kts` - Đã thêm Google Services plugin
- ✅ `android/app/build.gradle.kts` - Đã thêm plugin
- ⏳ `android/app/google-services.json` - Cần download từ Firebase
- ⏳ `ios/Runner/GoogleService-Info.plist` - Cần download từ Firebase
- ✅ `lib/services/firebase_messaging_service.dart` - Đã tạo