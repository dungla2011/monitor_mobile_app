import 'dart:convert';
import 'package:http/http.dart' as http;
import 'web_auth_service.dart';

class MonitorConfigCrudService {
  static const String _baseUrl = 'https://mon.lad.vn';
  static const String _tableName = 'monitor_configs';

  // Config URLs
  static String get _fieldDetailsUrl =>
      '$_baseUrl/tool/common/get-api-info.php?table=$_tableName&field_details=1';
  static String get _apiListUrl =>
      '$_baseUrl/tool/common/get-api-info.php?table=$_tableName&api_list=1';
  static String get _apiGetOneUrl =>
      '$_baseUrl/tool/common/get-api-info.php?table=$_tableName&api_get_one=1';

  // API Endpoints
  static String get _listApiUrl => '$_baseUrl/api/member-monitor-config/list';
  static String get _addApiUrl => '$_baseUrl/api/member-monitor-config/add';
  static String _getApiUrl(int id) =>
      '$_baseUrl/api/member-monitor-config/get/$id';
  static String _updateApiUrl(int id) =>
      '$_baseUrl/api/member-monitor-config/update/$id';
  static String get _deleteApiUrl =>
      '$_baseUrl/api/member-monitor-config/delete';

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
      print('🔄 Initializing Monitor Config CRUD...');

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

      print('✅ Monitor Config CRUD initialized successfully');
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
          // field_details can return either array directly or wrapped in object
          if (jsonResponse is List) {
            return {'success': true, 'data': jsonResponse};
          } else if (jsonResponse is Map) {
            // If it's a map, check if it has the standard {code, payload} format
            if (jsonResponse['code'] == 1) {
              return {'success': true, 'data': jsonResponse['payload']};
            } else {
              // If it's not the standard format, try to extract field list
              // Look for common field list keys
              if (jsonResponse.containsKey('fields')) {
                return {'success': true, 'data': jsonResponse['fields']};
              } else if (jsonResponse.containsKey('data')) {
                return {'success': true, 'data': jsonResponse['data']};
              } else {
                // Treat the entire object as field details if it looks like field data
                final keys = jsonResponse.keys.toList();
                if (keys.isNotEmpty && jsonResponse[keys.first] is Map) {
                  // Convert map of fields to list of fields
                  final fieldsList = <Map<String, dynamic>>[];
                  for (final entry in jsonResponse.entries) {
                    if (entry.value is Map) {
                      final fieldMap = Map<String, dynamic>.from(
                        entry.value as Map,
                      );
                      fieldMap['field_name'] = entry.key; // Add field name
                      fieldsList.add(fieldMap);
                    }
                  }
                  return {'success': true, 'data': fieldsList};
                } else {
                  return {
                    'success': false,
                    'message':
                        'Unexpected field_details format: unable to parse structure',
                  };
                }
              }
            }
          } else {
            return {
              'success': false,
              'message':
                  'Unexpected field_details format: expected List or Map but got ${jsonResponse.runtimeType}',
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

  // Get list of monitor configs
  static Future<Map<String, dynamic>> getMonitorConfigs({
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
      final response = await http.get(
        Uri.parse(url),
        headers: WebAuthService.getAuthenticatedHeaders(),
      );

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
            'message': jsonResponse['message'] ?? 'Lỗi không xác định',
          };
        }
      } else {
        return {'success': false, 'message': 'Lỗi HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Get single monitor config
  static Future<Map<String, dynamic>> getMonitorConfig(int id) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final response = await http.get(
        Uri.parse(_getApiUrl(id)),
        headers: WebAuthService.getAuthenticatedHeaders(),
      );

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
            'message': jsonResponse['message'] ?? 'Không tìm thấy config',
          };
        }
      } else {
        return {'success': false, 'message': 'Lỗi HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Add new monitor config
  static Future<Map<String, dynamic>> addMonitorConfig(
    Map<String, dynamic> data,
  ) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final response = await http.post(
        Uri.parse(_addApiUrl),
        headers: WebAuthService.getAuthenticatedHeaders(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1) {
          return {
            'success': true,
            'data': jsonResponse['payload'],
            'message': jsonResponse['message'] ?? 'Thêm thành công',
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Lỗi khi thêm',
          };
        }
      } else {
        return {'success': false, 'message': 'Lỗi HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Update monitor config
  static Future<Map<String, dynamic>> updateMonitorConfig(
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

      final response = await http.post(
        Uri.parse(_updateApiUrl(id)),
        headers: WebAuthService.getAuthenticatedHeaders(),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1) {
          return {
            'success': true,
            'data': jsonResponse['payload'],
            'message': jsonResponse['message'] ?? 'Cập nhật thành công',
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Lỗi khi cập nhật',
          };
        }
      } else {
        return {'success': false, 'message': 'Lỗi HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Delete monitor configs
  static Future<Map<String, dynamic>> deleteMonitorConfigs(
    List<int> ids,
  ) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Chưa đăng nhập hoặc token không hợp lệ',
        };
      }

      final idsString = ids.join(',');
      final url = '$_deleteApiUrl?id=$idsString';

      final response = await http.get(
        Uri.parse(url),
        headers: WebAuthService.getAuthenticatedHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['code'] == 1) {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? 'Xóa thành công',
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Lỗi khi xóa',
          };
        }
      } else {
        return {'success': false, 'message': 'Lỗi HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Helper method to get field configuration for forms
  static List<Map<String, dynamic>> getFormFields({bool isEditMode = false}) {
    if (_fieldDetails == null) {
      return [];
    }

    // _fieldDetails is now directly the array of fields
    if (_fieldDetails is List) {
      final fields = _fieldDetails as List;

      List<Map<String, dynamic>> editableFields = [];
      List<Map<String, dynamic>> readOnlyFields = [];

      for (final field in fields) {
        if (field is Map) {
          final fieldMap = field as Map<String, dynamic>;
          final isEditable = fieldMap['editable'] == 'yes';
          final showInEditOne = fieldMap['show_in_api_edit_one'] == 'yes';

          // Include editable fields
          if (isEditable) {
            editableFields.add({
              'field': fieldMap['field_name'],
              'label': fieldMap['description'],
              'required': fieldMap['required'] == 'yes',
              'data_type': fieldMap['data_type'],
              'editable': fieldMap['editable'],
              'select_options': fieldMap['select_option_value'],
              'show_dependency': fieldMap['show_dependency'],
            });
          }
          // Include read-only fields if in edit mode and show_in_api_edit_one = yes
          // But exclude 'id' field since it's already shown in title
          else if (isEditMode &&
              showInEditOne &&
              fieldMap['field_name'] != 'id') {
            readOnlyFields.add({
              'field': fieldMap['field_name'],
              'label': fieldMap['description'],
              'required': false, // Read-only fields are never required
              'data_type': fieldMap['data_type'],
              'editable': fieldMap['editable'],
              'select_options': fieldMap['select_option_value'],
              'show_dependency': fieldMap['show_dependency'],
            });
          }
        }
      }

      // Return editable fields first, then read-only fields (without divider)
      return [...editableFields, ...readOnlyFields];
    }

    return [];
  }

  // Helper method to get mobile fields for list display
  static List<Map<String, dynamic>> getMobileFields() {
    if (_fieldDetails == null) {
      print('❌ getMobileFields: _fieldDetails is null');
      return [];
    }

    print(
      '🔍 getMobileFields: _fieldDetails type: ${_fieldDetails.runtimeType}',
    );
    print('🔍 getMobileFields: _fieldDetails content: $_fieldDetails');

    try {
      if (_fieldDetails is List) {
        final fields = _fieldDetails as List;
        print('✅ getMobileFields: Processing ${fields.length} fields');

        final mobileFields = <Map<String, dynamic>>[];

        for (int i = 0; i < fields.length; i++) {
          final field = fields[i];
          print('🔍 Field $i: ${field.runtimeType} - $field');

          if (field is Map) {
            final fieldMap = field as Map<String, dynamic>;
            final showMobile = fieldMap['show_mobile_field'];
            print(
              '🔍 Field ${fieldMap['field_name']}: show_mobile_field = $showMobile',
            );

            // Check for both string 'yes' and numeric 1
            if (showMobile == 'yes' || showMobile == 1 || showMobile == '1') {
              mobileFields.add({
                'field': fieldMap['field_name'],
                'label': fieldMap['description'],
                'data_type': fieldMap['data_type'],
                'editable': fieldMap['editable'],
                'select_options': fieldMap['select_option_value'],
              });
            }
          }
        }

        print('✅ getMobileFields: Found ${mobileFields.length} mobile fields');

        // Fallback: if no mobile fields found, show some important fields
        if (mobileFields.isEmpty) {
          print('⚠️ No mobile fields found, using fallback fields');
          for (final field in fields) {
            if (field is Map) {
              final fieldMap = field as Map<String, dynamic>;
              final fieldName = fieldMap['field_name'];

              // Show important fields: name, status, alert_type, created_at
              if ([
                'name',
                'status',
                'alert_type',
                'created_at',
              ].contains(fieldName)) {
                mobileFields.add({
                  'field': fieldMap['field_name'],
                  'label': fieldMap['description'],
                  'data_type': fieldMap['data_type'],
                  'editable': fieldMap['editable'],
                  'select_options': fieldMap['select_option_value'],
                });
              }
            }
          }
          print('✅ Using ${mobileFields.length} fallback mobile fields');
        }

        return mobileFields;
      } else {
        print(
          '❌ getMobileFields: _fieldDetails is not a List, it is ${_fieldDetails.runtimeType}',
        );
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ getMobileFields error: $e');
      print('❌ Stack trace: $stackTrace');
      return [];
    }
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
