# 🔔 Notification Sounds - Quick Reference

## 📱 User Flow

```
Settings → Cài đặt Thông báo
    ↓
┌─────────────────────────────┐
│ [●] Bật thông báo          │ ← Toggle ON/OFF
│                             │
│ 🔊 Âm thanh thông báo       │ ← Tap to select
│    Cảnh báo              ▸  │
│                             │
│ [●] Rung                    │ ← Toggle ON/OFF
└─────────────────────────────┘
```

## 🎵 Sound Options

| Option | Description | File Needed |
|--------|-------------|-------------|
| Mặc định (Hệ điều hành) | System default | ❌ None |
| Không có âm thanh | Silent | ❌ None |
| Cảnh báo | Alert tone | ✅ `notification_alert.mp3` |
| Nhẹ nhàng | Gentle tone | ✅ `notification_gentle.mp3` |
| Khẩn cấp | Urgent tone | ✅ `notification_urgent.mp3` |

## 📁 File Structure

```
assets/sounds/
├── notification_alert.mp3    ← Download & add
├── notification_gentle.mp3   ← Download & add
├── notification_urgent.mp3   ← Download & add
└── README.md
```

## 🔧 Code Usage

```dart
// Get current settings
final settings = await NotificationSoundService.getSettings();

// Change sound
final updated = settings.copyWith(
  notificationSound: 'notification_alert',
);
await NotificationSoundService.saveSettings(updated);

// Play notification sound
await NotificationSoundService.playNotificationSound();

// Preview sound
await NotificationSoundService.previewSound('notification_alert');
```

## ⚙️ Settings Storage

**SharedPreferences keys:**
- `notification_sound` → String (sound key)
- `notification_enabled` → bool (ON/OFF)
- `notification_vibrate` → bool (ON/OFF)

## 🔊 Sound Keys

```dart
NotificationSettings.soundDefault  // "default"
NotificationSettings.soundNone     // "none"
NotificationSettings.soundCustom1  // "notification_alert"
NotificationSettings.soundCustom2  // "notification_gentle"
NotificationSettings.soundCustom3  // "notification_urgent"
```

## 🚀 Quick Setup

```bash
# 1. Download 3 MP3 files from:
# https://mixkit.co/free-sound-effects/notification/

# 2. Rename to:
#    notification_alert.mp3
#    notification_gentle.mp3
#    notification_urgent.mp3

# 3. Copy to:
E:\Projects\MonitorApp2025\monitor_app\assets\sounds\

# 4. Rebuild:
flutter clean
flutter pub get
flutter build apk
```

## 🧪 Testing

```bash
# Test in Settings
App → Drawer → Settings → Cài đặt Thông báo
→ Chọn âm thanh → Tap "Nghe thử"

# Test with Firebase
cd _php
php send_notification.php
```

## 📊 Data Flow

```
FCM Notification
    ↓
FirebaseMessagingService
    ↓
NotificationSoundService.getSettings()
    ↓
Check: notificationEnabled?
    ↓ YES
Play sound based on notificationSound setting
    ↓
AudioPlayer.play(sound_file.mp3)
```

## ⚠️ Common Issues

| Issue | Solution |
|-------|----------|
| No sound plays | Check file exists: `assets/sounds/*.mp3` |
| "File not found" | Run `flutter clean && flutter pub get` |
| Can't preview | Only custom sounds have preview |
| Settings not saved | Check SharedPreferences permissions |

## 📚 Documentation Files

- `GUIDE_NOTIFICATION_SOUNDS.md` - Full guide
- `DOWNLOAD_SOUNDS.md` - How to download MP3 files
- `SUMMARY_NOTIFICATION_SOUNDS.md` - Feature summary
- `assets/sounds/README.md` - Assets folder guide

## 🎯 Key Files Modified

```
✨ New:
lib/models/notification_settings.dart
lib/services/notification_sound_service.dart
assets/sounds/

✏️ Modified:
lib/screens/settings_screen.dart
lib/services/firebase_messaging_service.dart
pubspec.yaml
```

## 💾 Dependencies

```yaml
audioplayers: ^6.1.0  # NEW - for playing sounds
shared_preferences: ^2.3.2  # Existing
flutter_local_notifications: ^18.0.1  # Existing
firebase_messaging: ^15.1.3  # Existing
```

## 🎨 UI Components

**Settings Screen:**
- Section: "Cài đặt Thông báo"
- SwitchListTile: Enable/Disable notifications
- ListTile: Sound selector
- SwitchListTile: Enable/Disable vibrate

**Sound Picker Dialog:**
- Title: "Chọn âm thanh thông báo"
- Radio buttons for each sound
- "Nghe thử" button (for custom sounds)
- "Hủy" / "Lưu" buttons

## 🔐 Privacy

- All settings stored locally (device only)
- No sync to server
- User-specific preferences
- Can be reset by clearing app data

---

**Quick Links:**
- Download sounds: `DOWNLOAD_SOUNDS.md`
- Full documentation: `GUIDE_NOTIFICATION_SOUNDS.md`
- Feature summary: `SUMMARY_NOTIFICATION_SOUNDS.md`
