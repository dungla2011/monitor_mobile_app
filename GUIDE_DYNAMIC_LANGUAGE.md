# Dynamic Language Loading System

Hệ thống cho phép tải ngôn ngữ động từ server mà không cần rebuild app.

## Tính năng

✅ **Sync transla3. **Khi dùng text**:
   - Kiểm tra server translation có không
   - Nếu có → dùng server version
   - Nếu không → fallback built-in ARB

4. **Sync định kỳ**:
   - ~~Mặc định: 24 giờ sync 1 lần~~ **REMOVED**
   - User bấm nút "Sync Language" khi muốn update
   - Có thể bấm bất kỳ lúc nào để nhận translations mới server** - Manual trigger qua Settings  
✅ **Fallback an toàn** - Dùng built-in ARB files nếu server không available  
✅ **Cache offline** - Lưu translations đã sync, hoạt động khi offline  
✅ **Thêm ngôn ngữ mới** - Chỉ cần update database, không rebuild app  
✅ **Update text dễ dàng** - Sửa database, user bấm Sync để nhận update  
✅ **User control** - User quyết định khi nào sync, không tự động  

## Kiến trúc

```
┌─────────────────┐
│   Flutter App   │
│  (Built-in ARB) │ ← Fallback
└────────┬────────┘
         │
         ↓ Sync on start
┌─────────────────┐
│   Server API    │
│  (Translations) │
└────────┬────────┘
         │
         ↓ Query
┌─────────────────┐
│    Database     │
│ languages table │
│translations tbl │
└─────────────────┘
```

## Setup

### 1. Database

Chạy SQL schema:
```bash
mysql -u root -p monitor_db < _php/schema_translations.sql
```

### 2. PHP API

Deploy 2 files PHP lên server:
- `_php/get-available-languages.php` → `/api/get-available-languages`
- `_php/get-language.php` → `/api/get-language`

Cấu hình database connection trong các file PHP.

### 3. Flutter App

Đã tích hợp sẵn! Không cần config thêm.

## Cách sử dụng

### Thêm ngôn ngữ mới

```sql
INSERT INTO languages (code, name, native_name, flag_code, display_order)
VALUES ('zh', 'Chinese', '中文', 'CN', 8);
```

### Thêm/sửa translation

```sql
INSERT INTO translations (language_code, translation_key, translation_value)
VALUES ('vi', 'appTitle', 'Ứng dụng Monitor')
ON DUPLICATE KEY UPDATE translation_value = VALUES(translation_value);
```

### Force sync trong app

**Cách 1: Qua UI Settings**
1. Mở app → Settings
2. Nhấn nút "Sync Language" (hoặc "Đồng bộ ngôn ngữ")
3. Đợi download hoàn tất
4. Translations mới sẽ áp dụng ngay

**Cách 2: Qua code (Debug)**
```dart
await DynamicLocalizationService.clearCache();
await DynamicLocalizationService.syncAllLanguages();
```

## API Endpoints

### GET /api/get-available-languages

Response:
```json
{
  "code": 1,
  "payload": [
    {
      "code": "vi",
      "name": "Vietnamese",
      "native_name": "Tiếng Việt",
      "flag_code": "VN",
      "is_active": 1,
      "last_updated": "2025-10-08 10:00:00"
    }
  ]
}
```

### POST /api/get-language

Request:
```json
{
  "language_code": "vi",
  "format": "arb"
}
```

Response:
```json
{
  "code": 1,
  "payload": {
    "appTitle": "Monitor App",
    "appError": "Lỗi",
    "appSuccess": "Thành công"
  },
  "count": 100
}
```

## Workflow

1. **App Start**: 
   - Load built-in ARB files
   - ~~Background sync từ server (không block UI)~~ **REMOVED**
   - ~~Cache translations vào SharedPreferences~~

2. **Manual Sync**:
   - User vào Settings → Nhấn nút "Sync Language"
   - App sẽ **force download** tất cả ngôn ngữ từ server (bỏ qua cache)
   - Cache translations vào SharedPreferences
   - **Load ALL synced languages into memory** (DynamicAppLocalizations)
   - Reload translations ngay lập tức
   - **Lưu ý**: 
     * Force sync = download tất cả, không kiểm tra cache expiry
     * Tất cả ngôn ngữ được apply vào app ngay sau sync
     * Khi đổi ngôn ngữ, server translations đã ready

3. **Khi dùng text**:
   - Kiểm tra server translation có không
   - Nếu có → dùng server version
   - Nếu không → fallback built-in ARB

3. **Sync định kỳ**:
   - Mặc định: 24 giờ sync 1 lần
   - Có thể force sync bất kỳ lúc nào

## Troubleshooting

### Server translations không load

1. Check network connection
2. Check API endpoint có hoạt động không
3. Check database có data không
4. Xem console logs: `flutter run -d chrome`

### Clear cache để test

```dart
import 'package:monitor_app/services/dynamic_localization_service.dart';

// Clear all cached translations
await DynamicLocalizationService.clearCache();
```

### Debug mode

Bật console logs để xem chi tiết:
- `🌍` = Fetching languages
- `📥` = Downloading translations
- `✅` = Success
- `❌` = Error
- `📦` = Loaded from cache

## Lưu ý

- **Built-in ARB files vẫn cần có** - Làm fallback khi offline
- **Server translations override built-in** - Server version ưu tiên hơn
- **Cache 24 hours** - Giảm load server, tăng tốc app
- **Non-blocking sync** - Không làm chậm app start
