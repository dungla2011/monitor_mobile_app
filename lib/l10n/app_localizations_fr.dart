// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Monitor App';

  @override
  String get appLoading => 'Chargement...';

  @override
  String get appError => 'Erreur';

  @override
  String get appSuccess => 'Succès';

  @override
  String get appCancel => 'Annuler';

  @override
  String get appSave => 'Enregistrer';

  @override
  String get appAdd => 'Ajouter';

  @override
  String get appEdit => 'Modifier';

  @override
  String get appDelete => 'Supprimer';

  @override
  String get appUpdate => 'Mettre à jour';

  @override
  String get appBack => 'Retour';

  @override
  String get appClose => 'Fermer';

  @override
  String get appConfirm => 'Confirmer';

  @override
  String get appYes => 'Oui';

  @override
  String get appNo => 'Non';

  @override
  String get appLoadingData => 'Chargement des données...';

  @override
  String get appRetry => 'Réessayer';

  @override
  String get crudInitError => 'Erreur d\'initialisation';

  @override
  String get crudLoadDataError => 'Erreur de chargement des données';

  @override
  String get crudSessionExpired => 'Session expirée';

  @override
  String get crudPleaseLoginAgain => 'Veuillez vous reconnecter pour continuer';

  @override
  String get crudDeleteConfirmTitle => 'Confirmer la suppression';

  @override
  String crudDeleteConfirmMessage(int count) {
    return 'Êtes-vous sûr de vouloir supprimer $count élément(s)?';
  }

  @override
  String get crudDeleteSuccess => 'Supprimé avec succès';

  @override
  String get crudDeleteError => 'Erreur de suppression';

  @override
  String get crudLoadingConfig => 'Chargement de la configuration...';

  @override
  String get crudCannotLoadConfig => 'Impossible de charger la configuration';

  @override
  String get crudLoadConfigError => 'Erreur de chargement de la configuration';

  @override
  String get crudCannotLoadData =>
      'Impossible de charger les données de l\'élément';

  @override
  String get crudLoading => 'Chargement...';

  @override
  String get crudNoData => 'Aucune donnée';

  @override
  String get crudAddFirstItem => 'Appuyez sur + pour ajouter un nouvel élément';

  @override
  String crudAddFirstButton(String item) {
    return 'Ajouter le premier $item';
  }

  @override
  String get crudSaveSuccess => 'Enregistré avec succès';

  @override
  String get crudSaveError => 'Erreur d\'enregistrement';

  @override
  String get crudConnectionError => 'Erreur de connexion';

  @override
  String get authLogin => 'Connexion';

  @override
  String get authLogout => 'Déconnexion';

  @override
  String get authUsername => 'Nom d\'utilisateur';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authLoginSuccess => 'Connexion réussie';

  @override
  String get authLoginFailed => 'Échec de la connexion';

  @override
  String get authPleaseEnterUsername => 'Veuillez saisir le nom d\'utilisateur';

  @override
  String get authPleaseEnterPassword => 'Veuillez saisir le mot de passe';

  @override
  String get monitorItems => 'Éléments de surveillance';

  @override
  String get monitorConfigs => 'Alertes de surveillance';

  @override
  String get monitorAddItem => 'Ajouter un élément de surveillance';

  @override
  String get monitorEditItem => 'Modifier l\'élément de surveillance';

  @override
  String get monitorDeleteItem => 'Supprimer l\'élément de surveillance';

  @override
  String get monitorAddConfig => 'Ajouter une alerte de surveillance';

  @override
  String get monitorEditConfig => 'Modifier l\'alerte de surveillance';

  @override
  String get monitorDeleteConfig => 'Supprimer l\'alerte de surveillance';

  @override
  String get monitorName => 'Nom de surveillance';

  @override
  String get monitorType => 'Type de vérification';

  @override
  String get monitorUrl => 'Lien Web/Domaine/IP';

  @override
  String get monitorInterval => 'Intervalle de vérification';

  @override
  String get monitorAlertConfig => 'Configuration d\'alerte';

  @override
  String get monitorEnable => 'Activer la surveillance';

  @override
  String get monitorStatus => 'Dernier statut';

  @override
  String get monitorLastCheck => 'Dernière vérification';

  @override
  String get monitorOnline => 'En ligne';

  @override
  String get monitorOffline => 'Hors ligne';

  @override
  String get monitorAllowConsecutiveAlert =>
      'Autoriser les alertes consécutives en cas d\'erreur';

  @override
  String get monitorErrorKeyword => 'Mot-clé d\'erreur';

  @override
  String get monitorValidKeyword => 'Mot-clé valide';

  @override
  String get monitorCreatedAt => 'Créé le';

  @override
  String get configAlertType => 'Type d\'alerte';

  @override
  String get configAlertConfig => 'Configuration d\'alerte';

  @override
  String get configEmail => 'Envoyer un Email';

  @override
  String get configSms => 'Envoyer un SMS';

  @override
  String get configTelegram => 'Envoyer sur Telegram';

  @override
  String get configWebhook => 'Appeler Webhook';

  @override
  String get configSelectAlertType => 'Sélectionner le type d\'alerte';

  @override
  String validationRequired(String field) {
    return 'Veuillez saisir $field';
  }

  @override
  String validationPleaseSelect(String field) {
    return 'Veuillez sélectionner $field';
  }

  @override
  String validationPleaseSelectAtLeastOne(String field) {
    return 'Veuillez sélectionner au moins un $field';
  }

  @override
  String validationInvalidFormat(String field) {
    return 'Format $field invalide';
  }

  @override
  String get messagesSaveSuccess => 'Enregistré avec succès';

  @override
  String get messagesSaveFailed => 'Échec de l\'enregistrement';

  @override
  String get messagesDeleteSuccess => 'Supprimé avec succès';

  @override
  String get messagesDeleteFailed => 'Échec de la suppression';

  @override
  String messagesDeleteConfirm(String item) {
    return 'Êtes-vous sûr de vouloir supprimer $item?';
  }

  @override
  String get messagesNetworkError => 'Erreur réseau';

  @override
  String get messagesServerError => 'Erreur serveur';

  @override
  String get messagesUnknownError => 'Erreur inconnue';

  @override
  String messagesLoadingSettingsError(String error) {
    return 'Erreur de chargement des paramètres: $error';
  }

  @override
  String get navigationHome => 'Accueil';

  @override
  String get navigationMonitorItems => 'Éléments de surveillance';

  @override
  String get navigationMonitorConfigs => 'Configurations de surveillance';

  @override
  String get navigationProfile => 'Profil';

  @override
  String get navigationSettings => 'Paramètres';

  @override
  String get navigationNotifications => 'Notifications';

  @override
  String get navigationAbout => 'À propos';

  @override
  String get navigationWelcome => 'Bienvenue!';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageDescription => 'Choisissez votre langue préférée';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDescription =>
      'Gérer les préférences de notification';

  @override
  String get settingsNotificationSettings => 'Paramètres de notification';

  @override
  String get settingsEnableNotifications => 'Activer les notifications';

  @override
  String get settingsEnableNotificationsDesc =>
      'Recevoir des notifications de l\'application';

  @override
  String get settingsNotificationSound => 'Son de notification';

  @override
  String get settingsNotificationSoundNotSelected => 'Non sélectionné';

  @override
  String get settingsVibrate => 'Vibration';

  @override
  String get settingsVibrateDesc => 'Vibrer lors d\'une notification';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeDescription =>
      'Choisir l\'apparence de l\'application';

  @override
  String get settingsAbout => 'À propos de l\'application';

  @override
  String get settingsAboutDescription =>
      'Version et informations sur l\'application';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsEnglish => 'Anglais';

  @override
  String get settingsVietnamese => 'Vietnamien';

  @override
  String get settingsLight => 'Clair';

  @override
  String get settingsDark => 'Sombre';

  @override
  String get settingsSystem => 'Système';

  @override
  String get settingsAppInfo => 'Informations sur l\'application';

  @override
  String get settingsAppName => 'Nom de l\'application';

  @override
  String get settingsVietnameseDesc => 'Vietnamien';

  @override
  String get settingsEnglishDesc => 'Anglais';

  @override
  String get settingsFrenchDesc => 'Français (défaut)';

  @override
  String get settingsGermanDesc => 'Allemand';

  @override
  String get settingsSpanishDesc => 'Espagnol';

  @override
  String get settingsJapaneseDesc => 'Japonais';

  @override
  String get settingsKoreanDesc => 'Coréen';

  @override
  String get languageAlreadySelected => 'Langue déjà sélectionnée';

  @override
  String get languageUpdateSuccess => 'Langue mise à jour avec succès';

  @override
  String get languageChangedNotSynced =>
      'Langue modifiée (non synchronisée avec le serveur)';

  @override
  String get languageChangeError => 'Erreur lors du changement de langue';

  @override
  String get languageUserNotLoggedIn => 'Utilisateur non connecté';

  @override
  String get languageSessionExpired => 'Session expirée';

  @override
  String get languageConnectionError => 'Erreur de connexion';

  @override
  String get languageApiError => 'Erreur API';

  @override
  String get languageHttpError => 'Erreur HTTP';

  @override
  String get notificationSoundDefault => 'Par défaut (Système)';

  @override
  String get notificationSoundNone => 'Aucun (Silencieux)';

  @override
  String get notificationSoundAlert => 'Alerte';

  @override
  String get notificationSoundGentle => 'Doux';

  @override
  String get notificationSoundUrgent => 'Urgent';

  @override
  String get notificationSoundSelectTitle =>
      'Sélectionner le son de notification';

  @override
  String get notificationSoundPreview => 'Aperçu';

  @override
  String get mobileActionNavigatingToConfig =>
      'Navigation vers Configuration de surveillance...';

  @override
  String get mobileActionNavigatingToItems =>
      'Navigation vers Éléments de surveillance...';

  @override
  String mobileActionCommandNotFound(String cmd) {
    return 'Commande introuvable: \"$cmd\"';
  }

  @override
  String get timeSeconds => 'Secondes';

  @override
  String get timeMinutes => 'Minutes';

  @override
  String get timeHours => 'Heures';

  @override
  String get timeDays => 'Jours';

  @override
  String get timeSelectTime => 'Sélectionner l\'heure';

  @override
  String get timeClearTime => 'Effacer l\'heure';

  @override
  String get timeNotSelected => 'Heure non sélectionnée';

  @override
  String get timeSecond => 'seconde';

  @override
  String get timeMinute => 'minute';

  @override
  String get timeHour => 'heure';

  @override
  String get timeDay => 'jour';

  @override
  String get timeMin => 'min';

  @override
  String get timeMins => 'mins';

  @override
  String get timeAgo => 'il y a';

  @override
  String get optionsSelect => '-Sélectionner-';

  @override
  String get optionsSelectAlertType => '-Sélectionner le type d\'alerte-';

  @override
  String get optionsWebContent => 'Serveur Web actif';

  @override
  String get optionsPing => 'Ping';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEditProfile => 'Modifier le profil';

  @override
  String get profileEditProfileTooltip => 'Modifier le profil';

  @override
  String get profileDisplayName => 'Nom d\'affichage';

  @override
  String get profileNoName => 'Pas de nom';

  @override
  String get profileNoUsername => 'Pas de nom d\'utilisateur';

  @override
  String get profileNoEmail => 'Pas d\'email';

  @override
  String get profileLoggedIn => 'Connecté';

  @override
  String get profileLoginInfo => 'Informations de connexion';

  @override
  String get profileLoginMethod => 'Méthode de connexion';

  @override
  String get profileLoginTime => 'Heure de connexion';

  @override
  String get profileBearerToken => 'Jeton Bearer';

  @override
  String get profileActions => 'Actions';

  @override
  String get profileRefreshInfo => 'Actualiser les informations';

  @override
  String get profileRefreshInfoDesc =>
      'Mettre à jour les dernières informations';

  @override
  String get profileLogoutDesc => 'Se déconnecter du compte';

  @override
  String get profileLogoutConfirm =>
      'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get profileLoggingOut => 'Déconnexion...';

  @override
  String get profileLogoutSuccess => '✅ Déconnexion réussie';

  @override
  String profileLogoutError(String error) {
    return '❌ Erreur de déconnexion: $error';
  }

  @override
  String profileLoadError(String error) {
    return 'Erreur de chargement des informations: $error';
  }

  @override
  String get profileUpdateNotSupported =>
      'La fonction de mise à jour du profil n\'est pas encore prise en charge';

  @override
  String get profileLoginMethodWebApi =>
      'API Web (Nom d\'utilisateur et mot de passe)';

  @override
  String get profileLoginMethodEmail => 'Email et mot de passe';

  @override
  String get profileLoginMethodUnknown => 'Inconnu';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutAppVersion => 'Monitor App v1.0.0';

  @override
  String get aboutCopyright => 'GalaxyCloud © 2025';

  @override
  String get aboutDescription =>
      'Application pour surveiller et gérer vos services.';

  @override
  String get aboutDeveloper => 'Développé par GalaxyCloud.vn';

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
  String get filterTitle => 'Filtres';

  @override
  String get filterByName => 'Filtrer par nom';

  @override
  String get filterNameHint => 'Entrez le nom à rechercher...';

  @override
  String get filterByStatus => 'Filtrer par statut';

  @override
  String get filterShowError => 'Afficher les moniteurs en erreur';

  @override
  String get filterShowErrorDesc => 'Éléments avec erreurs';

  @override
  String get filterShowSuccess => 'Afficher les moniteurs réussis';

  @override
  String get filterShowSuccessDesc => 'Éléments réussis';

  @override
  String get filterByEnableStatus => 'Filtrer par statut d\'activation';

  @override
  String get filterShowEnabled => 'Afficher les moniteurs activés';

  @override
  String get filterShowEnabledDesc => 'Éléments activés (enable = 1)';

  @override
  String get filterShowDisabled => 'Afficher les moniteurs désactivés';

  @override
  String get filterShowDisabledDesc => 'Éléments désactivés (enable = 0)';

  @override
  String get filterResetAll => 'Tout réinitialiser';

  @override
  String get filterOk => 'OK';

  @override
  String get filterClear => 'Effacer';

  @override
  String get filterShowing => 'Affichage';

  @override
  String get filterOf => 'sur';

  @override
  String get filterItems => 'éléments';

  @override
  String get filterName => 'Nom:';

  @override
  String get filterErrorItems => 'Éléments en erreur';

  @override
  String get filterSuccessItems => 'Éléments réussis';

  @override
  String get filterEnabledItems => 'Éléments activés';

  @override
  String get filterDisabledItems => 'Éléments désactivés';

  @override
  String get filterNoMatch => 'Aucun élément ne correspond au filtre';

  @override
  String get filterClearFilters => 'Effacer les filtres';
}
