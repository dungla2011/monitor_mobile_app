# Hướng dẫn cài đặt Authentication cho Monitor App

## Tổng quan
Ứng dụng Monitor App đã được tích hợp với hệ thống authentication hoàn chỉnh bao gồm:
- Đăng nhập bằng Email & Password
- Đăng ký tài khoản mới
- Đăng nhập bằng Google
- Quên mật khẩu
- Quản lý hồ sơ người dùng
- Đăng xuất

## Các tính năng đã được thêm

### 1. Dependencies mới
```yaml
# Firebase Authentication
firebase_auth: ^5.3.1
google_sign_in: ^6.2.1

# State management và UI
provider: ^6.1.2
shared_preferences: ^2.3.2
```

### 2. Cấu trúc file mới
```
lib/
├── services/
│   └── auth_service.dart          # Service quản lý authentication
├── screens/
│   ├── login_screen.dart          # Màn hình đăng nhập/đăng ký
│   └── profile_screen.dart        # Màn hình hồ sơ người dùng
└── widgets/
    └── auth_wrapper.dart          # Wrapper kiểm tra trạng thái đăng nhập
```

### 3. Tính năng Authentication

#### AuthService (lib/services/auth_service.dart)
- **signInWithEmailAndPassword()**: Đăng nhập bằng email/password
- **createUserWithEmailAndPassword()**: Đăng ký tài khoản mới
- **signInWithGoogle()**: Đăng nhập bằng Google
- **signOut()**: Đăng xuất
- **sendPasswordResetEmail()**: Gửi email reset password
- **updateProfile()**: Cập nhật thông tin profile
- **authStateChanges**: Stream theo dõi trạng thái đăng nhập

#### LoginScreen (lib/screens/login_screen.dart)
- Giao diện đăng nhập với 2 tab: Đăng nhập và Đăng ký
- Form validation cho email và password
- Nút đăng nhập bằng Google
- Tính năng quên mật khẩu
- Loading states và error handling

#### ProfileScreen (lib/screens/profile_screen.dart)
- Hiển thị thông tin người dùng (avatar, tên, email)
- Trạng thái xác thực email
- Thông tin đăng nhập (phương thức, UID, ngày tạo)
- Chỉnh sửa profile
- Gửi email xác thực
- Đăng xuất

#### AuthWrapper (lib/widgets/auth_wrapper.dart)
- Kiểm tra trạng thái đăng nhập
- Điều hướng tự động giữa LoginScreen và MainScreen
- Xử lý loading và error states

## Cài đặt và cấu hình

### 1. Firebase Console
Đảm bảo Firebase Authentication đã được kích hoạt:
1. Vào Firebase Console → Authentication
2. Kích hoạt Email/Password provider
3. Kích hoạt Google provider
4. Thêm domain của bạn vào Authorized domains

### 2. Google Sign-In cấu hình
Để Google Sign-In hoạt động:

#### Android:
- File `android/app/google-services.json` đã có sẵn
- Không cần cấu hình thêm

#### iOS (nếu cần):
- Thêm `GoogleService-Info.plist` vào `ios/Runner/`
- Cập nhật `ios/Runner/Info.plist` với URL scheme

#### Web:
- Cập nhật `web/index.html` với Google Sign-In meta tags

### 3. Chạy ứng dụng
```bash
flutter pub get
flutter run
```

## Cách sử dụng

### 1. Đăng nhập lần đầu
- Mở ứng dụng → Màn hình đăng nhập xuất hiện
- Chọn tab "Đăng ký" để tạo tài khoản mới
- Hoặc chọn "Đăng nhập bằng Google"

### 2. Đăng nhập
- Nhập email và password
- Hoặc nhấn "Đăng nhập bằng Google"
- Nếu quên mật khẩu, nhấn "Quên mật khẩu?"

### 3. Quản lý hồ sơ
- Vào menu → "Hồ sơ"
- Xem thông tin cá nhân
- Chỉnh sửa tên hiển thị
- Xác thực email (nếu chưa)
- Đăng xuất

### 4. Đăng xuất
- Từ menu drawer → "Đăng xuất"
- Hoặc từ màn hình Hồ sơ → "Đăng xuất"

## Bảo mật

### 1. Validation
- Email format validation
- Password minimum 6 characters
- Form validation trước khi submit

### 2. Error Handling
- Firebase Auth exceptions được xử lý và hiển thị bằng tiếng Việt
- Network errors và timeout handling
- User-friendly error messages

### 3. State Management
- Persistent login state với SharedPreferences
- Automatic logout on token expiry
- Secure token storage

## Troubleshooting

### 1. Google Sign-In không hoạt động
- Kiểm tra `google-services.json` đã đúng project
- Kiểm tra SHA-1 fingerprint trong Firebase Console
- Đảm bảo Google provider đã được kích hoạt

### 2. Email verification không gửi được
- Kiểm tra email template trong Firebase Console
- Kiểm tra spam folder
- Đảm bảo domain đã được authorize

### 3. Build errors
```bash
flutter clean
flutter pub get
flutter run
```

## Tính năng mở rộng có thể thêm

1. **Social Login khác**: Facebook, Apple, Twitter
2. **Two-Factor Authentication**: SMS OTP, Authenticator app
3. **Biometric Authentication**: Fingerprint, Face ID
4. **Account Linking**: Liên kết nhiều provider
5. **User Roles**: Admin, User permissions
6. **Profile Pictures**: Upload và crop avatar
7. **Account Deletion**: Xóa tài khoản và data

## Cấu trúc Database (nếu cần)

Nếu muốn lưu thêm thông tin user:
```firestore
users/{uid}
├── displayName: string
├── email: string
├── photoURL: string
├── createdAt: timestamp
├── lastLoginAt: timestamp
├── preferences: object
└── profile: object
```

## Kết luận

Hệ thống authentication đã được tích hợp hoàn chỉnh với:
- ✅ Email/Password authentication
- ✅ Google Sign-In
- ✅ User profile management
- ✅ Password reset
- ✅ Email verification
- ✅ Persistent login state
- ✅ Error handling
- ✅ Vietnamese localization

Ứng dụng sẵn sàng để sử dụng và có thể mở rộng thêm các tính năng authentication khác theo nhu cầu.
