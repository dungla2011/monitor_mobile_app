import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monitor_app/l10n/app_localizations.dart';
import 'package:monitor_app/l10n/app_localizations_en.dart';
import 'package:monitor_app/services/dynamic_localization_service.dart';

/// Custom AppLocalizations that merges built-in ARB with server translations
/// Uses dynamic member access to intercept all property getters
class ServerAppLocalizations extends AppLocalizations {
  final AppLocalizations _builtIn;
  final Map<String, String> _serverTranslations;
  final Map<String, String> _serverTranslationsEN;
  static final AppLocalizationsEn _enFallback = AppLocalizationsEn();

  ServerAppLocalizations(
    this._builtIn,
    this._serverTranslations,
    this._serverTranslationsEN,
  ) : super(_builtIn.localeName);

  @override
  String get localeName => _builtIn.localeName;

  // Override methods with parameters to use built-in implementation
  @override
  String crudDeleteConfirmMessage(int count) =>
      _builtIn.crudDeleteConfirmMessage(count);

  @override
  String crudAddFirstButton(String item) => _builtIn.crudAddFirstButton(item);

  @override
  String validationRequired(String field) => _builtIn.validationRequired(field);

  @override
  String validationPleaseSelect(String field) =>
      _builtIn.validationPleaseSelect(field);

  @override
  String validationPleaseSelectAtLeastOne(String field) =>
      _builtIn.validationPleaseSelectAtLeastOne(field);

  @override
  String validationInvalidFormat(String field) =>
      _builtIn.validationInvalidFormat(field);

  @override
  String messagesDeleteConfirm(String item) =>
      _builtIn.messagesDeleteConfirm(item);

  @override
  String messagesLoadingSettingsError(String error) =>
      _builtIn.messagesLoadingSettingsError(error);

  @override
  String settingsSyncLanguageError(String error) =>
      _builtIn.settingsSyncLanguageError(error);

  @override
  String mobileActionCommandNotFound(String cmd) =>
      _builtIn.mobileActionCommandNotFound(cmd);

  @override
  String profileLogoutError(String error) => _builtIn.profileLogoutError(error);

  @override
  String profileLoadError(String error) => _builtIn.profileLoadError(error);

  @override
  String httpErrorDefaultHint3(Object code) =>
      _builtIn.httpErrorDefaultHint3(code);

  // Override new registration getters to check server translations first
  @override
  String get authRegisterNewAccount {
    final serverValue = _serverTranslations['authRegisterNewAccount'];
    if (serverValue != null) {
      print('🔵 Using server translation for: authRegisterNewAccount');
      return serverValue;
    }
    print(
        '📦 Using built-in ARB for: authRegisterNewAccount = ${_builtIn.authRegisterNewAccount}');
    return _builtIn.authRegisterNewAccount;
  }

  @override
  String get authRegisterDescription {
    final serverValue = _serverTranslations['authRegisterDescription'];
    if (serverValue != null) {
      print('🔵 Using server translation for: authRegisterDescription');
      return serverValue;
    }
    print(
        '📦 Using built-in ARB for: authRegisterDescription = ${_builtIn.authRegisterDescription}');
    return _builtIn.authRegisterDescription;
  }

  @override
  String get authOpenRegistrationPage {
    final serverValue = _serverTranslations['authOpenRegistrationPage'];
    if (serverValue != null) {
      print('🔵 Using server translation for: authOpenRegistrationPage');
      return serverValue;
    }
    print(
        '📦 Using built-in ARB for: authOpenRegistrationPage = ${_builtIn.authOpenRegistrationPage}');
    return _builtIn.authOpenRegistrationPage;
  }

  @override
  String get authAfterRegistration {
    final serverValue = _serverTranslations['authAfterRegistration'];
    if (serverValue != null) {
      print('🔵 Using server translation for: authAfterRegistration');
      return serverValue;
    }
    print(
        '📦 Using built-in ARB for: authAfterRegistration = ${_builtIn.authAfterRegistration}');
    return _builtIn.authAfterRegistration;
  }

  @override
  String get authCouldNotOpenRegistration {
    final serverValue = _serverTranslations['authCouldNotOpenRegistration'];
    if (serverValue != null) {
      print('🔵 Using server translation for: authCouldNotOpenRegistration');
      return serverValue;
    }
    print(
        '📦 Using built-in ARB for: authCouldNotOpenRegistration = ${_builtIn.authCouldNotOpenRegistration}');
    return _builtIn.authCouldNotOpenRegistration;
  }

  /// Intercept all property access and check server translations first
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      final symbolName = invocation.memberName.toString();
      // Extract property name from Symbol format: 'Symbol("propertyName")'
      final propertyName = symbolName.substring(8, symbolName.length - 2);

      // Priority 1: Check server translations for current language
      try {
        if (_serverTranslations.containsKey(propertyName)) {
          print('🔵 Using server translation for: $propertyName');
          return _serverTranslations[propertyName];
        }
      } catch (e) {
        print('❌ Error checking server translations: $e');
      }

      // Priority 2: Try to get from built-in ARB (current language)
      try {
        final result = _builtIn.noSuchMethod(invocation);
        print('📦 Using built-in ARB for: $propertyName');
        return result;
      } on NoSuchMethodError {
        // Not found in current language, fallback to EN
      } catch (e) {
        print('❌ Error getting translation for: $propertyName - $e');
      }

      // Priority 3: Fallback to server EN translations
      try {
        if (_serverTranslationsEN.containsKey(propertyName)) {
          print('🔄 Fallback to server EN for: $propertyName');
          return _serverTranslationsEN[propertyName];
        }
      } catch (e) {
        print('❌ Error checking EN server translations: $e');
      }

      // Priority 4: Fallback to built-in EN (AppLocalizationsEn)
      try {
        final result = _enFallback.noSuchMethod(invocation);
        print('� Fallback to built-in EN for: $propertyName');
        return result;
      } on NoSuchMethodError {
        // Property doesn't exist anywhere
        print('⚠️ Translation missing everywhere for: $propertyName (returning key)');
        return propertyName; // Return key name as last resort
      } catch (e) {
        print('❌ Error fallback EN for: $propertyName - $e');
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
    // Support all language codes - no hardcoded list
    // This allows dynamic languages from server to work
    return true;
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

    // Load server translations for current language
    final serverTranslations =
        await DynamicLocalizationService.loadCachedLanguage(
            locale.languageCode);

    // Always load EN translations as fallback
    final serverTranslationsEN =
        await DynamicLocalizationService.loadCachedLanguage('en');

    if (serverTranslations != null && serverTranslations.isNotEmpty) {
      print(
          '✅ Using ServerAppLocalizations for ${locale.languageCode} (${serverTranslations.length} keys)');
      return ServerAppLocalizations(
        builtIn,
        serverTranslations,
        serverTranslationsEN ?? {},
      );
    }

    // If no server translations, still create ServerAppLocalizations with EN fallback
    print('📦 Using built-in translations for ${locale.languageCode} with EN fallback');
    return ServerAppLocalizations(
      builtIn,
      {},
      serverTranslationsEN ?? {},
    );
  }

  @override
  bool shouldReload(ServerAppLocalizationsDelegate old) => true;
}
