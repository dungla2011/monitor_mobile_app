import 'dart:io';
import 'package:flutter/foundation.dart';
import 'user_agent_utils.dart';

/// Debug utilities for development
class DebugUtils {
  /// Print current User-Agent information
  static void printUserAgentInfo() {
    print('🔍 === User-Agent Debug Info ===');
    print('📱 Platform: ${_getPlatformInfo()}');
    print('🌐 User-Agent: ${UserAgentUtils.getUserAgent()}');
    print('🔗 API User-Agent: ${UserAgentUtils.getApiUserAgent()}');
    print('💻 Web User-Agent: ${UserAgentUtils.getWebUserAgent()}');
    print(
        '📋 Detailed: ${UserAgentUtils.getDetailedUserAgent(customInfo: 'Debug-Mode')}');
    print('🔍 ========================');
  }

  static String _getPlatformInfo() {
    if (kIsWeb) return 'Web Browser';
    if (Platform.isAndroid) return 'Android ${Platform.operatingSystemVersion}';
    if (Platform.isIOS) return 'iOS ${Platform.operatingSystemVersion}';
    if (Platform.isWindows) return 'Windows ${Platform.operatingSystemVersion}';
    if (Platform.isMacOS) return 'macOS ${Platform.operatingSystemVersion}';
    if (Platform.isLinux) return 'Linux ${Platform.operatingSystemVersion}';
    return 'Unknown Platform';
  }

  /// Print HTTP headers that will be sent
  static void printHttpHeaders(Map<String, String> headers) {
    print('📤 === HTTP Headers ===');
    headers.forEach((key, value) {
      print('📋 $key: $value');
    });
    print('📤 ==================');
  }
}
