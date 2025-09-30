# Show Dependency Feature - Hướng dẫn sử dụng

## Tổng quan

Tính năng `show_dependency` cho phép điều khiển việc hiển thị các trường trong form dựa trên giá trị của các trường khác. Điều này giúp tạo ra các form động và thân thiện với người dùng.

## Cách hoạt động

### 1. Cấu hình trong Field Definition

Thêm thuộc tính `show_dependency` vào field configuration:

```json
{
    "field_name": "result_error",
    "description": "Keyword nếu lỗi",
    "data_type": "varchar(1024)",
    "editable": "yes",
    "show_in_api_edit_one": "yes",
    "show_in_api_list": "no",
    "show_dependency": {
        "type": ["web_content", "abc123"]
    },
    "required": "no"
}
```

### 2. Logic hiển thị

- **Không có `show_dependency`**: Trường luôn hiển thị
- **Có `show_dependency`**: Trường chỉ hiển thị khi điều kiện được thỏa mãn
- **Item mới**: Các trường có `show_dependency` sẽ ẩn (vì chưa có dữ liệu để kiểm tra)

### 3. Các loại điều kiện hỗ trợ

#### Field Value Condition (Tổng quát)
Có thể sử dụng bất kỳ field nào làm điều kiện:

```json
"show_dependency": {
    "type": ["web_content", "abc123"]
}
```

```json
"show_dependency": {
    "enable": [1]
}
```

```json
"show_dependency": {
    "status": ["active", "pending"]
}
```

#### Multiple Field Dependencies
```json
"show_dependency": {
    "type": ["web_content"],
    "enable": [1],
    "status": ["active"]
}
```

Tất cả điều kiện phải được thỏa mãn (AND logic).

#### Single Value vs Array
```json
// Single value
"show_dependency": {
    "enable": 1
}

// Array of values (OR logic within the same field)
"show_dependency": {
    "enable": [1, true, "1"]
}
```

## Ví dụ thực tế

### Ví dụ 1: Trường error chỉ hiển thị cho loại web_content

```json
{
    "field_name": "result_error",
    "description": "Keyword nếu lỗi",
    "data_type": "varchar(1024)",
    "editable": "yes",
    "show_dependency": {
        "type": ["web_content"]
    },
    "required": "no"
}
```

### Ví dụ 2: Trường stopTo chỉ hiển thị khi enable = 1

```json
{
    "field_name": "stopTo",
    "description": "Dừng kiểm tra tới",
    "data_type": "datetime",
    "editable": "yes",
    "show_dependency": {
        "enable": [1]
    },
    "required": "no"
}
```

### Ví dụ 3: Error Status field

```json
{
    "field_name": "last_check_status",
    "description": "Trạng thái gần nhất",
    "data_type": "error_status",
    "editable": "no",
    "show_in_api_edit_one": "yes",
    "show_dependency": null,
    "required": "no"
}
```

### Ví dụ 4: Multiple conditions

```json
{
    "field_name": "advanced_settings",
    "description": "Cài đặt nâng cao",
    "data_type": "text",
    "editable": "yes",
    "show_dependency": {
        "type": ["web_content", "api_check"],
        "enable": [1],
        "status": ["active"]
    },
    "required": "no"
}
```

## Implementation Details

### 1. MonitorConfigCrudService.shouldShowField()

Method này kiểm tra điều kiện hiển thị:

```dart
static bool shouldShowField(Map<String, dynamic> field, Map<String, dynamic>? itemData) {
    final showDependency = field['show_dependency'];
    
    // Không có dependency -> luôn hiển thị
    if (showDependency == null) {
        return true;
    }
    
    // Không có dữ liệu item -> ẩn các field có dependency
    if (itemData == null) {
        return false;
    }
    
    // Kiểm tra điều kiện type
    if (showDependency is Map && showDependency.containsKey('type')) {
        final allowedTypes = showDependency['type'];
        final currentType = itemData['type']?.toString();
        
        if (allowedTypes is List) {
            return allowedTypes.contains(currentType);
        } else if (allowedTypes is String) {
            return allowedTypes == currentType;
        }
    }
    
    return false;
}
```

### 2. Dynamic Form Updates

Form tự động cập nhật khi field `type` thay đổi:

```dart
void _updateFieldValue(String fieldName, String value) {
    setState(() {
        _currentItemData[fieldName] = value;
    });
}
```

### 3. Field Filtering

Chỉ hiển thị các field thỏa mãn điều kiện:

```dart
widget.fields.where((field) {
    return MonitorConfigCrudService.shouldShowField(field, _currentItemData);
}).map((field) {
    // Render field
})
```

## Tính năng Read-Only Fields

### 1. Hiển thị trong Edit Mode

Khi edit item, các field có `editable = "no"` nhưng `show_in_api_edit_one = "yes"` sẽ được hiển thị ở dưới cùng form:

```json
{
    "field_name": "last_check_status",
    "description": "Trạng thái gần nhất",
    "data_type": "smallint(6)",
    "editable": "no",
    "show_in_api_edit_one": "yes",
    "show_in_api_list": "yes",
    "show_dependency": null,
    "required": "no"
}
```

### 2. Thứ tự hiển thị

1. **Editable fields** (có thể chỉnh sửa)
2. **Divider** "Thông tin Bổ xung" 
3. **Read-only fields** (chỉ xem, không chỉnh sửa)

### 3. Format hiển thị

**Layout**: 1 hàng với Label bên trái, Data bên phải (tỷ lệ 2:3)

- **String/Text**: Hiển thị nguyên văn
- **DateTime**: Format thành "DD/MM/YYYY HH:mm:ss"
- **Boolean/Tinyint**: "Có" (cho 1/true) hoặc "Không" (cho 0/false)
- **Error Status**: Icon + text dựa trên giá trị:
  - `< 0`: ❌ "Lỗi" (màu đỏ)
  - `> 0`: ✅ "Thành công" (màu xanh)
  - `= 0`: ❓ "N/A" (màu xám)
- **Null/Empty**: "Chưa có dữ liệu" (màu xám)

**Styling**: Background xám nhạt, border radius 8px, separator line giữa label và data

## Lưu ý quan trọng

1. **Performance**: Form sẽ rebuild khi field thay đổi để cập nhật visibility
2. **Validation**: Các field ẩn sẽ không được validate
3. **Data**: Dữ liệu của field ẩn vẫn được lưu trữ nhưng không hiển thị
4. **New Items**: Khi tạo item mới, các field có dependency sẽ ẩn cho đến khi điều kiện được thỏa mãn
5. **Read-Only Fields**: Chỉ hiển thị khi edit, không gửi lên server khi save
6. **Add Mode**: Read-only fields không hiển thị khi thêm mới

## Mở rộng trong tương lai

Có thể mở rộng để hỗ trợ:

1. **Multiple Field Dependencies**: Phụ thuộc vào nhiều field
2. **Complex Conditions**: AND, OR logic
3. **Value Ranges**: Hiển thị dựa trên khoảng giá trị
4. **Custom Functions**: Logic tùy chỉnh phức tạp

```json
"show_dependency": {
    "and": [
        {"type": ["web_content"]},
        {"status": ["active", "pending"]}
    ]
}
```
