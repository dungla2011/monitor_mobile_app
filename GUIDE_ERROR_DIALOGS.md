# Guide: Error Dialog Improvements

## Tổng quan

Đã cải thiện hiển thị lỗi API với popup dialog đẹp mắt và thông tin chi tiết hơn thay vì SnackBar đơn giản.

## Các cải tiến chính

### 1. **HTTP Error Dialog** - Dialog chuyên biệt cho lỗi HTTP

#### Features:
- ✅ Hiển thị icon và màu sắc tùy theo loại lỗi
- ✅ Giải thích rõ ràng về nguyên nhân lỗi
- ✅ Gợi ý cách khắc phục cụ thể cho từng mã lỗi
- ✅ Chi tiết kỹ thuật có thể mở rộng (ExpansionTile)
- ✅ Design đẹp với border radius, gradient colors

#### Các mã HTTP được hỗ trợ:

| HTTP Code | Title | Icon | Color | Gợi ý |
|-----------|-------|------|-------|-------|
| 400 | Yêu cầu không hợp lệ | error_outline | Orange | Kiểm tra định dạng dữ liệu |
| 401 | Chưa đăng nhập | lock_outline | Amber | Đăng nhập lại |
| 403 | Không có quyền | block | Red | Liên hệ admin |
| 404 | Không tìm thấy | search_off | Grey | Kiểm tra URL/ID |
| 408 | Hết thời gian chờ | hourglass_empty | Orange | Kiểm tra mạng |
| 429 | Quá nhiều yêu cầu | speed | Orange | Đợi vài phút |
| 500 | Lỗi máy chủ | dns_outlined | Red | Đợi và thử lại |
| 502/503/504 | Dịch vụ không khả dụng | cloud_off | Grey | Server bảo trì |

### 2. **Generic Error Dialog** - Dialog lỗi chung

Features:
- Decode Unicode escape sequences (\\u1ed7i → ỗi)
- Selectable text để copy lỗi
- Contextual hints dựa trên nội dung lỗi
- Custom hints có thể truyền vào

## Cách sử dụng

### 1. Import package

```dart
import '../utils/error_dialog_utils.dart';
```

### 2. Hiển thị HTTP Error Dialog

```dart
// Khi gọi API và nhận được lỗi HTTP
final response = await http.post(...);

if (response.statusCode != 200) {
  await ErrorDialogUtils.showHttpErrorDialog(
    context,
    response.statusCode,           // HTTP status code (400, 401, 500...)
    'Không thể cập nhật dữ liệu',  // Custom error message
    technicalDetails: response.body, // Optional: Chi tiết kỹ thuật
  );
}
```

### 3. Hiển thị Generic Error Dialog

```dart
try {
  // Some operation
} catch (e) {
  await ErrorDialogUtils.showErrorDialog(
    context,
    'Lỗi: $e',
    title: 'Lỗi không xác định',
    customHints: [
      'Kiểm tra kết nối mạng',
      'Thử lại sau vài giây',
      'Liên hệ hỗ trợ nếu vấn đề vẫn tiếp diễn',
    ],
  );
}
```

### 4. Hiển thị Success/Warning/Info SnackBar

```dart
// Success
ErrorDialogUtils.showSuccessSnackBar(context, 'Cập nhật thành công!');

// Warning
ErrorDialogUtils.showWarningSnackBar(context, '⚠️ Cảnh báo quan trọng');

// Info
ErrorDialogUtils.showInfoSnackBar(context, 'Thông tin hữu ích');
```

## Ví dụ trong Settings Screen

### Trước khi cải thiện:

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Lỗi HTTP 400'),
    backgroundColor: Colors.red,
  ),
);
```

**Vấn đề:**
- Không giải thích lỗi
- Không có gợi ý khắc phục
- Dễ bỏ qua
- Hiển thị ngắn và biến mất

### Sau khi cải thiện:

```dart
if (result['statusCode'] != null) {
  await ErrorDialogUtils.showHttpErrorDialog(
    context,
    result['statusCode'] as int,
    result['message'] as String?,
    technicalDetails: result['responseBody'] as String?,
  );
}
```

**Lợi ích:**
- Dialog popup thu hút sự chú ý
- Icon và màu sắc phù hợp với loại lỗi
- Giải thích rõ ràng nguyên nhân
- Gợi ý cách khắc phục cụ thể
- Chi tiết kỹ thuật có thể xem thêm
- User phải đóng dialog (không tự biến mất)

## UI Demo

### HTTP 400 Error Dialog:

```
┌─────────────────────────────────────────┐
│ [🟠] Yêu cầu không hợp lệ                │
│     HTTP 400                            │
├─────────────────────────────────────────┤
│                                         │
│ [ℹ️] Dữ liệu gửi lên server không đúng  │
│     định dạng hoặc thiếu thông tin...   │
│                                         │
│ [⚠️] Chi tiết lỗi:                      │
│     Trường email không hợp lệ           │
│                                         │
│ [💡] Gợi ý khắc phục:                   │
│     • Kiểm tra lại tất cả các trường    │
│     • Đảm bảo email có định dạng đúng   │
│     • Không để trống trường bắt buộc    │
│                                         │
│           [Đóng]  [Thử lại]            │
└─────────────────────────────────────────┘
```

### HTTP 401 Error Dialog:

```
┌─────────────────────────────────────────┐
│ [🟡] Chưa đăng nhập                      │
│     HTTP 401                            │
├─────────────────────────────────────────┤
│                                         │
│ [ℹ️] Phiên đăng nhập đã hết hạn hoặc    │
│     bạn chưa đăng nhập vào hệ thống.    │
│                                         │
│ [💡] Gợi ý khắc phục:                   │
│     • Vui lòng đăng nhập lại            │
│     • Kiểm tra kết nối mạng             │
│     • Liên hệ admin nếu vẫn lỗi         │
│                                         │
│           [Đóng]  [Thử lại]            │
└─────────────────────────────────────────┘
```

### HTTP 500 Error Dialog:

```
┌─────────────────────────────────────────┐
│ [🔴] Lỗi máy chủ                        │
│     HTTP 500                            │
├─────────────────────────────────────────┤
│                                         │
│ [ℹ️] Server gặp lỗi khi xử lý yêu cầu.  │
│     Vui lòng thử lại sau.               │
│                                         │
│ [💡] Gợi ý khắc phục:                   │
│     • Đợi vài phút rồi thử lại          │
│     • Liên hệ bộ phận kỹ thuật          │
│     • Lưu dữ liệu trước khi thử lại     │
│                                         │
│ ▼ Chi tiết kỹ thuật                     │
│                                         │
│           [Đóng]  [Thử lại]            │
└─────────────────────────────────────────┘
```

## Files đã thay đổi

### 1. `lib/utils/error_dialog_utils.dart`
- ✅ Thêm `showHttpErrorDialog()` method
- ✅ Thêm `_getHttpErrorInfo()` helper
- ✅ Thêm `_HttpErrorInfo` class để store error info

### 2. `lib/utils/language_manager.dart`
- ✅ Thêm `statusCode` vào return map khi lỗi HTTP
- ✅ Thêm `responseBody` để hiển thị technical details

### 3. `lib/screens/settings_screen.dart`
- ✅ Import `error_dialog_utils.dart`
- ✅ Thay thế SnackBar bằng `ErrorDialogUtils.showHttpErrorDialog()`
- ✅ Sử dụng `showSuccessSnackBar()` cho thông báo thành công
- ✅ Sử dụng `showWarningSnackBar()` cho cảnh báo

## Best Practices

### Khi nào dùng HTTP Error Dialog?
✅ Lỗi từ API call (có status code)
✅ Cần giải thích chi tiết cho user
✅ Cần gợi ý cách khắc phục
✅ Lỗi quan trọng cần user chú ý

### Khi nào dùng Generic Error Dialog?
✅ Lỗi không có status code
✅ Exception trong try-catch
✅ Validation errors
✅ Cần custom hints

### Khi nào dùng SnackBar?
✅ Thông báo thành công ngắn gọn
✅ Warning không quan trọng
✅ Info message
✅ Không cần user interaction

## Testing

```dart
// Test HTTP 400 error
await ErrorDialogUtils.showHttpErrorDialog(
  context,
  400,
  'Email không hợp lệ',
);

// Test HTTP 401 error
await ErrorDialogUtils.showHttpErrorDialog(
  context,
  401,
  'Token đã hết hạn',
);

// Test HTTP 500 error
await ErrorDialogUtils.showHttpErrorDialog(
  context,
  500,
  'Internal Server Error',
  technicalDetails: 'Stack trace: ...',
);
```

## Notes

- Dialog tự động dismiss khi user tap "Đóng" hoặc "Thử lại"
- Technical details được collapse mặc định để UI gọn gàng
- Màu sắc và icon được chọn phù hợp với từng loại lỗi
- Text có thể select và copy để báo lỗi
- Hỗ trợ Unicode decoding cho các lỗi tiếng Việt

## Next Steps

Có thể áp dụng pattern này cho:
1. Monitor CRUD operations errors
2. Authentication errors
3. Network timeout errors
4. Validation errors in forms
5. Firebase messaging errors

## Kết luận

Thay vì hiển thị lỗi đơn giản ở SnackBar:
- ❌ "Lỗi HTTP 400"

Giờ có dialog đẹp và thông tin đầy đủ:
- ✅ Title rõ ràng: "Yêu cầu không hợp lệ"
- ✅ Icon và màu sắc phù hợp
- ✅ Giải thích nguyên nhân
- ✅ Gợi ý cách khắc phục
- ✅ Chi tiết kỹ thuật (nếu cần)
- ✅ Buttons để đóng hoặc thử lại

**Better UX = Happier Users!** 🎉
