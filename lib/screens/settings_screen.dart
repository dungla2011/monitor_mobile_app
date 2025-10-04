import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:country_flags/country_flags.dart';
import '../utils/language_manager.dart';
import '../models/notification_settings.dart';
import '../services/notification_sound_service.dart';
import '../utils/error_dialog_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  NotificationSettings? _notificationSettings;
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() => _isLoadingSettings = true);

    try {
      final settings = await NotificationSoundService.getSettings();

      setState(() {
        _notificationSettings = settings;
        _isLoadingSettings = false;
      });
    } catch (e) {
      setState(() => _isLoadingSettings = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.messagesLoadingSettingsError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Get localized sound names
  Map<String, String> _getAvailableSounds(AppLocalizations l10n) {
    return {
      NotificationSettings.soundDefault: l10n.notificationSoundDefault,
      NotificationSettings.soundNone: l10n.notificationSoundNone,
      NotificationSettings.soundCustom1: l10n.notificationSoundAlert,
      NotificationSettings.soundCustom2: l10n.notificationSoundGentle,
      NotificationSettings.soundCustom3: l10n.notificationSoundUrgent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navigationSettings),
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
                        l10n.settingsLanguage,
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

                          final countryCode =
                              _getCountryCode(locale.languageCode);

                          return ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CountryFlag.fromCountryCode(
                                  countryCode,
                                  height: 24,
                                  width: 36,
                                ),
                                const SizedBox(width: 12),
                                Radio<String>(
                                  value: locale.languageCode,
                                  groupValue: languageManager
                                      .currentLocale.languageCode,
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await _changeLanguage(context,
                                          languageManager, Locale(value, ''));
                                    }
                                  },
                                ),
                              ],
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
                      Text(
                        l10n.settingsNotificationSettings,
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
                      title: Text(l10n.settingsEnableNotifications),
                      subtitle: Text(l10n.settingsEnableNotificationsDesc),
                      value: _notificationSettings!.notificationEnabled,
                      onChanged: (value) async {
                        final updated = _notificationSettings!.copyWith(
                          notificationEnabled: value,
                        );
                        final success =
                            await NotificationSoundService.saveSettings(
                                updated);
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
                      opacity: _notificationSettings!.notificationEnabled
                          ? 1.0
                          : 0.5,
                      child: ListTile(
                        leading: const Icon(Icons.volume_up),
                        title: Text(l10n.settingsNotificationSound),
                        subtitle: Text(_getAvailableSounds(l10n)[
                                _notificationSettings!.notificationSound] ??
                            l10n.settingsNotificationSoundNotSelected),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _notificationSettings!.notificationEnabled
                            ? () => _showSoundPicker(context)
                            : null,
                      ),
                    ),

                  // Vibrate toggle
                  if (!_isLoadingSettings && _notificationSettings != null)
                    SwitchListTile(
                      title: Text(l10n.settingsVibrate),
                      subtitle: Text(l10n.settingsVibrateDesc),
                      value: _notificationSettings!.notificationVibrate,
                      onChanged: _notificationSettings!.notificationEnabled
                          ? (value) async {
                              final updated = _notificationSettings!.copyWith(
                                notificationVibrate: value,
                              );
                              final success =
                                  await NotificationSoundService.saveSettings(
                                      updated);
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
                        l10n.settingsAppInfo,
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
                    title: Text(l10n.settingsAppName),
                    subtitle: Text(l10n.appTitle),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: Text(l10n.settingsVersion),
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
        return l10n.settingsVietnameseDesc;
      case 'en':
        return l10n.settingsEnglishDesc;
      case 'fr':
        return l10n.settingsFrenchDesc;
      case 'de':
        return l10n.settingsGermanDesc;
      case 'es':
        return l10n.settingsSpanishDesc;
      case 'ja':
        return l10n.settingsJapaneseDesc;
      case 'ko':
        return l10n.settingsKoreanDesc;
      default:
        return '';
    }
  }

  // Map language code to country code for flag display
  String _getCountryCode(String languageCode) {
    switch (languageCode) {
      case 'vi':
        return 'vn'; // Vietnam
      case 'en':
        return 'gb'; // United Kingdom
      case 'fr':
        return 'fr'; // France
      case 'de':
        return 'de'; // Germany
      case 'es':
        return 'es'; // Spain
      case 'ja':
        return 'jp'; // Japan
      case 'ko':
        return 'kr'; // South Korea
      default:
        return 'gb';
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
        if (result['success'] == true) {
          ErrorDialogUtils.showSuccessSnackBar(
            context,
            result['message'] ?? 'Đã thay đổi ngôn ngữ thành công',
          );

          // Show warning if API failed but local change succeeded
          if (result['warning'] != null) {
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                ErrorDialogUtils.showWarningSnackBar(
                  context,
                  '⚠️ ${result['warning']}',
                );
              }
            });
          }
        } else {
          // Check if there's a status code (HTTP error)
          if (result['statusCode'] != null) {
            await ErrorDialogUtils.showHttpErrorDialog(
              context,
              result['statusCode'] as int,
              result['message'] as String?,
              technicalDetails: result['responseBody'] as String?,
            );
          } else {
            // Generic error without status code
            await ErrorDialogUtils.showErrorDialog(
              context,
              result['message'] ?? 'Lỗi khi thay đổi ngôn ngữ',
              title: 'Lỗi thay đổi ngôn ngữ',
            );
          }
        }
      }
    } catch (e) {
      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        await ErrorDialogUtils.showErrorDialog(
          context,
          'Lỗi: $e',
          title: 'Lỗi không xác định',
          customHints: [
            'Kiểm tra kết nối mạng',
            'Thử lại sau vài giây',
            'Liên hệ hỗ trợ nếu vấn đề vẫn tiếp diễn',
          ],
        );
      }
    }
  }

  // Show sound picker dialog
  Future<void> _showSoundPicker(BuildContext context) async {
    String? selectedSound = _notificationSettings?.notificationSound;
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.notificationSoundSelectTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _getAvailableSounds(l10n).entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.value),
                      subtitle: entry.key !=
                                  NotificationSettings.soundDefault &&
                              entry.key != NotificationSettings.soundNone
                          ? TextButton.icon(
                              icon: const Icon(Icons.play_arrow, size: 16),
                              label: Text(l10n.notificationSoundPreview),
                              onPressed: () async {
                                try {
                                  await NotificationSoundService.previewSound(
                                      entry.key);
                                } catch (e) {
                                  if (context.mounted) {
                                    final errorL10n =
                                        AppLocalizations.of(context)!;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('${errorL10n.appError}: $e'),
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
                  child: Text(l10n.appCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(selectedSound),
                  child: Text(l10n.appSave),
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
