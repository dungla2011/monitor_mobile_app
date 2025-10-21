# Hướng dẫn: Vô hiệu hóa tải ngôn ngữ từ server và chỉ dùng ARB files

## Tổng quan

Hướng dẫn này giải thích cách chặn hoàn toàn việc tải ngôn ngữ từ server và chỉ sử dụng các file ARB built-in (app_en.arb, app_vi.arb). 

**Vấn đề gốc:** App hiển thị các translation key (như "appTitle", "navigationHome") thay vì giá trị thực từ ARB files do `ServerAppLocalizationsDelegate` dùng `noSuchMethod` không forward getters đúng cách.

**Giải pháp:** Loại bỏ `ServerAppLocalizationsDelegate` khỏi delegate list khi server loading bị disabled.

---

## Bước 1: Thêm biến feature flag

**File: `lib/config/app_config.dart`**

Thêm constant vào class `AppConfig`:

```dart
// Feature flags
/// Enable/Disable loading languages from server
/// 0 = disabled (block API calls)
/// 1 = enabled (allow API calls)
static const int enableLoadLanguage = 0;
```

---

## Bước 2: Chặn download/load từ server

**File: `lib/services/dynamic_localization_service.dart`**

### Function: `getAvailableLanguages()`

Thêm check ở đầu function:

```dart
static Future<List<LanguageInfo>> getAvailableLanguages() async {
  // Check if loading from server is enabled
  if (AppConfig.enableLoadLanguage == 0) {
    print('🚫 Server language loading is disabled (enableLoadLanguage = 0)');
    // Return default languages
    return [
      LanguageInfo(
        code: 'vi',
        name: 'Vietnamese',
        nativeName: 'Tiếng Việt',
        flagCode: 'VN',
        isActive: true,
      ),
      LanguageInfo(
        code: 'en',
        name: 'English',
        nativeName: 'English',
        flagCode: 'US',
        isActive: true,
      ),
    ];
  }
  
  // ... existing code
}
```

### Function: `downloadLanguage()`

Thêm check ở đầu function:

```dart
static Future<Map<String, String>?> downloadLanguage(
  String languageCode,
) async {
  // Check if loading from server is enabled
  if (AppConfig.enableLoadLanguage == 0) {
    print('🚫 Language download blocked (enableLoadLanguage = 0)');
    return null;
  }
  
  // ... existing code
}
```

### Function: `loadCachedLanguage()`

Thêm check ở đầu function:

```dart
static Future<Map<String, String>?> loadCachedLanguage(
  String languageCode,
) async {
  // Check if loading from server is enabled
  if (AppConfig.enableLoadLanguage == 0) {
    print('🚫 Loading cached language blocked (enableLoadLanguage = 0)');
    return null;
  }
  
  // ... existing code
}
```

### Function: `syncAllLanguages()`

Thêm check ở đầu function:

```dart
static Future<List<String>> syncAllLanguages({bool forceSync = false}) async {
  // Check if loading from server is enabled
  if (AppConfig.enableLoadLanguage == 0) {
    print('🚫 Language sync is disabled (enableLoadLanguage = 0)');
    return [];
  }
  
  // ... existing code
}
```

---

## Bước 3: Chặn load server translations vào memory

**File: `lib/l10n/dynamic_app_localizations.dart`**

### Function: `loadServerTranslations()`

Thêm check ở đầu function:

```dart
static Future<void> loadServerTranslations(Locale locale) async {
  // Check if loading from server is enabled
  if (AppConfig.enableLoadLanguage == 0) {
    print('🚫 Server language loading is disabled (enableLoadLanguage = 0)');
    return;
  }
  
  print('🌐 Loading server translations for ${locale.languageCode}');
  
  // ... existing code
}
```

### Extension method: `t()`

Thêm check trong extension method:

```dart
extension DynamicAppLocalizationsExtension on AppLocalizations {
  /// Try to get translation from server, fallback to built-in
  String t(String key, String Function() builtInGetter) {
    // If server loading is disabled, always use built-in
    if (AppConfig.enableLoadLanguage == 0) {
      return builtInGetter();
    }
    
    final serverValue =
        DynamicAppLocalizations.getServerTranslation(localeName, key);
    if (serverValue != null) {
      return serverValue;
    }
    return builtInGetter();
  }
}
```

---

## Bước 4: Clear server translations khi app start

**File: `lib/main.dart`**

### Function: `_MyAppState._loadInitialLanguage()`

Thêm import ở đầu file (nếu chưa có):

```dart
import 'package:monitor_app/config/app_config.dart';
```

Sửa function `_loadInitialLanguage()`:

```dart
Future<void> _loadInitialLanguage() async {
  // Clear server translations if loading is disabled
  if (AppConfig.enableLoadLanguage == 0) {
    DynamicAppLocalizations.clearServerTranslations();
    print('🚫 Server translations cleared (enableLoadLanguage = 0)');
    return;
  }
  
  final languageManager = context.read<LanguageManager>();
  await DynamicAppLocalizations.loadServerTranslations(
    languageManager.currentLocale,
  );
  // Trigger rebuild if server translations loaded
  if (mounted &&
      DynamicAppLocalizations.hasServerTranslations(
        languageManager.currentLocale.languageCode,
      )) {
    setState(() {});
  }
}
```

---

## Bước 5: ⭐ QUAN TRỌNG NHẤT - Loại bỏ ServerAppLocalizationsDelegate

**File: `lib/main.dart`**

### Trong `MaterialApp` widget

Tìm dòng `localizationsDelegates: const [` và **đổi từ `const []` thành list có điều kiện**:

**TRƯỚC:**
```dart
localizationsDelegates: const [
  ServerAppLocalizationsDelegate(), // ⭐ Custom delegate for server translations
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
```

**SAU:**
```dart
localizationsDelegates: [
  // Only use ServerAppLocalizationsDelegate if server loading is enabled
  if (AppConfig.enableLoadLanguage == 1)
    const ServerAppLocalizationsDelegate(),
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
```

**LÝ DO TẠI SAO BƯỚC NÀY QUAN TRỌNG:**

`ServerAppLocalizationsDelegate` tạo một wrapper class `ServerAppLocalizations` sử dụng `noSuchMethod` để intercept property getters. Tuy nhiên, cơ chế `noSuchMethod` không forward getters đúng cách từ built-in instance, dẫn đến việc trả về raw key name (ví dụ: "appTitle") thay vì giá trị thực ("TimChuyenTaxi").

Khi loại bỏ delegate này, app sẽ dùng trực tiếp `AppLocalizations.delegate` với các getters đã được generated từ ARB files, đảm bảo getters hoạt động chính xác.

---

## Bước 6: (Optional) Fallback trong delegate

**File: `lib/l10n/server_app_localizations_delegate.dart`**

### Method: `load()`

Sửa logic cuối của method `load()`:

**TRƯỚC:**
```dart
if (serverTranslations != null && serverTranslations.isNotEmpty) {
  print('✅ Using ServerAppLocalizations for ${locale.languageCode} (${serverTranslations.length} keys)');
  return ServerAppLocalizations(
    builtIn,
    serverTranslations,
    serverTranslationsEN ?? {},
  );
}

// If no server translations, still create ServerAppLocalizations with EN fallback
print('📦 Using built-in translations for ${locale.languageCode} with EN fallback');
return ServerAppLocalizations(
  builtIn,
  {},
  serverTranslationsEN ?? {},
);
```

**SAU:**
```dart
if (serverTranslations != null && serverTranslations.isNotEmpty) {
  print('✅ Using ServerAppLocalizations for ${locale.languageCode} (${serverTranslations.length} keys)');
  return ServerAppLocalizations(
    builtIn,
    serverTranslations,
    serverTranslationsEN ?? {},
  );
}

// No server translations available: return the built-in AppLocalizations
// directly. Returning ServerAppLocalizations in this case causes the
// fallback noSuchMethod logic to attempt dynamic forwarding to the
// built-in instance via `noSuchMethod`, which doesn't retrieve getters
// correctly and results in raw keys being shown in the UI. Returning the
// built-in instance preserves the generated getters behavior.
print('📦 No server translations: using built-in AppLocalizations for ${locale.languageCode}');
return builtIn;
```

---

## Bước 7: Rebuild và clear cache

### Rebuild app

```bash
flutter clean
flutter pub get
flutter build web --release
```

### Clear browser cache (cho Web)

**Cách 1: Dùng DevTools Console**

Mở Chrome DevTools (F12), chuyển sang tab Console và chạy:

```javascript
localStorage.clear();
sessionStorage.clear();
location.reload();
```

**Cách 2: Dùng Application tab**

1. Mở Chrome DevTools (F12)
2. Chuyển sang tab **Application**
3. Ở sidebar trái, chọn **Storage**
4. Click nút **Clear site data**
5. Reload trang

### Clear cache (cho Mobile)

**Android:**
```bash
# Uninstall app
adb uninstall com.timchuyentaxi.vn

# Or clear app data
adb shell pm clear com.timchuyentaxi.vn
```

**iOS:**
Uninstall app từ device hoặc xóa app data trong Settings > General > iPhone Storage

---

## Kết quả mong đợi

Sau khi hoàn thành các bước trên:

- ✅ App không gọi API `get-language` hay `get-available-languages`
- ✅ UI hiển thị giá trị từ ARB files (ví dụ: "TimChuyenTaxi" thay vì "appTitle")
- ✅ Không có warning "Translation missing everywhere" trong console
- ✅ Server translations không được load vào localStorage/SharedPreferences
- ✅ Console log hiển thị: `🚫 Server language loading is disabled`

---

## Debugging

### Nếu vẫn thấy translation keys

1. **Kiểm tra console logs:** Phải thấy các log `🚫 Server language loading is disabled`
2. **Kiểm tra ARB files:** Đảm bảo `lib/l10n/app_en.arb` và `app_vi.arb` có đầy đủ keys và values
3. **Kiểm tra generated files:** Đảm bảo `lib/l10n/app_localizations_en.dart` và `app_localizations_vi.dart` tồn tại và có getters
4. **Clear cache lại:** Làm lại bước 7 để clear hoàn toàn cache
5. **Kiểm tra `localizationsDelegates`:** Đảm bảo `ServerAppLocalizationsDelegate` **KHÔNG** có trong list khi `enableLoadLanguage == 0`

### Nếu vẫn thấy server API calls

1. **Kiểm tra `AppConfig.enableLoadLanguage`:** Đảm bảo = 0
2. **Kiểm tra imports:** Đảm bảo import `app_config.dart` trong các file service
3. **Rebuild lại:** Chạy `flutter clean` và build lại

---

## Technical Details

### Root Cause

`ServerAppLocalizations` class sử dụng `noSuchMethod` để intercept tất cả property access:

```dart
@override
dynamic noSuchMethod(Invocation invocation) {
  if (invocation.isGetter) {
    // Try to get from server translations
    // Then try from built-in
    // Then return property name as fallback
    return propertyName; // ← This returns "appTitle" instead of "TimChuyenTaxi"
  }
}
```

Khi không có server translations và cũng không tìm thấy trong built-in (do forwarding không đúng), nó fallback về `propertyName`, dẫn đến hiển thị raw keys.

### Solution

Thay vì fix logic `noSuchMethod`, cách đơn giản nhất là **loại bỏ wrapper** khi không cần server translations. Điều này cho phép app sử dụng trực tiếp generated getters từ ARB files, đảm bảo hoạt động chính xác 100%.

---

## Checklist

Copy checklist này để đảm bảo bạn đã làm đủ các bước:

- [ ] Thêm `enableLoadLanguage = 0` vào `lib/config/app_config.dart`
- [ ] Chặn `getAvailableLanguages()` trong `dynamic_localization_service.dart`
- [ ] Chặn `downloadLanguage()` trong `dynamic_localization_service.dart`
- [ ] Chặn `loadCachedLanguage()` trong `dynamic_localization_service.dart`
- [ ] Chặn `syncAllLanguages()` trong `dynamic_localization_service.dart`
- [ ] Chặn `loadServerTranslations()` trong `dynamic_app_localizations.dart`
- [ ] Thêm check trong extension `t()` trong `dynamic_app_localizations.dart`
- [ ] Clear translations trong `_loadInitialLanguage()` trong `main.dart`
- [ ] **Đổi `localizationsDelegates` sang conditional list trong `main.dart`** ⭐
- [ ] (Optional) Update fallback trong `server_app_localizations_delegate.dart`
- [ ] Run `flutter clean && flutter pub get && flutter build web --release`
- [ ] Clear browser cache (localStorage.clear())
- [ ] Test và verify không còn thấy translation keys

---

**LƯU Ý:** Đây là giải pháp vĩnh viễn. Nếu sau này muốn bật lại server translations, chỉ cần đổi `enableLoadLanguage = 1` và rebuild.
