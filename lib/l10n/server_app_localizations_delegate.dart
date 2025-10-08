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
      final propertyName = invocation.memberName.toString().split('"')[1];
      
      // Check server translations first
      if (_serverTranslations.containsKey(propertyName)) {
        print('🔵 Using server translation for: $propertyName');
        return _serverTranslations[propertyName];
      }
    }

    // Fallback to built-in by calling on the built-in instance
    return _builtIn.noSuchMethod(invocation);
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
    // First load built-in
    final builtIn = await AppLocalizations.delegate.load(locale);

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
