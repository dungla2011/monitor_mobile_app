import 'dart:io';
import 'package:flutter/foundation.dart';

/// Utility class for generating User-Agent strings
class UserAgentUtils {
  static const String _appName = 'MonitorApp glx_mobile';
  static const String _appVersion = '1.0.0';

  /// Get platform-specific User-Agent string
  static String getUserAgent() {
    if (kIsWeb) {
      return '$_appName/$_appVersion (Flutter; Web; Browser)';
    }

    if (Platform.isAndroid) {
      return '$_appName/$_appVersion (Flutter; Mobile; Android ${Platform.operatingSystemVersion})';
    }

    if (Platform.isIOS) {
      return '$_appName/$_appVersion (Flutter; Mobile; iOS ${Platform.operatingSystemVersion})';
    }

    if (Platform.isWindows) {
      return '$_appName/$_appVersion (Flutter; Desktop; Windows ${Platform.operatingSystemVersion})';
    }

    if (Platform.isMacOS) {
      return '$_appName/$_appVersion (Flutter; Desktop; macOS ${Platform.operatingSystemVersion})';
    }

    if (Platform.isLinux) {
      return '$_appName/$_appVersion (Flutter; Desktop; Linux ${Platform.operatingSystemVersion})';
    }

    // Fallback for unknown platforms
    return '$_appName/$_appVersion (Flutter; Unknown; ${Platform.operatingSystem})';
  }

  /// Get detailed User-Agent with additional info
  static String getDetailedUserAgent({
    String? customInfo,
  }) {
    final baseUserAgent = getUserAgent();

    if (customInfo != null && customInfo.isNotEmpty) {
      return '$baseUserAgent; $customInfo';
    }

    return baseUserAgent;
  }

  /// Get User-Agent for API requests
  static String getApiUserAgent() {
    return getDetailedUserAgent(customInfo: 'API-Client');
  }

  /// Get User-Agent for web requests
  static String getWebUserAgent() {
    return getDetailedUserAgent(customInfo: 'Web-Client');
  }
}
