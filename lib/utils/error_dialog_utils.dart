import 'package:flutter/material.dart';
import 'package:monitor_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(title ?? l10n.errorDialogTitle),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.errorDialogDetails,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
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
    // We need BuildContext for l10n, but this is a static method
    // So we'll return a builder function that can access context
    // For now, we'll keep the Vietnamese text as placeholders
    // and fix this properly with a context parameter
    final hints = <Widget>[];
    final lowerErrorMessage = errorMessage.toLowerCase();

    // Custom hints take precedence
    if (customHints != null && customHints.isNotEmpty) {
      hints.add(_buildHintContainer('Hints:', customHints, Colors.blue));
    } else {
      // Auto-detect hints based on error message content
      if (lowerErrorMessage.contains('email')) {
        hints.add(
          _buildHintContainer(
              'Email hints:',
              [
                'Email must be in valid format (e.g.: user@domain.com)',
                'Multiple emails separated by commas',
                'Should not contain extra spaces',
              ],
              Colors.blue),
        );
      }

      if (lowerErrorMessage.contains('url')) {
        hints.add(
          _buildHintContainer(
              'URL hints:',
              [
                'URL must be in valid format (e.g.: https://example.com)',
                'Must start with http:// or https://',
                'Should not contain invalid special characters',
              ],
              Colors.blue),
        );
      }

      if (lowerErrorMessage.contains('password')) {
        hints.add(
          _buildHintContainer(
              'Password hints:',
              [
                'Password must be at least 8 characters',
                'Should contain uppercase, lowercase, and numbers',
                'Should not contain spaces',
              ],
              Colors.orange),
        );
      }

      if (lowerErrorMessage.contains('required')) {
        hints.add(
          _buildHintContainer(
              'Hints:',
              [
                'Please fill in all required fields',
                'Fields with (*) are required',
                'Check form before submitting',
              ],
              Colors.red),
        );
      }

      if (lowerErrorMessage.contains('duplicate')) {
        hints.add(
          _buildHintContainer(
              'Hints:',
              [
                'This value already exists in the system',
                'Please choose a different value',
                'Check existing list before adding new',
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
    String? errorLink, // Add error link parameter
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
                // Error description - Only show if not empty
                if (errorInfo.description.isNotEmpty)
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
                              fontSize: 10,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Custom error message if provided
                if (errorMessage != null && errorMessage.isNotEmpty) ...[
                  // Add spacing only if description was shown
                  if (errorInfo.description.isNotEmpty)
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
                              'Error details:',
                              style: TextStyle(
                                fontSize: 15,
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
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),

                        // Error link if provided
                        if (errorLink != null &&
                            errorLink.isNotEmpty &&
                            _isValidUrl(errorLink)) ...[
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _openUrl(errorLink),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 18, // Increased from 16
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      errorLink,
                                      style: TextStyle(
                                        fontSize: 15, // Increased from 13
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight
                                            .w500, // Add medium weight
                                        // decoration: TextDecoration.underline, // ❌ REMOVED
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.open_in_new,
                                    size: 16, // Increased from 14
                                    color: Colors.blue.shade700,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                      'Technical details',
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
                              'Suggestions:',
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
              label: const Text('Close'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
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
          title: 'Bad Request',
          description: '',
          hints: [],
          icon: Icons.error_outline,
          color: Colors.orange,
        );
      case 401:
        return _HttpErrorInfo(
          title: 'Not Logged In',
          description:
              'Session has expired or you are not logged in to the system.',
          hints: [
            'Please log in again',
          ],
          icon: Icons.lock_outline,
          color: Colors.amber,
        );
      case 403:
        return _HttpErrorInfo(
          title: 'Access Denied',
          description:
              'You do not have permission to perform this operation. Please contact administrator.',
          hints: [],
          icon: Icons.block,
          color: Colors.red,
        );
      case 404:
        return _HttpErrorInfo(
          title: 'Not Found',
          description:
              'The requested resource does not exist or has been deleted.',
          hints: [],
          icon: Icons.search_off,
          color: Colors.grey,
        );
      case 408:
        return _HttpErrorInfo(
          title: 'Timeout',
          description: 'Request took too long. Please try again.',
          hints: [
            'Check internet connection',
          ],
          icon: Icons.hourglass_empty,
          color: Colors.orange,
        );
      case 429:
        return _HttpErrorInfo(
          title: 'Too Many Requests',
          description:
              'You have sent too many requests in a short time. Please wait and try again.',
          hints: [
            'Wait a few minutes before trying again',
          ],
          icon: Icons.speed,
          color: Colors.orange,
        );
      case 500:
        return _HttpErrorInfo(
          title: 'Server Error',
          description: '',
          hints: [],
          icon: Icons.dns_outlined,
          color: Colors.red,
        );
      case 502:
      case 503:
      case 504:
        return _HttpErrorInfo(
          title: 'Service Temporarily Unavailable',
          description:
              'Server is under maintenance or overloaded. Please try again later.',
          hints: [],
          icon: Icons.cloud_off,
          color: Colors.grey,
        );
      default:
        return _HttpErrorInfo(
          title: 'Unknown Error',
          description:
              'An unexpected error occurred. Please try again or contact support.',
          hints: [
            'Contact support with error code $statusCode',
          ],
          icon: Icons.help_outline,
          color: Colors.red,
        );
    }
  }

  /// Validate if string is a valid URL
  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Open URL in browser
  static Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      // Use url_launcher package
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('❌ Error opening URL: $e');
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
