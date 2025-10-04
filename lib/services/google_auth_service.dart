import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../utils/user_agent_utils.dart';
import '../config/app_config.dart';

class GoogleAuthService {
  static String get _baseUrl => AppConfig.apiBaseUrl;

  // Web Client ID - chỉ dùng cho Web, Android tự lấy từ google-services.json
  static const String _webClientId =
      '916524608033-pqqvfdhqsosklb0cfb4nrogi6tm5cpvu.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Chỉ set clientId cho Web, Android không cần (lấy từ google-services.json)
    clientId: kIsWeb ? _webClientId : null,
    scopes: ['email', 'profile', 'openid'],
  );

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('[GOOGLE] Starting Google Sign-In...');

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {'success': false, 'message': 'Sign-In cancelled by user'};
      }

      print('[GOOGLE] Sign-In successful: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      print('[GOOGLE] ID Token: ${idToken != null ? "Found" : "NULL"}');
      print('[GOOGLE] Access Token: ${accessToken != null ? "Found" : "NULL"}');

      // Nếu không có idToken (web), dùng email thay vì verify token
      if (idToken == null && accessToken == null) {
        return {
          'success': false,
          'message': 'Cannot obtain tokens from Google'
        };
      }

      print('[GOOGLE] Sending to backend...');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/google-mobile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': UserAgentUtils.getApiUserAgent(),
        },
        body: jsonEncode({
          'id_token': idToken, // Có thể null trên web
          'access_token': accessToken, // Gửi cả 2
          'email': googleUser.email,
          'name': googleUser.displayName,
        }),
      );

      print('[GOOGLE] Backend response: ${response.statusCode}');
      print('[GOOGLE] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 1) {
          return {
            'success': true,
            'message': 'Login successful',
            'token': data['payload'],
            'email': googleUser.email,
            'username': data['username'] ?? googleUser.displayName,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('[GOOGLE] Error: $e');
      return {'success': false, 'message': 'Login error: $e'};
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('[GOOGLE] Sign out successful');
    } catch (e) {
      print('[GOOGLE] Sign out error: $e');
    }
  }
}
