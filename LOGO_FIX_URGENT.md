# HƯỚNG DẪN KHẨN CẤP - CÀI ĐẶT LOGO MỚI

## ❌ Vấn đề hiện tại:
- File `assets/icon/logo.png` KHÔNG TỒN TẠI
- Flutter Launcher Icons đã generate từ logo cũ (hoặc file không đúng)
- Android icons vẫn là logo cũ

## ✅ Giải pháp:

### Bước 1: Copy file PNG mới
Từ 3 file PNG bạn có:
- File 300x300 (nhỏ)
- File 512x512 (trung bình)
- File 1024x1024 (LỚN NHẤT) ← Dùng file này!

**Copy file 1024x1024 vào:**
```
E:/Projects/MonitorApp2025/monitor_app/assets/icon/logo.png
```

**Cách 1: Dùng File Explorer**
1. Mở thư mục: `E:/Projects/MonitorApp2025/monitor_app/assets/icon/`
2. Kéo file PNG 1024x1024 vào đây
3. Đổi tên thành: `logo.png`

**Cách 2: Dùng Terminal**
```bash
# Copy file PNG (thay <path-to-your-1024x1024.png>)
cp <path-to-your-1024x1024.png> E:/Projects/MonitorApp2025/monitor_app/assets/icon/logo.png
```

### Bước 2: Regenerate icons
```bash
cd /e/Projects/MonitorApp2025/monitor_app
dart run flutter_launcher_icons
```

### Bước 3: Verify icons được tạo mới
```bash
ls -lah android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
# Kiểm tra timestamp - phải là NGAY BÂY GIỜ
```

### Bước 4: Clean build
```bash
flutter clean
```

### Bước 5: Build APK mới
```bash
flutter build apk --release
```

### Bước 6: Install APK
```bash
# Uninstall app cũ trên điện thoại
# Install APK mới từ: build/app/outputs/flutter-apk/app-release.apk
```

## 🔍 Verify file logo.png:
```bash
cd /e/Projects/MonitorApp2025/monitor_app
ls -lah assets/icon/logo.png

# File size phải ~15-30KB (cho PNG 1024x1024)
# Timestamp phải là hôm nay
```

## ⚠️ Lưu ý:
- **KHÔNG dùng file SVG** - Flutter Launcher Icons cần PNG
- File phải đúng tên: `logo.png` (không phải logo2.png hay logo_new.png)
- File phải ở đúng path: `assets/icon/logo.png`
- Size tối thiểu: 1024x1024 pixels

## 🎯 Kết quả mong đợi:
Sau khi hoàn thành, icon sẽ là:
- Vòng tròn cam (#FF8C00)
- Middle section: White background với text "Ping24" màu cam
- Top & Bottom: Orange fill

