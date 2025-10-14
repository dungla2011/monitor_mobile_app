# SYSTEM TRAY & AUTO-START SETUP GUIDE

## ✅ Đã cài đặt:
1. ✅ `tray_manager` - System tray icon
2. ✅ `window_manager` - Window management (show/hide/minimize)
3. ✅ `launch_at_startup` - Auto-start with Windows
4. ✅ `SystemTrayService` - Service quản lý tray & auto-start

## 📋 Cần làm tiếp:

### 1. Tạo Tray Icon (ICO file)
Windows cần file `.ico` cho system tray icon.

**Cách tạo:**
- Dùng online tool: https://www.icoconverter.com/
- Upload logo PNG 1024x1024
- Download file `.ico`
- Lưu vào: `assets/icon/tray_icon.ico`

**Hoặc dùng ImageMagick:**
```bash
magick convert assets/icon/logo.png -define icon:auto-resize=256,128,64,48,32,16 assets/icon/tray_icon.ico
```

### 2. Update pubspec.yaml với icon
```yaml
flutter:
  assets:
    - assets/images/
    - assets/sounds/
    - assets/translations/
    - assets/icon/tray_icon.ico    # ← Thêm dòng này
    - assets/icon/tray_icon.png    # ← Cho macOS/Linux
```

### 3. Thêm Settings UI để enable/disable auto-start

Trong `lib/screens/settings_screen.dart`, thêm:

```dart
import 'package:monitor_app/services/system_tray_service.dart';

// Trong build method, thêm switch:
SwitchListTile(
  title: Text('Start with Windows'),
  subtitle: Text('Launch app automatically when Windows starts'),
  value: _autoStartEnabled,
  onChanged: (bool value) async {
    if (value) {
      await SystemTrayService.enableAutoStart();
    } else {
      await SystemTrayService.disableAutoStart();
    }
    setState(() {
      _autoStartEnabled = value;
    });
  },
)

// Trong initState, check status:
@override
void initState() {
  super.initState();
  _checkAutoStartStatus();
}

Future<void> _checkAutoStartStatus() async {
  bool isEnabled = await SystemTrayService.isAutoStartEnabled();
  setState(() {
    _autoStartEnabled = isEnabled;
  });
}
```

### 4. Handle Window Close Event

Để minimize to tray thay vì exit, trong `main.dart`:

```dart
class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Minimize to tray instead of closing
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await SystemTrayService.minimizeToTray();
    }
  }
}
```

### 5. Setup Tray Listener

Trong `main.dart`, thêm tray listener:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... existing code ...

  // Initialize System Tray
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await SystemTrayService.initialize();
    trayManager.addListener(TrayListener());  // ← Thêm listener
  }

  runApp(...);
}
```

## 🎯 Features:

### System Tray Menu:
- ✅ Show Window
- ✅ Monitor Items
- ✅ Monitor Configs
- ✅ Settings
- ✅ About
- ✅ Exit

### Auto-start:
- ✅ Enable/disable từ Settings
- ✅ Check status khi mở app
- ✅ Registry key: `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run`

### Window Management:
- ✅ Click tray icon → Show window
- ✅ Right-click → Context menu
- ✅ Close button → Minimize to tray
- ✅ Exit menu → Completely close app

## 🧪 Test:

```bash
# Build và test
flutter build windows --release
./build/windows/x64/runner/Release/monitor_app.exe

# Check tray icon appears in system tray
# Right-click tray icon to see menu
# Close window → should minimize to tray
# Click tray icon → should show window again
```

## ⚙️ Registry Info (for debug):

```bash
# Check if auto-start is enabled
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v Ping365Monitor

# Manually add auto-start
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v Ping365Monitor /t REG_SZ /d "C:\path\to\monitor_app.exe --minimized"

# Manually remove auto-start
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v Ping365Monitor
```

## 📝 Notes:

1. **Tray icon file cần tồn tại** trước khi app start, không thì sẽ crash
2. **Auto-start path** phải là absolute path đến `.exe` file
3. **Windows Defender** có thể warning lần đầu chạy auto-start
4. **Admin rights KHÔNG cần thiết** - chỉ cần user permissions

## 🚀 Quick Start:

1. Tạo tray icon (`.ico` file)
2. Add icon vào `assets/icon/`
3. Update `pubspec.yaml` assets
4. Run `flutter pub get`
5. Build Windows app
6. Test tray features!

