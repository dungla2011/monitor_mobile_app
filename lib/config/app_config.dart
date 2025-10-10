/// App configuration - Centralized config for API URLs and app settings
class AppConfig {
  // Base API URL - Change this to point to different environments
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mon.lad.vn',
  );

  // API endpoints
  static const String apiUrl = '$apiBaseUrl/api';
  static const String authUrl = '$apiUrl/auth';
  static const String memberUrl = '$apiUrl/member-user';
  static const String monitorDataUrl = '$apiUrl/monitor-data';
  static const String toolUrl = '$apiBaseUrl/tool';
  static const String commonToolUrl = '$toolUrl/common';

  // App metadata
  static const String appName = 'Ping365';
  static const String appVersion = '1.6.1';

  // API Key
  static const String apiKey = 'glx_mobile';

  // Timeouts (milliseconds)
  static const int apiTimeout = 30000;
  static const int connectionTimeout = 15000;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
