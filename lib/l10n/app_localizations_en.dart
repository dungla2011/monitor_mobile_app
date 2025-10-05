// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Monitor App';

  @override
  String get appLoading => 'Loading...';

  @override
  String get appError => 'Error';

  @override
  String get appSuccess => 'Success';

  @override
  String get appCancel => 'Cancel';

  @override
  String get appSave => 'Save';

  @override
  String get appAdd => 'Add';

  @override
  String get appEdit => 'Edit';

  @override
  String get appDelete => 'Delete';

  @override
  String get appUpdate => 'Update';

  @override
  String get appBack => 'Back';

  @override
  String get appClose => 'Close';

  @override
  String get appConfirm => 'Confirm';

  @override
  String get appYes => 'Yes';

  @override
  String get appNo => 'No';

  @override
  String get appLoadingData => 'Loading data...';

  @override
  String get appRetry => 'Retry';

  @override
  String get crudInitError => 'Initialization error';

  @override
  String get crudLoadDataError => 'Data loading error';

  @override
  String get crudSessionExpired => 'Session expired';

  @override
  String get crudPleaseLoginAgain => 'Please login again to continue';

  @override
  String get crudDeleteConfirmTitle => 'Confirm deletion';

  @override
  String crudDeleteConfirmMessage(int count) {
    return 'Are you sure you want to delete $count item(s)?';
  }

  @override
  String get crudDeleteSuccess => 'Deleted successfully';

  @override
  String get crudDeleteError => 'Error deleting';

  @override
  String get crudLoadingConfig => 'Loading configuration...';

  @override
  String get crudCannotLoadConfig => 'Cannot load configuration';

  @override
  String get crudLoadConfigError => 'Error loading configuration';

  @override
  String get crudCannotLoadData => 'Cannot load item data';

  @override
  String get crudLoading => 'Loading...';

  @override
  String get crudNoData => 'No data';

  @override
  String get crudAddFirstItem => 'Press + button to add new item';

  @override
  String crudAddFirstButton(String item) {
    return 'Add first $item';
  }

  @override
  String get crudSaveSuccess => 'Saved successfully';

  @override
  String get crudSaveError => 'Error saving';

  @override
  String get crudConnectionError => 'Connection error';

  @override
  String get authLogin => 'Login';

  @override
  String get authLogout => 'Logout';

  @override
  String get authUsername => 'Username';

  @override
  String get authPassword => 'Password';

  @override
  String get authLoginSuccess => 'Login successful';

  @override
  String get authLoginFailed => 'Login failed';

  @override
  String get authPleaseEnterUsername => 'Please enter username';

  @override
  String get authPleaseEnterPassword => 'Please enter password';

  @override
  String get monitorItems => 'Monitor Items';

  @override
  String get monitorConfigs => 'Monitor Alerts';

  @override
  String get monitorAddItem => 'Add Monitor Item';

  @override
  String get monitorEditItem => 'Edit Monitor Item';

  @override
  String get monitorDeleteItem => 'Delete Monitor Item';

  @override
  String get monitorAddConfig => 'Add Monitor Alert';

  @override
  String get monitorEditConfig => 'Edit Monitor Alert';

  @override
  String get monitorDeleteConfig => 'Delete Monitor Alert';

  @override
  String get monitorName => 'Monitor name';

  @override
  String get monitorType => 'Check type';

  @override
  String get monitorUrl => 'Web/Domain/IP Link';

  @override
  String get monitorInterval => 'Check interval';

  @override
  String get monitorAlertConfig => 'Alert configuration';

  @override
  String get monitorEnable => 'Enable monitoring';

  @override
  String get monitorStatus => 'Latest status';

  @override
  String get monitorLastCheck => 'Last check';

  @override
  String get monitorOnline => 'Online';

  @override
  String get monitorOffline => 'Offline';

  @override
  String get monitorAllowConsecutiveAlert =>
      'Allow consecutive alerts on error';

  @override
  String get monitorErrorKeyword => 'Error keyword';

  @override
  String get monitorValidKeyword => 'Valid keyword';

  @override
  String get monitorCreatedAt => 'Created at';

  @override
  String get configAlertType => 'Alert type';

  @override
  String get configAlertConfig => 'Alert configuration';

  @override
  String get configEmail => 'Send Email';

  @override
  String get configSms => 'Send SMS';

  @override
  String get configTelegram => 'Send Telegram';

  @override
  String get configWebhook => 'Call Webhook';

  @override
  String get configSelectAlertType => 'Select alert type';

  @override
  String validationRequired(String field) {
    return 'Please enter $field';
  }

  @override
  String validationPleaseSelect(String field) {
    return 'Please select $field';
  }

  @override
  String validationPleaseSelectAtLeastOne(String field) {
    return 'Please select at least one $field';
  }

  @override
  String validationInvalidFormat(String field) {
    return 'Invalid $field format';
  }

  @override
  String get messagesSaveSuccess => 'Saved successfully';

  @override
  String get messagesSaveFailed => 'Save failed';

  @override
  String get messagesDeleteSuccess => 'Deleted successfully';

  @override
  String get messagesDeleteFailed => 'Delete failed';

  @override
  String messagesDeleteConfirm(String item) {
    return 'Are you sure you want to delete $item?';
  }

  @override
  String get messagesNetworkError => 'Network error';

  @override
  String get messagesServerError => 'Server error';

  @override
  String get messagesUnknownError => 'Unknown error';

  @override
  String messagesLoadingSettingsError(String error) {
    return 'Error loading settings: $error';
  }

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationMonitorItems => 'Monitor Items';

  @override
  String get navigationMonitorConfigs => 'Monitor Configs';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get navigationNotifications => 'Notifications';

  @override
  String get navigationAbout => 'About';

  @override
  String get navigationWelcome => 'Welcome!';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDescription => 'Choose your preferred language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDescription =>
      'Manage notification preferences';

  @override
  String get settingsNotificationSettings => 'Notification Settings';

  @override
  String get settingsEnableNotifications => 'Enable notifications';

  @override
  String get settingsEnableNotificationsDesc =>
      'Receive notifications from app';

  @override
  String get settingsNotificationSound => 'Notification sound';

  @override
  String get settingsNotificationSoundNotSelected => 'Not selected';

  @override
  String get settingsVibrate => 'Vibrate';

  @override
  String get settingsVibrateDesc => 'Vibrate on notification';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDescription => 'Choose app appearance';

  @override
  String get settingsAbout => 'About App';

  @override
  String get settingsAboutDescription => 'Version and app information';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsVietnamese => 'Vietnamese';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsAppInfo => 'App Information';

  @override
  String get settingsAppName => 'App Name';

  @override
  String get settingsVietnameseDesc => 'Tiếng Việt (Vietnamese)';

  @override
  String get settingsEnglishDesc => 'English (default)';

  @override
  String get settingsFrenchDesc => 'Français (French)';

  @override
  String get settingsGermanDesc => 'Deutsch (German)';

  @override
  String get settingsSpanishDesc => 'Español (Spanish)';

  @override
  String get settingsJapaneseDesc => '日本語 (Japanese)';

  @override
  String get settingsKoreanDesc => '한국어 (Korean)';

  @override
  String get languageAlreadySelected => 'Language already selected';

  @override
  String get languageUpdateSuccess => 'Language updated successfully';

  @override
  String get languageChangedNotSynced =>
      'Language changed (not synced to server)';

  @override
  String get languageChangeError => 'Error changing language';

  @override
  String get languageUserNotLoggedIn => 'User not logged in';

  @override
  String get languageSessionExpired => 'Session expired';

  @override
  String get languageConnectionError => 'Connection error';

  @override
  String get languageApiError => 'API error';

  @override
  String get languageHttpError => 'HTTP Error';

  @override
  String get notificationSoundDefault => 'Default (System)';

  @override
  String get notificationSoundNone => 'None (Silent)';

  @override
  String get notificationSoundAlert => 'Alert';

  @override
  String get notificationSoundGentle => 'Gentle';

  @override
  String get notificationSoundUrgent => 'Urgent';

  @override
  String get notificationSoundSelectTitle => 'Select notification sound';

  @override
  String get notificationSoundPreview => 'Preview';

  @override
  String get mobileActionNavigatingToConfig =>
      'Navigating to Monitor Config...';

  @override
  String get mobileActionNavigatingToItems => 'Navigating to Monitor Items...';

  @override
  String mobileActionCommandNotFound(String cmd) {
    return 'Command not found: \"$cmd\"';
  }

  @override
  String get timeSeconds => 'Seconds';

  @override
  String get timeMinutes => 'Minutes';

  @override
  String get timeHours => 'Hours';

  @override
  String get timeDays => 'Days';

  @override
  String get timeSelectTime => 'Select time';

  @override
  String get timeClearTime => 'Clear time';

  @override
  String get timeNotSelected => 'Time not selected';

  @override
  String get timeSecond => 'second';

  @override
  String get timeMinute => 'minute';

  @override
  String get timeHour => 'hour';

  @override
  String get timeDay => 'day';

  @override
  String get timeMin => 'min';

  @override
  String get timeMins => 'mins';

  @override
  String get timeAgo => 'ago';

  @override
  String get optionsSelect => '-Select-';

  @override
  String get optionsSelectAlertType => '-Select Alert Type-';

  @override
  String get optionsWebContent => 'Web Server Active';

  @override
  String get optionsPing => 'Ping';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileEditProfileTooltip => 'Edit profile';

  @override
  String get profileDisplayName => 'Display Name';

  @override
  String get profileNoName => 'No name';

  @override
  String get profileNoUsername => 'No username';

  @override
  String get profileNoEmail => 'No email';

  @override
  String get profileLoggedIn => 'Logged in';

  @override
  String get profileLoginInfo => 'Login Information';

  @override
  String get profileLoginMethod => 'Login method';

  @override
  String get profileLoginTime => 'Login time';

  @override
  String get profileBearerToken => 'Bearer Token';

  @override
  String get profileActions => 'Actions';

  @override
  String get profileRefreshInfo => 'Refresh information';

  @override
  String get profileRefreshInfoDesc => 'Update latest information';

  @override
  String get profileLogoutDesc => 'Sign out of account';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileLoggingOut => 'Signing out...';

  @override
  String get profileLogoutSuccess => '✅ Signed out successfully';

  @override
  String profileLogoutError(String error) {
    return '❌ Error signing out: $error';
  }

  @override
  String profileLoadError(String error) {
    return 'Error loading information: $error';
  }

  @override
  String get profileUpdateNotSupported =>
      'Profile update feature is not yet supported';

  @override
  String get profileLoginMethodWebApi => 'Web API (Username & Password)';

  @override
  String get profileLoginMethodEmail => 'Email & Password';

  @override
  String get profileLoginMethodUnknown => 'Unknown';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutAppVersion => 'Monitor App v1.0.0';

  @override
  String get aboutCopyright => 'GalaxyCloud © 2025';

  @override
  String get aboutDescription =>
      'Application for monitoring and managing your services.';

  @override
  String get aboutDeveloper => 'Developed by GalaxyCloud.vn';

  @override
  String get errorDialogTitle => 'Error';

  @override
  String get errorDialogDetails => 'Error details:';

  @override
  String get errorDialogHints => 'Hints:';

  @override
  String get errorDialogHintsEmail => 'Email hints:';

  @override
  String get errorDialogHintEmailValid =>
      'Email must be in valid format (e.g.: user@domain.com)';

  @override
  String get errorDialogHintEmailMultiple =>
      'Multiple emails separated by commas';

  @override
  String get errorDialogHintEmailNoSpace => 'Should not contain extra spaces';

  @override
  String get errorDialogHintsUrl => 'URL hints:';

  @override
  String get errorDialogHintUrlValid =>
      'URL must be in valid format (e.g.: https://example.com)';

  @override
  String get errorDialogHintUrlProtocol =>
      'Must start with http:// or https://';

  @override
  String get errorDialogHintUrlNoSpecial =>
      'Should not contain invalid special characters';

  @override
  String get errorDialogHintsPassword => 'Password hints:';

  @override
  String get errorDialogHintPasswordLength =>
      'Password must be at least 8 characters';

  @override
  String get errorDialogHintPasswordMix =>
      'Should contain uppercase, lowercase, and numbers';

  @override
  String get errorDialogHintPasswordNoSpace => 'Should not contain spaces';

  @override
  String get errorDialogHintRequired1 => 'Please fill in all required fields';

  @override
  String get errorDialogHintRequired2 => 'Fields with (*) are required';

  @override
  String get errorDialogHintRequired3 => 'Check form before submitting';

  @override
  String get errorDialogHintDuplicate1 =>
      'This value already exists in the system';

  @override
  String get errorDialogHintDuplicate2 => 'Please choose a different value';

  @override
  String get errorDialogHintDuplicate3 =>
      'Check existing list before adding new';

  @override
  String get httpErrorTechnical => 'Technical details';

  @override
  String get httpErrorSuggestions => 'Suggestions:';

  @override
  String get httpErrorClose => 'Close';

  @override
  String get httpErrorRetry => 'Retry';

  @override
  String get httpError400Title => 'Bad Request';

  @override
  String get httpError400Desc =>
      'The data sent to the server is not in the correct format or missing required information.';

  @override
  String get httpError400Hint1 => 'Check all information fields';

  @override
  String get httpError400Hint2 =>
      'Ensure email, URL, phone number are in correct format';

  @override
  String get httpError400Hint3 => 'Do not leave required fields empty';

  @override
  String get httpError401Title => 'Not Logged In';

  @override
  String get httpError401Desc =>
      'Session has expired or you are not logged in to the system.';

  @override
  String get httpError401Hint1 => 'Please log in again';

  @override
  String get httpError401Hint2 => 'Check network connection';

  @override
  String get httpError401Hint3 =>
      'Contact administrator if the problem persists';

  @override
  String get httpError403Title => 'Access Denied';

  @override
  String get httpError403Desc =>
      'You do not have permission to perform this operation. Please contact administrator.';

  @override
  String get httpError403Hint1 => 'Contact administrator for permission';

  @override
  String get httpError403Hint2 =>
      'Log in with an account that has appropriate permissions';

  @override
  String get httpError404Title => 'Not Found';

  @override
  String get httpError404Desc =>
      'The requested resource does not exist or has been deleted.';

  @override
  String get httpError404Hint1 => 'Check URL or ID again';

  @override
  String get httpError404Hint2 => 'Refresh list and try again';

  @override
  String get httpError404Hint3 => 'Data may have been deleted earlier';

  @override
  String get httpError408Title => 'Timeout';

  @override
  String get httpError408Desc => 'Request took too long. Please try again.';

  @override
  String get httpError408Hint1 => 'Check internet connection';

  @override
  String get httpError408Hint2 => 'Try again after a few seconds';

  @override
  String get httpError408Hint3 => 'Contact support if error repeats';

  @override
  String get httpError429Title => 'Too Many Requests';

  @override
  String get httpError429Desc =>
      'You have sent too many requests in a short time. Please wait and try again.';

  @override
  String get httpError429Hint1 => 'Wait a few minutes before trying again';

  @override
  String get httpError429Hint2 => 'Avoid sending requests continuously';

  @override
  String get httpError500Title => 'Server Error';

  @override
  String get httpError500Desc =>
      'Server encountered an error while processing the request. Please try again later.';

  @override
  String get httpError500Hint1 => 'Wait a few minutes then try again';

  @override
  String get httpError500Hint2 => 'Contact technical support if error persists';

  @override
  String get httpError500Hint3 => 'Save important data before retrying';

  @override
  String get httpError503Title => 'Service Temporarily Unavailable';

  @override
  String get httpError503Desc =>
      'Server is under maintenance or overloaded. Please try again later.';

  @override
  String get httpError503Hint1 => 'Try again after 5-10 minutes';

  @override
  String get httpError503Hint2 =>
      'Check maintenance notifications from administrator';

  @override
  String get httpError503Hint3 => 'Contact technical support if urgent';

  @override
  String get httpErrorDefaultTitle => 'Unknown Error';

  @override
  String get httpErrorDefaultDesc =>
      'An unexpected error occurred. Please try again or contact support.';

  @override
  String get httpErrorDefaultHint1 => 'Try again after a few minutes';

  @override
  String get httpErrorDefaultHint2 => 'Check internet connection';

  @override
  String httpErrorDefaultHint3(Object code) {
    return 'Contact support with error code $code';
  }

  @override
  String get filterTitle => 'Filters';

  @override
  String get filterByName => 'Filter by name';

  @override
  String get filterNameHint => 'Enter name to search...';

  @override
  String get filterByStatus => 'Filter by status';

  @override
  String get filterShowError => 'Show OFFLINE monitors';

  @override
  String get filterShowErrorDesc => 'Items with OFFLINE';

  @override
  String get filterShowSuccess => 'Show ONLINE monitors';

  @override
  String get filterShowSuccessDesc => 'Items with ONLINE';

  @override
  String get filterByEnableStatus => 'Filter by enable status';

  @override
  String get filterShowEnabled => 'Show enabled monitors';

  @override
  String get filterShowEnabledDesc => 'Items with enable = 1';

  @override
  String get filterShowDisabled => 'Show disabled monitors';

  @override
  String get filterShowDisabledDesc => 'Items with enable = 0';

  @override
  String get filterResetAll => 'Reset All';

  @override
  String get filterOk => 'OK';

  @override
  String get filterClear => 'Clear';

  @override
  String get filterShowing => 'Showing';

  @override
  String get filterOf => 'of';

  @override
  String get filterItems => 'items';

  @override
  String get filterName => 'Name:';

  @override
  String get filterErrorItems => 'Error items';

  @override
  String get filterSuccessItems => 'Success items';

  @override
  String get filterEnabledItems => 'Enabled items';

  @override
  String get filterDisabledItems => 'Disabled items';

  @override
  String get filterNoMatch => 'No items match the filter';

  @override
  String get filterClearFilters => 'Clear filters';
}
