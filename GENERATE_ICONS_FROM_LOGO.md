# Generate App Icons từ Logo mới (Ping24)

## 🎨 File logo hiện tại:
- Logo mới: `assets/images/icon.svg` (Ping24 - màu cam)
- Kích thước: Circular logo

## 📋 Các bước thực hiện:

### Bước 1: Cài đặt flutter_launcher_icons

```yaml
# Thêm vào pubspec.yaml (dev_dependencies)
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### Bước 2: Cấu hình flutter_icons

```yaml
# Thêm vào pubspec.yaml (cuối file)
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/icon.svg"
  adaptive_icon_background: "#FF9800"  # Màu cam của logo
  adaptive_icon_foreground: "assets/images/icon.svg"
  
  # Web
  web:
    generate: true
    image_path: "assets/images/icon.svg"
    background_color: "#FF9800"
    theme_color: "#FF9800"
  
  # Windows
  windows:
    generate: true
    image_path: "assets/images/icon.svg"
    icon_size: 256
  
  # macOS
  macos:
    generate: true
    image_path: "assets/images/icon.svg"
```

### Bước 3: Chạy lệnh generate

```bash
# Install dependencies
flutter pub get

# Generate icons
flutter pub run flutter_launcher_icons
```

---

## 🚀 Hoặc dùng script thủ công:

### Cách 1: Dùng ImageMagick (nếu đã cài)

```bash
# Convert SVG sang PNG với các kích thước
magick convert -background none assets/images/icon.svg -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
magick convert -background none assets/images/icon.svg -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
magick convert -background none assets/images/icon.svg -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
magick convert -background none assets/images/icon.svg -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
magick convert -background none assets/images/icon.svg -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png

# Web icon
magick convert -background none assets/images/icon.svg -resize 192x192 web/icons/Icon-192.png
magick convert -background none assets/images/icon.svg -resize 512x512 web/icons/Icon-512.png

# Windows icon
magick convert -background none assets/images/icon.svg -resize 256x256 windows/runner/resources/app_icon.ico
```

### Cách 2: Dùng online tool

1. Mở https://www.appicon.co/
2. Upload file `assets/images/icon.svg`
3. Chọn platforms: Android, iOS, Web
4. Download và giải nén vào thư mục tương ứng

---

## 📱 Kích thước icon cần thiết:

### Android:
- `mipmap-mdpi`: 48x48
- `mipmap-hdpi`: 72x72
- `mipmap-xhdpi`: 96x96
- `mipmap-xxhdpi`: 144x144
- `mipmap-xxxhdpi`: 192x192

### iOS:
- `AppIcon.appiconset`: Nhiều kích thước từ 20x20 đến 1024x1024

### Web:
- `icons/Icon-192.png`: 192x192
- `icons/Icon-512.png`: 512x512
- `favicon.png`: 16x16 hoặc 32x32

### Windows:
- `app_icon.ico`: 256x256 (multi-size ICO file)

---

## ✅ Sau khi generate xong:

```bash
# Clean và rebuild
flutter clean
flutter pub get

# Build cho từng platform
flutter build apk              # Android
flutter build web              # Web
flutter build windows          # Windows
```

---

## 🎯 Kiểm tra:

1. **Android**: Xem icon trên launcher
2. **Web**: Xem favicon trên browser tab
3. **Windows**: Xem icon của .exe file và taskbar

---

## 💡 Lưu ý:

- Logo hiện tại là circular (tròn) - phù hợp cho Android Adaptive Icons
- Màu nền: `#FF9800` (cam)
- Nếu SVG không hoạt động, convert sang PNG 1024x1024 trước
