import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_settings.dart';

/// Service để quản lý âm thanh thông báo
class NotificationSoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static NotificationSettings? _cachedSettings;

  /// Load settings từ cache hoặc SharedPreferences
  static Future<NotificationSettings> getSettings() async {
    _cachedSettings ??= await NotificationSettings.load();
    return _cachedSettings!;
  }

  /// Refresh settings từ SharedPreferences
  static Future<NotificationSettings> refreshSettings() async {
    _cachedSettings = await NotificationSettings.load();
    return _cachedSettings!;
  }

  /// Lưu settings mới
  static Future<bool> saveSettings(NotificationSettings settings) async {
    final success = await settings.save();
    if (success) {
      _cachedSettings = settings;
    }
    return success;
  }

  /// Phát âm thanh thông báo dựa vào settings hiện tại
  static Future<void> playNotificationSound() async {
    try {
      final settings = await getSettings();

      // Kiểm tra xem notification có được bật không
      if (!settings.notificationEnabled) {
        if (kDebugMode) {
          print('Notification is disabled');
        }
        return;
      }

      // Kiểm tra loại âm thanh
      final soundFilePath = settings.getSoundFilePath();

      if (soundFilePath == null) {
        // Âm thanh mặc định hoặc không có âm thanh
        if (settings.notificationSound == NotificationSettings.soundNone) {
          if (kDebugMode) {
            print('No sound configured');
          }
          return;
        }
        // soundDefault: Để hệ điều hành xử lý (flutter_local_notifications)
        if (kDebugMode) {
          print('Using system default sound');
        }
        return;
      }

      // Phát custom sound
      await _audioPlayer.stop(); // Dừng âm thanh đang phát (nếu có)
      await _audioPlayer.play(AssetSource(soundFilePath));

      if (kDebugMode) {
        print('Playing custom sound: $soundFilePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing notification sound: $e');
      }
    }
  }

  /// Preview âm thanh (dùng trong Settings)
  static Future<void> previewSound(String soundKey) async {
    try {
      await _audioPlayer.stop(); // Dừng âm thanh đang phát

      // Nếu là âm thanh mặc định hoặc không có âm thanh
      if (soundKey == NotificationSettings.soundDefault ||
          soundKey == NotificationSettings.soundNone) {
        if (kDebugMode) {
          print('Cannot preview system default or no sound');
        }
        return;
      }

      // Phát custom sound
      final soundFilePath = 'sounds/$soundKey.mp3';
      await _audioPlayer.play(AssetSource(soundFilePath));

      if (kDebugMode) {
        print('Previewing sound: $soundFilePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error previewing sound: $e');
      }
      rethrow; // Throw lại để UI có thể xử lý error
    }
  }

  /// Dừng âm thanh đang phát
  static Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping sound: $e');
      }
    }
  }

  /// Dispose audio player
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing audio player: $e');
      }
    }
  }

  /// Kiểm tra xem file âm thanh có tồn tại không
  static Future<bool> checkSoundFileExists(String soundKey) async {
    if (soundKey == NotificationSettings.soundDefault ||
        soundKey == NotificationSettings.soundNone) {
      return true; // Luôn tồn tại
    }

    try {
      final soundFilePath = 'sounds/$soundKey.mp3';
      // Thử load asset để kiểm tra
      await _audioPlayer.setSource(AssetSource(soundFilePath));
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Sound file does not exist: $soundKey');
      }
      return false;
    }
  }

  /// Lấy danh sách các âm thanh có sẵn (đã kiểm tra file tồn tại)
  static Future<Map<String, String>> getAvailableSounds() async {
    final allSounds = NotificationSettings.getSoundOptions();
    final availableSounds = <String, String>{};

    for (final entry in allSounds.entries) {
      final exists = await checkSoundFileExists(entry.key);
      if (exists) {
        availableSounds[entry.key] = entry.value;
      }
    }

    return availableSounds;
  }
}
