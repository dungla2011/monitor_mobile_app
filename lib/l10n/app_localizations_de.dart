// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Monitor App';

  @override
  String get appLoading => 'Laden...';

  @override
  String get appError => 'Fehler';

  @override
  String get appSuccess => 'Erfolg';

  @override
  String get appCancel => 'Abbrechen';

  @override
  String get appSave => 'Speichern';

  @override
  String get appAdd => 'Hinzufügen';

  @override
  String get appEdit => 'Bearbeiten';

  @override
  String get appDelete => 'Löschen';

  @override
  String get appUpdate => 'Aktualisieren';

  @override
  String get appBack => 'Zurück';

  @override
  String get appClose => 'Schließen';

  @override
  String get appConfirm => 'Bestätigen';

  @override
  String get appYes => 'Ja';

  @override
  String get appNo => 'Nein';

  @override
  String get appLoadingData => 'Daten werden geladen...';

  @override
  String get appRetry => 'Wiederholen';

  @override
  String get crudInitError => 'Initialisierungsfehler';

  @override
  String get crudLoadDataError => 'Fehler beim Laden der Daten';

  @override
  String get crudSessionExpired => 'Sitzung abgelaufen';

  @override
  String get crudPleaseLoginAgain =>
      'Bitte melden Sie sich erneut an, um fortzufahren';

  @override
  String get crudDeleteConfirmTitle => 'Löschen bestätigen';

  @override
  String crudDeleteConfirmMessage(int count) {
    return 'Sind Sie sicher, dass Sie $count Element(e) löschen möchten?';
  }

  @override
  String get crudDeleteSuccess => 'Erfolgreich gelöscht';

  @override
  String get crudDeleteError => 'Fehler beim Löschen';

  @override
  String get crudLoadingConfig => 'Konfiguration wird geladen...';

  @override
  String get crudCannotLoadConfig => 'Konfiguration kann nicht geladen werden';

  @override
  String get crudLoadConfigError => 'Fehler beim Laden der Konfiguration';

  @override
  String get crudCannotLoadData => 'Elementdaten können nicht geladen werden';

  @override
  String get crudLoading => 'Wird geladen...';

  @override
  String get crudNoData => 'Keine Daten';

  @override
  String get crudAddFirstItem =>
      'Drücken Sie +, um ein neues Element hinzuzufügen';

  @override
  String crudAddFirstButton(String item) {
    return 'Erstes $item hinzufügen';
  }

  @override
  String get crudSaveSuccess => 'Erfolgreich gespeichert';

  @override
  String get crudSaveError => 'Fehler beim Speichern';

  @override
  String get crudConnectionError => 'Verbindungsfehler';

  @override
  String get authLogin => 'Anmelden';

  @override
  String get authLogout => 'Abmelden';

  @override
  String get authUsername => 'Benutzername';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authLoginSuccess => 'Anmeldung erfolgreich';

  @override
  String get authLoginFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get authPleaseEnterUsername => 'Bitte Benutzernamen eingeben';

  @override
  String get authPleaseEnterPassword => 'Bitte Passwort eingeben';

  @override
  String get monitorItems => 'Überwachungselemente';

  @override
  String get monitorConfigs => 'Überwachungswarnungen';

  @override
  String get monitorAddItem => 'Überwachungselement hinzufügen';

  @override
  String get monitorEditItem => 'Überwachungselement bearbeiten';

  @override
  String get monitorDeleteItem => 'Überwachungselement löschen';

  @override
  String get monitorAddConfig => 'Überwachungswarnung hinzufügen';

  @override
  String get monitorEditConfig => 'Überwachungswarnung bearbeiten';

  @override
  String get monitorDeleteConfig => 'Überwachungswarnung löschen';

  @override
  String get monitorName => 'Überwachungsname';

  @override
  String get monitorType => 'Prüftyp';

  @override
  String get monitorUrl => 'Web/Domain/IP-Link';

  @override
  String get monitorInterval => 'Prüfintervall';

  @override
  String get monitorAlertConfig => 'Warnungskonfiguration';

  @override
  String get monitorEnable => 'Überwachung aktivieren';

  @override
  String get monitorStatus => 'Letzter Status';

  @override
  String get monitorLastCheck => 'Letzte Prüfung';

  @override
  String get monitorOnline => 'Online';

  @override
  String get monitorOffline => 'Offline';

  @override
  String get monitorAllowConsecutiveAlert =>
      'Aufeinanderfolgende Warnungen bei Fehler zulassen';

  @override
  String get monitorErrorKeyword => 'Fehler-Schlüsselwort';

  @override
  String get monitorValidKeyword => 'Gültiges Schlüsselwort';

  @override
  String get monitorCreatedAt => 'Erstellt am';

  @override
  String get configAlertType => 'Warnungstyp';

  @override
  String get configAlertConfig => 'Warnungskonfiguration';

  @override
  String get configEmail => 'E-Mail senden';

  @override
  String get configSms => 'SMS senden';

  @override
  String get configTelegram => 'Telegram senden';

  @override
  String get configWebhook => 'Webhook aufrufen';

  @override
  String get configSelectAlertType => 'Warnungstyp auswählen';

  @override
  String validationRequired(String field) {
    return 'Bitte $field eingeben';
  }

  @override
  String validationPleaseSelect(String field) {
    return 'Bitte $field auswählen';
  }

  @override
  String validationPleaseSelectAtLeastOne(String field) {
    return 'Bitte mindestens ein $field auswählen';
  }

  @override
  String validationInvalidFormat(String field) {
    return 'Ungültiges $field-Format';
  }

  @override
  String get messagesSaveSuccess => 'Erfolgreich gespeichert';

  @override
  String get messagesSaveFailed => 'Speichern fehlgeschlagen';

  @override
  String get messagesDeleteSuccess => 'Erfolgreich gelöscht';

  @override
  String get messagesDeleteFailed => 'Löschen fehlgeschlagen';

  @override
  String messagesDeleteConfirm(String item) {
    return 'Sind Sie sicher, dass Sie $item löschen möchten?';
  }

  @override
  String get messagesNetworkError => 'Netzwerkfehler';

  @override
  String get messagesServerError => 'Serverfehler';

  @override
  String get messagesUnknownError => 'Unbekannter Fehler';

  @override
  String messagesLoadingSettingsError(String error) {
    return 'Fehler beim Laden der Einstellungen: $error';
  }

  @override
  String get navigationHome => 'Startseite';

  @override
  String get navigationMonitorItems => 'Überwachungselemente';

  @override
  String get navigationMonitorConfigs => 'Überwachungskonfigurationen';

  @override
  String get navigationProfile => 'Profil';

  @override
  String get navigationSettings => 'Einstellungen';

  @override
  String get navigationNotifications => 'Benachrichtigungen';

  @override
  String get navigationAbout => 'Über';

  @override
  String get navigationWelcome => 'Willkommen!';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageDescription =>
      'Wählen Sie Ihre bevorzugte Sprache';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsNotificationsDescription =>
      'Benachrichtigungseinstellungen verwalten';

  @override
  String get settingsNotificationSettings => 'Benachrichtigungseinstellungen';

  @override
  String get settingsEnableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get settingsEnableNotificationsDesc =>
      'Benachrichtigungen von der App erhalten';

  @override
  String get settingsNotificationSound => 'Benachrichtigungston';

  @override
  String get settingsNotificationSoundNotSelected => 'Nicht ausgewählt';

  @override
  String get settingsVibrate => 'Vibrieren';

  @override
  String get settingsVibrateDesc => 'Bei Benachrichtigung vibrieren';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeDescription => 'App-Erscheinungsbild auswählen';

  @override
  String get settingsAbout => 'Über die App';

  @override
  String get settingsAboutDescription => 'Version und App-Informationen';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsEnglish => 'Englisch';

  @override
  String get settingsVietnamese => 'Vietnamesisch';

  @override
  String get settingsLight => 'Hell';

  @override
  String get settingsDark => 'Dunkel';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsAppInfo => 'App-Informationen';

  @override
  String get settingsAppName => 'App-Name';

  @override
  String get settingsSyncLanguage => 'Sprache synchronisieren';

  @override
  String get settingsSyncLanguageProgress =>
      'Sprachen vom Server synchronisieren...';

  @override
  String get settingsSyncLanguageSuccess =>
      'Sprachensynchronisierung erfolgreich abgeschlossen';

  @override
  String settingsSyncLanguageError(String error) {
    return 'Sprachensynchronisierungsfehler: $error';
  }

  @override
  String get settingsVietnameseDesc => 'Vietnamesisch';

  @override
  String get settingsEnglishDesc => 'Englisch';

  @override
  String get settingsFrenchDesc => 'Französisch';

  @override
  String get settingsGermanDesc => 'Deutsch (Standard)';

  @override
  String get settingsSpanishDesc => 'Spanisch';

  @override
  String get settingsJapaneseDesc => 'Japanisch';

  @override
  String get settingsKoreanDesc => 'Koreanisch';

  @override
  String get languageAlreadySelected => 'Sprache bereits ausgewählt';

  @override
  String get languageUpdateSuccess => 'Sprache erfolgreich aktualisiert';

  @override
  String get languageChangedNotSynced =>
      'Sprache geändert (nicht mit Server synchronisiert)';

  @override
  String get languageChangeError => 'Fehler beim Ändern der Sprache';

  @override
  String get languageUserNotLoggedIn => 'Benutzer nicht angemeldet';

  @override
  String get languageSessionExpired => 'Sitzung abgelaufen';

  @override
  String get languageConnectionError => 'Verbindungsfehler';

  @override
  String get languageApiError => 'API-Fehler';

  @override
  String get languageHttpError => 'HTTP-Fehler';

  @override
  String get notificationSoundDefault => 'Standard (System)';

  @override
  String get notificationSoundNone => 'Keine (Stumm)';

  @override
  String get notificationSoundAlert => 'Alarm';

  @override
  String get notificationSoundGentle => 'Sanft';

  @override
  String get notificationSoundUrgent => 'Dringend';

  @override
  String get notificationSoundSelectTitle => 'Benachrichtigungston auswählen';

  @override
  String get notificationSoundPreview => 'Vorschau';

  @override
  String get mobileActionNavigatingToConfig =>
      'Navigation zur Überwachungskonfiguration...';

  @override
  String get mobileActionNavigatingToItems =>
      'Navigation zu Überwachungselementen...';

  @override
  String mobileActionCommandNotFound(String cmd) {
    return 'Befehl nicht gefunden: \"$cmd\"';
  }

  @override
  String get timeSeconds => 'Sekunden';

  @override
  String get timeMinutes => 'Minuten';

  @override
  String get timeHours => 'Stunden';

  @override
  String get timeDays => 'Tage';

  @override
  String get timeSelectTime => 'Zeit auswählen';

  @override
  String get timeClearTime => 'Zeit löschen';

  @override
  String get timeNotSelected => 'Zeit nicht ausgewählt';

  @override
  String get timeSecond => 'Sekunde';

  @override
  String get timeMinute => 'Minute';

  @override
  String get timeHour => 'Stunde';

  @override
  String get timeDay => 'Tag';

  @override
  String get timeMin => 'Min';

  @override
  String get timeMins => 'Mins';

  @override
  String get timeAgo => 'vor';

  @override
  String get optionsSelect => '-Auswählen-';

  @override
  String get optionsSelectAlertType => '-Warnungstyp auswählen-';

  @override
  String get optionsWebContent => 'Webserver aktiv';

  @override
  String get optionsPing => 'Ping';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEditProfile => 'Profil bearbeiten';

  @override
  String get profileEditProfileTooltip => 'Profil bearbeiten';

  @override
  String get profileDisplayName => 'Anzeigename';

  @override
  String get profileNoName => 'Kein Name';

  @override
  String get profileNoUsername => 'Kein Benutzername';

  @override
  String get profileNoEmail => 'Keine E-Mail';

  @override
  String get profileLoggedIn => 'Angemeldet';

  @override
  String get profileLoginInfo => 'Anmeldeinformationen';

  @override
  String get profileLoginMethod => 'Anmeldemethode';

  @override
  String get profileLoginTime => 'Anmeldezeit';

  @override
  String get profileBearerToken => 'Bearer-Token';

  @override
  String get profileActions => 'Aktionen';

  @override
  String get profileRefreshInfo => 'Informationen aktualisieren';

  @override
  String get profileRefreshInfoDesc => 'Neueste Informationen aktualisieren';

  @override
  String get profileLogoutDesc => 'Vom Konto abmelden';

  @override
  String get profileLogoutConfirm =>
      'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get profileLoggingOut => 'Abmelden...';

  @override
  String get profileLogoutSuccess => '✅ Erfolgreich abgemeldet';

  @override
  String profileLogoutError(String error) {
    return '❌ Fehler beim Abmelden: $error';
  }

  @override
  String profileLoadError(String error) {
    return 'Fehler beim Laden der Informationen: $error';
  }

  @override
  String get profileUpdateNotSupported =>
      'Profilaktualisierungsfunktion wird noch nicht unterstützt';

  @override
  String get profileLoginMethodWebApi => 'Web-API (Benutzername & Passwort)';

  @override
  String get profileLoginMethodEmail => 'E-Mail & Passwort';

  @override
  String get profileLoginMethodUnknown => 'Unbekannt';

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutAppVersion => 'Monitor App v1.0.0';

  @override
  String get aboutCopyright => 'GalaxyCloud © 2025';

  @override
  String get aboutDescription =>
      'Anwendung zur Überwachung und Verwaltung Ihrer Dienste.';

  @override
  String get aboutDeveloper => 'Entwickelt von GalaxyCloud.vn';

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
  String get filterTitle => 'Filter';

  @override
  String get filterByName => 'Nach Name filtern';

  @override
  String get filterNameHint => 'Namen zum Suchen eingeben...';

  @override
  String get filterByStatus => 'Nach Status filtern';

  @override
  String get filterShowError => 'Fehlermonitore anzeigen';

  @override
  String get filterShowErrorDesc => 'Elemente mit Fehlern';

  @override
  String get filterShowSuccess => 'Erfolgsmonitore anzeigen';

  @override
  String get filterShowSuccessDesc => 'Erfolgreiche Elemente';

  @override
  String get filterByEnableStatus => 'Nach Aktivierungsstatus filtern';

  @override
  String get filterShowEnabled => 'Aktivierte Monitore anzeigen';

  @override
  String get filterShowEnabledDesc => 'Aktivierte Elemente (enable = 1)';

  @override
  String get filterShowDisabled => 'Deaktivierte Monitore anzeigen';

  @override
  String get filterShowDisabledDesc => 'Deaktivierte Elemente (enable = 0)';

  @override
  String get filterResetAll => 'Alle zurücksetzen';

  @override
  String get filterOk => 'OK';

  @override
  String get filterClear => 'Löschen';

  @override
  String get filterShowing => 'Anzeige';

  @override
  String get filterOf => 'von';

  @override
  String get filterItems => 'Elementen';

  @override
  String get filterName => 'Name:';

  @override
  String get filterErrorItems => 'Fehlerelemente';

  @override
  String get filterSuccessItems => 'Erfolgselemente';

  @override
  String get filterEnabledItems => 'Aktivierte Elemente';

  @override
  String get filterDisabledItems => 'Deaktivierte Elemente';

  @override
  String get filterNoMatch => 'Keine Elemente entsprechen dem Filter';

  @override
  String get filterClearFilters => 'Filter löschen';
}
