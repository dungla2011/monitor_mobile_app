import 'dart:convert';
import 'package:http/http.dart' as http;
import 'web_auth_service.dart';
import '../config/app_config.dart';

class ApiService {
  static String get _baseUrl => AppConfig.apiUrl;

  // Example: Lấy danh sách user
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Not logged in or invalid token',
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
          'message': 'Token expired, please login again',
          'needReauth': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Server error (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
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
          'message': 'Not logged in or invalid token',
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
            'message': jsonResponse['message'] ?? 'Post created successfully',
            'data': jsonResponse['payload'],
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Post creation failed',
            'error_link': jsonResponse['error_link'], // Add error_link
          };
        }
      } else if (response.statusCode == 401) {
        // Token hết hạn
        await WebAuthService.signOut();
        return {
          'success': false,
          'message': 'Token expired, please login again',
          'needReauth': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Server error (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
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
          'message': 'Not logged in or invalid token',
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
            'message':
                jsonResponse['message'] ?? 'Profile updated successfully',
            'data': jsonResponse['payload'],
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Profile update failed',
          };
        }
      } else if (response.statusCode == 401) {
        await WebAuthService.signOut();
        return {
          'success': false,
          'message': 'Token expired, please login again',
          'needReauth': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Server error (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
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
          'message': 'Not logged in or invalid token',
        };
      }

      http.Response response;
      final headers = await WebAuthService.getAuthenticatedHeaders();

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
            'message': 'Unsupported HTTP method: $method',
          };
      }

      if (response.statusCode == 401) {
        await WebAuthService.signOut();
        return {
          'success': false,
          'message': 'Token expired, please login again',
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
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get monitor uptime list for dashboard
  static Future<Map<String, dynamic>> getMonitorUptimeList(String period) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        throw Exception('Not logged in');
      }

      final response = await WebAuthService.authenticatedGet(
        '$_baseUrl/monitor-graph/uptime-list?period=$period',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await WebAuthService.signOut();
        throw Exception('Token expired, please login again');
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }
}
