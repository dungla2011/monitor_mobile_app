import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_localizations.dart';
import '../utils/language_manager.dart';
import '../models/notification_settings.dart';
import '../services/notification_sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  NotificationSettings? _notificationSettings;
  bool _isLoadingSettings = true;
  Map<String, String> _availableSounds = {};

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() => _isLoadingSettings = true);
    
    try {
      final settings = await NotificationSoundService.getSettings();
      final sounds = await NotificationSoundService.getAvailableSounds();
      
      setState(() {
        _notificationSettings = settings;
        _availableSounds = sounds;
        _isLoadingSettings = false;
      });
    } catch (e) {
      setState(() => _isLoadingSettings = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải cài đặt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSettings),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        l10n.translate('settings.language'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<LanguageManager>(
                    builder: (context, languageManager, child) {
                      return Column(
                        children:
                            LanguageManager.supportedLocales.map((locale) {
                          final languageName = LanguageManager
                                  .languageNames[locale.languageCode] ??
                              locale.languageCode;

                          return ListTile(
                            leading: Radio<String>(
                              value: locale.languageCode,
                              groupValue:
                                  languageManager.currentLocale.languageCode,
                              onChanged: (value) async {
                                if (value != null) {
                                  await _changeLanguage(context,
                                      languageManager, Locale(value, ''));
                                }
                              },
                            ),
                            title: Text(languageName),
                            subtitle: Text(_getLanguageDescription(
                                locale.languageCode, l10n)),
                            onTap: () async {
                              await _changeLanguage(
                                  context, languageManager, locale);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notification Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications, color: Colors.orange),
                      const SizedBox(width: 12),
                      const Text(
                        'Cài đặt Thông báo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Enable/Disable Notifications
                  if (!_isLoadingSettings && _notificationSettings != null)
                    SwitchListTile(
                      title: const Text('Bật thông báo'),
                      subtitle: const Text('Nhận thông báo từ ứng dụng'),
                      value: _notificationSettings!.notificationEnabled,
                      onChanged: (value) async {
                        final updated = _notificationSettings!.copyWith(
                          notificationEnabled: value,
                        );
                        final success = await NotificationSoundService.saveSettings(updated);
                        if (success) {
                          setState(() {
                            _notificationSettings = updated;
                          });
                        }
                      },
                    ),
                  
                  // Sound Selection
                  if (!_isLoadingSettings && _notificationSettings != null)
                    Opacity(
                      opacity: _notificationSettings!.notificationEnabled ? 1.0 : 0.5,
                      child: ListTile(
                        leading: const Icon(Icons.volume_up),
                        title: const Text('Âm thanh thông báo'),
                        subtitle: Text(_availableSounds[_notificationSettings!.notificationSound] ?? 'Chưa chọn'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _notificationSettings!.notificationEnabled 
                            ? () => _showSoundPicker(context)
                            : null,
                      ),
                    ),
                  
                  // Vibrate toggle
                  if (!_isLoadingSettings && _notificationSettings != null)
                    SwitchListTile(
                      title: const Text('Rung'),
                      subtitle: const Text('Rung khi có thông báo'),
                      value: _notificationSettings!.notificationVibrate,
                      onChanged: _notificationSettings!.notificationEnabled 
                          ? (value) async {
                              final updated = _notificationSettings!.copyWith(
                                notificationVibrate: value,
                              );
                              final success = await NotificationSoundService.saveSettings(updated);
                              if (success) {
                                setState(() {
                                  _notificationSettings = updated;
                                });
                              }
                            }
                          : null,
                    ),
                  
                  // Loading indicator
                  if (_isLoadingSettings)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App Info Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        l10n.translate('settings.appInfo'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.apps),
                    title: Text(l10n.translate('settings.appName')),
                    subtitle: Text(l10n.appTitle),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: Text(l10n.translate('settings.version')),
                    subtitle: const Text('1.0.0+1'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageDescription(String languageCode, AppLocalizations l10n) {
    switch (languageCode) {
      case 'vi':
        return l10n.translate('settings.vietnameseDesc');
      case 'en':
        return l10n.translate('settings.englishDesc');
      default:
        return '';
    }
  }

  Future<void> _changeLanguage(
    BuildContext context,
    LanguageManager languageManager,
    Locale locale,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Call API to change language
      final result = await languageManager.changeLanguage(locale);

      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show result message
      if (context.mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        if (result['success'] == true) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Đã thay đổi ngôn ngữ thành công',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Show warning if API failed but local change succeeded
          if (result['warning'] != null) {
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('⚠️ ${result['warning']}'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            });
          }
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Lỗi khi thay đổi ngôn ngữ',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Show sound picker dialog
  Future<void> _showSoundPicker(BuildContext context) async {
    String? selectedSound = _notificationSettings?.notificationSound;

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chọn âm thanh thông báo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _availableSounds.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.value),
                      subtitle: entry.key != NotificationSettings.soundDefault &&
                              entry.key != NotificationSettings.soundNone
                          ? TextButton.icon(
                              icon: const Icon(Icons.play_arrow, size: 16),
                              label: const Text('Nghe thử'),
                              onPressed: () async {
                                try {
                                  await NotificationSoundService.previewSound(entry.key);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Lỗi khi phát âm thanh: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            )
                          : null,
                      value: entry.key,
                      groupValue: selectedSound,
                      onChanged: (value) {
                        setState(() {
                          selectedSound = value;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(selectedSound),
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    // Save selected sound
    if (result != null && _notificationSettings != null) {
      final updated = _notificationSettings!.copyWith(
        notificationSound: result,
      );
      final success = await NotificationSoundService.saveSettings(updated);
      if (success) {
        setState(() {
          _notificationSettings = updated;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã lưu âm thanh thông báo'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}
