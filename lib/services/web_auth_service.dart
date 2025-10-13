import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/user_agent_utils.dart';
import 'google_auth_service.dart';
import 'firebase_messaging_service.dart';
import 'affiliate_service.dart';
import '../config/app_config.dart';

class WebAuthService {
  // Cấu hình API endpoint - Thay đổi URL này theo API của bạn
  static String get _baseUrl => AppConfig.apiBaseUrl;
  static String get _loginEndpoint => '${AppConfig.apiUrl}/login-api';
  static String get _registerEndpoint => '$_baseUrl/register';

  // User model đơn giản
  static Map<String, dynamic>? _currentUser;
  static bool _isLoggedIn = false;
  static String? _bearerToken;
  static bool _isInitialized = false; // Track initialization status

  // Getters
  static Map<String, dynamic>? get currentUser => _currentUser;
  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUsername => _currentUser?['username'];
  static String? get currentEmail => _currentUser?['email'];
  static String? get bearerToken => _bearerToken;
  static bool get isInitialized => _isInitialized;

  // Khởi tạo - Load thông tin đã lưu
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ WebAuthService already initialized');
      return;
    }
    print('🔄 Initializing WebAuthService...');
    await _loadSavedUserInfo();
    _isInitialized = true;
    print('✅ WebAuthService initialized. Bearer token: ${_bearerToken != null ? "PRESENT" : "MISSING"}');
  }

  // Đợi cho đến khi initialization hoàn tất
  static Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    
    print('⏳ Waiting for WebAuthService initialization...');
    int attempts = 0;
    while (!_isInitialized && attempts < 100) {
      await Future.delayed(const Duration(milliseconds: 50));
      attempts++;
    }
    
    if (!_isInitialized) {
      print('⚠️ WebAuthService initialization timeout, calling initialize()');
      await initialize();
    }
  }

  // Đăng nhập bằng username/password
  static Future<Map<String, dynamic>> signInWithUsernameAndPassword({
    required String username,
    required String password,
  }) async {
    try {
      print('🔗 Calling API: $_loginEndpoint');
      print(
        '📤 Request body: ${jsonEncode({
              'username': username,
              'password': password
            })}',
      );

      // Get locale for X-Locale header
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('selected_language') ?? 'vi';

      final response = await http.post(
        Uri.parse(_loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': UserAgentUtils.getApiUserAgent(),
          'X-Locale': locale,
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Kiểm tra code = 1 là thành công
        if (jsonResponse['code'] == 1) {
          // Lưu Bearer Token
          _bearerToken = jsonResponse['payload'];

          // Lưu thông tin user
          _currentUser = {
            'username': username,
            'email': jsonResponse['email'] ?? username, // Nếu API trả về email
            'displayName': jsonResponse['display_name'] ?? username,
            'loginTime': DateTime.now().toIso8601String(),
            'token': _bearerToken,
          };
          _isLoggedIn = true;

          // Lưu vào SharedPreferences
          await _saveUserInfo(username, 'web_api');

          return {
            'success': true,
            'message': jsonResponse['message'] ?? 'Login successful',
            'user': _currentUser,
            'token': _bearerToken,
          };
        } else {
          // API returned code != 1 (business logic error)
          // Extract message from payload or message field
          String errorMsg = jsonResponse['message'] ??
              jsonResponse['payload'] ??
              'Login failed';

          return {
            'success': false,
            'message': errorMsg,
            'code': jsonResponse['code'],
            'error_link': jsonResponse['error_link'], // Add error_link
            'isApiError':
                true, // Flag to indicate this is API business logic error
          };
        }
      } else {
        // HTTP error (4xx, 5xx) - try to parse JSON response
        String errorMessage =
            'Server connection error (${response.statusCode})';
        Map<String, dynamic>? jsonResponse;

        try {
          jsonResponse = jsonDecode(response.body);
          // Extract message from JSON if available
          if (jsonResponse != null) {
            errorMessage = jsonResponse['message'] ??
                jsonResponse['payload'] ??
                errorMessage;
          }
        } catch (e) {
          // Not JSON, use response body as is
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
          'responseBody': response.body,
          'code': jsonResponse?['code'],
          'error_link': jsonResponse?['error_link'], // Add error_link
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Đăng ký tài khoản mới (nếu API hỗ trợ)
  static Future<Map<String, dynamic>> registerWithUsernameAndPassword({
    required String username,
    required String password,
    String? email,
    String? displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_registerEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': UserAgentUtils.getApiUserAgent(),
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'display_name': displayName,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'register_success') {
          // Tự động đăng nhập sau khi đăng ký thành công
          return await signInWithUsernameAndPassword(
            username: username,
            password: password,
          );
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Registration failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server connection error (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Đăng xuất
  static Future<void> signOut() async {
    try {
      // Check login method để sign out Google nếu cần
      final prefs = await SharedPreferences.getInstance();
      final loginMethod = prefs.getString('login_method');

      // Clear in-memory data
      _currentUser = null;
      _isLoggedIn = false;
      _bearerToken = null;

      // Clear all stored data
      await _clearUserInfo();

      // Sign out from Google if using Google login
      if (loginMethod == 'google') {
        try {
          await GoogleAuthService.signOut();
        } catch (e) {
          print('⚠️ Error signing out from Google: $e');
        }
      }

      // Clear Firebase token if available (optional - for more complete logout)
      if (!kIsWeb) {
        try {
          // Delete FCM token to stop receiving notifications
          await FirebaseMessaging.instance.deleteToken();
          print('🔥 Firebase token deleted');
        } catch (e) {
          print('⚠️ Error deleting Firebase token: $e');
        }
      }

      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error during sign out: $e');
      // Even if there's an error, we still want to clear local data
      _currentUser = null;
      _isLoggedIn = false;
      _bearerToken = null;
      await _clearUserInfo();
    }
  }

  // Kiểm tra trạng thái đăng nhập từ storage
  static Future<bool> checkAuthStatus() async {
    await _loadSavedUserInfo();
    return _isLoggedIn;
  }

  // Lưu user info từ Google Sign-In
  static Future<void> saveGoogleUser({
    required String token,
    required String email,
    required String username,
  }) async {
    _bearerToken = token;
    _currentUser = {
      'username': username,
      'email': email,
      'displayName': username,
      'loginTime': DateTime.now().toIso8601String(),
      'token': _bearerToken,
    };
    _isLoggedIn = true;

    // Lưu vào SharedPreferences
    await _saveUserInfo(username, 'google');
  }

  // Lưu thông tin user vào SharedPreferences
  static Future<void> _saveUserInfo(String username, String loginMethod) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_username', username);
    await prefs.setString('user_email', _currentUser?['email'] ?? '');
    await prefs.setString(
      'user_display_name',
      _currentUser?['displayName'] ?? '',
    );
    await prefs.setString('login_method', loginMethod);
    await prefs.setString('login_time', _currentUser?['loginTime'] ?? '');
    await prefs.setString(
      'bearer_token',
      _bearerToken ?? '',
    ); // Lưu Bearer Token
    await prefs.setBool('is_logged_in', true);
  }

  // Load thông tin user từ SharedPreferences
  static Future<void> _loadSavedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      _bearerToken = prefs.getString('bearer_token'); // Load Bearer Token
      _currentUser = {
        'username': prefs.getString('user_username') ?? '',
        'email': prefs.getString('user_email') ?? '',
        'displayName': prefs.getString('user_display_name') ?? '',
        'loginTime': prefs.getString('login_time') ?? '',
        'token': _bearerToken,
      };
      _isLoggedIn = true;
    } else {
      _currentUser = null;
      _isLoggedIn = false;
      _bearerToken = null;
    }
  }

  // Xóa thông tin user
  static Future<void> _clearUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all user-related data
      await Future.wait([
        prefs.remove('user_username'),
        prefs.remove('user_email'),
        prefs.remove('user_display_name'),
        prefs.remove('login_method'),
        prefs.remove('login_time'),
        prefs.remove('bearer_token'),
        prefs.remove('fcm_token'), // Clear FCM token if stored
        prefs.remove('user_preferences'), // Clear any user preferences
        prefs.setBool('is_logged_in', false),
      ]);

      print('🗑️ All user data cleared from storage');
    } catch (e) {
      print('❌ Error clearing user info: $e');
    }
  }

  // Lấy thông tin đăng nhập đã lưu
  static Future<Map<String, String?>> getSavedLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('user_username'),
      'email': prefs.getString('user_email'),
      'display_name': prefs.getString('user_display_name'),
      'login_method': prefs.getString('login_method'),
      'login_time': prefs.getString('login_time'),
      'bearer_token': prefs.getString('bearer_token'),
    };
  }

  // Lấy headers với Bearer Token và Firebase token cookie cho các request API
  static Future<Map<String, String>> getAuthenticatedHeaders() async {
    // ĐỢI initialization hoàn tất trước
    await ensureInitialized();
    
    // Đảm bảo bearer token đã được load từ SharedPreferences
    if (_bearerToken == null || _bearerToken!.isEmpty) {
      print('⚠️ Bearer token not loaded, loading from SharedPreferences...');
      await _loadSavedUserInfo();
    }

    final headers = {
      'X-API-Key': AppConfig.apiKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': UserAgentUtils.getApiUserAgent(),
    };

    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_bearerToken';
      print('✅ Bearer token added to headers: ${_bearerToken!.substring(0, 20)}...');
    } else {
      print('❌ WARNING: No bearer token available for API request!');
    }

    // Thêm X-Locale header
    try {
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('selected_language') ?? 'vi';
      headers['X-Locale'] = locale;
      print('🌐 Debug X-Locale: $locale');
    } catch (e) {
      print('⚠️ Debug Cannot get locale: $e');
      headers['X-Locale'] = 'vi'; // fallback
    }

    // Tạo cookie string để gộp tất cả cookies
    List<String> cookies = [];

    // Thêm Firebase FCM token vào cookie
    if (!kIsWeb) {
      try {
        final fcmToken = await FirebaseMessagingService.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          cookies.add('firebase_token_cookie=$fcmToken');
        }
      } catch (e) {
        print('⚠️ Cannot get FCM token: $e');
      }
    }

    // Thêm Affiliate code vào cookie
    try {
      final affiliateCookie = await AffiliateService.getAffiliateCookie();
      if (affiliateCookie != null && affiliateCookie.isNotEmpty) {
        cookies.add(affiliateCookie);
      }
    } catch (e) {
      print('⚠️ Cannot get affiliate cookie: $e');
    }

    // Gộp tất cả cookies vào header
    if (cookies.isNotEmpty) {
      headers['Cookie'] = cookies.join('; ');
      print('🍪 Cookies: ${headers['Cookie']}');
    }

    return headers;
  }

  // Phiên bản synchronous (deprecated, dùng getAuthenticatedHeaders() thay thế)
  @Deprecated(
      'Use getAuthenticatedHeaders() instead. This synchronous version does not include Firebase FCM token.')
  static Map<String, String> getAuthenticatedHeadersSync() {
    final headers = {
      'X-API-Key': AppConfig.apiKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': UserAgentUtils.getApiUserAgent(),
    };

    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_bearerToken';
    }

    return headers;
  }

  // Kiểm tra xem có token hợp lệ không
  static bool hasValidToken() {
    return _bearerToken != null && _bearerToken!.isNotEmpty && _isLoggedIn;
  }

  // Method để gọi API với authentication
  static Future<http.Response> authenticatedGet(String endpoint) async {
    final headers = await getAuthenticatedHeaders();
    return await http.get(
      Uri.parse(endpoint),
      headers: headers,
    );
  }

  static Future<http.Response> authenticatedPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await getAuthenticatedHeaders();
    return await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // Cập nhật URL API
  static void updateApiUrl(String newBaseUrl) {
    // Có thể implement để thay đổi URL API runtime nếu cần
  }

  // Test connection đến API
  static Future<bool> testApiConnection() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: {
        'Accept': 'application/json',
        'User-Agent': 'MonitorApp/1.0.0 (Flutter; Mobile; Android/iOS)',
      }).timeout(const Duration(seconds: 10));

      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }

  // Load current user info from API
  static Future<Map<String, dynamic>> loadUserInfo() async {
    try {
      if (!hasValidToken()) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final String apiUrl = '${AppConfig.memberUrl}/get-member';

      print('🔗 Loading user info from: $apiUrl');

      final headers = await getAuthenticatedHeaders();
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      print('📥 User info response status: ${response.statusCode}');
      print('📥 User info response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1 && jsonResponse['payload'] != null) {
          final userInfo = jsonResponse['payload'];

          // Update current user info
          _currentUser = {
            'username': userInfo['username'],
            'email': userInfo['email'],
            'language': userInfo['language'] ?? 'vi',
            'created_at': userInfo['created_at'],
          };

          // Save updated user info
          await _saveUserInfo(userInfo['username'], 'api_refresh');

          return {
            'success': true,
            'user': _currentUser,
            'message': 'User info loaded successfully',
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Invalid data from API',
          };
        }
      } else if (response.statusCode == 401) {
        // Token expired
        await signOut();
        return {
          'success': false,
          'message': 'Session expired',
          'needReauth': true,
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP error ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error loading user info: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Debug method to check current auth state
  static Map<String, dynamic> getAuthDebugInfo() {
    return {
      'isLoggedIn': _isLoggedIn,
      'hasToken': _bearerToken != null && _bearerToken!.isNotEmpty,
      'tokenLength': _bearerToken?.length ?? 0,
      'hasCurrentUser': _currentUser != null,
      'username': _currentUser?['username'] ?? 'null',
      'language': _currentUser?['language'] ?? 'null',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
