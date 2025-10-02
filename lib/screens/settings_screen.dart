import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_localizations.dart';
import '../utils/language_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                                  await _changeLanguage(
                                      context, languageManager, Locale(value, ''));
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
}
