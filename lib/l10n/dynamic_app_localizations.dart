import 'package:flutter/material.dart';
import 'package:monitor_app/l10n/app_localizations.dart';
import 'package:monitor_app/services/dynamic_localization_service.dart';

/// Wrapper for AppLocalizations that adds server translations
class DynamicAppLocalizations {
  static Map<String, Map<String, String>> _serverTranslations = {};

  /// Load server translations for a locale
  static Future<void> loadServerTranslations(Locale locale) async {
    print('🌐 Loading server translations for ${locale.languageCode}');

    final translations = await DynamicLocalizationService.loadCachedLanguage(
      locale.languageCode,
    );

    if (translations != null && translations.isNotEmpty) {
      _serverTranslations[locale.languageCode] = translations;
      print(
        '✅ Loaded ${translations.length} server translations for ${locale.languageCode}',
      );
    }
  }

  /// Get server translation or fallback to built-in
  static String? getServerTranslation(String languageCode, String key) {
    return _serverTranslations[languageCode]?[key];
  }

  /// Check if has server translations
  static bool hasServerTranslations(String languageCode) {
    return _serverTranslations.containsKey(languageCode) &&
        _serverTranslations[languageCode]!.isNotEmpty;
  }

  /// Clear all server translations
  static void clearServerTranslations() {
    _serverTranslations.clear();
  }

  /// Reload server translations (call after sync)
  static Future<void> reloadTranslations(Locale locale) async {
    _serverTranslations.remove(locale.languageCode);
    await loadServerTranslations(locale);
  }
}

/// Extension to add server translation lookup to AppLocalizations
extension DynamicAppLocalizationsExtension on AppLocalizations {
  /// Try to get translation from server, fallback to built-in
  String t(String key, String Function() builtInGetter) {
    final serverValue =
        DynamicAppLocalizations.getServerTranslation(localeName, key);
    if (serverValue != null) {
      return serverValue;
    }
    return builtInGetter();
  }
}

