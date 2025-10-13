import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Ping365'**
  String get appTitle;

  /// No description provided for @appLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get appLoading;

  /// No description provided for @appError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get appError;

  /// No description provided for @appSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get appSuccess;

  /// No description provided for @appCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get appCancel;

  /// No description provided for @appSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get appSave;

  /// No description provided for @appAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get appAdd;

  /// No description provided for @appEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get appEdit;

  /// No description provided for @appDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get appDelete;

  /// No description provided for @appUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get appUpdate;

  /// No description provided for @appBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get appBack;

  /// No description provided for @appClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get appClose;

  /// No description provided for @appConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get appConfirm;

  /// No description provided for @appYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get appYes;

  /// No description provided for @appNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get appNo;

  /// No description provided for @appLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get appLoadingData;

  /// No description provided for @appRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get appRetry;

  /// No description provided for @crudInitError.
  ///
  /// In en, this message translates to:
  /// **'Initialization error'**
  String get crudInitError;

  /// No description provided for @crudLoadDataError.
  ///
  /// In en, this message translates to:
  /// **'Data loading error'**
  String get crudLoadDataError;

  /// No description provided for @crudSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get crudSessionExpired;

  /// No description provided for @crudPleaseLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Please login again to continue'**
  String get crudPleaseLoginAgain;

  /// No description provided for @crudDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get crudDeleteConfirmTitle;

  /// No description provided for @crudDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} item(s)?'**
  String crudDeleteConfirmMessage(int count);

  /// No description provided for @crudDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get crudDeleteSuccess;

  /// No description provided for @crudDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting'**
  String get crudDeleteError;

  /// No description provided for @crudLoadingConfig.
  ///
  /// In en, this message translates to:
  /// **'Loading configuration...'**
  String get crudLoadingConfig;

  /// No description provided for @crudCannotLoadConfig.
  ///
  /// In en, this message translates to:
  /// **'Cannot load configuration'**
  String get crudCannotLoadConfig;

  /// No description provided for @crudLoadConfigError.
  ///
  /// In en, this message translates to:
  /// **'Error loading configuration'**
  String get crudLoadConfigError;

  /// No description provided for @crudCannotLoadData.
  ///
  /// In en, this message translates to:
  /// **'Cannot load item data'**
  String get crudCannotLoadData;

  /// No description provided for @crudLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get crudLoading;

  /// No description provided for @crudNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get crudNoData;

  /// No description provided for @crudAddFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Press + button to add new item'**
  String get crudAddFirstItem;

  /// No description provided for @crudAddFirstButton.
  ///
  /// In en, this message translates to:
  /// **'Add first {item}'**
  String crudAddFirstButton(String item);

  /// No description provided for @crudSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get crudSaveSuccess;

  /// No description provided for @crudSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving'**
  String get crudSaveError;

  /// No description provided for @crudConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get crudConnectionError;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get authLogout;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get authLoginSuccess;

  /// No description provided for @authLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get authLoginFailed;

  /// No description provided for @authPleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get authPleaseEnterUsername;

  /// No description provided for @authPleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get authPleaseEnterPassword;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Login with'**
  String get authLoginWith;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get authForgotPassword;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// No description provided for @authPleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get authPleaseEnterFullName;

  /// No description provided for @authLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get authLogoutConfirm;

  /// No description provided for @authLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get authLoggingOut;

  /// No description provided for @authLogoutError.
  ///
  /// In en, this message translates to:
  /// **'Logout error'**
  String get authLogoutError;

  /// No description provided for @authRegisterNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Register New Account'**
  String get authRegisterNewAccount;

  /// No description provided for @authRegisterDescription.
  ///
  /// In en, this message translates to:
  /// **'Click the button below to open the registration page in your browser'**
  String get authRegisterDescription;

  /// No description provided for @authOpenRegistrationPage.
  ///
  /// In en, this message translates to:
  /// **'Open Registration Page'**
  String get authOpenRegistrationPage;

  /// No description provided for @authAfterRegistration.
  ///
  /// In en, this message translates to:
  /// **'After registration, return here to login'**
  String get authAfterRegistration;

  /// No description provided for @authCouldNotOpenRegistration.
  ///
  /// In en, this message translates to:
  /// **'Could not open registration page'**
  String get authCouldNotOpenRegistration;

  /// No description provided for @monitorItems.
  ///
  /// In en, this message translates to:
  /// **'Ping Items'**
  String get monitorItems;

  /// No description provided for @monitorConfigs.
  ///
  /// In en, this message translates to:
  /// **'Monitor Alerts'**
  String get monitorConfigs;

  /// No description provided for @monitorAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Ping Item'**
  String get monitorAddItem;

  /// No description provided for @monitorEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Ping Item'**
  String get monitorEditItem;

  /// No description provided for @monitorDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Ping Item'**
  String get monitorDeleteItem;

  /// No description provided for @monitorAddConfig.
  ///
  /// In en, this message translates to:
  /// **'Add Monitor Alert'**
  String get monitorAddConfig;

  /// No description provided for @monitorEditConfig.
  ///
  /// In en, this message translates to:
  /// **'Edit Monitor Alert'**
  String get monitorEditConfig;

  /// No description provided for @monitorDeleteConfig.
  ///
  /// In en, this message translates to:
  /// **'Delete Monitor Alert'**
  String get monitorDeleteConfig;

  /// No description provided for @monitorName.
  ///
  /// In en, this message translates to:
  /// **'Monitor name'**
  String get monitorName;

  /// No description provided for @monitorType.
  ///
  /// In en, this message translates to:
  /// **'Check type'**
  String get monitorType;

  /// No description provided for @monitorUrl.
  ///
  /// In en, this message translates to:
  /// **'Web/Domain/IP Link'**
  String get monitorUrl;

  /// No description provided for @monitorInterval.
  ///
  /// In en, this message translates to:
  /// **'Check interval'**
  String get monitorInterval;

  /// No description provided for @monitorAlertConfig.
  ///
  /// In en, this message translates to:
  /// **'Alert configuration'**
  String get monitorAlertConfig;

  /// No description provided for @monitorEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable monitoring'**
  String get monitorEnable;

  /// No description provided for @monitorStatus.
  ///
  /// In en, this message translates to:
  /// **'Latest status'**
  String get monitorStatus;

  /// No description provided for @monitorLastCheck.
  ///
  /// In en, this message translates to:
  /// **'Last check'**
  String get monitorLastCheck;

  /// No description provided for @monitorOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get monitorOnline;

  /// No description provided for @monitorOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get monitorOffline;

  /// No description provided for @monitorAllowConsecutiveAlert.
  ///
  /// In en, this message translates to:
  /// **'Allow consecutive alerts on error'**
  String get monitorAllowConsecutiveAlert;

  /// No description provided for @monitorErrorKeyword.
  ///
  /// In en, this message translates to:
  /// **'Error keyword'**
  String get monitorErrorKeyword;

  /// No description provided for @monitorValidKeyword.
  ///
  /// In en, this message translates to:
  /// **'Valid keyword'**
  String get monitorValidKeyword;

  /// No description provided for @monitorCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get monitorCreatedAt;

  /// No description provided for @configAlertType.
  ///
  /// In en, this message translates to:
  /// **'Alert type'**
  String get configAlertType;

  /// No description provided for @configAlertConfig.
  ///
  /// In en, this message translates to:
  /// **'Alert configuration'**
  String get configAlertConfig;

  /// No description provided for @configEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get configEmail;

  /// No description provided for @configSms.
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get configSms;

  /// No description provided for @configTelegram.
  ///
  /// In en, this message translates to:
  /// **'Send Telegram'**
  String get configTelegram;

  /// No description provided for @configWebhook.
  ///
  /// In en, this message translates to:
  /// **'Call Webhook'**
  String get configWebhook;

  /// No description provided for @configSelectAlertType.
  ///
  /// In en, this message translates to:
  /// **'Select alert type'**
  String get configSelectAlertType;

  /// Validation message for required fields
  ///
  /// In en, this message translates to:
  /// **'Please enter {field}'**
  String validationRequired(String field);

  /// No description provided for @validationPleaseSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select {field}'**
  String validationPleaseSelect(String field);

  /// No description provided for @validationPleaseSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one {field}'**
  String validationPleaseSelectAtLeastOne(String field);

  /// No description provided for @validationInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid {field} format'**
  String validationInvalidFormat(String field);

  /// No description provided for @messagesSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get messagesSaveSuccess;

  /// No description provided for @messagesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get messagesSaveFailed;

  /// No description provided for @messagesDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get messagesDeleteSuccess;

  /// No description provided for @messagesDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get messagesDeleteFailed;

  /// No description provided for @messagesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {item}?'**
  String messagesDeleteConfirm(String item);

  /// No description provided for @messagesNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get messagesNetworkError;

  /// No description provided for @messagesServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get messagesServerError;

  /// No description provided for @messagesUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get messagesUnknownError;

  /// No description provided for @messagesLoadingSettingsError.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings: {error}'**
  String messagesLoadingSettingsError(String error);

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationMonitorItems.
  ///
  /// In en, this message translates to:
  /// **'Ping Items'**
  String get navigationMonitorItems;

  /// No description provided for @navigationMonitorConfigs.
  ///
  /// In en, this message translates to:
  /// **'Monitor Configs'**
  String get navigationMonitorConfigs;

  /// No description provided for @navigationProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// No description provided for @navigationSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// No description provided for @navigationNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navigationNotifications;

  /// No description provided for @navigationAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navigationAbout;

  /// No description provided for @navigationWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get navigationWelcome;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage notification preferences'**
  String get settingsNotificationsDescription;

  /// No description provided for @settingsNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get settingsNotificationSettings;

  /// No description provided for @settingsEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get settingsEnableNotifications;

  /// No description provided for @settingsEnableNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications from app'**
  String get settingsEnableNotificationsDesc;

  /// No description provided for @settingsNotificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification sound'**
  String get settingsNotificationSound;

  /// No description provided for @settingsNotificationSoundNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get settingsNotificationSoundNotSelected;

  /// No description provided for @settingsVibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get settingsVibrate;

  /// No description provided for @settingsVibrateDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on notification'**
  String get settingsVibrateDesc;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose app appearance'**
  String get settingsThemeDescription;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Version and app information'**
  String get settingsAboutDescription;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get settingsVietnamese;

  /// No description provided for @settingsLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// No description provided for @settingsSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystem;

  /// No description provided for @settingsAppInfo.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get settingsAppInfo;

  /// No description provided for @settingsAppName.
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get settingsAppName;

  /// No description provided for @settingsSyncLanguage.
  ///
  /// In en, this message translates to:
  /// **'Sync Language'**
  String get settingsSyncLanguage;

  /// No description provided for @settingsSyncLanguageProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing languages from server...'**
  String get settingsSyncLanguageProgress;

  /// No description provided for @settingsSyncLanguageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Language sync completed successfully'**
  String get settingsSyncLanguageSuccess;

  /// No description provided for @settingsSyncLanguageError.
  ///
  /// In en, this message translates to:
  /// **'Language sync error: {error}'**
  String settingsSyncLanguageError(String error);

  /// No description provided for @settingsVietnameseDesc.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt (Vietnamese)'**
  String get settingsVietnameseDesc;

  /// No description provided for @settingsEnglishDesc.
  ///
  /// In en, this message translates to:
  /// **'English (default)'**
  String get settingsEnglishDesc;

  /// No description provided for @settingsFrenchDesc.
  ///
  /// In en, this message translates to:
  /// **'Français (French)'**
  String get settingsFrenchDesc;

  /// No description provided for @settingsGermanDesc.
  ///
  /// In en, this message translates to:
  /// **'Deutsch (German)'**
  String get settingsGermanDesc;

  /// No description provided for @settingsSpanishDesc.
  ///
  /// In en, this message translates to:
  /// **'Español (Spanish)'**
  String get settingsSpanishDesc;

  /// No description provided for @settingsJapaneseDesc.
  ///
  /// In en, this message translates to:
  /// **'日本語 (Japanese)'**
  String get settingsJapaneseDesc;

  /// No description provided for @settingsKoreanDesc.
  ///
  /// In en, this message translates to:
  /// **'한국어 (Korean)'**
  String get settingsKoreanDesc;

  /// No description provided for @languageAlreadySelected.
  ///
  /// In en, this message translates to:
  /// **'Language already selected'**
  String get languageAlreadySelected;

  /// No description provided for @languageUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Language updated successfully'**
  String get languageUpdateSuccess;

  /// No description provided for @languageChangedNotSynced.
  ///
  /// In en, this message translates to:
  /// **'Language changed (not synced to server)'**
  String get languageChangedNotSynced;

  /// No description provided for @languageChangeError.
  ///
  /// In en, this message translates to:
  /// **'Error changing language'**
  String get languageChangeError;

  /// No description provided for @languageUserNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get languageUserNotLoggedIn;

  /// No description provided for @languageSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get languageSessionExpired;

  /// No description provided for @languageConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get languageConnectionError;

  /// No description provided for @languageApiError.
  ///
  /// In en, this message translates to:
  /// **'API error'**
  String get languageApiError;

  /// No description provided for @languageHttpError.
  ///
  /// In en, this message translates to:
  /// **'HTTP Error'**
  String get languageHttpError;

  /// No description provided for @notificationSoundDefault.
  ///
  /// In en, this message translates to:
  /// **'Default (System)'**
  String get notificationSoundDefault;

  /// No description provided for @notificationSoundNone.
  ///
  /// In en, this message translates to:
  /// **'None (Silent)'**
  String get notificationSoundNone;

  /// No description provided for @notificationSoundAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get notificationSoundAlert;

  /// No description provided for @notificationSoundGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get notificationSoundGentle;

  /// No description provided for @notificationSoundUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get notificationSoundUrgent;

  /// No description provided for @notificationSoundSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select notification sound'**
  String get notificationSoundSelectTitle;

  /// No description provided for @notificationSoundPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get notificationSoundPreview;

  /// No description provided for @mobileActionNavigatingToConfig.
  ///
  /// In en, this message translates to:
  /// **'Navigating to Monitor Config...'**
  String get mobileActionNavigatingToConfig;

  /// No description provided for @mobileActionNavigatingToItems.
  ///
  /// In en, this message translates to:
  /// **'Navigating to Ping Items...'**
  String get mobileActionNavigatingToItems;

  /// No description provided for @mobileActionCommandNotFound.
  ///
  /// In en, this message translates to:
  /// **'Command not found: \"{cmd}\"'**
  String mobileActionCommandNotFound(String cmd);

  /// No description provided for @timeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get timeSeconds;

  /// No description provided for @timeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get timeMinutes;

  /// No description provided for @timeHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get timeHours;

  /// No description provided for @timeDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get timeDays;

  /// No description provided for @timeSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get timeSelectTime;

  /// No description provided for @timeClearTime.
  ///
  /// In en, this message translates to:
  /// **'Clear time'**
  String get timeClearTime;

  /// No description provided for @timeNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Time not selected'**
  String get timeNotSelected;

  /// No description provided for @timeSecond.
  ///
  /// In en, this message translates to:
  /// **'second'**
  String get timeSecond;

  /// No description provided for @timeMinute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get timeMinute;

  /// No description provided for @timeHour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get timeHour;

  /// No description provided for @timeDay.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get timeDay;

  /// No description provided for @timeMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get timeMin;

  /// No description provided for @timeMins.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get timeMins;

  /// No description provided for @timeAgo.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get timeAgo;

  /// No description provided for @optionsSelect.
  ///
  /// In en, this message translates to:
  /// **'-Select-'**
  String get optionsSelect;

  /// No description provided for @optionsSelectAlertType.
  ///
  /// In en, this message translates to:
  /// **'-Select Alert Type-'**
  String get optionsSelectAlertType;

  /// No description provided for @optionsWebContent.
  ///
  /// In en, this message translates to:
  /// **'Web Server Active'**
  String get optionsWebContent;

  /// No description provided for @optionsPing.
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get optionsPing;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileEditProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditProfileTooltip;

  /// No description provided for @profileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileDisplayName;

  /// No description provided for @profileNoName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get profileNoName;

  /// No description provided for @profileNoUsername.
  ///
  /// In en, this message translates to:
  /// **'No username'**
  String get profileNoUsername;

  /// No description provided for @profileNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get profileNoEmail;

  /// No description provided for @profileLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Logged in'**
  String get profileLoggedIn;

  /// No description provided for @profileLoginInfo.
  ///
  /// In en, this message translates to:
  /// **'Login Information'**
  String get profileLoginInfo;

  /// No description provided for @profileLoginMethod.
  ///
  /// In en, this message translates to:
  /// **'Login method'**
  String get profileLoginMethod;

  /// No description provided for @profileLoginTime.
  ///
  /// In en, this message translates to:
  /// **'Login time'**
  String get profileLoginTime;

  /// No description provided for @profileBearerToken.
  ///
  /// In en, this message translates to:
  /// **'Bearer Token'**
  String get profileBearerToken;

  /// No description provided for @profileActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get profileActions;

  /// No description provided for @profileRefreshInfo.
  ///
  /// In en, this message translates to:
  /// **'Refresh information'**
  String get profileRefreshInfo;

  /// No description provided for @profileRefreshInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Update latest information'**
  String get profileRefreshInfoDesc;

  /// No description provided for @profileLogoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign out of account'**
  String get profileLogoutDesc;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get profileLoggingOut;

  /// No description provided for @profileLogoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Signed out successfully'**
  String get profileLogoutSuccess;

  /// No description provided for @profileLogoutError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error signing out: {error}'**
  String profileLogoutError(String error);

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading information: {error}'**
  String profileLoadError(String error);

  /// No description provided for @profileUpdateNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Profile update feature is not yet supported'**
  String get profileUpdateNotSupported;

  /// No description provided for @profileLoginMethodWebApi.
  ///
  /// In en, this message translates to:
  /// **'Web API (Username & Password)'**
  String get profileLoginMethodWebApi;

  /// No description provided for @profileLoginMethodEmail.
  ///
  /// In en, this message translates to:
  /// **'Email & Password'**
  String get profileLoginMethodEmail;

  /// No description provided for @profileLoginMethodUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get profileLoginMethodUnknown;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Ping365 v1.0.0'**
  String get aboutAppVersion;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'GalaxyCloud © 2025'**
  String get aboutCopyright;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Application for monitoring and managing your services.'**
  String get aboutDescription;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developed by GalaxyCloud.vn'**
  String get aboutDeveloper;

  /// No description provided for @errorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorDialogTitle;

  /// No description provided for @errorDialogDetails.
  ///
  /// In en, this message translates to:
  /// **'Error details:'**
  String get errorDialogDetails;

  /// No description provided for @errorDialogHints.
  ///
  /// In en, this message translates to:
  /// **'Hints:'**
  String get errorDialogHints;

  /// No description provided for @errorDialogHintsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email hints:'**
  String get errorDialogHintsEmail;

  /// No description provided for @errorDialogHintEmailValid.
  ///
  /// In en, this message translates to:
  /// **'Email must be in valid format (e.g.: user@domain.com)'**
  String get errorDialogHintEmailValid;

  /// No description provided for @errorDialogHintEmailMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple emails separated by commas'**
  String get errorDialogHintEmailMultiple;

  /// No description provided for @errorDialogHintEmailNoSpace.
  ///
  /// In en, this message translates to:
  /// **'Should not contain extra spaces'**
  String get errorDialogHintEmailNoSpace;

  /// No description provided for @errorDialogHintsUrl.
  ///
  /// In en, this message translates to:
  /// **'URL hints:'**
  String get errorDialogHintsUrl;

  /// No description provided for @errorDialogHintUrlValid.
  ///
  /// In en, this message translates to:
  /// **'URL must be in valid format (e.g.: https://example.com)'**
  String get errorDialogHintUrlValid;

  /// No description provided for @errorDialogHintUrlProtocol.
  ///
  /// In en, this message translates to:
  /// **'Must start with http:// or https://'**
  String get errorDialogHintUrlProtocol;

  /// No description provided for @errorDialogHintUrlNoSpecial.
  ///
  /// In en, this message translates to:
  /// **'Should not contain invalid special characters'**
  String get errorDialogHintUrlNoSpecial;

  /// No description provided for @errorDialogHintsPassword.
  ///
  /// In en, this message translates to:
  /// **'Password hints:'**
  String get errorDialogHintsPassword;

  /// No description provided for @errorDialogHintPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorDialogHintPasswordLength;

  /// No description provided for @errorDialogHintPasswordMix.
  ///
  /// In en, this message translates to:
  /// **'Should contain uppercase, lowercase, and numbers'**
  String get errorDialogHintPasswordMix;

  /// No description provided for @errorDialogHintPasswordNoSpace.
  ///
  /// In en, this message translates to:
  /// **'Should not contain spaces'**
  String get errorDialogHintPasswordNoSpace;

  /// No description provided for @errorDialogHintRequired1.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get errorDialogHintRequired1;

  /// No description provided for @errorDialogHintRequired2.
  ///
  /// In en, this message translates to:
  /// **'Fields with (*) are required'**
  String get errorDialogHintRequired2;

  /// No description provided for @errorDialogHintRequired3.
  ///
  /// In en, this message translates to:
  /// **'Check form before submitting'**
  String get errorDialogHintRequired3;

  /// No description provided for @errorDialogHintDuplicate1.
  ///
  /// In en, this message translates to:
  /// **'This value already exists in the system'**
  String get errorDialogHintDuplicate1;

  /// No description provided for @errorDialogHintDuplicate2.
  ///
  /// In en, this message translates to:
  /// **'Please choose a different value'**
  String get errorDialogHintDuplicate2;

  /// No description provided for @errorDialogHintDuplicate3.
  ///
  /// In en, this message translates to:
  /// **'Check existing list before adding new'**
  String get errorDialogHintDuplicate3;

  /// No description provided for @httpErrorTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical details'**
  String get httpErrorTechnical;

  /// No description provided for @httpErrorSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions:'**
  String get httpErrorSuggestions;

  /// No description provided for @httpErrorClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get httpErrorClose;

  /// No description provided for @httpErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get httpErrorRetry;

  /// No description provided for @httpError400Title.
  ///
  /// In en, this message translates to:
  /// **'Bad Request'**
  String get httpError400Title;

  /// No description provided for @httpError400Desc.
  ///
  /// In en, this message translates to:
  /// **'The data sent to the server is not in the correct format or missing required information.'**
  String get httpError400Desc;

  /// No description provided for @httpError400Hint1.
  ///
  /// In en, this message translates to:
  /// **'Check all information fields'**
  String get httpError400Hint1;

  /// No description provided for @httpError400Hint2.
  ///
  /// In en, this message translates to:
  /// **'Ensure email, URL, phone number are in correct format'**
  String get httpError400Hint2;

  /// No description provided for @httpError400Hint3.
  ///
  /// In en, this message translates to:
  /// **'Do not leave required fields empty'**
  String get httpError400Hint3;

  /// No description provided for @httpError401Title.
  ///
  /// In en, this message translates to:
  /// **'Not Logged In'**
  String get httpError401Title;

  /// No description provided for @httpError401Desc.
  ///
  /// In en, this message translates to:
  /// **'Session has expired or you are not logged in to the system.'**
  String get httpError401Desc;

  /// No description provided for @httpError401Hint1.
  ///
  /// In en, this message translates to:
  /// **'Please log in again'**
  String get httpError401Hint1;

  /// No description provided for @httpError401Hint2.
  ///
  /// In en, this message translates to:
  /// **'Check network connection'**
  String get httpError401Hint2;

  /// No description provided for @httpError401Hint3.
  ///
  /// In en, this message translates to:
  /// **'Contact administrator if the problem persists'**
  String get httpError401Hint3;

  /// No description provided for @httpError403Title.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get httpError403Title;

  /// No description provided for @httpError403Desc.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this operation. Please contact administrator.'**
  String get httpError403Desc;

  /// No description provided for @httpError403Hint1.
  ///
  /// In en, this message translates to:
  /// **'Contact administrator for permission'**
  String get httpError403Hint1;

  /// No description provided for @httpError403Hint2.
  ///
  /// In en, this message translates to:
  /// **'Log in with an account that has appropriate permissions'**
  String get httpError403Hint2;

  /// No description provided for @httpError404Title.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get httpError404Title;

  /// No description provided for @httpError404Desc.
  ///
  /// In en, this message translates to:
  /// **'The requested resource does not exist or has been deleted.'**
  String get httpError404Desc;

  /// No description provided for @httpError404Hint1.
  ///
  /// In en, this message translates to:
  /// **'Check URL or ID again'**
  String get httpError404Hint1;

  /// No description provided for @httpError404Hint2.
  ///
  /// In en, this message translates to:
  /// **'Refresh list and try again'**
  String get httpError404Hint2;

  /// No description provided for @httpError404Hint3.
  ///
  /// In en, this message translates to:
  /// **'Data may have been deleted earlier'**
  String get httpError404Hint3;

  /// No description provided for @httpError408Title.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get httpError408Title;

  /// No description provided for @httpError408Desc.
  ///
  /// In en, this message translates to:
  /// **'Request took too long. Please try again.'**
  String get httpError408Desc;

  /// No description provided for @httpError408Hint1.
  ///
  /// In en, this message translates to:
  /// **'Check internet connection'**
  String get httpError408Hint1;

  /// No description provided for @httpError408Hint2.
  ///
  /// In en, this message translates to:
  /// **'Try again after a few seconds'**
  String get httpError408Hint2;

  /// No description provided for @httpError408Hint3.
  ///
  /// In en, this message translates to:
  /// **'Contact support if error repeats'**
  String get httpError408Hint3;

  /// No description provided for @httpError429Title.
  ///
  /// In en, this message translates to:
  /// **'Too Many Requests'**
  String get httpError429Title;

  /// No description provided for @httpError429Desc.
  ///
  /// In en, this message translates to:
  /// **'You have sent too many requests in a short time. Please wait and try again.'**
  String get httpError429Desc;

  /// No description provided for @httpError429Hint1.
  ///
  /// In en, this message translates to:
  /// **'Wait a few minutes before trying again'**
  String get httpError429Hint1;

  /// No description provided for @httpError429Hint2.
  ///
  /// In en, this message translates to:
  /// **'Avoid sending requests continuously'**
  String get httpError429Hint2;

  /// No description provided for @httpError500Title.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get httpError500Title;

  /// No description provided for @httpError500Desc.
  ///
  /// In en, this message translates to:
  /// **'Server encountered an error while processing the request. Please try again later.'**
  String get httpError500Desc;

  /// No description provided for @httpError500Hint1.
  ///
  /// In en, this message translates to:
  /// **'Wait a few minutes then try again'**
  String get httpError500Hint1;

  /// No description provided for @httpError500Hint2.
  ///
  /// In en, this message translates to:
  /// **'Contact technical support if error persists'**
  String get httpError500Hint2;

  /// No description provided for @httpError500Hint3.
  ///
  /// In en, this message translates to:
  /// **'Save important data before retrying'**
  String get httpError500Hint3;

  /// No description provided for @httpError503Title.
  ///
  /// In en, this message translates to:
  /// **'Service Temporarily Unavailable'**
  String get httpError503Title;

  /// No description provided for @httpError503Desc.
  ///
  /// In en, this message translates to:
  /// **'Server is under maintenance or overloaded. Please try again later.'**
  String get httpError503Desc;

  /// No description provided for @httpError503Hint1.
  ///
  /// In en, this message translates to:
  /// **'Try again after 5-10 minutes'**
  String get httpError503Hint1;

  /// No description provided for @httpError503Hint2.
  ///
  /// In en, this message translates to:
  /// **'Check maintenance notifications from administrator'**
  String get httpError503Hint2;

  /// No description provided for @httpError503Hint3.
  ///
  /// In en, this message translates to:
  /// **'Contact technical support if urgent'**
  String get httpError503Hint3;

  /// No description provided for @httpErrorDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get httpErrorDefaultTitle;

  /// No description provided for @httpErrorDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again or contact support.'**
  String get httpErrorDefaultDesc;

  /// No description provided for @httpErrorDefaultHint1.
  ///
  /// In en, this message translates to:
  /// **'Try again after a few minutes'**
  String get httpErrorDefaultHint1;

  /// No description provided for @httpErrorDefaultHint2.
  ///
  /// In en, this message translates to:
  /// **'Check internet connection'**
  String get httpErrorDefaultHint2;

  /// No description provided for @httpErrorDefaultHint3.
  ///
  /// In en, this message translates to:
  /// **'Contact support with error code {code}'**
  String httpErrorDefaultHint3(Object code);

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterTitle;

  /// No description provided for @filterByName.
  ///
  /// In en, this message translates to:
  /// **'Filter by name'**
  String get filterByName;

  /// No description provided for @filterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name to search...'**
  String get filterNameHint;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by status'**
  String get filterByStatus;

  /// No description provided for @filterShowError.
  ///
  /// In en, this message translates to:
  /// **'Show OFFLINE monitors'**
  String get filterShowError;

  /// No description provided for @filterShowErrorDesc.
  ///
  /// In en, this message translates to:
  /// **'Items with OFFLINE'**
  String get filterShowErrorDesc;

  /// No description provided for @filterShowSuccess.
  ///
  /// In en, this message translates to:
  /// **'Show ONLINE monitors'**
  String get filterShowSuccess;

  /// No description provided for @filterShowSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Items with ONLINE'**
  String get filterShowSuccessDesc;

  /// No description provided for @filterByEnableStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by enable status'**
  String get filterByEnableStatus;

  /// No description provided for @filterShowEnabled.
  ///
  /// In en, this message translates to:
  /// **'Show enabled monitors'**
  String get filterShowEnabled;

  /// No description provided for @filterShowEnabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Items with enable = 1'**
  String get filterShowEnabledDesc;

  /// No description provided for @filterShowDisabled.
  ///
  /// In en, this message translates to:
  /// **'Show disabled monitors'**
  String get filterShowDisabled;

  /// No description provided for @filterShowDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Items with enable = 0'**
  String get filterShowDisabledDesc;

  /// No description provided for @filterResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get filterResetAll;

  /// No description provided for @filterOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get filterOk;

  /// No description provided for @filterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filterClear;

  /// No description provided for @filterShowing.
  ///
  /// In en, this message translates to:
  /// **'Showing'**
  String get filterShowing;

  /// No description provided for @filterOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get filterOf;

  /// No description provided for @filterItems.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get filterItems;

  /// No description provided for @filterName.
  ///
  /// In en, this message translates to:
  /// **'Name:'**
  String get filterName;

  /// No description provided for @filterErrorItems.
  ///
  /// In en, this message translates to:
  /// **'Error items'**
  String get filterErrorItems;

  /// No description provided for @filterSuccessItems.
  ///
  /// In en, this message translates to:
  /// **'Success items'**
  String get filterSuccessItems;

  /// No description provided for @filterEnabledItems.
  ///
  /// In en, this message translates to:
  /// **'Enabled items'**
  String get filterEnabledItems;

  /// No description provided for @filterDisabledItems.
  ///
  /// In en, this message translates to:
  /// **'Disabled items'**
  String get filterDisabledItems;

  /// No description provided for @filterNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No items match the filter'**
  String get filterNoMatch;

  /// No description provided for @filterClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filterClearFilters;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
