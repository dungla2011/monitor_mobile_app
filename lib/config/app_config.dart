/// App configuration - Centralized config for API URLs and app settings
class AppConfig {
  // Base domain - Change this to point to different environments
  static const String domain = String.fromEnvironment(
    'DOMAIN',
    defaultValue: 'ping24.io',
  );

  // Base API URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://$domain',
  );

  // API endpoints
  static const String apiUrl = '$apiBaseUrl/api';
  static const String authUrl = '$apiUrl/auth';
  static const String memberUrl = '$apiUrl/member-user';
  static const String monitorDataUrl = '$apiUrl/monitor-data';
  static const String toolUrl = '$apiBaseUrl/tool';
  static const String commonToolUrl = '$toolUrl/common';

  // App metadata
  static const String appName = 'Ping24';
  static const String appVersion = '1.6.1';

  // API Key
  static const String apiKey = 'glx_mobile';

  // Timeouts (milliseconds)
  static const int apiTimeout = 30000;
  static const int connectionTimeout = 15000;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Enable/Disable loading languages from server
  /// 0 = disabled (block API calls, use only ARB files)
  /// 1 = enabled (allow API calls and server translations)
  static const int enableLoadLanguage = 1;
}
