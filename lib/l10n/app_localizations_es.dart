// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Monitor App';

  @override
  String get appLoading => 'Cargando...';

  @override
  String get appError => 'Error';

  @override
  String get appSuccess => 'Éxito';

  @override
  String get appCancel => 'Cancelar';

  @override
  String get appSave => 'Guardar';

  @override
  String get appAdd => 'Agregar';

  @override
  String get appEdit => 'Editar';

  @override
  String get appDelete => 'Eliminar';

  @override
  String get appUpdate => 'Actualizar';

  @override
  String get appBack => 'Atrás';

  @override
  String get appClose => 'Cerrar';

  @override
  String get appConfirm => 'Confirmar';

  @override
  String get appYes => 'Sí';

  @override
  String get appNo => 'No';

  @override
  String get appLoadingData => 'Cargando datos...';

  @override
  String get appRetry => 'Reintentar';

  @override
  String get crudInitError => 'Error de inicialización';

  @override
  String get crudLoadDataError => 'Error al cargar datos';

  @override
  String get crudSessionExpired => 'Sesión expirada';

  @override
  String get crudPleaseLoginAgain =>
      'Por favor, inicie sesión nuevamente para continuar';

  @override
  String get crudDeleteConfirmTitle => 'Confirmar eliminación';

  @override
  String crudDeleteConfirmMessage(int count) {
    return '¿Está seguro de que desea eliminar $count elemento(s)?';
  }

  @override
  String get crudDeleteSuccess => 'Eliminado correctamente';

  @override
  String get crudDeleteError => 'Error al eliminar';

  @override
  String get crudLoadingConfig => 'Cargando configuración...';

  @override
  String get crudCannotLoadConfig => 'No se puede cargar la configuración';

  @override
  String get crudLoadConfigError => 'Error al cargar la configuración';

  @override
  String get crudCannotLoadData => 'No se pueden cargar los datos del elemento';

  @override
  String get crudLoading => 'Cargando...';

  @override
  String get crudNoData => 'Sin datos';

  @override
  String get crudAddFirstItem => 'Presione + para agregar un nuevo elemento';

  @override
  String crudAddFirstButton(String item) {
    return 'Agregar primer $item';
  }

  @override
  String get crudSaveSuccess => 'Guardado correctamente';

  @override
  String get crudSaveError => 'Error al guardar';

  @override
  String get crudConnectionError => 'Error de conexión';

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authLogout => 'Cerrar sesión';

  @override
  String get authUsername => 'Nombre de usuario';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authLoginSuccess => 'Inicio de sesión exitoso';

  @override
  String get authLoginFailed => 'Error al iniciar sesión';

  @override
  String get authPleaseEnterUsername =>
      'Por favor ingrese el nombre de usuario';

  @override
  String get authPleaseEnterPassword => 'Por favor ingrese la contraseña';

  @override
  String get monitorItems => 'Elementos de monitoreo';

  @override
  String get monitorConfigs => 'Alertas de monitoreo';

  @override
  String get monitorAddItem => 'Agregar elemento de monitoreo';

  @override
  String get monitorEditItem => 'Editar elemento de monitoreo';

  @override
  String get monitorDeleteItem => 'Eliminar elemento de monitoreo';

  @override
  String get monitorAddConfig => 'Agregar alerta de monitoreo';

  @override
  String get monitorEditConfig => 'Editar alerta de monitoreo';

  @override
  String get monitorDeleteConfig => 'Eliminar alerta de monitoreo';

  @override
  String get monitorName => 'Nombre de monitoreo';

  @override
  String get monitorType => 'Tipo de verificación';

  @override
  String get monitorUrl => 'Enlace Web/Dominio/IP';

  @override
  String get monitorInterval => 'Intervalo de verificación';

  @override
  String get monitorAlertConfig => 'Configuración de alerta';

  @override
  String get monitorEnable => 'Habilitar monitoreo';

  @override
  String get monitorStatus => 'Último estado';

  @override
  String get monitorLastCheck => 'Última verificación';

  @override
  String get monitorOnline => 'En línea';

  @override
  String get monitorOffline => 'Fuera de línea';

  @override
  String get monitorAllowConsecutiveAlert =>
      'Permitir alertas consecutivas en caso de error';

  @override
  String get monitorErrorKeyword => 'Palabra clave de error';

  @override
  String get monitorValidKeyword => 'Palabra clave válida';

  @override
  String get monitorCreatedAt => 'Creado el';

  @override
  String get configAlertType => 'Tipo de alerta';

  @override
  String get configAlertConfig => 'Configuración de alerta';

  @override
  String get configEmail => 'Enviar Email';

  @override
  String get configSms => 'Enviar SMS';

  @override
  String get configTelegram => 'Enviar por Telegram';

  @override
  String get configWebhook => 'Llamar Webhook';

  @override
  String get configSelectAlertType => 'Seleccionar tipo de alerta';

  @override
  String validationRequired(String field) {
    return 'Por favor ingrese $field';
  }

  @override
  String validationPleaseSelect(String field) {
    return 'Por favor seleccione $field';
  }

  @override
  String validationPleaseSelectAtLeastOne(String field) {
    return 'Por favor seleccione al menos un $field';
  }

  @override
  String validationInvalidFormat(String field) {
    return 'Formato $field inválido';
  }

  @override
  String get messagesSaveSuccess => 'Guardado exitosamente';

  @override
  String get messagesSaveFailed => 'Error al guardar';

  @override
  String get messagesDeleteSuccess => 'Eliminado exitosamente';

  @override
  String get messagesDeleteFailed => 'Error al eliminar';

  @override
  String messagesDeleteConfirm(String item) {
    return '¿Está seguro de que desea eliminar $item?';
  }

  @override
  String get messagesNetworkError => 'Error de red';

  @override
  String get messagesServerError => 'Error del servidor';

  @override
  String get messagesUnknownError => 'Error desconocido';

  @override
  String messagesLoadingSettingsError(String error) {
    return 'Error al cargar la configuración: $error';
  }

  @override
  String get navigationHome => 'Inicio';

  @override
  String get navigationMonitorItems => 'Elementos de monitoreo';

  @override
  String get navigationMonitorConfigs => 'Configuraciones de monitoreo';

  @override
  String get navigationProfile => 'Perfil';

  @override
  String get navigationSettings => 'Configuración';

  @override
  String get navigationNotifications => 'Notificaciones';

  @override
  String get navigationAbout => 'Acerca de';

  @override
  String get navigationWelcome => '¡Bienvenido!';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDescription => 'Elija su idioma preferido';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsDescription =>
      'Administrar preferencias de notificación';

  @override
  String get settingsNotificationSettings => 'Configuración de notificaciones';

  @override
  String get settingsEnableNotifications => 'Habilitar notificaciones';

  @override
  String get settingsEnableNotificationsDesc =>
      'Recibir notificaciones de la aplicación';

  @override
  String get settingsNotificationSound => 'Sonido de notificación';

  @override
  String get settingsNotificationSoundNotSelected => 'No seleccionado';

  @override
  String get settingsVibrate => 'Vibración';

  @override
  String get settingsVibrateDesc => 'Vibrar en notificación';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDescription => 'Elegir apariencia de la aplicación';

  @override
  String get settingsAbout => 'Acerca de la aplicación';

  @override
  String get settingsAboutDescription =>
      'Versión e información de la aplicación';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsEnglish => 'Inglés';

  @override
  String get settingsVietnamese => 'Vietnamita';

  @override
  String get settingsLight => 'Claro';

  @override
  String get settingsDark => 'Oscuro';

  @override
  String get settingsSystem => 'Sistema';

  @override
  String get settingsAppInfo => 'Información de la aplicación';

  @override
  String get settingsAppName => 'Nombre de la aplicación';

  @override
  String get settingsSyncLanguage => 'Sincronizar idioma';

  @override
  String get settingsSyncLanguageProgress =>
      'Sincronizando idiomas desde el servidor...';

  @override
  String get settingsSyncLanguageSuccess =>
      'Sincronización de idioma completada con éxito';

  @override
  String settingsSyncLanguageError(String error) {
    return 'Error de sincronización de idioma: $error';
  }

  @override
  String get settingsVietnameseDesc => 'Vietnamita';

  @override
  String get settingsEnglishDesc => 'Inglés';

  @override
  String get settingsFrenchDesc => 'Francés';

  @override
  String get settingsGermanDesc => 'Alemán';

  @override
  String get settingsSpanishDesc => 'Español (predeterminado)';

  @override
  String get settingsJapaneseDesc => 'Japonés';

  @override
  String get settingsKoreanDesc => 'Coreano';

  @override
  String get languageAlreadySelected => 'Idioma ya seleccionado';

  @override
  String get languageUpdateSuccess => 'Idioma actualizado correctamente';

  @override
  String get languageChangedNotSynced =>
      'Idioma cambiado (no sincronizado con el servidor)';

  @override
  String get languageChangeError => 'Error al cambiar el idioma';

  @override
  String get languageUserNotLoggedIn => 'Usuario no conectado';

  @override
  String get languageSessionExpired => 'Sesión expirada';

  @override
  String get languageConnectionError => 'Error de conexión';

  @override
  String get languageApiError => 'Error de API';

  @override
  String get languageHttpError => 'Error HTTP';

  @override
  String get notificationSoundDefault => 'Predeterminado (Sistema)';

  @override
  String get notificationSoundNone => 'Ninguno (Silencioso)';

  @override
  String get notificationSoundAlert => 'Alerta';

  @override
  String get notificationSoundGentle => 'Suave';

  @override
  String get notificationSoundUrgent => 'Urgente';

  @override
  String get notificationSoundSelectTitle =>
      'Seleccionar sonido de notificación';

  @override
  String get notificationSoundPreview => 'Vista previa';

  @override
  String get mobileActionNavigatingToConfig =>
      'Navegando a Configuración de monitoreo...';

  @override
  String get mobileActionNavigatingToItems =>
      'Navegando a Elementos de monitoreo...';

  @override
  String mobileActionCommandNotFound(String cmd) {
    return 'Comando no encontrado: \"$cmd\"';
  }

  @override
  String get timeSeconds => 'Segundos';

  @override
  String get timeMinutes => 'Minutos';

  @override
  String get timeHours => 'Horas';

  @override
  String get timeDays => 'Días';

  @override
  String get timeSelectTime => 'Seleccionar hora';

  @override
  String get timeClearTime => 'Borrar hora';

  @override
  String get timeNotSelected => 'Hora no seleccionada';

  @override
  String get timeSecond => 'segundo';

  @override
  String get timeMinute => 'minuto';

  @override
  String get timeHour => 'hora';

  @override
  String get timeDay => 'día';

  @override
  String get timeMin => 'min';

  @override
  String get timeMins => 'mins';

  @override
  String get timeAgo => 'hace';

  @override
  String get optionsSelect => '-Seleccionar-';

  @override
  String get optionsSelectAlertType => '-Seleccionar tipo de alerta-';

  @override
  String get optionsWebContent => 'Servidor web activo';

  @override
  String get optionsPing => 'Ping';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get profileEditProfileTooltip => 'Editar perfil';

  @override
  String get profileDisplayName => 'Nombre para mostrar';

  @override
  String get profileNoName => 'Sin nombre';

  @override
  String get profileNoUsername => 'Sin nombre de usuario';

  @override
  String get profileNoEmail => 'Sin correo electrónico';

  @override
  String get profileLoggedIn => 'Conectado';

  @override
  String get profileLoginInfo => 'Información de inicio de sesión';

  @override
  String get profileLoginMethod => 'Método de inicio de sesión';

  @override
  String get profileLoginTime => 'Hora de inicio de sesión';

  @override
  String get profileBearerToken => 'Token Bearer';

  @override
  String get profileActions => 'Acciones';

  @override
  String get profileRefreshInfo => 'Actualizar información';

  @override
  String get profileRefreshInfoDesc => 'Actualizar última información';

  @override
  String get profileLogoutDesc => 'Cerrar sesión de la cuenta';

  @override
  String get profileLogoutConfirm => '¿Está seguro de que desea cerrar sesión?';

  @override
  String get profileLoggingOut => 'Cerrando sesión...';

  @override
  String get profileLogoutSuccess => '✅ Sesión cerrada exitosamente';

  @override
  String profileLogoutError(String error) {
    return '❌ Error al cerrar sesión: $error';
  }

  @override
  String profileLoadError(String error) {
    return 'Error al cargar información: $error';
  }

  @override
  String get profileUpdateNotSupported =>
      'La función de actualización de perfil aún no está soportada';

  @override
  String get profileLoginMethodWebApi =>
      'API Web (Nombre de usuario y contraseña)';

  @override
  String get profileLoginMethodEmail => 'Correo electrónico y contraseña';

  @override
  String get profileLoginMethodUnknown => 'Desconocido';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutAppVersion => 'Monitor App v1.0.0';

  @override
  String get aboutCopyright => 'GalaxyCloud © 2025';

  @override
  String get aboutDescription =>
      'Aplicación para monitorear y gestionar sus servicios.';

  @override
  String get aboutDeveloper => 'Desarrollado por GalaxyCloud.vn';

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
  String get filterTitle => 'Filtros';

  @override
  String get filterByName => 'Filtrar por nombre';

  @override
  String get filterNameHint => 'Ingrese el nombre a buscar...';

  @override
  String get filterByStatus => 'Filtrar por estado';

  @override
  String get filterShowError => 'Mostrar monitores con error';

  @override
  String get filterShowErrorDesc => 'Elementos con errores';

  @override
  String get filterShowSuccess => 'Mostrar monitores exitosos';

  @override
  String get filterShowSuccessDesc => 'Elementos exitosos';

  @override
  String get filterByEnableStatus => 'Filtrar por estado de activación';

  @override
  String get filterShowEnabled => 'Mostrar monitores activados';

  @override
  String get filterShowEnabledDesc => 'Elementos activados (enable = 1)';

  @override
  String get filterShowDisabled => 'Mostrar monitores desactivados';

  @override
  String get filterShowDisabledDesc => 'Elementos desactivados (enable = 0)';

  @override
  String get filterResetAll => 'Restablecer todo';

  @override
  String get filterOk => 'OK';

  @override
  String get filterClear => 'Limpiar';

  @override
  String get filterShowing => 'Mostrando';

  @override
  String get filterOf => 'de';

  @override
  String get filterItems => 'elementos';

  @override
  String get filterName => 'Nombre:';

  @override
  String get filterErrorItems => 'Elementos con error';

  @override
  String get filterSuccessItems => 'Elementos exitosos';

  @override
  String get filterEnabledItems => 'Elementos activados';

  @override
  String get filterDisabledItems => 'Elementos desactivados';

  @override
  String get filterNoMatch => 'No hay elementos que coincidan con el filtro';

  @override
  String get filterClearFilters => 'Limpiar filtros';
}
