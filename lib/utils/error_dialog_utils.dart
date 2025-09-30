import 'package:flutter/material.dart';

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
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Sửa lại'),
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
}
