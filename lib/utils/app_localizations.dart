import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    // Load the language JSON file from the "assets/translations" folder
    String jsonString = await rootBundle
        .loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap;

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key, {Map<String, String>? params}) {
    String? value = _getNestedValue(_localizedStrings, key);

    if (value == null) {
      return '**$key**'; // Return key with ** if not found for debugging
    }

    // Replace parameters if provided
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value!.replaceAll('{$paramKey}', paramValue);
      });
    }

    return value!;
  }

  // Helper method to get nested values from JSON
  String? _getNestedValue(Map<String, dynamic> map, String key) {
    List<String> keys = key.split('.');
    dynamic current = map;

    for (String k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return null;
      }
    }

    return current?.toString();
  }

  // Convenience methods for common translations
  String get appTitle => translate('app.title');
  String get loading => translate('app.loading');
  String get error => translate('app.error');
  String get success => translate('app.success');
  String get cancel => translate('app.cancel');
  String get save => translate('app.save');
  String get add => translate('app.add');
  String get edit => translate('app.edit');
  String get delete => translate('app.delete');
  String get update => translate('app.update');
  String get back => translate('app.back');
  String get close => translate('app.close');
  String get confirm => translate('app.confirm');
  String get yes => translate('app.yes');
  String get no => translate('app.no');

  // Auth translations
  String get login => translate('auth.login');
  String get logout => translate('auth.logout');
  String get username => translate('auth.username');
  String get password => translate('auth.password');
  String get loginSuccess => translate('auth.loginSuccess');
  String get loginFailed => translate('auth.loginFailed');
  String get pleaseEnterUsername => translate('auth.pleaseEnterUsername');
  String get pleaseEnterPassword => translate('auth.pleaseEnterPassword');

  // Monitor translations
  String get monitorItems => translate('monitor.items');
  String get monitorConfigs => translate('monitor.configs');
  String get addMonitorItem => translate('monitor.addItem');
  String get editMonitorItem => translate('monitor.editItem');
  String get deleteMonitorItem => translate('monitor.deleteItem');
  String get addMonitorConfig => translate('monitor.addConfig');
  String get editMonitorConfig => translate('monitor.editConfig');
  String get deleteMonitorConfig => translate('monitor.deleteConfig');
  String get monitorName => translate('monitor.name');
  String get monitorType => translate('monitor.type');
  String get monitorUrl => translate('monitor.url');
  String get monitorInterval => translate('monitor.interval');
  String get monitorAlertConfig => translate('monitor.alertConfig');
  String get monitorEnable => translate('monitor.enable');
  String get monitorStatus => translate('monitor.status');
  String get monitorLastCheck => translate('monitor.lastCheck');
  String get monitorOnline => translate('monitor.online');
  String get monitorOffline => translate('monitor.offline');
  String get monitorAllowConsecutiveAlert =>
      translate('monitor.allowConsecutiveAlert');
  String get monitorErrorKeyword => translate('monitor.errorKeyword');
  String get monitorValidKeyword => translate('monitor.validKeyword');
  String get monitorCreatedAt => translate('monitor.createdAt');

  // Config translations
  String get configAlertType => translate('config.alertType');
  String get configAlertConfig => translate('config.alertConfig');
  String get configEmail => translate('config.email');
  String get configSms => translate('config.sms');
  String get configTelegram => translate('config.telegram');
  String get configWebhook => translate('config.webhook');
  String get configSelectAlertType => translate('config.selectAlertType');

  // Validation translations
  String required(String field) =>
      translate('validation.required', params: {'field': field});
  String pleaseSelect(String field) =>
      translate('validation.pleaseSelect', params: {'field': field});
  String pleaseSelectAtLeastOne(String field) =>
      translate('validation.pleaseSelectAtLeastOne', params: {'field': field});
  String invalidFormat(String field) =>
      translate('validation.invalidFormat', params: {'field': field});

  // Message translations
  String get saveSuccess => translate('messages.saveSuccess');
  String get saveFailed => translate('messages.saveFailed');
  String get deleteSuccess => translate('messages.deleteSuccess');
  String get deleteFailed => translate('messages.deleteFailed');
  String deleteConfirm(String item) =>
      translate('messages.deleteConfirm', params: {'item': item});
  String get networkError => translate('messages.networkError');
  String get serverError => translate('messages.serverError');
  String get unknownError => translate('messages.unknownError');

  // Navigation translations
  String get navHome => translate('navigation.home');
  String get navMonitorItems => translate('navigation.monitorItems');
  String get navMonitorConfigs => translate('navigation.monitorConfigs');
  String get navProfile => translate('navigation.profile');
  String get navSettings => translate('navigation.settings');

  // Mobile Action translations
  String get mobileActionNavigatingToConfig =>
      translate('mobileAction.navigatingToConfig');
  String get mobileActionNavigatingToItems =>
      translate('mobileAction.navigatingToItems');
  String mobileActionCommandNotFound(String cmd) =>
      translate('mobileAction.commandNotFound', params: {'cmd': cmd});

  // Time translations
  String get timeSeconds => translate('time.seconds');
  String get timeMinutes => translate('time.minutes');
  String get timeHours => translate('time.hours');
  String get timeDays => translate('time.days');
  String get timeSelectTime => translate('time.selectTime');
  String get timeClearTime => translate('time.clearTime');
  String get timeNotSelected => translate('time.notSelected');

  // Options translations
  String get optionsSelect => translate('options.select');
  String get optionsSelectAlertType => translate('options.selectAlertType');
  String get optionsWebContent => translate('options.webContent');
  String get optionsPing => translate('options.ping');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
