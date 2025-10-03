import 'package:shared_preferences/shared_preferences.dart';

/// Model để quản lý cài đặt thông báo
class NotificationSettings {
  // Các loại âm thanh có sẵn
  static const String soundDefault =
      'default'; // Âm thanh mặc định của hệ điều hành
  static const String soundNone = 'none'; // Không có âm thanh
  static const String soundCustom1 = 'notification_alert'; // Custom sound 1
  static const String soundCustom2 = 'notification_gentle'; // Custom sound 2
  static const String soundCustom3 = 'notification_urgent'; // Custom sound 3

  // Key để lưu trong SharedPreferences
  static const String _keyNotificationSound = 'notification_sound';
  static const String _keyNotificationEnabled = 'notification_enabled';
  static const String _keyNotificationVibrate = 'notification_vibrate';

  String notificationSound;
  bool notificationEnabled;
  bool notificationVibrate;

  NotificationSettings({
    this.notificationSound = soundDefault,
    this.notificationEnabled = true,
    this.notificationVibrate = true,
  });

  /// Lấy danh sách các âm thanh có sẵn với tên hiển thị
  static Map<String, String> getSoundOptions() {
    return {
      soundDefault: 'Mặc định (Hệ điều hành)',
      soundNone: 'Không có âm thanh',
      soundCustom1: 'Cảnh báo',
      soundCustom2: 'Nhẹ nhàng',
      soundCustom3: 'Khẩn cấp',
    };
  }

  /// Lấy tên file âm thanh (không bao gồm extension)
  /// Trả về null nếu là âm thanh mặc định hoặc không có âm thanh
  String? getSoundFileName() {
    if (notificationSound == soundDefault || notificationSound == soundNone) {
      return null;
    }
    return notificationSound;
  }

  /// Lấy đường dẫn đầy đủ của file âm thanh (dùng cho AssetSource)
  String? getSoundFilePath() {
    final fileName = getSoundFileName();
    if (fileName == null) return null;
    return 'sounds/$fileName.mp3';
  }

  /// Load settings từ SharedPreferences
  static Future<NotificationSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return NotificationSettings(
        notificationSound:
            prefs.getString(_keyNotificationSound) ?? soundDefault,
        notificationEnabled: prefs.getBool(_keyNotificationEnabled) ?? true,
        notificationVibrate: prefs.getBool(_keyNotificationVibrate) ?? true,
      );
    } catch (e) {
      print('Error loading notification settings: $e');
      return NotificationSettings(); // Return default settings
    }
  }

  /// Lưu settings vào SharedPreferences
  Future<bool> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyNotificationSound, notificationSound);
      await prefs.setBool(_keyNotificationEnabled, notificationEnabled);
      await prefs.setBool(_keyNotificationVibrate, notificationVibrate);

      return true;
    } catch (e) {
      print('Error saving notification settings: $e');
      return false;
    }
  }

  /// Copy với các giá trị mới
  NotificationSettings copyWith({
    String? notificationSound,
    bool? notificationEnabled,
    bool? notificationVibrate,
  }) {
    return NotificationSettings(
      notificationSound: notificationSound ?? this.notificationSound,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationVibrate: notificationVibrate ?? this.notificationVibrate,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'notificationSound': notificationSound,
      'notificationEnabled': notificationEnabled,
      'notificationVibrate': notificationVibrate,
    };
  }

  /// Create from Map
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      notificationSound: map['notificationSound'] ?? soundDefault,
      notificationEnabled: map['notificationEnabled'] ?? true,
      notificationVibrate: map['notificationVibrate'] ?? true,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(sound: $notificationSound, enabled: $notificationEnabled, vibrate: $notificationVibrate)';
  }
}
