// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Monitor App';

  @override
  String get appLoading => '読み込み中...';

  @override
  String get appError => 'エラー';

  @override
  String get appSuccess => '成功';

  @override
  String get appCancel => 'キャンセル';

  @override
  String get appSave => '保存';

  @override
  String get appAdd => '追加';

  @override
  String get appEdit => '編集';

  @override
  String get appDelete => '削除';

  @override
  String get appUpdate => '更新';

  @override
  String get appBack => '戻る';

  @override
  String get appClose => '閉じる';

  @override
  String get appConfirm => '確認';

  @override
  String get appYes => 'はい';

  @override
  String get appNo => 'いいえ';

  @override
  String get appLoadingData => 'データ読み込み中...';

  @override
  String get appRetry => '再試行';

  @override
  String get crudInitError => '初期化エラー';

  @override
  String get crudLoadDataError => 'データ読み込みエラー';

  @override
  String get crudSessionExpired => 'セッションの有効期限が切れました';

  @override
  String get crudPleaseLoginAgain => '続行するには再度ログインしてください';

  @override
  String get crudDeleteConfirmTitle => '削除の確認';

  @override
  String crudDeleteConfirmMessage(int count) {
    return '$count個のアイテムを削除してもよろしいですか?';
  }

  @override
  String get crudDeleteSuccess => '正常に削除されました';

  @override
  String get crudDeleteError => '削除エラー';

  @override
  String get crudLoadingConfig => '設定を読み込み中...';

  @override
  String get crudCannotLoadConfig => '設定を読み込めません';

  @override
  String get crudLoadConfigError => '設定読み込みエラー';

  @override
  String get crudCannotLoadData => 'アイテムデータを読み込めません';

  @override
  String get crudLoading => '読み込み中...';

  @override
  String get crudNoData => 'データなし';

  @override
  String get crudAddFirstItem => '+ボタンを押して新しいアイテムを追加';

  @override
  String crudAddFirstButton(String item) {
    return '最初の$itemを追加';
  }

  @override
  String get crudSaveSuccess => '保存成功';

  @override
  String get crudSaveError => '保存エラー';

  @override
  String get crudConnectionError => '接続エラー';

  @override
  String get authLogin => 'ログイン';

  @override
  String get authLogout => 'ログアウト';

  @override
  String get authUsername => 'ユーザー名';

  @override
  String get authPassword => 'パスワード';

  @override
  String get authLoginSuccess => 'ログインに成功しました';

  @override
  String get authLoginFailed => 'ログインに失敗しました';

  @override
  String get authPleaseEnterUsername => 'ユーザー名を入力してください';

  @override
  String get authPleaseEnterPassword => 'パスワードを入力してください';

  @override
  String get monitorItems => '監視項目';

  @override
  String get monitorConfigs => '監視アラート';

  @override
  String get monitorAddItem => '監視項目を追加';

  @override
  String get monitorEditItem => '監視項目を編集';

  @override
  String get monitorDeleteItem => '監視項目を削除';

  @override
  String get monitorAddConfig => '監視アラートを追加';

  @override
  String get monitorEditConfig => '監視アラートを編集';

  @override
  String get monitorDeleteConfig => '監視アラートを削除';

  @override
  String get monitorName => '監視名';

  @override
  String get monitorType => 'チェックタイプ';

  @override
  String get monitorUrl => 'Web/ドメイン/IPリンク';

  @override
  String get monitorInterval => 'チェック間隔';

  @override
  String get monitorAlertConfig => 'アラート設定';

  @override
  String get monitorEnable => '監視を有効化';

  @override
  String get monitorStatus => '最新ステータス';

  @override
  String get monitorLastCheck => '最終チェック';

  @override
  String get monitorOnline => 'オンライン';

  @override
  String get monitorOffline => 'オフライン';

  @override
  String get monitorAllowConsecutiveAlert => 'エラー時の連続アラートを許可';

  @override
  String get monitorErrorKeyword => 'エラーキーワード';

  @override
  String get monitorValidKeyword => '有効キーワード';

  @override
  String get monitorCreatedAt => '作成日時';

  @override
  String get configAlertType => 'アラートタイプ';

  @override
  String get configAlertConfig => 'アラート設定';

  @override
  String get configEmail => 'メール送信';

  @override
  String get configSms => 'SMS送信';

  @override
  String get configTelegram => 'Telegram送信';

  @override
  String get configWebhook => 'Webhook呼び出し';

  @override
  String get configSelectAlertType => 'アラートタイプを選択';

  @override
  String validationRequired(String field) {
    return '$fieldを入力してください';
  }

  @override
  String validationPleaseSelect(String field) {
    return '$fieldを選択してください';
  }

  @override
  String validationPleaseSelectAtLeastOne(String field) {
    return '少なくとも1つの$fieldを選択してください';
  }

  @override
  String validationInvalidFormat(String field) {
    return '$fieldの形式が無効です';
  }

  @override
  String get messagesSaveSuccess => '正常に保存されました';

  @override
  String get messagesSaveFailed => '保存に失敗しました';

  @override
  String get messagesDeleteSuccess => '正常に削除されました';

  @override
  String get messagesDeleteFailed => '削除に失敗しました';

  @override
  String messagesDeleteConfirm(String item) {
    return '$itemを削除してもよろしいですか？';
  }

  @override
  String get messagesNetworkError => 'ネットワークエラー';

  @override
  String get messagesServerError => 'サーバーエラー';

  @override
  String get messagesUnknownError => '不明なエラー';

  @override
  String messagesLoadingSettingsError(String error) {
    return '設定の読み込みエラー: $error';
  }

  @override
  String get navigationHome => 'ホーム';

  @override
  String get navigationMonitorItems => '監視項目';

  @override
  String get navigationMonitorConfigs => '監視設定';

  @override
  String get navigationProfile => 'プロフィール';

  @override
  String get navigationSettings => '設定';

  @override
  String get navigationNotifications => '通知';

  @override
  String get navigationAbout => 'アプリについて';

  @override
  String get navigationWelcome => 'ようこそ！';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageDescription => '優先言語を選択';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsDescription => '通知設定を管理';

  @override
  String get settingsNotificationSettings => '通知設定';

  @override
  String get settingsEnableNotifications => '通知を有効化';

  @override
  String get settingsEnableNotificationsDesc => 'アプリから通知を受信';

  @override
  String get settingsNotificationSound => '通知音';

  @override
  String get settingsNotificationSoundNotSelected => '未選択';

  @override
  String get settingsVibrate => 'バイブレーション';

  @override
  String get settingsVibrateDesc => '通知時にバイブレーション';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsThemeDescription => 'アプリの外観を選択';

  @override
  String get settingsAbout => 'アプリについて';

  @override
  String get settingsAboutDescription => 'バージョンとアプリ情報';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String get settingsEnglish => '英語';

  @override
  String get settingsVietnamese => 'ベトナム語';

  @override
  String get settingsLight => 'ライト';

  @override
  String get settingsDark => 'ダーク';

  @override
  String get settingsSystem => 'システム';

  @override
  String get settingsAppInfo => 'アプリ情報';

  @override
  String get settingsAppName => 'アプリ名';

  @override
  String get settingsSyncLanguage => '言語を同期';

  @override
  String get settingsSyncLanguageProgress => 'サーバーから言語を同期中...';

  @override
  String get settingsSyncLanguageSuccess => '言語の同期が完了しました';

  @override
  String settingsSyncLanguageError(String error) {
    return '言語同期エラー: $error';
  }

  @override
  String get settingsVietnameseDesc => 'Tiếng Việt (ベトナム語)';

  @override
  String get settingsEnglishDesc => 'English (英語)';

  @override
  String get settingsFrenchDesc => 'Français (フランス語)';

  @override
  String get settingsGermanDesc => 'Deutsch (ドイツ語)';

  @override
  String get settingsSpanishDesc => 'Español (スペイン語)';

  @override
  String get settingsJapaneseDesc => '日本語 (Japanese)';

  @override
  String get settingsKoreanDesc => '한국어 (韓国語)';

  @override
  String get languageAlreadySelected => '言語は既に選択されています';

  @override
  String get languageUpdateSuccess => '言語を正常に更新しました';

  @override
  String get languageChangedNotSynced => '言語を変更しました（サーバーと未同期）';

  @override
  String get languageChangeError => '言語変更エラー';

  @override
  String get languageUserNotLoggedIn => 'ユーザーがログインしていません';

  @override
  String get languageSessionExpired => 'セッションの有効期限が切れました';

  @override
  String get languageConnectionError => '接続エラー';

  @override
  String get languageApiError => 'APIエラー';

  @override
  String get languageHttpError => 'HTTPエラー';

  @override
  String get notificationSoundDefault => 'デフォルト（システム）';

  @override
  String get notificationSoundNone => 'なし（サイレント）';

  @override
  String get notificationSoundAlert => 'アラート';

  @override
  String get notificationSoundGentle => 'ソフト';

  @override
  String get notificationSoundUrgent => '緊急';

  @override
  String get notificationSoundSelectTitle => '通知音を選択';

  @override
  String get notificationSoundPreview => 'プレビュー';

  @override
  String get mobileActionNavigatingToConfig => '監視設定に移動中...';

  @override
  String get mobileActionNavigatingToItems => '監視項目に移動中...';

  @override
  String mobileActionCommandNotFound(String cmd) {
    return 'コマンドが見つかりません: \"$cmd\"';
  }

  @override
  String get timeSeconds => '秒';

  @override
  String get timeMinutes => '分';

  @override
  String get timeHours => '時間';

  @override
  String get timeDays => '日';

  @override
  String get timeSelectTime => '時間を選択';

  @override
  String get timeClearTime => '時間をクリア';

  @override
  String get timeNotSelected => '時間が選択されていません';

  @override
  String get timeSecond => '秒';

  @override
  String get timeMinute => '分';

  @override
  String get timeHour => '時間';

  @override
  String get timeDay => '日';

  @override
  String get timeMin => '分';

  @override
  String get timeMins => '分';

  @override
  String get timeAgo => '前';

  @override
  String get optionsSelect => '-選択-';

  @override
  String get optionsSelectAlertType => '-アラートタイプを選択-';

  @override
  String get optionsWebContent => 'Webサーバーアクティブ';

  @override
  String get optionsPing => 'Ping';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get profileEditProfile => 'プロフィールを編集';

  @override
  String get profileEditProfileTooltip => 'プロフィールを編集';

  @override
  String get profileDisplayName => '表示名';

  @override
  String get profileNoName => '名前なし';

  @override
  String get profileNoUsername => 'ユーザー名なし';

  @override
  String get profileNoEmail => 'メールなし';

  @override
  String get profileLoggedIn => 'ログイン中';

  @override
  String get profileLoginInfo => 'ログイン情報';

  @override
  String get profileLoginMethod => 'ログイン方法';

  @override
  String get profileLoginTime => 'ログイン時刻';

  @override
  String get profileBearerToken => 'Bearer Token';

  @override
  String get profileActions => 'アクション';

  @override
  String get profileRefreshInfo => '情報を更新';

  @override
  String get profileRefreshInfoDesc => '最新情報を更新';

  @override
  String get profileLogoutDesc => 'アカウントからサインアウト';

  @override
  String get profileLogoutConfirm => 'サインアウトしてもよろしいですか？';

  @override
  String get profileLoggingOut => 'サインアウト中...';

  @override
  String get profileLogoutSuccess => '✅ 正常にサインアウトしました';

  @override
  String profileLogoutError(String error) {
    return '❌ サインアウトエラー: $error';
  }

  @override
  String profileLoadError(String error) {
    return '情報の読み込みエラー: $error';
  }

  @override
  String get profileUpdateNotSupported => 'プロフィール更新機能はまだサポートされていません';

  @override
  String get profileLoginMethodWebApi => 'Web API (ユーザー名 & パスワード)';

  @override
  String get profileLoginMethodEmail => 'メール & パスワード';

  @override
  String get profileLoginMethodUnknown => '不明';

  @override
  String get aboutTitle => 'アプリについて';

  @override
  String get aboutAppVersion => 'Monitor App v1.0.0';

  @override
  String get aboutCopyright => 'GalaxyCloud © 2025';

  @override
  String get aboutDescription => 'サービスを監視・管理するためのアプリケーション';

  @override
  String get aboutDeveloper => 'GalaxyCloud.vnによって開発';

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
  String get filterTitle => 'フィルター';

  @override
  String get filterByName => '名前でフィルター';

  @override
  String get filterNameHint => '検索する名前を入力...';

  @override
  String get filterByStatus => 'ステータスでフィルター';

  @override
  String get filterShowError => 'エラーモニターを表示';

  @override
  String get filterShowErrorDesc => 'エラーのあるアイテム';

  @override
  String get filterShowSuccess => '成功モニターを表示';

  @override
  String get filterShowSuccessDesc => '成功したアイテム';

  @override
  String get filterByEnableStatus => '有効ステータスでフィルター';

  @override
  String get filterShowEnabled => '有効なモニターを表示';

  @override
  String get filterShowEnabledDesc => '有効なアイテム (enable = 1)';

  @override
  String get filterShowDisabled => '無効なモニターを表示';

  @override
  String get filterShowDisabledDesc => '無効なアイテム (enable = 0)';

  @override
  String get filterResetAll => 'すべてリセット';

  @override
  String get filterOk => 'OK';

  @override
  String get filterClear => 'クリア';

  @override
  String get filterShowing => '表示中';

  @override
  String get filterOf => 'の';

  @override
  String get filterItems => 'アイテム';

  @override
  String get filterName => '名前:';

  @override
  String get filterErrorItems => 'エラーアイテム';

  @override
  String get filterSuccessItems => '成功アイテム';

  @override
  String get filterEnabledItems => '有効アイテム';

  @override
  String get filterDisabledItems => '無効アイテム';

  @override
  String get filterNoMatch => 'フィルターに一致するアイテムがありません';

  @override
  String get filterClearFilters => 'フィルターをクリア';
}
