# Cấu hình API Base URL

App sử dụng file cấu hình tập trung để quản lý API URLs và các settings khác.

## File cấu hình: `lib/config/app_config.dart`

Tất cả các API URLs được quản lý tại file này:

```dart
class AppConfig {
  // Base API URL - Thay đổi giá trị này để trỏ sang server khác
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ping24.io',
  );

  // Các endpoint được tạo tự động từ baseUrl
  static const String apiUrl = '$apiBaseUrl/api';
  static const String authUrl = '$apiUrl/auth';
  static const String memberUrl = '$apiUrl/member-user';
  // ...
}
```

## Cách thay đổi API Base URL

### Cách 1: Thay đổi trong code (Development)

Sửa trực tiếp trong file `lib/config/app_config.dart`:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://your-new-domain.com', // Thay đổi ở đây
);
```

### Cách 2: Sử dụng build arguments (Recommended for different environments)

Build với URL khác mà không cần sửa code:

```bash
# Build cho staging server
flutter build apk --dart-define=API_BASE_URL=https://staging.example.com

# Build cho production server
flutter build apk --dart-define=API_BASE_URL=https://api.example.com

# Run app với URL custom
flutter run --dart-define=API_BASE_URL=https://dev.example.com
```

### Cách 3: Sử dụng multiple build configurations

Tạo file `build_config.json`:

```json
{
  "dev": {
    "API_BASE_URL": "https://dev.example.com"
  },
  "staging": {
    "API_BASE_URL": "https://staging.example.com"
  },
  "production": {
    "API_BASE_URL": "https://api.example.com"
  }
}
```

## Các service sử dụng AppConfig

Tất cả các service đã được cập nhật để sử dụng `AppConfig`:

- ✅ `base_crud_service.dart` - CRUD operations
- ✅ `web_auth_service.dart` - Authentication
- ✅ `google_auth_service.dart` - Google Sign-In
- ✅ `api_service.dart` - Generic API calls
- ✅ `language_manager.dart` - Language sync

## Ví dụ sử dụng trong code

```dart
import 'package:monitor_app/config/app_config.dart';

// Sử dụng base URL
final url = '${AppConfig.apiBaseUrl}/custom-endpoint';

// Sử dụng các endpoint có sẵn
final authUrl = AppConfig.authUrl;
final memberUrl = AppConfig.memberUrl;
```

## Testing với URL khác

Khi chạy tests, có thể override URL:

```bash
flutter test --dart-define=API_BASE_URL=https://test.example.com
```

## Lưu ý

- ⚠️ Không commit API keys hoặc sensitive data vào file config
- ⚠️ Nên sử dụng `--dart-define` cho production builds
- ✅ File config này được commit vào git với giá trị default an toàn
- ✅ Mọi thay đổi URL chỉ cần sửa 1 file duy nhất
