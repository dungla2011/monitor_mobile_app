import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Utility class for handling error dialogs with Unicode support
class ErrorDialogUtils {
  /// Decode Unicode escape sequences in error messages
  static String decodeUnicodeMessage(String message) {
    try {
      // Replace Unicode escape sequences like \u1ed7i with actual characters
      return message.replaceAllMapped(RegExp(r'\\u([0-9a-fA-F]{4})'), (match) {
        final hexCode = match.group(1)!;
        final charCode = int.parse(hexCode, radix: 16);
        return String.fromCharCode(charCode);
      });
    } catch (e) {
      return message; // Return original if decoding fails
    }
  }

  /// Show detailed error dialog with Unicode support and contextual hints
  static Future<void> showErrorDialog(
    BuildContext context,
    String errorMessage, {
    String? title,
    List<String>? customHints,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(title ?? 'Lỗi'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Chi tiết lỗi:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Always try to decode Unicode first
                      SelectableText(
                        decodeUnicodeMessage(errorMessage),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      // Show original if it contains Unicode escape sequences
                      if (errorMessage.contains('\\u') &&
                          decodeUnicodeMessage(errorMessage) != errorMessage)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Raw message:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                errorMessage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Add helpful hints based on error type or custom hints
                ..._buildHints(errorMessage, customHints),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.appClose),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.appRetry),
            ),
          ],
        );
      },
    );
  }

  /// Build hint containers based on error message content or custom hints
  static List<Widget> _buildHints(
    String errorMessage,
    List<String>? customHints,
  ) {
    final hints = <Widget>[];
    final lowerErrorMessage = errorMessage.toLowerCase();

    // Custom hints take precedence
    if (customHints != null && customHints.isNotEmpty) {
      hints.add(_buildHintContainer('Gợi ý:', customHints, Colors.blue));
    } else {
      // Auto-detect hints based on error message content
      if (lowerErrorMessage.contains('email')) {
        hints.add(
          _buildHintContainer(
              'Gợi ý về Email:',
              [
                'Email phải có định dạng hợp lệ (ví dụ: user@domain.com)',
                'Nhiều email cách nhau bằng dấu phẩy',
                'Không được chứa khoảng trắng thừa',
              ],
              Colors.blue),
        );
      }

      if (lowerErrorMessage.contains('url')) {
        hints.add(
          _buildHintContainer(
              'Gợi ý về URL:',
              [
                'URL phải có định dạng hợp lệ (ví dụ: https://example.com)',
                'Phải bắt đầu bằng http:// hoặc https://',
                'Không được chứa ký tự đặc biệt không hợp lệ',
              ],
              Colors.blue),
        );
      }

      if (lowerErrorMessage.contains('password') ||
          lowerErrorMessage.contains('mật khẩu')) {
        hints.add(
          _buildHintContainer(
              'Gợi ý về Mật khẩu:',
              [
                'Mật khẩu phải có ít nhất 8 ký tự',
                'Nên chứa cả chữ hoa, chữ thường và số',
                'Không được chứa khoảng trắng',
              ],
              Colors.orange),
        );
      }

      if (lowerErrorMessage.contains('required') ||
          lowerErrorMessage.contains('bắt buộc')) {
        hints.add(
          _buildHintContainer(
              'Gợi ý:',
              [
                'Vui lòng điền đầy đủ các trường bắt buộc',
                'Các trường có dấu (*) là bắt buộc',
                'Kiểm tra lại form trước khi submit',
              ],
              Colors.red),
        );
      }

      if (lowerErrorMessage.contains('duplicate') ||
          lowerErrorMessage.contains('trùng lặp')) {
        hints.add(
          _buildHintContainer(
              'Gợi ý:',
              [
                'Giá trị này đã tồn tại trong hệ thống',
                'Vui lòng chọn giá trị khác',
                'Kiểm tra danh sách hiện có trước khi thêm mới',
              ],
              Colors.orange),
        );
      }
    }

    return hints;
  }

  /// Build a hint container with icon and text list
  static Widget _buildHintContainer(
    String title,
    List<String> hints,
    MaterialColor color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hints.map((hint) => '• $hint').join('\n'),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// Show success snackbar with consistent styling
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show warning snackbar with consistent styling
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show info snackbar with consistent styling
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show HTTP error dialog with status code explanation and hints
  static Future<void> showHttpErrorDialog(
    BuildContext context,
    int statusCode,
    String? errorMessage, {
    String? technicalDetails,
  }) async {
    final errorInfo = _getHttpErrorInfo(statusCode);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: errorInfo.color.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  errorInfo.icon,
                  color: errorInfo.color.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      errorInfo.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: errorInfo.color.shade900,
                      ),
                    ),
                    Text(
                      'HTTP $statusCode',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: errorInfo.color.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: errorInfo.color.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: errorInfo.color.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorInfo.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Custom error message if provided
                if (errorMessage != null && errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Chi tiết lỗi:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          decodeUnicodeMessage(errorMessage),
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Technical details (collapsible)
                if (technicalDetails != null &&
                    technicalDetails.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      'Chi tiết kỹ thuật',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: SelectableText(
                          technicalDetails,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Hints
                if (errorInfo.hints.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 18,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Gợi ý khắc phục:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...errorInfo.hints.map((hint) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      hint,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Đóng'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: errorInfo.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get HTTP error information with localized descriptions and hints
  static _HttpErrorInfo _getHttpErrorInfo(int statusCode) {
    switch (statusCode) {
      case 400:
        return _HttpErrorInfo(
          title: 'Yêu cầu không hợp lệ',
          description:
              'Dữ liệu gửi lên server không đúng định dạng hoặc thiếu thông tin bắt buộc.',
          hints: [
            'Kiểm tra lại tất cả các trường thông tin',
            'Đảm bảo email, URL, số điện thoại có định dạng đúng',
            'Không để trống các trường bắt buộc',
          ],
          icon: Icons.error_outline,
          color: Colors.orange,
        );
      case 401:
        return _HttpErrorInfo(
          title: 'Chưa đăng nhập',
          description:
              'Phiên đăng nhập đã hết hạn hoặc bạn chưa đăng nhập vào hệ thống.',
          hints: [
            'Vui lòng đăng nhập lại',
            'Kiểm tra kết nối mạng',
            'Liên hệ quản trị viên nếu vấn đề vẫn tiếp diễn',
          ],
          icon: Icons.lock_outline,
          color: Colors.amber,
        );
      case 403:
        return _HttpErrorInfo(
          title: 'Không có quyền truy cập',
          description:
              'Bạn không có quyền thực hiện thao tác này. Vui lòng liên hệ quản trị viên.',
          hints: [
            'Liên hệ quản trị viên để được cấp quyền',
            'Đăng nhập với tài khoản có quyền phù hợp',
          ],
          icon: Icons.block,
          color: Colors.red,
        );
      case 404:
        return _HttpErrorInfo(
          title: 'Không tìm thấy',
          description: 'Tài nguyên yêu cầu không tồn tại hoặc đã bị xóa.',
          hints: [
            'Kiểm tra lại URL hoặc ID',
            'Làm mới danh sách và thử lại',
            'Dữ liệu có thể đã bị xóa trước đó',
          ],
          icon: Icons.search_off,
          color: Colors.grey,
        );
      case 408:
        return _HttpErrorInfo(
          title: 'Hết thời gian chờ',
          description: 'Yêu cầu mất quá nhiều thời gian. Vui lòng thử lại.',
          hints: [
            'Kiểm tra kết nối internet',
            'Thử lại sau vài giây',
            'Liên hệ hỗ trợ nếu lỗi lặp lại',
          ],
          icon: Icons.hourglass_empty,
          color: Colors.orange,
        );
      case 429:
        return _HttpErrorInfo(
          title: 'Quá nhiều yêu cầu',
          description:
              'Bạn đã gửi quá nhiều yêu cầu trong thời gian ngắn. Vui lòng đợi và thử lại.',
          hints: [
            'Đợi một vài phút trước khi thử lại',
            'Tránh gửi yêu cầu liên tục',
          ],
          icon: Icons.speed,
          color: Colors.orange,
        );
      case 500:
        return _HttpErrorInfo(
          title: 'Lỗi máy chủ',
          description:
              'Server gặp lỗi khi xử lý yêu cầu. Vui lòng thử lại sau.',
          hints: [
            'Đợi vài phút rồi thử lại',
            'Liên hệ bộ phận kỹ thuật nếu lỗi vẫn tiếp diễn',
            'Lưu dữ liệu quan trọng trước khi thử lại',
          ],
          icon: Icons.dns_outlined,
          color: Colors.red,
        );
      case 502:
      case 503:
      case 504:
        return _HttpErrorInfo(
          title: 'Dịch vụ tạm thời không khả dụng',
          description:
              'Server đang bảo trì hoặc quá tải. Vui lòng thử lại sau.',
          hints: [
            'Thử lại sau 5-10 phút',
            'Kiểm tra thông báo bảo trì từ quản trị viên',
            'Liên hệ hỗ trợ kỹ thuật nếu cần gấp',
          ],
          icon: Icons.cloud_off,
          color: Colors.grey,
        );
      default:
        return _HttpErrorInfo(
          title: 'Lỗi không xác định',
          description:
              'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại hoặc liên hệ hỗ trợ.',
          hints: [
            'Thử lại sau vài phút',
            'Kiểm tra kết nối internet',
            'Liên hệ bộ phận hỗ trợ với mã lỗi $statusCode',
          ],
          icon: Icons.help_outline,
          color: Colors.red,
        );
    }
  }
}

/// Helper class to store HTTP error information
class _HttpErrorInfo {
  final String title;
  final String description;
  final List<String> hints;
  final IconData icon;
  final MaterialColor color;

  _HttpErrorInfo({
    required this.title,
    required this.description,
    required this.hints,
    required this.icon,
    required this.color,
  });
}
