# Migration to Flutter Official i18n (ARB Format)

## ✅ Migration Complete

App đã được chuyển từ custom JSON-based localization sang **Flutter official i18n** với `.arb` files.

## 📁 Cấu trúc mới

### 1. **Configuration Files**
- `l10n.yaml` - Flutter localization config
  ```yaml
  arb-dir: lib/l10n
  template-arb-file: app_en.arb
  output-localization-file: app_localizations.dart
  ```

### 2. **ARB Files (Application Resource Bundle)**
- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_vi.arb` - Vietnamese translations

### 3. **Generated Code**
Flutter tự động generate code vào:
- `.dart_tool/flutter_gen/gen_l10n/app_localizations.dart`
- `.dart_tool/flutter_gen/gen_l10n/app_localizations_en.dart`
- `.dart_tool/flutter_gen/gen_l10n/app_localizations_vi.dart`

## 🔄 Thay đổi chính

### **Trước (Custom JSON)**
```dart
import '../utils/app_localizations.dart';

final l10n = AppLocalizations.of(context);
Text(l10n.translate('app.title'))
Text(l10n.translate('settings.language'))
```

### **Sau (Flutter i18n)**
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final l10n = AppLocalizations.of(context)!;
Text(l10n.appTitle)
Text(l10n.settingsLanguage)
```

## 🎯 Lợi ích

### ✅ **Tuân thủ chuẩn Flutter**
- Sử dụng official Flutter i18n framework
- Generated code với type safety
- Hot reload hoạt động tốt hơn

### ✅ **Type-safe**
- Không còn magic strings `'app.title'`
- IDE autocomplete cho tất cả translations
- Compile-time error nếu thiếu translation

### ✅ **Placeholder support**
```dart
// ARB file
"messagesDeleteConfirm": "Are you sure you want to delete {item}?",
"@messagesDeleteConfirm": {
  "placeholders": {
    "item": {
      "type": "String"
    }
  }
}

// Dart code
l10n.messagesDeleteConfirm('Monitor Item')
```

### ✅ **Metadata & Documentation**
```dart
"appTitle": "Ping365",
"@appTitle": {
  "description": "The title of the application"
}
```

## 📝 Translation Keys Mapping

### App Keys
- `app.title` → `appTitle`
- `app.loading` → `appLoading`
- `app.error` → `appError`
- `app.save` → `appSave`
- `app.cancel` → `appCancel`

### Auth Keys
- `auth.login` → `authLogin`
- `auth.logout` → `authLogout`
- `auth.username` → `authUsername`
- `auth.password` → `authPassword`

### Navigation Keys
- `navigation.home` → `navigationHome`
- `navigation.settings` → `navigationSettings`
- `navigation.profile` → `navigationProfile`

### Settings Keys
- `settings.language` → `settingsLanguage`
- `settings.notifications` → `settingsNotifications`
- `settings.notificationSettings` → `settingsNotificationSettings`
- `settings.enableNotifications` → `settingsEnableNotifications`
- `settings.notificationSound` → `settingsNotificationSound`
- `settings.vibrate` → `settingsVibrate`

### Notification Sound Keys
- `notificationSoundDefault` → "Default (System)" / "Mặc định (Hệ thống)"
- `notificationSoundNone` → "None (Silent)" / "Không (Im lặng)"
- `notificationSoundAlert` → "Alert" / "Cảnh báo"
- `notificationSoundGentle` → "Gentle" / "Nhẹ nhàng"
- `notificationSoundUrgent` → "Urgent" / "Khẩn cấp"

### Monitor Keys
- `monitor.items` → `monitorItems`
- `monitor.configs` → `monitorConfigs`
- `monitor.name` → `monitorName`

### Messages Keys
- `messages.saveSuccess` → `messagesSaveSuccess`
- `messages.deleteConfirm` → `messagesDeleteConfirm(item)`
- `messages.loadingSettingsError` → `messagesLoadingSettingsError(error)`

## 🔧 Cách thêm translation mới

### 1. Thêm vào ARB files
**app_en.arb:**
```json
{
  "newFeatureTitle": "New Feature",
  "@newFeatureTitle": {
    "description": "Title for new feature"
  }
}
```

**app_vi.arb:**
```json
{
  "newFeatureTitle": "Tính năng mới"
}
```

### 2. Generate code
```bash
flutter gen-l10n
```

Hoặc Flutter tự động generate khi bạn hot reload.

### 3. Sử dụng trong code
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.newFeatureTitle)
```

## 🗑️ Files đã xóa

- ❌ `lib/utils/app_localizations.dart` - Custom localization class
- ✅ `assets/translations/vi.json` - Giữ lại cho reference (không dùng nữa)
- ✅ `assets/translations/en.json` - Giữ lại cho reference (không dùng nữa)

## 📦 Dependencies

Đã có sẵn trong `pubspec.yaml`:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true  # ✅ Enable code generation
```

## 🌍 Supported Locales

```dart
static const List<Locale> supportedLocales = [
  Locale('vi', ''), // Vietnamese
  Locale('en', ''), // English
];
```

## 🎨 Best Practices

### ✅ **DO:**
- Dùng getters thay vì strings: `l10n.appTitle`
- Add null-safety operator: `AppLocalizations.of(context)!`
- Add descriptions trong ARB files cho context
- Dùng placeholders cho dynamic text

### ❌ **DON'T:**
- Hardcode text trong UI: ~~`Text('Cài đặt')`~~
- Dùng magic strings: ~~`l10n.translate('app.title')`~~
- Quên chạy `flutter gen-l10n` sau khi edit ARB

## 🚀 Next Steps

### Thêm ngôn ngữ mới (VD: Tiếng Trung)

1. Tạo `lib/l10n/app_zh.arb`
2. Copy structure từ `app_en.arb`
3. Translate tất cả values
4. Add locale vào `LanguageManager`:
   ```dart
   static const List<Locale> supportedLocales = [
     Locale('vi', ''),
     Locale('en', ''),
     Locale('zh', ''), // Chinese
   ];
   ```
5. Run `flutter gen-l10n`

## 🐛 Troubleshooting

### Lỗi: "The system cannot find the file specified"
```
import '../utils/app_localizations.dart';
```
**Fix:** Đổi thành:
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### Lỗi: "The getter 'X' isn't defined"
**Fix:** Chạy `flutter gen-l10n` để regenerate code.

### Lỗi: "can't be unconditionally invoked"
```dart
final l10n = AppLocalizations.of(context); // ❌
```
**Fix:** Add null-safety operator:
```dart
final l10n = AppLocalizations.of(context)!; // ✅
```

## 📚 Resources

- [Flutter Internationalization Guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB Format Specification](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Intl Package](https://pub.dev/packages/intl)

---

**Migration Date:** October 3, 2025  
**Status:** ✅ Complete  
**All hardcoded Vietnamese text replaced with i18n keys**
