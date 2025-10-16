// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Ping2U - Theo dõi cảnh báo';

  @override
  String get appLoading => 'Đang tải...';

  @override
  String get appError => 'Lỗi';

  @override
  String get appSuccess => 'Thành công';

  @override
  String get appCancel => 'Hủy';

  @override
  String get appSave => 'Lưu';

  @override
  String get appAdd => 'Thêm';

  @override
  String get appEdit => 'Sửa';

  @override
  String get appDelete => 'Xóa';

  @override
  String get appUpdate => 'Cập nhật';

  @override
  String get appBack => 'Quay lại';

  @override
  String get appClose => 'Đóng';

  @override
  String get appConfirm => 'Xác nhận';

  @override
  String get appYes => 'Có';

  @override
  String get appNo => 'Không';

  @override
  String get appLoadingData => 'Đang tải dữ liệu...';

  @override
  String get appRetry => 'Sửa lại';

  @override
  String get crudInitError => 'Lỗi khởi tạo';

  @override
  String get crudLoadDataError => 'Lỗi tải dữ liệu';

  @override
  String get crudSessionExpired => 'Phiên đăng nhập hết hạn';

  @override
  String get crudPleaseLoginAgain => 'Vui lòng đăng nhập lại để tiếp tục';

  @override
  String get crudDeleteConfirmTitle => 'Xác nhận xóa';

  @override
  String crudDeleteConfirmMessage(int count) {
    return 'Bạn có chắc chắn muốn xóa $count item(s)?';
  }

  @override
  String get crudDeleteSuccess => 'Xóa thành công';

  @override
  String get crudDeleteError => 'Lỗi khi xóa';

  @override
  String get crudLoadingConfig => 'Đang tải cấu hình...';

  @override
  String get crudCannotLoadConfig => 'Không thể tải cấu hình';

  @override
  String get crudLoadConfigError => 'Lỗi khi tải cấu hình';

  @override
  String get crudCannotLoadData => 'Không thể tải dữ liệu item';

  @override
  String get crudLoading => 'Đang tải...';

  @override
  String get crudNoData => 'Chưa có dữ liệu';

  @override
  String get crudAddFirstItem => 'Nhấn nút + để thêm item mới';

  @override
  String crudAddFirstButton(String item) {
    return 'Thêm $item đầu tiên';
  }

  @override
  String get crudSaveSuccess => 'Lưu thành công';

  @override
  String get crudSaveError => 'Lỗi khi lưu';

  @override
  String get crudConnectionError => 'Lỗi kết nối';

  @override
  String get authLogin => 'Đăng nhập';

  @override
  String get authLogout => 'Đăng xuất';

  @override
  String get authUsername => 'Tên đăng nhập';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authLoginSuccess => 'Đăng nhập thành công';

  @override
  String get authLoginFailed => 'Đăng nhập thất bại';

  @override
  String get authPleaseEnterUsername => 'Vui lòng nhập tên đăng nhập';

  @override
  String get authPleaseEnterPassword => 'Vui lòng nhập mật khẩu';

  @override
  String get authRegister => 'Đăng ký';

  @override
  String get authLoginWith => 'Đăng nhập với';

  @override
  String get authForgotPassword => 'Quên mật khẩu';

  @override
  String get authOr => 'hoặc';

  @override
  String get authFullName => 'Họ và Tên';

  @override
  String get authPleaseEnterFullName => 'Vui lòng nhập họ và tên';

  @override
  String get authLogoutConfirm => 'Bạn có chắc chắn muốn đăng xuất?';

  @override
  String get authLoggingOut => 'Đang đăng xuất...';

  @override
  String get authLogoutError => 'Lỗi đăng xuất';

  @override
  String get authRegisterNewAccount => 'Đăng Ký Tài Khoản Mới';

  @override
  String get authRegisterDescription =>
      'Nhấn nút bên dưới để mở trang đăng ký trên trình duyệt';

  @override
  String get authOpenRegistrationPage => 'Mở Trang Đăng Ký';

  @override
  String get authAfterRegistration =>
      'Sau khi đăng ký, quay lại đây để đăng nhập';

  @override
  String get authCouldNotOpenRegistration => 'Không thể mở trang đăng ký';

  @override
  String get monitorItems => 'Ping Items';

  @override
  String get monitorConfigs => 'Monitor Cảnh báo';

  @override
  String get monitorAddItem => 'Thêm Ping Item';

  @override
  String get monitorEditItem => 'Sửa Ping Item';

  @override
  String get monitorDeleteItem => 'Xóa Ping Item';

  @override
  String get monitorAddConfig => 'Thêm Monitor Cảnh báo';

  @override
  String get monitorEditConfig => 'Sửa Monitor Cảnh báo';

  @override
  String get monitorDeleteConfig => 'Xóa Monitor Cảnh báo';

  @override
  String get monitorName => 'Tên monitor';

  @override
  String get monitorType => 'Kiểu kiểm tra';

  @override
  String get monitorUrl => 'Link Web/Domain/IP';

  @override
  String get monitorInterval => 'Khoảng thời gian kiểm tra';

  @override
  String get monitorAlertConfig => 'Cấu hình cảnh báo';

  @override
  String get monitorEnable => 'Bật kiểm tra';

  @override
  String get monitorStatus => 'Trạng thái gần nhất';

  @override
  String get monitorLastCheck => 'Kiểm tra gần nhất';

  @override
  String get monitorOnline => 'Online';

  @override
  String get monitorOffline => 'Offline';

  @override
  String get monitorAllowConsecutiveAlert =>
      'Cho phép gửi cảnh báo liên tiếp khi lỗi';

  @override
  String get monitorErrorKeyword => 'Keyword nếu lỗi';

  @override
  String get monitorValidKeyword => 'Keyword nếu không lỗi';

  @override
  String get monitorCreatedAt => 'Ngày tạo';

  @override
  String get configAlertType => 'Loại cảnh báo';

  @override
  String get configAlertConfig => 'Cấu hình cảnh báo';

  @override
  String get configEmail => 'Gửi Email';

  @override
  String get configSms => 'Gửi SMS';

  @override
  String get configTelegram => 'Gửi Telegram';

  @override
  String get configWebhook => 'Gọi Webhook';

  @override
  String get configSelectAlertType => 'Chọn loại cảnh báo';

  @override
  String validationRequired(String field) {
    return 'Vui lòng nhập $field';
  }

  @override
  String validationPleaseSelect(String field) {
    return 'Vui lòng chọn $field';
  }

  @override
  String validationPleaseSelectAtLeastOne(String field) {
    return 'Vui lòng chọn ít nhất một $field';
  }

  @override
  String validationInvalidFormat(String field) {
    return 'Định dạng $field không hợp lệ';
  }

  @override
  String get messagesSaveSuccess => 'Lưu thành công';

  @override
  String get messagesSaveFailed => 'Lưu thất bại';

  @override
  String get messagesDeleteSuccess => 'Xóa thành công';

  @override
  String get messagesDeleteFailed => 'Xóa thất bại';

  @override
  String messagesDeleteConfirm(String item) {
    return 'Bạn có chắc chắn muốn xóa $item?';
  }

  @override
  String get messagesNetworkError => 'Lỗi kết nối mạng';

  @override
  String get messagesServerError => 'Lỗi máy chủ';

  @override
  String get messagesUnknownError => 'Lỗi không xác định';

  @override
  String messagesLoadingSettingsError(String error) {
    return 'Lỗi khi tải cài đặt: $error';
  }

  @override
  String get navigationHome => 'Trang chủ';

  @override
  String get navigationMonitorItems => 'Danh sách Monitor';

  @override
  String get navigationMonitorConfigs => 'Cấu hình Cảnh báo';

  @override
  String get navigationProfile => 'Hồ sơ';

  @override
  String get navigationSettings => 'Cài đặt';

  @override
  String get navigationNotifications => 'Thông báo';

  @override
  String get navigationAbout => 'Giới thiệu';

  @override
  String get navigationWelcome => 'Chào mừng bạn!';

  @override
  String get homeDashboard => 'Bảng điều khiển';

  @override
  String get homeStatistics => 'Thống kê';

  @override
  String get homeTotal => 'Tổng';

  @override
  String get homeError => 'Lỗi';

  @override
  String get homeOk => 'OK';

  @override
  String get homeOther => 'Khác';

  @override
  String get homeLoadingMonitors => 'Đang tải monitors...';

  @override
  String get homeNoMonitors => 'Không tìm thấy monitor';

  @override
  String get homeAddMonitorsHint => 'Thêm monitors để hiển thị ở đây';

  @override
  String get homeNoData => 'Không có dữ liệu';

  @override
  String get homeRefresh => 'Làm mới';

  @override
  String get homeRetry => 'Thử lại';

  @override
  String get homeAddPingItem => 'Thêm Ping Item';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsLanguageDescription => 'Chọn ngôn ngữ ưa thích';

  @override
  String get settingsNotifications => 'Thông báo';

  @override
  String get settingsNotificationsDescription => 'Quản lý cài đặt thông báo';

  @override
  String get settingsNotificationSettings => 'Cài đặt Thông báo';

  @override
  String get settingsEnableNotifications => 'Bật thông báo';

  @override
  String get settingsEnableNotificationsDesc => 'Nhận thông báo từ ứng dụng';

  @override
  String get settingsNotificationSound => 'Âm thanh thông báo';

  @override
  String get settingsNotificationSoundNotSelected => 'Chưa chọn';

  @override
  String get settingsVibrate => 'Rung';

  @override
  String get settingsVibrateDesc => 'Rung khi có thông báo';

  @override
  String get settingsTheme => 'Giao diện';

  @override
  String get settingsThemeDescription => 'Chọn giao diện ứng dụng';

  @override
  String get settingsAbout => 'Về ứng dụng';

  @override
  String get settingsAboutDescription => 'Phiên bản và thông tin ứng dụng';

  @override
  String get settingsVersion => 'Phiên bản';

  @override
  String get settingsEnglish => 'Tiếng Anh';

  @override
  String get settingsVietnamese => 'Tiếng Việt';

  @override
  String get settingsLight => 'Sáng';

  @override
  String get settingsDark => 'Tối';

  @override
  String get settingsSystem => 'Theo hệ thống';

  @override
  String get settingsAppInfo => 'Thông tin ứng dụng';

  @override
  String get settingsAppName => 'Tên ứng dụng';

  @override
  String get settingsSyncLanguage => 'Đồng bộ ngôn ngữ';

  @override
  String get settingsSyncLanguageProgress =>
      'Đang đồng bộ ngôn ngữ từ server...';

  @override
  String get settingsSyncLanguageSuccess => 'Đồng bộ ngôn ngữ thành công';

  @override
  String settingsSyncLanguageError(String error) {
    return 'Lỗi đồng bộ ngôn ngữ: $error';
  }

  @override
  String get settingsVietnameseDesc => 'Tiếng Việt (mặc định)';

  @override
  String get settingsEnglishDesc => 'English';

  @override
  String get settingsWindowsSettings => 'Cài đặt Windows';

  @override
  String get settingsStartupWithWindows => 'Khởi động cùng Windows';

  @override
  String get settingsStartupWithWindowsDesc =>
      'Tự động chạy khi Windows khởi động';

  @override
  String get settingsFrenchDesc => 'Tiếng Pháp';

  @override
  String get settingsGermanDesc => 'Tiếng Đức';

  @override
  String get settingsSpanishDesc => 'Tiếng Tây Ban Nha';

  @override
  String get settingsJapaneseDesc => 'Tiếng Nhật';

  @override
  String get settingsKoreanDesc => 'Tiếng Hàn';

  @override
  String get languageAlreadySelected => 'Ngôn ngữ đã được chọn';

  @override
  String get languageUpdateSuccess => 'Đã cập nhật ngôn ngữ thành công';

  @override
  String get languageChangedNotSynced =>
      'Đã thay đổi ngôn ngữ (chưa đồng bộ lên server)';

  @override
  String get languageChangeError => 'Lỗi khi thay đổi ngôn ngữ';

  @override
  String get languageUserNotLoggedIn => 'Người dùng chưa đăng nhập';

  @override
  String get languageSessionExpired => 'Phiên đăng nhập hết hạn';

  @override
  String get languageConnectionError => 'Lỗi kết nối';

  @override
  String get languageApiError => 'API trả về lỗi';

  @override
  String get languageHttpError => 'Lỗi HTTP';

  @override
  String get notificationSoundDefault => 'Mặc định (Hệ thống)';

  @override
  String get notificationSoundNone => 'Không (Im lặng)';

  @override
  String get notificationSoundAlert => 'Cảnh báo';

  @override
  String get notificationSoundGentle => 'Nhẹ nhàng';

  @override
  String get notificationSoundUrgent => 'Khẩn cấp';

  @override
  String get notificationSoundSelectTitle => 'Chọn âm thanh thông báo';

  @override
  String get notificationSoundPreview => 'Nghe thử';

  @override
  String get mobileActionNavigatingToConfig =>
      'Đang chuyển đến Monitor Config...';

  @override
  String get mobileActionNavigatingToItems => 'Đang chuyển đến Ping Items...';

  @override
  String mobileActionCommandNotFound(String cmd) {
    return 'Không tìm thấy lệnh: \"$cmd\"';
  }

  @override
  String get timeSeconds => 'Giây';

  @override
  String get timeMinutes => 'Phút';

  @override
  String get timeHours => 'Giờ';

  @override
  String get timeDays => 'Ngày';

  @override
  String get timeSelectTime => 'Chọn thời gian';

  @override
  String get timeClearTime => 'Xóa thời gian';

  @override
  String get timeNotSelected => 'Chưa chọn thời gian';

  @override
  String get timeSecond => 'giây';

  @override
  String get timeMinute => 'phút';

  @override
  String get timeHour => 'giờ';

  @override
  String get timeDay => 'ngày';

  @override
  String get timeMin => 'phút';

  @override
  String get timeMins => 'phút';

  @override
  String get timeAgo => 'trước';

  @override
  String get optionsSelect => '-Chọn-';

  @override
  String get optionsSelectAlertType => '-Chọn Kiểu Alert-';

  @override
  String get optionsWebContent => 'Web Server hoạt động';

  @override
  String get optionsPing => 'Ping';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get profileEditProfile => 'Chỉnh sửa hồ sơ';

  @override
  String get profileEditProfileTooltip => 'Chỉnh sửa hồ sơ';

  @override
  String get profileDisplayName => 'Tên hiển thị';

  @override
  String get profileNoName => 'Chưa có tên';

  @override
  String get profileNoUsername => 'Chưa có username';

  @override
  String get profileNoEmail => 'Chưa có email';

  @override
  String get profileLoggedIn => 'Đã đăng nhập';

  @override
  String get profileLoginInfo => 'Thông tin đăng nhập';

  @override
  String get profileLoginMethod => 'Phương thức đăng nhập';

  @override
  String get profileLoginTime => 'Thời gian đăng nhập';

  @override
  String get profileBearerToken => 'Bearer Token';

  @override
  String get profileActions => 'Hành động';

  @override
  String get profileRefreshInfo => 'Làm mới thông tin';

  @override
  String get profileRefreshInfoDesc => 'Cập nhật thông tin mới nhất';

  @override
  String get profileLogoutDesc => 'Thoát khỏi tài khoản';

  @override
  String get profileLogoutConfirm => 'Bạn có chắc chắn muốn đăng xuất?';

  @override
  String get profileLoggingOut => 'Đang đăng xuất...';

  @override
  String get profileLogoutSuccess => '✅ Đăng xuất thành công';

  @override
  String profileLogoutError(String error) {
    return '❌ Lỗi khi đăng xuất: $error';
  }

  @override
  String profileLoadError(String error) {
    return 'Lỗi khi tải thông tin: $error';
  }

  @override
  String get profileUpdateNotSupported =>
      'Chức năng cập nhật hồ sơ chưa được hỗ trợ';

  @override
  String get profileLoginMethodWebApi => 'Web API (Username & Password)';

  @override
  String get profileLoginMethodEmail => 'Email & Mật khẩu';

  @override
  String get profileLoginMethodUnknown => 'Không xác định';

  @override
  String get aboutTitle => 'Giới thiệu';

  @override
  String get aboutAppVersion => 'Ping365 v1.0.0';

  @override
  String get aboutCopyright => 'GalaxyCloud © 2025';

  @override
  String get aboutDescription =>
      'Ứng dụng giám sát và quản lý dịch vụ của bạn.';

  @override
  String get aboutDeveloper => 'Phát triển bởi GalaxyCloud.vn';

  @override
  String get errorDialogTitle => 'Lỗi';

  @override
  String get errorDialogDetails => 'Chi tiết lỗi:';

  @override
  String get errorDialogHints => 'Gợi ý:';

  @override
  String get errorDialogHintsEmail => 'Gợi ý về Email:';

  @override
  String get errorDialogHintEmailValid =>
      'Email phải có định dạng hợp lệ (ví dụ: user@domain.com)';

  @override
  String get errorDialogHintEmailMultiple =>
      'Nhiều email cách nhau bằng dấu phẩy';

  @override
  String get errorDialogHintEmailNoSpace => 'Không được chứa khoảng trắng thừa';

  @override
  String get errorDialogHintsUrl => 'Gợi ý về URL:';

  @override
  String get errorDialogHintUrlValid =>
      'URL phải có định dạng hợp lệ (ví dụ: https://example.com)';

  @override
  String get errorDialogHintUrlProtocol =>
      'Phải bắt đầu bằng http:// hoặc https://';

  @override
  String get errorDialogHintUrlNoSpecial =>
      'Không được chứa ký tự đặc biệt không hợp lệ';

  @override
  String get errorDialogHintsPassword => 'Gợi ý về Mật khẩu:';

  @override
  String get errorDialogHintPasswordLength =>
      'Mật khẩu phải có ít nhất 8 ký tự';

  @override
  String get errorDialogHintPasswordMix =>
      'Nên chứa cả chữ hoa, chữ thường và số';

  @override
  String get errorDialogHintPasswordNoSpace => 'Không được chứa khoảng trắng';

  @override
  String get errorDialogHintRequired1 =>
      'Vui lòng điền đầy đủ các trường bắt buộc';

  @override
  String get errorDialogHintRequired2 => 'Các trường có dấu (*) là bắt buộc';

  @override
  String get errorDialogHintRequired3 => 'Kiểm tra lại form trước khi submit';

  @override
  String get errorDialogHintDuplicate1 =>
      'Giá trị này đã tồn tại trong hệ thống';

  @override
  String get errorDialogHintDuplicate2 => 'Vui lòng chọn giá trị khác';

  @override
  String get errorDialogHintDuplicate3 =>
      'Kiểm tra danh sách hiện có trước khi thêm mới';

  @override
  String get httpErrorTechnical => 'Chi tiết kỹ thuật';

  @override
  String get httpErrorSuggestions => 'Gợi ý khắc phục:';

  @override
  String get httpErrorClose => 'Đóng';

  @override
  String get httpErrorRetry => 'Thử lại';

  @override
  String get httpError400Title => 'Yêu cầu không hợp lệ';

  @override
  String get httpError400Desc =>
      'Dữ liệu gửi lên server không đúng định dạng hoặc thiếu thông tin bắt buộc.';

  @override
  String get httpError400Hint1 => 'Kiểm tra lại tất cả các trường thông tin';

  @override
  String get httpError400Hint2 =>
      'Đảm bảo email, URL, số điện thoại có định dạng đúng';

  @override
  String get httpError400Hint3 => 'Không để trống các trường bắt buộc';

  @override
  String get httpError401Title => 'Chưa đăng nhập';

  @override
  String get httpError401Desc =>
      'Phiên đăng nhập đã hết hạn hoặc bạn chưa đăng nhập vào hệ thống.';

  @override
  String get httpError401Hint1 => 'Vui lòng đăng nhập lại';

  @override
  String get httpError401Hint2 => 'Kiểm tra kết nối mạng';

  @override
  String get httpError401Hint3 =>
      'Liên hệ quản trị viên nếu vấn đề vẫn tiếp diễn';

  @override
  String get httpError403Title => 'Không có quyền truy cập';

  @override
  String get httpError403Desc =>
      'Bạn không có quyền thực hiện thao tác này. Vui lòng liên hệ quản trị viên.';

  @override
  String get httpError403Hint1 => 'Liên hệ quản trị viên để được cấp quyền';

  @override
  String get httpError403Hint2 => 'Đăng nhập với tài khoản có quyền phù hợp';

  @override
  String get httpError404Title => 'Không tìm thấy';

  @override
  String get httpError404Desc =>
      'Tài nguyên yêu cầu không tồn tại hoặc đã bị xóa.';

  @override
  String get httpError404Hint1 => 'Kiểm tra lại URL hoặc ID';

  @override
  String get httpError404Hint2 => 'Làm mới danh sách và thử lại';

  @override
  String get httpError404Hint3 => 'Dữ liệu có thể đã bị xóa trước đó';

  @override
  String get httpError408Title => 'Hết thời gian chờ';

  @override
  String get httpError408Desc =>
      'Yêu cầu mất quá nhiều thời gian. Vui lòng thử lại.';

  @override
  String get httpError408Hint1 => 'Kiểm tra kết nối internet';

  @override
  String get httpError408Hint2 => 'Thử lại sau vài giây';

  @override
  String get httpError408Hint3 => 'Liên hệ hỗ trợ nếu lỗi lặp lại';

  @override
  String get httpError429Title => 'Quá nhiều yêu cầu';

  @override
  String get httpError429Desc =>
      'Bạn đã gửi quá nhiều yêu cầu trong thời gian ngắn. Vui lòng đợi và thử lại.';

  @override
  String get httpError429Hint1 => 'Đợi một vài phút trước khi thử lại';

  @override
  String get httpError429Hint2 => 'Tránh gửi yêu cầu liên tục';

  @override
  String get httpError500Title => 'Lỗi máy chủ';

  @override
  String get httpError500Desc =>
      'Server gặp lỗi khi xử lý yêu cầu. Vui lòng thử lại sau.';

  @override
  String get httpError500Hint1 => 'Đợi vài phút rồi thử lại';

  @override
  String get httpError500Hint2 =>
      'Liên hệ bộ phận kỹ thuật nếu lỗi vẫn tiếp diễn';

  @override
  String get httpError500Hint3 => 'Lưu dữ liệu quan trọng trước khi thử lại';

  @override
  String get httpError503Title => 'Dịch vụ tạm thời không khả dụng';

  @override
  String get httpError503Desc =>
      'Server đang bảo trì hoặc quá tải. Vui lòng thử lại sau.';

  @override
  String get httpError503Hint1 => 'Thử lại sau 5-10 phút';

  @override
  String get httpError503Hint2 => 'Kiểm tra thông báo bảo trì từ quản trị viên';

  @override
  String get httpError503Hint3 => 'Liên hệ hỗ trợ kỹ thuật nếu cần gấp';

  @override
  String get httpErrorDefaultTitle => 'Lỗi không xác định';

  @override
  String get httpErrorDefaultDesc =>
      'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại hoặc liên hệ hỗ trợ.';

  @override
  String get httpErrorDefaultHint1 => 'Thử lại sau vài phút';

  @override
  String get httpErrorDefaultHint2 => 'Kiểm tra kết nối internet';

  @override
  String httpErrorDefaultHint3(Object code) {
    return 'Liên hệ bộ phận hỗ trợ với mã lỗi $code';
  }

  @override
  String get filterTitle => 'Bộ lọc';

  @override
  String get filterByName => 'Lọc theo tên';

  @override
  String get filterNameHint => 'Nhập tên để tìm kiếm...';

  @override
  String get filterByStatus => 'Lọc theo trạng thái';

  @override
  String get filterShowError => 'Hiển thị monitor OFFLINE';

  @override
  String get filterShowErrorDesc => 'Các item có lỗi';

  @override
  String get filterShowSuccess => 'Hiển thị monitor ONLINE';

  @override
  String get filterShowSuccessDesc => 'Các item thành công';

  @override
  String get filterByEnableStatus => 'Lọc theo trạng thái kích hoạt';

  @override
  String get filterShowEnabled => 'Hiển thị monitor đang bật theo dõi';

  @override
  String get filterShowEnabledDesc => 'Các item có enable = 1';

  @override
  String get filterShowDisabled => 'Hiển thị monitor tắt theo dõi';

  @override
  String get filterShowDisabledDesc => 'Các item có enable = 0';

  @override
  String get filterResetAll => 'Đặt lại tất cả';

  @override
  String get filterOk => 'OK';

  @override
  String get filterClear => 'Xóa';

  @override
  String get filterShowing => 'Hiển thị';

  @override
  String get filterOf => 'của';

  @override
  String get filterItems => 'items';

  @override
  String get filterName => 'Tên:';

  @override
  String get filterErrorItems => 'Items lỗi';

  @override
  String get filterSuccessItems => 'Items thành công';

  @override
  String get filterEnabledItems => 'Items đã kích hoạt';

  @override
  String get filterDisabledItems => 'Items đã vô hiệu hóa';

  @override
  String get filterNoMatch => 'Không có item nào khớp với bộ lọc';

  @override
  String get filterClearFilters => 'Xóa bộ lọc';
}
