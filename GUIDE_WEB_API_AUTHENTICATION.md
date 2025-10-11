# Hướng dẫn sử dụng Web API Authentication

## 📋 Tóm tắt thay đổi

Đã cập nhật hệ thống authentication từ Firebase Auth sang Web API của bạn với format response mới:

### ✅ Response Format mới:
```json
{
    "code": 1,
    "payload": "TK1_eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "payloadEx": null,
    "message": "Token OK"
}
```

- **`code: 1`** = Thành công
- **`payload`** = Bearer Token (JWT)
- **`message`** = Thông báo

## 🔧 Các thay đổi đã thực hiện

### 1. **WebAuthService** (`lib/services/web_auth_service.dart`)

#### ✅ API Endpoints:
```dart
static const String _baseUrl = 'https://ping365.io/';
static const String _loginEndpoint = '$_baseUrl/api/login-api';
```

#### ✅ Bearer Token Management:
- Lưu trữ Bearer Token từ `payload`
- Tự động thêm `Authorization: Bearer <token>` cho mọi request
- Persistent storage với SharedPreferences

#### ✅ Login Process:
```dart
// POST https://ping365.io/api/login-api
{
  "username": "your_username",
  "password": "your_password"
}

// Response Success (code: 1):
{
  "code": 1,
  "payload": "TK1_eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "message": "Token OK"
}
```

### 2. **Authenticated API Calls**

#### ✅ Automatic Bearer Token Headers:
```dart
WebAuthService.getAuthenticatedHeaders()
// Returns:
{
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer TK1_eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...'
}
```

#### ✅ Helper Methods:
```dart
// GET request với auth
await WebAuthService.authenticatedGet('https://api.example.com/users');

// POST request với auth
await WebAuthService.authenticatedPost('https://api.example.com/posts', {
  'title': 'Hello',
  'content': 'World'
});
```

### 3. **ApiService** (`lib/services/api_service.dart`)

Example usage với automatic token handling:

```dart
// Lấy danh sách users
final result = await ApiService.getUsers();
if (result['success']) {
  print('Data: ${result['data']}');
} else {
  print('Error: ${result['message']}');
  if (result['needReauth'] == true) {
    // Redirect to login
  }
}

// Tạo post mới
final result = await ApiService.createPost(
  title: 'My Post',
  content: 'Post content here',
);

// Generic API call
final result = await ApiService.callApi(
  method: 'GET',
  endpoint: 'https://ping365.io/api/my-endpoint',
  body: {'key': 'value'},
);
```

## 🔒 Token Security Features

### ✅ Auto Token Validation:
```dart
WebAuthService.hasValidToken() // bool
```

### ✅ Auto Logout on Token Expiry:
```dart
// Khi response.statusCode == 401
await WebAuthService.signOut(); // Clear token & redirect
```

### ✅ Persistent Login:
- Token được lưu trong SharedPreferences
- Auto login khi mở app (nếu token còn valid)

## 📱 UI Updates

### ✅ LoginScreen:
- Username/Password thay vì Email/Password
- Bỏ Google Sign-In
- Form validation cho username (min 3 ký tự)

### ✅ ProfileScreen:
- Hiển thị thông tin từ Web API
- Show Bearer Token (masked)
- Remove Firebase-specific features

### ✅ AuthWrapper:
- Kiểm tra token validity
- Auto navigation dựa trên auth state

## 🚀 Cách sử dụng

### 1. **Đăng nhập:**
```dart
final result = await WebAuthService.signInWithUsernameAndPassword(
  username: 'your_username',
  password: 'your_password',
);

if (result['success']) {
  String token = result['token']; // Bearer Token
  // Navigate to main screen
} else {
  String error = result['message'];
  // Show error
}
```

### 2. **Gọi API với authentication:**
```dart
// Option 1: Sử dụng helper methods
final response = await WebAuthService.authenticatedGet('https://api.example.com/data');

// Option 2: Sử dụng ApiService
final result = await ApiService.callApi(
  method: 'POST',
  endpoint: 'https://ping365.io/api/create-something',
  body: {'name': 'Test'},
);

// Option 3: Manual headers
final headers = WebAuthService.getAuthenticatedHeaders();
final response = await http.get(Uri.parse('https://api.example.com'), headers: headers);
```

### 3. **Kiểm tra auth status:**
```dart
if (WebAuthService.isLoggedIn && WebAuthService.hasValidToken()) {
  // User đã đăng nhập với token hợp lệ
} else {
  // Cần đăng nhập
}
```

### 4. **Xử lý token expiry:**
```dart
final result = await ApiService.callApi(...);
if (result['needReauth'] == true) {
  // Token hết hạn, redirect to login
  Navigator.pushReplacementNamed(context, '/login');
}
```

## 🔍 Debug & Testing

### ✅ Current Token:
```dart
String? token = WebAuthService.bearerToken;
print('Current token: $token');
```

### ✅ Test API Connection:
```dart
bool connected = await WebAuthService.testApiConnection();
print('API reachable: $connected');
```

### ✅ Saved Login Info:
```dart
Map<String, String?> info = await WebAuthService.getSavedLoginInfo();
print('Login info: $info');
```

## 🎯 Next Steps

1. **Update API URL** nếu cần:
```dart
// Trong WebAuthService
static const String _baseUrl = 'https://your-domain.com/';
```

2. **Implement API endpoints** cụ thể trong `ApiService`

3. **Handle specific error codes** từ API của bạn

4. **Add refresh token logic** nếu API hỗ trợ

## 🔧 Configuration

### Environment-specific URLs:
```dart
class ApiConfig {
  static const String baseUrl = 'https://ping365.io/';
  static const String loginEndpoint = '${baseUrl}api/login-api';
  
  // Dev/Staging URLs
  static const String devBaseUrl = 'https://dev.ping365.io/';
}
```

---

**🎉 Hệ thống Web API Authentication đã sẵn sàng!**

Tất cả requests từ app sẽ tự động include Bearer Token và handle token expiry một cách graceful.
