// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Monitor App';

  @override
  String get appLoading => '로딩 중...';

  @override
  String get appError => '오류';

  @override
  String get appSuccess => '성공';

  @override
  String get appCancel => '취소';

  @override
  String get appSave => '저장';

  @override
  String get appAdd => '추가';

  @override
  String get appEdit => '수정';

  @override
  String get appDelete => '삭제';

  @override
  String get appUpdate => '업데이트';

  @override
  String get appBack => '뒤로';

  @override
  String get appClose => '닫기';

  @override
  String get appConfirm => '확인';

  @override
  String get appYes => '예';

  @override
  String get appNo => '아니오';

  @override
  String get appLoadingData => '데이터 로딩 중...';

  @override
  String get appRetry => '재시도';

  @override
  String get crudInitError => '초기화 오류';

  @override
  String get crudLoadDataError => '데이터 로딩 오류';

  @override
  String get crudSessionExpired => '세션이 만료되었습니다';

  @override
  String get crudPleaseLoginAgain => '계속하려면 다시 로그인하세요';

  @override
  String get crudDeleteConfirmTitle => '삭제 확인';

  @override
  String crudDeleteConfirmMessage(int count) {
    return '$count개의 항목을 삭제하시겠습니까?';
  }

  @override
  String get crudDeleteSuccess => '성공적으로 삭제되었습니다';

  @override
  String get crudDeleteError => '삭제 오류';

  @override
  String get crudLoadingConfig => '구성 로딩 중...';

  @override
  String get crudCannotLoadConfig => '구성을 로드할 수 없습니다';

  @override
  String get crudLoadConfigError => '구성 로딩 오류';

  @override
  String get crudCannotLoadData => '항목 데이터를 로드할 수 없습니다';

  @override
  String get crudLoading => '로딩 중...';

  @override
  String get crudNoData => '데이터 없음';

  @override
  String get crudAddFirstItem => '+ 버튼을 눌러 새 항목을 추가하세요';

  @override
  String crudAddFirstButton(String item) {
    return '첫 번째 $item 추가';
  }

  @override
  String get crudSaveSuccess => '성공적으로 저장되었습니다';

  @override
  String get crudSaveError => '저장 오류';

  @override
  String get crudConnectionError => '연결 오류';

  @override
  String get authLogin => '로그인';

  @override
  String get authLogout => '로그아웃';

  @override
  String get authUsername => '사용자 이름';

  @override
  String get authPassword => '비밀번호';

  @override
  String get authLoginSuccess => '로그인 성공';

  @override
  String get authLoginFailed => '로그인 실패';

  @override
  String get authPleaseEnterUsername => '사용자 이름을 입력하세요';

  @override
  String get authPleaseEnterPassword => '비밀번호를 입력하세요';

  @override
  String get monitorItems => '모니터 항목';

  @override
  String get monitorConfigs => '모니터 알림';

  @override
  String get monitorAddItem => '모니터 항목 추가';

  @override
  String get monitorEditItem => '모니터 항목 수정';

  @override
  String get monitorDeleteItem => '모니터 항목 삭제';

  @override
  String get monitorAddConfig => '모니터 알림 추가';

  @override
  String get monitorEditConfig => '모니터 알림 수정';

  @override
  String get monitorDeleteConfig => '모니터 알림 삭제';

  @override
  String get monitorName => '모니터 이름';

  @override
  String get monitorType => '체크 유형';

  @override
  String get monitorUrl => '웹/도메인/IP 링크';

  @override
  String get monitorInterval => '체크 간격';

  @override
  String get monitorAlertConfig => '알림 설정';

  @override
  String get monitorEnable => '모니터링 활성화';

  @override
  String get monitorStatus => '최신 상태';

  @override
  String get monitorLastCheck => '마지막 체크';

  @override
  String get monitorOnline => '온라인';

  @override
  String get monitorOffline => '오프라인';

  @override
  String get monitorAllowConsecutiveAlert => '오류 시 연속 알림 허용';

  @override
  String get monitorErrorKeyword => '오류 키워드';

  @override
  String get monitorValidKeyword => '유효 키워드';

  @override
  String get monitorCreatedAt => '생성일';

  @override
  String get configAlertType => '알림 유형';

  @override
  String get configAlertConfig => '알림 설정';

  @override
  String get configEmail => '이메일 전송';

  @override
  String get configSms => 'SMS 전송';

  @override
  String get configTelegram => '텔레그램 전송';

  @override
  String get configWebhook => 'Webhook 호출';

  @override
  String get configSelectAlertType => '알림 유형 선택';

  @override
  String validationRequired(String field) {
    return '$field을(를) 입력하세요';
  }

  @override
  String validationPleaseSelect(String field) {
    return '$field을(를) 선택하세요';
  }

  @override
  String validationPleaseSelectAtLeastOne(String field) {
    return '최소 하나의 $field을(를) 선택하세요';
  }

  @override
  String validationInvalidFormat(String field) {
    return '$field 형식이 잘못되었습니다';
  }

  @override
  String get messagesSaveSuccess => '성공적으로 저장되었습니다';

  @override
  String get messagesSaveFailed => '저장 실패';

  @override
  String get messagesDeleteSuccess => '성공적으로 삭제되었습니다';

  @override
  String get messagesDeleteFailed => '삭제 실패';

  @override
  String messagesDeleteConfirm(String item) {
    return '$item을(를) 삭제하시겠습니까?';
  }

  @override
  String get messagesNetworkError => '네트워크 오류';

  @override
  String get messagesServerError => '서버 오류';

  @override
  String get messagesUnknownError => '알 수 없는 오류';

  @override
  String messagesLoadingSettingsError(String error) {
    return '설정 로드 오류: $error';
  }

  @override
  String get navigationHome => '홈';

  @override
  String get navigationMonitorItems => '모니터 항목';

  @override
  String get navigationMonitorConfigs => '모니터 설정';

  @override
  String get navigationProfile => '프로필';

  @override
  String get navigationSettings => '설정';

  @override
  String get navigationNotifications => '알림';

  @override
  String get navigationAbout => '정보';

  @override
  String get navigationWelcome => '환영합니다!';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageDescription => '선호하는 언어 선택';

  @override
  String get settingsNotifications => '알림';

  @override
  String get settingsNotificationsDescription => '알림 설정 관리';

  @override
  String get settingsNotificationSettings => '알림 설정';

  @override
  String get settingsEnableNotifications => '알림 활성화';

  @override
  String get settingsEnableNotificationsDesc => '앱에서 알림 받기';

  @override
  String get settingsNotificationSound => '알림음';

  @override
  String get settingsNotificationSoundNotSelected => '선택되지 않음';

  @override
  String get settingsVibrate => '진동';

  @override
  String get settingsVibrateDesc => '알림 시 진동';

  @override
  String get settingsTheme => '테마';

  @override
  String get settingsThemeDescription => '앱 외관 선택';

  @override
  String get settingsAbout => '앱 정보';

  @override
  String get settingsAboutDescription => '버전 및 앱 정보';

  @override
  String get settingsVersion => '버전';

  @override
  String get settingsEnglish => '영어';

  @override
  String get settingsVietnamese => '베트남어';

  @override
  String get settingsLight => '밝게';

  @override
  String get settingsDark => '어둡게';

  @override
  String get settingsSystem => '시스템';

  @override
  String get settingsAppInfo => '앱 정보';

  @override
  String get settingsAppName => '앱 이름';

  @override
  String get settingsSyncLanguage => '언어 동기화';

  @override
  String get settingsSyncLanguageProgress => '서버에서 언어 동기화 중...';

  @override
  String get settingsSyncLanguageSuccess => '언어 동기화가 완료되었습니다';

  @override
  String settingsSyncLanguageError(String error) {
    return '언어 동기화 오류: $error';
  }

  @override
  String get settingsVietnameseDesc => 'Tiếng Việt (베트남어)';

  @override
  String get settingsEnglishDesc => 'English (영어)';

  @override
  String get settingsFrenchDesc => 'Français (프랑스어)';

  @override
  String get settingsGermanDesc => 'Deutsch (독일어)';

  @override
  String get settingsSpanishDesc => 'Español (스페인어)';

  @override
  String get settingsJapaneseDesc => '日本語 (일본어)';

  @override
  String get settingsKoreanDesc => '한국어 (Korean)';

  @override
  String get languageAlreadySelected => '언어가 이미 선택되었습니다';

  @override
  String get languageUpdateSuccess => '언어가 성공적으로 업데이트되었습니다';

  @override
  String get languageChangedNotSynced => '언어 변경됨 (서버와 동기화 안 됨)';

  @override
  String get languageChangeError => '언어 변경 오류';

  @override
  String get languageUserNotLoggedIn => '사용자가 로그인하지 않았습니다';

  @override
  String get languageSessionExpired => '세션이 만료되었습니다';

  @override
  String get languageConnectionError => '연결 오류';

  @override
  String get languageApiError => 'API 오류';

  @override
  String get languageHttpError => 'HTTP 오류';

  @override
  String get notificationSoundDefault => '기본 (시스템)';

  @override
  String get notificationSoundNone => '없음 (무음)';

  @override
  String get notificationSoundAlert => '알림';

  @override
  String get notificationSoundGentle => '부드럽게';

  @override
  String get notificationSoundUrgent => '긴급';

  @override
  String get notificationSoundSelectTitle => '알림음 선택';

  @override
  String get notificationSoundPreview => '미리 듣기';

  @override
  String get mobileActionNavigatingToConfig => '모니터 설정으로 이동 중...';

  @override
  String get mobileActionNavigatingToItems => '모니터 항목으로 이동 중...';

  @override
  String mobileActionCommandNotFound(String cmd) {
    return '명령을 찾을 수 없습니다: \"$cmd\"';
  }

  @override
  String get timeSeconds => '초';

  @override
  String get timeMinutes => '분';

  @override
  String get timeHours => '시간';

  @override
  String get timeDays => '일';

  @override
  String get timeSelectTime => '시간 선택';

  @override
  String get timeClearTime => '시간 지우기';

  @override
  String get timeNotSelected => '시간이 선택되지 않음';

  @override
  String get timeSecond => '초';

  @override
  String get timeMinute => '분';

  @override
  String get timeHour => '시간';

  @override
  String get timeDay => '일';

  @override
  String get timeMin => '분';

  @override
  String get timeMins => '분';

  @override
  String get timeAgo => '전';

  @override
  String get optionsSelect => '-선택-';

  @override
  String get optionsSelectAlertType => '-알림 유형 선택-';

  @override
  String get optionsWebContent => '웹 서버 활성';

  @override
  String get optionsPing => 'Ping';

  @override
  String get profileTitle => '프로필';

  @override
  String get profileEditProfile => '프로필 수정';

  @override
  String get profileEditProfileTooltip => '프로필 수정';

  @override
  String get profileDisplayName => '표시 이름';

  @override
  String get profileNoName => '이름 없음';

  @override
  String get profileNoUsername => '사용자 이름 없음';

  @override
  String get profileNoEmail => '이메일 없음';

  @override
  String get profileLoggedIn => '로그인됨';

  @override
  String get profileLoginInfo => '로그인 정보';

  @override
  String get profileLoginMethod => '로그인 방법';

  @override
  String get profileLoginTime => '로그인 시간';

  @override
  String get profileBearerToken => 'Bearer Token';

  @override
  String get profileActions => '작업';

  @override
  String get profileRefreshInfo => '정보 새로고침';

  @override
  String get profileRefreshInfoDesc => '최신 정보 업데이트';

  @override
  String get profileLogoutDesc => '계정에서 로그아웃';

  @override
  String get profileLogoutConfirm => '로그아웃하시겠습니까?';

  @override
  String get profileLoggingOut => '로그아웃 중...';

  @override
  String get profileLogoutSuccess => '✅ 성공적으로 로그아웃되었습니다';

  @override
  String profileLogoutError(String error) {
    return '❌ 로그아웃 오류: $error';
  }

  @override
  String profileLoadError(String error) {
    return '정보 로드 오류: $error';
  }

  @override
  String get profileUpdateNotSupported => '프로필 업데이트 기능은 아직 지원되지 않습니다';

  @override
  String get profileLoginMethodWebApi => 'Web API (사용자 이름 & 비밀번호)';

  @override
  String get profileLoginMethodEmail => '이메일 & 비밀번호';

  @override
  String get profileLoginMethodUnknown => '알 수 없음';

  @override
  String get aboutTitle => '정보';

  @override
  String get aboutAppVersion => 'Monitor App v1.0.0';

  @override
  String get aboutCopyright => 'GalaxyCloud © 2025';

  @override
  String get aboutDescription => '서비스를 모니터링하고 관리하는 애플리케이션';

  @override
  String get aboutDeveloper => 'GalaxyCloud.vn에서 개발';

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
  String get filterTitle => '필터';

  @override
  String get filterByName => '이름으로 필터';

  @override
  String get filterNameHint => '검색할 이름 입력...';

  @override
  String get filterByStatus => '상태로 필터';

  @override
  String get filterShowError => '오류 모니터 표시';

  @override
  String get filterShowErrorDesc => '오류가 있는 항목';

  @override
  String get filterShowSuccess => '성공 모니터 표시';

  @override
  String get filterShowSuccessDesc => '성공한 항목';

  @override
  String get filterByEnableStatus => '활성화 상태로 필터';

  @override
  String get filterShowEnabled => '활성화된 모니터 표시';

  @override
  String get filterShowEnabledDesc => '활성화된 항목 (enable = 1)';

  @override
  String get filterShowDisabled => '비활성화된 모니터 표시';

  @override
  String get filterShowDisabledDesc => '비활성화된 항목 (enable = 0)';

  @override
  String get filterResetAll => '모두 재설정';

  @override
  String get filterOk => '확인';

  @override
  String get filterClear => '지우기';

  @override
  String get filterShowing => '표시 중';

  @override
  String get filterOf => '의';

  @override
  String get filterItems => '항목';

  @override
  String get filterName => '이름:';

  @override
  String get filterErrorItems => '오류 항목';

  @override
  String get filterSuccessItems => '성공 항목';

  @override
  String get filterEnabledItems => '활성화된 항목';

  @override
  String get filterDisabledItems => '비활성화된 항목';

  @override
  String get filterNoMatch => '필터와 일치하는 항목이 없습니다';

  @override
  String get filterClearFilters => '필터 지우기';
}
