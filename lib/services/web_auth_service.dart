import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/user_agent_utils.dart';

class WebAuthService {
  // Cấu hình API endpoint - Thay đổi URL này theo API của bạn
  static const String _baseUrl = 'https://mon.lad.vn';
  static const String _loginEndpoint = '$_baseUrl/api/login-api';
  static const String _registerEndpoint = '$_baseUrl/register';

  // User model đơn giản
  static Map<String, dynamic>? _currentUser;
  static bool _isLoggedIn = false;
  static String? _bearerToken;

  // Getters
  static Map<String, dynamic>? get currentUser => _currentUser;
  static bool get isLoggedIn => _isLoggedIn;
  static String? get currentUsername => _currentUser?['username'];
  static String? get currentEmail => _currentUser?['email'];
  static String? get bearerToken => _bearerToken;

  // Khởi tạo - Load thông tin đã lưu
  static Future<void> initialize() async {
    await _loadSavedUserInfo();
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

      final response = await http.post(
        Uri.parse(_loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': UserAgentUtils.getApiUserAgent(),
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
            'message': jsonResponse['message'] ?? 'Đăng nhập thành công',
            'user': _currentUser,
            'token': _bearerToken,
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Đăng nhập không thành công',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Lỗi kết nối server (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
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
            'message': jsonResponse['message'] ?? 'Đăng ký không thành công',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Lỗi kết nối server (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Đăng xuất
  static Future<void> signOut() async {
    try {
      // Clear in-memory data
      _currentUser = null;
      _isLoggedIn = false;
      _bearerToken = null;

      // Clear all stored data
      await _clearUserInfo();

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

  // Lấy headers với Bearer Token cho các request API
  static Map<String, String> getAuthenticatedHeaders() {
    final headers = {
      'X-API-Key': 'glx_mobile',
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
    return await http.get(
      Uri.parse(endpoint),
      headers: getAuthenticatedHeaders(),
    );
  }

  static Future<http.Response> authenticatedPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return await http.post(
      Uri.parse(endpoint),
      headers: getAuthenticatedHeaders(),
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

  // Debug method to check current auth state
  static Map<String, dynamic> getAuthDebugInfo() {
    return {
      'isLoggedIn': _isLoggedIn,
      'hasToken': _bearerToken != null && _bearerToken!.isNotEmpty,
      'tokenLength': _bearerToken?.length ?? 0,
      'hasCurrentUser': _currentUser != null,
      'username': _currentUser?['username'] ?? 'null',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
