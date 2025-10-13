# Hướng dẫn áp dụng Logo mới (Ping365 Orange Circle)

## File SVG đã tạo:
- `assets/images/icon.svg` (1024x1024, white background)

## Các bước để áp dụng logo:

### Cách 1: Convert online (Nhanh nhất - 2 phút)

1. **Mở online converter:**
   - https://svgtopng.com/
   - Hoặc: https://cloudconvert.com/svg-to-png
   
2. **Upload file:**
   - Chọn file: `assets/images/icon.svg`
   
3. **Set resolution:**
   - Width: 1024px
   - Height: 1024px
   - Maintain aspect ratio: YES
   
4. **Download PNG:**
   - Lưu file thành: `icon-1024.png`
   
5. **Copy vào project:**
   ```bash
   mkdir -p assets/icon
   cp icon-1024.png assets/icon/logo.png
   ```

6. **Generate icons:**
   ```bash
   flutter pub get
   dart run flutter_launcher_icons
   ```

### Cách 2: Dùng ImageMagick (Nếu đã cài)

```bash
# Install ImageMagick trước (Windows)
# Download từ: https://imagemagick.org/script/download.php#windows

# Convert SVG to PNG
magick convert -background white -resize 1024x1024 assets/images/icon.svg assets/icon/logo.png

# Generate launcher icons
flutter pub get
dart run flutter_launcher_icons
```

### Cách 3: Dùng Inkscape (Nếu đã cài)

```bash
# Install Inkscape trước
# Download từ: https://inkscape.org/release/

# Convert
inkscape --export-type=png --export-width=1024 --export-height=1024 assets/images/icon.svg --export-filename=assets/icon/logo.png

# Generate icons
flutter pub get
dart run flutter_launcher_icons
```

## Kiểm tra kết quả:

Sau khi chạy `dart run flutter_launcher_icons`, icons sẽ được tạo tại:
- **Android:** `android/app/src/main/res/mipmap-*/ic_launcher.png`
- **iOS:** `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Logo design:

```
┌─────────────────────┐
│   🟠🟠🟠🟠🟠🟠🟠     │  ← Top 1/3: Orange fill
│   🟠         🟠     │
│ 🟠             🟠   │
│ 🟠   Ping365   🟠   │  ← Middle: White with orange text
│   🟠         🟠     │
│   🟠🟠🟠🟠🟠🟠🟠     │  ← Bottom 1/3: Orange fill
└─────────────────────┘
     Orange circle border (#FF8C00)
```

## Nếu gặp lỗi:

1. **"command not found"**: Cài ImageMagick hoặc dùng online converter
2. **"image_path not found"**: Kiểm tra file `assets/icon/logo.png` đã tồn tại chưa
3. **Icons không update**: Run `flutter clean` và build lại

## Build APK với logo mới:

```bash
flutter clean
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`
