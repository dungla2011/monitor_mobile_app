import 'dart:convert';
import 'package:http/http.dart' as http;
import 'web_auth_service.dart';

class ApiService {
  static const String _baseUrl = 'https://mon.lad.vn/api';

  // Example: Lấy danh sách user
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final response = await WebAuthService.authenticatedGet('$_baseUrl/users');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return {'success': true, 'data': jsonResponse};
      } else if (response.statusCode == 401) {
        // Token hết hạn, cần đăng nhập lại
        await WebAuthService.signOut();
        return {
          'success': false,
          'message': 'Token hết hạn, vui lòng đăng nhập lại',
          'needReauth': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi server (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Example: Tạo post mới
  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
  }) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final response = await WebAuthService.authenticatedPost(
        '$_baseUrl/posts',
        {'title': title, 'content': content},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1) {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? 'Tạo bài viết thành công',
            'data': jsonResponse['payload'],
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Tạo bài viết thất bại',
          };
        }
      } else if (response.statusCode == 401) {
        // Token hết hạn
        await WebAuthService.signOut();
        return {
          'success': false,
          'message': 'Token hết hạn, vui lòng đăng nhập lại',
          'needReauth': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi server (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Example: Cập nhật profile
  static Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? email,
  }) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final body = <String, dynamic>{};
      if (displayName != null) body['display_name'] = displayName;
      if (email != null) body['email'] = email;

      final response = await WebAuthService.authenticatedPost(
        '$_baseUrl/profile/update',
        body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1) {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? 'Cập nhật profile thành công',
            'data': jsonResponse['payload'],
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Cập nhật profile thất bại',
          };
        }
      } else if (response.statusCode == 401) {
        await WebAuthService.signOut();
        return {
          'success': false,
          'message': 'Token hết hạn, vui lòng đăng nhập lại',
          'needReauth': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi server (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Generic method để gọi bất kỳ API nào với Bearer Token
  static Future<Map<String, dynamic>> callApi({
    required String method, // GET, POST, PUT, DELETE
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      http.Response response;
      final headers = WebAuthService.getAuthenticatedHeaders();

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(endpoint), headers: headers);
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(endpoint),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(endpoint),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(Uri.parse(endpoint), headers: headers);
          break;
        default:
          return {
            'success': false,
            'message': 'HTTP method không được hỗ trợ: $method',
          };
      }

      if (response.statusCode == 401) {
        await WebAuthService.signOut();
        return {
          'success': false,
          'message': 'Token hết hạn, vui lòng đăng nhập lại',
          'needReauth': true,
        };
      }

      final jsonResponse = jsonDecode(response.body);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'data': jsonResponse,
      };
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
