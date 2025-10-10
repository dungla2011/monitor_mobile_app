import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monitor_app/l10n/app_localizations.dart';
import 'package:monitor_app/l10n/dynamic_app_localizations.dart';
import 'package:monitor_app/services/dynamic_localization_service.dart';
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
  List<LanguageInfo> _availableLanguages = [];
  bool _isLoadingLanguages = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadAvailableLanguages();
  }

  Future<void> _loadAvailableLanguages() async {
    try {
      final languages =
          await DynamicLocalizationService.getAvailableLanguages();
      setState(() {
        _availableLanguages = languages.where((lang) => lang.isActive).toList();
        _isLoadingLanguages = false;
      });
    } catch (e) {
      print('❌ Error loading available languages: $e');
      // Fallback to local languages if API fails
      setState(() {
        _availableLanguages = [
          LanguageInfo(
            code: 'vi',
            name: 'Vietnamese',
            nativeName: 'Tiếng Việt',
            flagCode: 'VN',
          ),
          LanguageInfo(
            code: 'en',
            name: 'English',
            nativeName: 'English',
            flagCode: 'US',
          ),
        ];
        _isLoadingLanguages = false;
      });
    }
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
                      final currentLanguageCode =
                          languageManager.currentLocale.languageCode;

                      // Show loading indicator if languages are still loading
                      if (_isLoadingLanguages) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Show dropdown with available languages from API
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: currentLanguageCode,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: _availableLanguages.map((langInfo) {
                              return DropdownMenuItem<String>(
                                value: langInfo.code,
                                child: Row(
                                  children: [
                                    CountryFlag.fromCountryCode(
                                      langInfo.flagCode?.toUpperCase() ?? 'US',
                                      height: 20,
                                      width: 30,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            langInfo.nativeName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            langInfo.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) async {
                              if (value != null) {
                                await _changeLanguage(context, languageManager,
                                    Locale(value, ''));
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Sync Language Button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.sync),
                    label: Text(l10n.settingsSyncLanguage),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () => _syncLanguagesFromServer(context),
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
                    subtitle: const Text('1.6.1'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
        final l10n =
            AppLocalizations.of(context)!; // Refresh after language change

        if (result['success'] == true) {
          // Translate message key
          String message =
              _translateMessageKey(l10n, result['messageKey'] ?? '');

          ErrorDialogUtils.showSuccessSnackBar(
            context,
            message,
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
            String errorMessage =
                _translateMessageKey(l10n, result['messageKey'] ?? '');

            await ErrorDialogUtils.showHttpErrorDialog(
              context,
              result['statusCode'] as int,
              errorMessage,
              technicalDetails: result['responseBody'] as String?,
            );
          } else {
            // Generic error without status code
            String errorMessage =
                _translateMessageKey(l10n, result['messageKey'] ?? '');

            await ErrorDialogUtils.showErrorDialog(
              context,
              errorMessage,
              title: l10n.languageChangeError,
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
        final l10n = AppLocalizations.of(context)!;
        await ErrorDialogUtils.showErrorDialog(
          context,
          '${l10n.appError}: $e',
          title: l10n.languageChangeError,
        );
      }
    }
  }

  // Helper method to translate message keys
  String _translateMessageKey(AppLocalizations l10n, String key) {
    switch (key) {
      case 'languageAlreadySelected':
        return l10n.languageAlreadySelected;
      case 'languageUpdateSuccess':
        return l10n.languageUpdateSuccess;
      case 'languageChangedNotSynced':
        return l10n.languageChangedNotSynced;
      case 'languageChangeError':
        return l10n.languageChangeError;
      case 'languageUserNotLoggedIn':
        return l10n.languageUserNotLoggedIn;
      case 'languageSessionExpired':
        return l10n.languageSessionExpired;
      case 'languageConnectionError':
        return l10n.languageConnectionError;
      case 'languageApiError':
        return l10n.languageApiError;
      case 'languageHttpError':
        return l10n.languageHttpError;
      default:
        return key; // Return key as fallback
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
                      value: entry.key,
                      // ignore: deprecated_member_use
                      groupValue: selectedSound,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setState(() {
                          selectedSound =
                              value ?? NotificationSettings.soundDefault;
                        });
                      },
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
            SnackBar(
              content: Text('✅ Notification sound updated'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  // Sync languages from server
  Future<void> _syncLanguagesFromServer(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(
              child: Text(l10n.settingsSyncLanguageProgress),
            ),
          ],
        ),
      ),
    );

    try {
      // Sync all languages from server (force sync to ignore cache)
      final syncedLanguages =
          await DynamicLocalizationService.syncAllLanguages(forceSync: true);

      // Reload ALL synced server translations into memory
      // This ensures when user switches language, server translations are ready
      for (final langCode in syncedLanguages) {
        await DynamicAppLocalizations.loadServerTranslations(
          Locale(langCode),
        );
      }

      print(
          '🔄 Loaded ${syncedLanguages.length} languages into memory: ${syncedLanguages.join(", ")}');

      // Reload available languages list to show updated languages
      await _loadAvailableLanguages();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ErrorDialogUtils.showSuccessSnackBar(
          context,
          l10n.settingsSyncLanguageSuccess,
        );

        // Trigger rebuild to apply new translations
        setState(() {});
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        ErrorDialogUtils.showErrorDialog(
          context,
          l10n.settingsSyncLanguageError(e.toString()),
          title: l10n.appError,
        );
      }
    }
  }
}
