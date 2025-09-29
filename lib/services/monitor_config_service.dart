import 'dart:convert';
import 'package:http/http.dart' as http;
import 'web_auth_service.dart';

class MonitorConfigService {
  static const String _baseUrl = 'https://mon.lad.vn';
  static const String _tableName = 'monitor_items';

  // Config URLs
  static String get _fieldDetailsUrl =>
      '$_baseUrl/tool/common/get-api-info.php?table=$_tableName&field_details=1';
  static String get _apiListUrl =>
      '$_baseUrl/tool/common/get-api-info.php?table=$_tableName&api_list=1';
  static String get _apiGetOneUrl =>
      '$_baseUrl/tool/common/get-api-info.php?table=$_tableName&api_get_one=1';

  // API Endpoints
  static String get _listApiUrl => '$_baseUrl/api/member-monitor-item/list';
  static String get _addApiUrl => '$_baseUrl/api/member-monitor-item/add';
  static String _getApiUrl(int id) =>
      '$_baseUrl/api/member-monitor-item/get/$id';
  static String _updateApiUrl(int id) =>
      '$_baseUrl/api/member-monitor-item/update/$id';
  static String get _deleteApiUrl => '$_baseUrl/api/member-monitor-item/delete';

  // Cached config data
  static dynamic _fieldDetails; // Can be List or Map depending on API
  static Map<String, dynamic>? _apiList;
  static Map<String, dynamic>? _apiGetOne;

  // Getters
  static dynamic get fieldDetails => _fieldDetails;
  static Map<String, dynamic>? get apiList => _apiList;
  static Map<String, dynamic>? get apiGetOne => _apiGetOne;

  // Fetch all configuration data
  static Future<Map<String, dynamic>> initializeConfig() async {
    try {
      print('🔄 Initializing Monitor Config...');

      // Fetch field details
      final fieldDetailsResult = await _fetchConfig(
        _fieldDetailsUrl,
        'field_details',
      );
      if (!fieldDetailsResult['success']) {
        return fieldDetailsResult;
      }
      _fieldDetails = fieldDetailsResult['data'];

      // Fetch API list
      final apiListResult = await _fetchConfig(_apiListUrl, 'api_list');
      if (!apiListResult['success']) {
        return apiListResult;
      }
      _apiList = apiListResult['data'];

      // Fetch API get one
      final apiGetOneResult = await _fetchConfig(_apiGetOneUrl, 'api_get_one');
      if (!apiGetOneResult['success']) {
        return apiGetOneResult;
      }
      _apiGetOne = apiGetOneResult['data'];

      print('✅ Monitor Config initialized successfully');
      return {
        'success': true,
        'message': 'Config loaded successfully',
        'data': {
          'field_details': _fieldDetails,
          'api_list': _apiList,
          'api_get_one': _apiGetOne,
        },
      };
    } catch (e) {
      print('❌ Error initializing config: $e');
      return {'success': false, 'message': 'Error initializing config: $e'};
    }
  }

  // Fetch individual config
  static Future<Map<String, dynamic>> _fetchConfig(
    String url,
    String configType,
  ) async {
    try {
      print('🔗 Fetching $configType from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      print('📥 $configType Response status: ${response.statusCode}');
      print('📥 $configType Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Handle different response formats
        if (configType == 'field_details') {
          // field_details returns array directly, not wrapped in {code, payload}
          if (jsonResponse is List) {
            return {'success': true, 'data': jsonResponse};
          } else {
            return {
              'success': false,
              'message':
                  'Unexpected field_details format: expected List but got ${jsonResponse.runtimeType}',
            };
          }
        } else {
          // api_list and api_get_one return {code, message, payload} format
          if (jsonResponse is Map && jsonResponse['code'] == 1) {
            return {'success': true, 'data': jsonResponse['payload']};
          } else {
            return {
              'success': false,
              'message':
                  jsonResponse['message'] ?? 'Failed to fetch $configType',
            };
          }
        }
      } else {
        return {
          'success': false,
          'message': 'HTTP Error ${response.statusCode} for $configType',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error fetching $configType: $e',
      };
    }
  }

  // CRUD Operations

  // Get list of monitor items
  static Future<Map<String, dynamic>> getMonitorItems({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final url = '$_listApiUrl?page=$page&limit=$limit';
      final response = await WebAuthService.authenticatedGet(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1) {
          final payload = jsonResponse['payload'];
          // Handle paginated response structure
          final data =
              payload is Map && payload.containsKey('data')
                  ? payload['data']
                  : payload;

          return {
            'success': true,
            'data': data,
            'message': jsonResponse['message'],
            'pagination':
                payload is Map
                    ? {
                      'current_page': payload['current_page'],
                      'total': payload['total'],
                      'per_page': payload['per_page'],
                    }
                    : null,
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Lỗi khi lấy danh sách',
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

  // Get single monitor item
  static Future<Map<String, dynamic>> getMonitorItem(int id) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final response = await WebAuthService.authenticatedGet(_getApiUrl(id));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1) {
          return {
            'success': true,
            'data': jsonResponse['payload'],
            'message': jsonResponse['message'],
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Lỗi khi lấy thông tin item',
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

  // Add new monitor item
  static Future<Map<String, dynamic>> addMonitorItem(
    Map<String, dynamic> data,
  ) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final response = await WebAuthService.authenticatedPost(_addApiUrl, data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1) {
          return {
            'success': true,
            'data': jsonResponse['payload'],
            'message': jsonResponse['message'] ?? 'Thêm item thành công',
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Lỗi khi thêm item',
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

  // Update monitor item
  static Future<Map<String, dynamic>> updateMonitorItem(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final response = await WebAuthService.authenticatedPost(
        _updateApiUrl(id),
        data,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1) {
          return {
            'success': true,
            'data': jsonResponse['payload'],
            'message': jsonResponse['message'] ?? 'Cập nhật item thành công',
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Lỗi khi cập nhật item',
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

  // Delete monitor items
  static Future<Map<String, dynamic>> deleteMonitorItems(List<int> ids) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final idsString = ids.join(',');
      final url = '$_deleteApiUrl?id=$idsString';

      final response = await http.delete(
        Uri.parse(url),
        headers: WebAuthService.getAuthenticatedHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1) {
          return {
            'success': true,
            'data': jsonResponse['payload'],
            'message': jsonResponse['message'] ?? 'Xóa item thành công',
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Lỗi khi xóa item',
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

  // Helper method to get field configuration
  static List<Map<String, dynamic>> getFormFields() {
    if (_fieldDetails == null) {
      return [];
    }

    // _fieldDetails is now directly the array of fields
    if (_fieldDetails is List) {
      final fields = _fieldDetails as List;

      return fields
          .where((field) => field is Map && field['editable'] == 'yes')
          .map((field) {
            final fieldMap = field as Map<String, dynamic>;
            return {
              'field': fieldMap['field_name'],
              'label': fieldMap['description'],
              'required': fieldMap['required'] == 'yes',
              'data_type': fieldMap['data_type'],
              'editable': fieldMap['editable'], // Add missing editable field
              'select_options':
                  fieldMap['select_option_value'], // For dropdown fields
              'show_dependency':
                  fieldMap['show_dependency'], // Add show_dependency support
            };
          })
          .toList();
    }

    return [];
  }

  // Helper method to check if field should be shown based on show_dependency
  static bool shouldShowField(
    Map<String, dynamic> field,
    Map<String, dynamic>? itemData,
  ) {
    final showDependency = field['show_dependency'];

    // If no show_dependency, always show the field
    if (showDependency == null) {
      return true;
    }

    // If no item data, hide fields with dependencies (for new items)
    if (itemData == null) {
      return false;
    }

    // Process all dependency conditions
    if (showDependency is Map) {
      // Check each dependency condition
      for (final entry in showDependency.entries) {
        final dependencyFieldName = entry.key; // e.g., "type", "enable"
        final allowedValues = entry.value; // e.g., ["web_content"], [1]
        final currentValue = itemData[dependencyFieldName];

        // Convert current value to appropriate type for comparison
        String? currentValueStr = currentValue?.toString();
        int? currentValueInt;
        bool? currentValueBool;

        // Try to parse as int
        if (currentValueStr != null) {
          currentValueInt = int.tryParse(currentValueStr);
        }

        // Try to parse as bool
        if (currentValue is bool) {
          currentValueBool = currentValue;
        } else if (currentValueStr != null) {
          if (currentValueStr == '1' ||
              currentValueStr.toLowerCase() == 'true') {
            currentValueBool = true;
          } else if (currentValueStr == '0' ||
              currentValueStr.toLowerCase() == 'false') {
            currentValueBool = false;
          }
        }

        // Check if current value matches any allowed value
        bool conditionMet = false;

        if (allowedValues is List) {
          for (final allowedValue in allowedValues) {
            if (_valuesMatch(
              allowedValue,
              currentValue,
              currentValueStr,
              currentValueInt,
              currentValueBool,
            )) {
              conditionMet = true;
              break;
            }
          }
        } else {
          // Single value condition
          conditionMet = _valuesMatch(
            allowedValues,
            currentValue,
            currentValueStr,
            currentValueInt,
            currentValueBool,
          );
        }

        // If any condition is not met, hide the field
        if (!conditionMet) {
          return false;
        }
      }

      // All conditions are met
      return true;
    }

    // Default: hide if show_dependency exists but is not a Map
    return false;
  }

  // Helper method to check if values match (supports different types)
  static bool _valuesMatch(
    dynamic allowedValue,
    dynamic currentValue,
    String? currentValueStr,
    int? currentValueInt,
    bool? currentValueBool,
  ) {
    // Direct comparison
    if (allowedValue == currentValue) {
      return true;
    }

    // String comparison
    if (allowedValue is String && currentValueStr != null) {
      return allowedValue == currentValueStr;
    }

    // Int comparison
    if (allowedValue is int && currentValueInt != null) {
      return allowedValue == currentValueInt;
    }

    // Bool comparison
    if (allowedValue is bool && currentValueBool != null) {
      return allowedValue == currentValueBool;
    }

    // Cross-type comparisons
    if (allowedValue is int && currentValueStr != null) {
      return allowedValue.toString() == currentValueStr;
    }

    if (allowedValue is String && currentValueInt != null) {
      return allowedValue == currentValueInt.toString();
    }

    return false;
  }

  // Helper method to check if config is loaded
  static bool get isConfigLoaded {
    return _fieldDetails != null && _apiList != null && _apiGetOne != null;
  }
}
