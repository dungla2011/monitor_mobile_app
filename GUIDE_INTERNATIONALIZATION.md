# 🌍 Hướng dẫn Đa ngôn ngữ (Internationalization - i18n)

## 📋 Tổng quan

Hệ thống đa ngôn ngữ đã được setup hoàn chỉnh với:
- ✅ **Tiếng Việt** (mặc định)
- ✅ **Tiếng Anh**
- ✅ File JSON translations
- ✅ AppLocalizations class
- ✅ Language Manager

## 📁 Cấu trúc File

```
assets/translations/
├── vi.json          # Tiếng Việt
└── en.json          # Tiếng Anh

lib/utils/
├── app_localizations.dart    # Main localization class
└── language_manager.dart     # Language switching logic
```

## 🎯 Cách sử dụng

### 1. Sử dụng trong Widget

```dart
import '../utils/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Text(localizations.appTitle); // "Ping365"
  }
}
```

### 2. Các method tiện lợi

```dart
final l10n = AppLocalizations.of(context);

// App general
l10n.appTitle        // "Ping365"
l10n.loading         // "Đang tải..." / "Loading..."
l10n.save           // "Lưu" / "Save"
l10n.cancel         // "Hủy" / "Cancel"

// Auth
l10n.login          // "Đăng nhập" / "Login"
l10n.username       // "Tên đăng nhập" / "Username"
l10n.password       // "Mật khẩu" / "Password"

// Monitor
l10n.monitorItems   // "Ping Items"
l10n.monitorConfigs // "Monitor Configs"
l10n.monitorName    // "Tên monitor" / "Monitor name"

// Validation với parameters
l10n.required('tên')           // "Vui lòng nhập tên"
l10n.pleaseSelect('loại')      // "Vui lòng chọn loại"
l10n.deleteConfirm('item #1')  // "Bạn có chắc chắn muốn xóa item #1?"
```

### 3. Sử dụng với key trực tiếp

```dart
// Cho các text phức tạp không có method sẵn
final text = AppLocalizations.of(context).translate('custom.key');

// Với parameters
final text = AppLocalizations.of(context).translate(
  'validation.required', 
  params: {'field': 'email'}
);
```

## 🔧 Thêm ngôn ngữ mới

### 1. Tạo file translation mới

```bash
# Tạo file cho tiếng Nhật
touch assets/translations/ja.json
```

### 2. Copy structure từ vi.json

```json
{
  "app": {
    "title": "モニターアプリ",
    "loading": "読み込み中...",
    "save": "保存"
  }
}
```

### 3. Cập nhật LanguageManager

```dart
// lib/utils/language_manager.dart
static const List<Locale> supportedLocales = [
  Locale('vi', ''),
  Locale('en', ''),
  Locale('ja', ''), // Thêm tiếng Nhật
];

static const Map<String, String> languageNames = {
  'vi': 'Tiếng Việt',
  'en': 'English',
  'ja': '日本語', // Thêm tiếng Nhật
};
```

### 4. Cập nhật AppLocalizations delegate

```dart
// lib/utils/app_localizations.dart
@override
bool isSupported(Locale locale) {
  return ['en', 'vi', 'ja'].contains(locale.languageCode); // Thêm 'ja'
}
```

## 🎨 Thay đổi ngôn ngữ runtime

### 1. Tạo Language Selector Widget

```dart
class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: LanguageManager().currentLocale,
      items: LanguageManager.supportedLocales.map((locale) {
        return DropdownMenuItem(
          value: locale,
          child: Text(LanguageManager().getLanguageName(locale.languageCode)),
        );
      }).toList(),
      onChanged: (locale) {
        if (locale != null) {
          LanguageManager().changeLanguage(locale);
        }
      },
    );
  }
}
```

### 2. Sử dụng Provider pattern (recommended)

```dart
// main.dart
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageManager(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (context, languageManager, child) {
        return MaterialApp(
          locale: languageManager.currentLocale,
          // ... other properties
        );
      },
    );
  }
}
```

## 📝 Thêm text mới

### 1. Thêm vào file JSON

```json
// assets/translations/vi.json
{
  "newFeature": {
    "title": "Tính năng mới",
    "description": "Mô tả tính năng",
    "button": "Thử ngay"
  }
}
```

### 2. Thêm method vào AppLocalizations

```dart
// lib/utils/app_localizations.dart
class AppLocalizations {
  // Thêm getter methods
  String get newFeatureTitle => translate('newFeature.title');
  String get newFeatureDescription => translate('newFeature.description');
  String get newFeatureButton => translate('newFeature.button');
}
```

## 🎯 Best Practices

### 1. Naming Convention

```json
{
  "module": {
    "action": "Text",
    "actionWithParam": "Text with {param}"
  }
}
```

### 2. Grouping

```json
{
  "auth": { /* authentication related */ },
  "monitor": { /* monitor related */ },
  "validation": { /* validation messages */ },
  "messages": { /* success/error messages */ }
}
```

### 3. Parameters

```json
{
  "validation": {
    "required": "Vui lòng nhập {field}",
    "minLength": "{field} phải có ít nhất {min} ký tự"
  }
}
```

## 🚀 Ví dụ thực tế

### Cập nhật Mobile Action

```dart
// Trước (hardcoded)
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Navigating to Monitor Config...')),
);

// Sau (i18n)
final l10n = AppLocalizations.of(context);
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(l10n.mobileActionNavigatingToConfig)),
);
```

### Cập nhật Form Labels

```dart
// Trước
TextFormField(
  decoration: InputDecoration(labelText: 'Tên monitor'),
)

// Sau
TextFormField(
  decoration: InputDecoration(
    labelText: AppLocalizations.of(context).monitorName
  ),
)
```

## 🔍 Debug

### Kiểm tra missing translations

```dart
// Nếu key không tồn tại, sẽ return '**key**'
final text = AppLocalizations.of(context).translate('nonexistent.key');
print(text); // Output: "**nonexistent.key**"
```

### Test với ngôn ngữ khác

```dart
// Trong main.dart, thay đổi locale mặc định
MaterialApp(
  locale: const Locale('en', ''), // Test với tiếng Anh
  // ...
)
```

## ✅ Checklist Implementation

- [x] ✅ Setup dependencies (flutter_localizations, intl)
- [x] ✅ Tạo translation files (vi.json, en.json)
- [x] ✅ Tạo AppLocalizations class
- [x] ✅ Tạo LanguageManager
- [x] ✅ Cập nhật MaterialApp
- [x] ✅ Example usage trong mobile action
- [ ] 🔄 Thay thế tất cả hardcoded strings
- [ ] 🔄 Thêm language selector UI
- [ ] 🔄 Test với cả 2 ngôn ngữ

**Hệ thống đa ngôn ngữ đã sẵn sàng! Bây giờ có thể bắt đầu thay thế các text hardcoded.** 🌍✨
