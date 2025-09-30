# Hướng dẫn Monitor CRUD System

## 🎯 Tổng quan

Đã tích hợp **hệ thống CRUD hoàn chỉnh cho Monitor Items** vào ứng dụng Flutter, thay thế trang chủ cũ.

## 📋 Tính năng đã hoàn thành

### ✅ **Dynamic Configuration Loading**
Tự động fetch cấu hình từ API khi khởi động:

```dart
// URLs được fetch tự động:
https://mon.lad.vn/tool/common/get-api-info.php?table=monitor_items&field_details=1
https://mon.lad.vn/tool/common/get-api-info.php?table=monitor_items&api_list=1  
https://mon.lad.vn/tool/common/get-api-info.php?table=monitor_items&api_get_one=1
```

### ✅ **Full CRUD Operations**
- **📝 CREATE**: Thêm monitor item mới
- **📖 READ**: Hiển thị danh sách và chi tiết
- **✏️ UPDATE**: Sửa thông tin item
- **🗑️ DELETE**: Xóa item (single/bulk)

### ✅ **API Integration**
```dart
// Các endpoint được sử dụng:
GET  api/member-monitor-item/list           // Danh sách items
POST api/member-monitor-item/add            // Thêm item mới  
GET  api/member-monitor-item/get/{id}       // Lấy 1 item
POST api/member-monitor-item/update/{id}    // Cập nhật item
DELETE api/member-monitor-item/delete?id=1,2,3  // Xóa nhiều items
```

### ✅ **UI Features**
- **📱 Responsive Design**: Hoạt động mượt trên mobile
- **🔄 Pull-to-Refresh**: Kéo để làm mới danh sách
- **✅ Selection Mode**: Chọn nhiều items để xóa bulk
- **📝 Dynamic Forms**: Form tự động tạo dựa trên config API
- **🔍 Loading States**: Hiển thị loading khi fetch data
- **⚠️ Error Handling**: Xử lý lỗi network và auth

## 🏗️ Cấu trúc Code

### **MonitorConfigService** (`lib/services/monitor_config_crud_service.dart`)
```dart
class MonitorConfigService {
  // Fetch dynamic config từ API
  static Future<Map<String, dynamic>> initializeConfig()
  
  // CRUD Operations
  static Future<Map<String, dynamic>> getMonitorItems()
  static Future<Map<String, dynamic>> addMonitorItem()
  static Future<Map<String, dynamic>> updateMonitorItem()
  static Future<Map<String, dynamic>> deleteMonitorItems()
  
  // Helper methods
  static List<Map<String, dynamic>> getFormFields()
  static bool get isConfigLoaded
}
```

### **MonitorScreen** (`lib/screens/monitor_item_screen.dart`)
```dart
class MonitorScreen extends StatefulWidget {
  // Main CRUD interface
  // - List view với search/filter
  // - Add/Edit dialog
  // - Bulk selection & delete
  // - Pull to refresh
}

class MonitorItemDialog extends StatefulWidget {
  // Dynamic form dialog
  // - Auto-generated fields từ API config
  // - Validation
  // - Save/Update operations
}
```

## 🚀 Cách sử dụng

### **1. Khởi động App**
- App tự động fetch config từ 3 URLs
- Load danh sách monitor items
- Hiển thị ở trang chủ (thay thế HomeScreen)

### **2. Xem danh sách**
- Scroll để xem tất cả items
- Pull-to-refresh để làm mới
- Tap vào item để xem/sửa

### **3. Thêm item mới**
- Nhấn nút **+** (FloatingActionButton)
- Điền form với các trường được config từ API
- Nhấn **"Thêm"** để lưu

### **4. Sửa item**
- Tap vào item trong danh sách
- Hoặc nhấn menu **⋮** → **"Sửa"**
- Form sẽ pre-fill với data hiện tại
- Nhấn **"Cập nhật"** để lưu

### **5. Xóa items**
- **Single delete**: Menu **⋮** → **"Xóa"**
- **Bulk delete**: 
  - Nhấn icon **☰** (select all)
  - Chọn multiple items
  - Nhấn icon **🗑️** để xóa

## 🔧 Technical Details

### **API Response Format**
Tất cả APIs trả về format chuẩn:
```json
{
  "code": 1,           // 1 = success, ≠1 = error
  "message": "...",    // Thông báo
  "payload": "..."     // Data thực tế
}
```

### **Authentication**
- Tự động sử dụng Bearer Token từ WebAuthService
- Auto logout khi token hết hạn (401)
- Redirect về login screen khi cần reauth

### **Error Handling**
```dart
// Network errors
"Lỗi kết nối: ..."

// Auth errors  
"Token hết hạn, vui lòng đăng nhập lại"

// API errors
"Lỗi server (404/500/...)"

// Validation errors
"Vui lòng nhập [field_name]"
```

### **State Management**
- Local state với setState()
- Persistent auth state với WebAuthService
- Config caching trong MonitorConfigService

## 📱 UI Flow

```
App Start
    ↓
WebAuthWrapper (check login)
    ↓ (if logged in)
MainScreen → MonitorScreen
    ↓
MonitorConfigService.initializeConfig()
    ↓ (fetch 3 config URLs)
Load Monitor Items List
    ↓
Display CRUD Interface
```

## 🎨 UI Components

### **MonitorScreen AppBar**
- Title: "Monitor Items"  
- Actions: Select All, Refresh, Delete (selection mode)

### **Item List**
```dart
Card(
  ListTile(
    leading: CircleAvatar | Checkbox (selection mode)
    title: item['name'] 
    subtitle: item['description'] + ID
    trailing: PopupMenuButton (Edit/Delete)
  )
)
```

### **Add/Edit Dialog**
- Dynamic form fields từ API config
- Required field validation (*)
- Save/Cancel buttons với loading states

## 🔍 Debug & Testing

### **Console Logs**
```dart
print('🔄 Initializing Monitor Config...');
print('🔗 Calling API: $_loginEndpoint');
print('📤 Request body: ...');
print('📥 Response status: ${response.statusCode}');
print('✅ Config loaded. Fields: ${_formFields.length}');
```

### **Test Scenarios**
1. **Login** → Xem monitor list
2. **Add new item** → Check API call
3. **Edit item** → Verify pre-fill data
4. **Delete single** → Confirm removal
5. **Bulk delete** → Select multiple → Delete
6. **Network error** → Check error handling
7. **Token expiry** → Auto logout flow

## 🎯 Next Steps

### **Có thể mở rộng:**
1. **Search & Filter**: Tìm kiếm trong danh sách
2. **Pagination**: Load more khi scroll
3. **Sort Options**: Sắp xếp theo field
4. **Export Data**: Export CSV/JSON
5. **Offline Mode**: Cache data locally
6. **Real-time Updates**: WebSocket/SSE
7. **Advanced Validation**: Custom validators
8. **File Upload**: Upload images/files
9. **Bulk Edit**: Sửa nhiều items cùng lúc
10. **Activity Log**: Track changes

---

## 🎉 Kết quả

✅ **Monitor CRUD System hoàn chỉnh**
✅ **Dynamic config loading từ API**  
✅ **Bearer Token authentication**
✅ **Modern Flutter UI/UX**
✅ **Error handling & validation**
✅ **Build thành công**

**Monitor App đã sẵn sàng để sử dụng với đầy đủ tính năng CRUD!** 🚀
