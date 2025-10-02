import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../utils/user_agent_utils.dart';

class GoogleAuthService {
  static const String _baseUrl = 'https://mon.lad.vn';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '211733424826-d7dns77hrghn70tugmlbo7p15ugfed4m.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
  );
  
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('[GOOGLE] Starting Google Sign-In...');
      
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return {'success': false, 'message': 'Đăng nhập bị hủy'};
      }
      
      print('[GOOGLE] Sign-In successful: ${googleUser.email}');
      
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      
      print('[GOOGLE] ID Token: ${idToken != null ? "Found" : "NULL"}');
      print('[GOOGLE] Access Token: ${accessToken != null ? "Found" : "NULL"}');
      
      // Nếu không có idToken (web), dùng email thay vì verify token
      if (idToken == null && accessToken == null) {
        return {'success': false, 'message': 'Không lấy được token từ Google'};
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
            'message': 'Đăng nhập thành công',
            'token': data['payload'],
            'email': googleUser.email,
            'username': data['username'] ?? googleUser.displayName,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Đăng nhập thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Lỗi server: ${response.statusCode}',
        };
      }
      
    } catch (e) {
      print('[GOOGLE] Error: $e');
      return {'success': false, 'message': 'Lỗi: $e'};
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
