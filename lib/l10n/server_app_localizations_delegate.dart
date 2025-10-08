import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monitor_app/l10n/app_localizations.dart';
import 'package:monitor_app/services/dynamic_localization_service.dart';

/// Custom AppLocalizations that merges built-in ARB with server translations
/// Uses dynamic member access to intercept all property getters
class ServerAppLocalizations extends AppLocalizations {
  final AppLocalizations _builtIn;
  final Map<String, String> _serverTranslations;

  ServerAppLocalizations(this._builtIn, this._serverTranslations)
      : super(_builtIn.localeName);

  @override
  String get localeName => _builtIn.localeName;

  /// Intercept all property access and check server translations first
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      final symbolName = invocation.memberName.toString();
      // Extract property name from Symbol format: 'Symbol("propertyName")'
      final propertyName = symbolName.substring(8, symbolName.length - 2);

      // Priority 1: Check server translations first
      if (_serverTranslations.containsKey(propertyName)) {
        print('🔵 Using server translation for: $propertyName');
        return _serverTranslations[propertyName];
      }

      // Priority 2: Try to get from built-in ARB by calling the same invocation
      // Wrap in try-catch to handle missing properties gracefully
      try {
        // Call the actual property getter on built-in instance
        // This uses reflection through noSuchMethod but catches the error
        final result = _builtIn.noSuchMethod(invocation);
        print('📦 Using built-in ARB for: $propertyName');
        return result;
      } on NoSuchMethodError {
        // Property doesn't exist in built-in ARB either
        print(
            '⚠️ Translation missing for: $propertyName (returning key as fallback)');
        return propertyName; // Return key name as fallback
      } catch (e) {
        // Other errors
        print('❌ Error getting translation for: $propertyName - $e');
        return propertyName;
      }
    }

    // For non-getter invocations, throw
    return super.noSuchMethod(invocation);
  }
}

/// Custom delegate that creates ServerAppLocalizations
class ServerAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const ServerAppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en', 'ja', 'ko', 'fr', 'de', 'es']
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Try to load built-in for this locale, fallback to English if not available
    AppLocalizations builtIn;
    try {
      builtIn = await AppLocalizations.delegate.load(locale);
    } catch (e) {
      // ARB file doesn't exist for this locale, fallback to English
      print(
          '⚠️ No ARB file for ${locale.languageCode}, using English as fallback');
      builtIn = await AppLocalizations.delegate.load(const Locale('en', ''));
    }

    // Then try to load server translations
    final serverTranslations =
        await DynamicLocalizationService.loadCachedLanguage(
            locale.languageCode);

    if (serverTranslations != null && serverTranslations.isNotEmpty) {
      print(
          '✅ Using ServerAppLocalizations for ${locale.languageCode} (${serverTranslations.length} keys)');
      return ServerAppLocalizations(builtIn, serverTranslations);
    }

    print('📦 Using built-in translations for ${locale.languageCode}');
    return builtIn;
  }

  @override
  bool shouldReload(ServerAppLocalizationsDelegate old) => true;
}
