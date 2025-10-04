import 'dart:convert';
import 'package:http/http.dart' as http;
import 'web_auth_service.dart';
import '../utils/user_agent_utils.dart';
import '../config/app_config.dart';

/// Base CRUD service với common error handling và API utilities
abstract class BaseCrudService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// Parse API response với unified error handling
  static Map<String, dynamic> parseApiResponse(
    http.Response response,
    String operation, {
    String? successMessage,
    String? errorMessage,
  }) {
    print('📥 $operation response status: ${response.statusCode}');
    print('📥 $operation response body: ${response.body}');

    try {
      final jsonResponse = jsonDecode(response.body);

      // Handle successful responses (status 200 with code = 1)
      if (response.statusCode == 200 && jsonResponse['code'] == 1) {
        return {
          'success': true,
          'data': jsonResponse['payload'],
          'message': jsonResponse['message'] ?? successMessage ?? 'Success',
          'statusCode': response.statusCode,
        };
      }

      // Handle API errors (status 200 but code != 1, or non-200 status)
      return {
        'success': false,
        'message': jsonResponse['message'] ??
            jsonResponse['payload'] ??
            errorMessage ??
            'HTTP error ${response.statusCode}',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      // Handle JSON parsing errors
      return {
        'success': false,
        'message': 'HTTP error ${response.statusCode}: ${response.body}',
        'statusCode': response.statusCode,
      };
    }
  }

  /// Generic GET request với authentication
  static Future<Map<String, dynamic>> getRequest(
    String url,
    String operation, {
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Not logged in or invalid token',
        };
      }

      final headers = await WebAuthService.getAuthenticatedHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return parseApiResponse(
        response,
        operation,
        successMessage: successMessage,
        errorMessage: errorMessage,
      );
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Generic POST request với authentication
  static Future<Map<String, dynamic>> postRequest(
    String url,
    Map<String, dynamic> data,
    String operation, {
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Not logged in or invalid token',
        };
      }

      print('📤 Sending $operation data to server: $data');

      final headers = await WebAuthService.getAuthenticatedHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      return parseApiResponse(
        response,
        operation,
        successMessage: successMessage,
        errorMessage: errorMessage,
      );
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Generic DELETE request (using GET method as per API spec)
  static Future<Map<String, dynamic>> deleteRequest(
    String url,
    List<int> ids,
    String operation, {
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'Not logged in or invalid token',
        };
      }

      final idsString = ids.join(',');
      final deleteUrl = '$url?id=$idsString';

      final headers = await WebAuthService.getAuthenticatedHeaders();
      final response = await http.get(
        Uri.parse(deleteUrl),
        headers: headers,
      );

      return parseApiResponse(
        response,
        operation,
        successMessage: successMessage ?? 'Delete successful',
        errorMessage: errorMessage ?? 'Delete error',
      );
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Fetch config data từ tool/common/get-api-info.php
  static Future<Map<String, dynamic>> fetchConfig(
    String tableName,
    String configType,
  ) async {
    final url =
        '$baseUrl/tool/common/get-api-info.php?table=$tableName&$configType=1';

    try {
      print('🔗 Fetching $configType for $tableName from: $url');

      final headers = await WebAuthService.getAuthenticatedHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📥 $configType Response status: ${response.statusCode}');
      print('📥 $configType Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Check for Laravel/PHP exception format first
        if (jsonResponse is Map && jsonResponse.containsKey('exception')) {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Server error occurred',
            'statusCode': response.statusCode,
            'responseBody': response.body,
            'isException': true,
            'exceptionType': jsonResponse['exception'],
            'file': jsonResponse['file'],
            'line': jsonResponse['line'],
          };
        }

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
                      // Don't override field_name if it already exists
                      // fieldMap['field_name'] = entry.key; // Remove this line
                      fieldsList.add(fieldMap);
                    }
                  }
                  return {'success': true, 'data': fieldsList};
                } else {
                  return {
                    'success': false,
                    'message':
                        'Unexpected field_details format: unable to parse structure',
                    'statusCode': response.statusCode,
                    'responseBody': response.body,
                  };
                }
              }
            }
          } else {
            return {
              'success': false,
              'message':
                  'Unexpected field_details format: expected List or Map but got ${jsonResponse.runtimeType}',
              'statusCode': response.statusCode,
              'responseBody': response.body,
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
              'statusCode': response.statusCode,
              'responseBody': response.body,
            };
          }
        }
      } else {
        return {
          'success': false,
          'message': 'HTTP Error ${response.statusCode} for $configType',
          'statusCode': response.statusCode,
          'responseBody': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error fetching $configType: $e',
      };
    }
  }

  /// Helper để extract data từ pagination response
  static List<Map<String, dynamic>> extractPaginationData(dynamic apiData) {
    if (apiData is Map && apiData.containsKey('data')) {
      // Pagination format: {current_page: 1, data: [...], total: 10}
      return List<Map<String, dynamic>>.from(apiData['data'] ?? []);
    } else if (apiData is List) {
      // Direct array format
      return List<Map<String, dynamic>>.from(apiData);
    } else {
      return [];
    }
  }

  /// Helper để get form fields từ field details
  static List<Map<String, dynamic>> getFormFields(
    dynamic fieldDetails, {
    bool isEditMode = false,
  }) {
    if (fieldDetails == null || fieldDetails is! List) {
      return [];
    }

    final fields = fieldDetails;
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
            'select_options_multi': fieldMap['select_option_multi_value'],
            'show_dependency': fieldMap['show_dependency'],
            'mobile_action': fieldMap['mobile_action'],
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
            'select_options_multi': fieldMap['select_option_multi_value'],
            'show_dependency': fieldMap['show_dependency'],
            'mobile_action': fieldMap['mobile_action'],
            'extra_mobile_info': fieldMap['extra_mobile_info'],
          });
        }
      }
    }

    // Return editable fields first, then read-only fields
    return [...editableFields, ...readOnlyFields];
  }

  /// Helper để get mobile fields từ field details
  static List<Map<String, dynamic>> getMobileFields(
    dynamic fieldDetails, {
    List<String>? fallbackFields,
  }) {
    if (fieldDetails == null || fieldDetails is! List) {
      return [];
    }

    final fields = fieldDetails;
    final mobileFields = <Map<String, dynamic>>[];

    for (final field in fields) {
      if (field is Map) {
        final fieldMap = field as Map<String, dynamic>;
        final showMobile = fieldMap['show_mobile_field'];

        // Check for both string 'yes' and numeric 1
        if (showMobile == 'yes' || showMobile == 1 || showMobile == '1') {
          mobileFields.add({
            'field': fieldMap['field_name'],
            'label': fieldMap['description'],
            'data_type': fieldMap['data_type'],
            'editable': fieldMap['editable'],
            'select_options': fieldMap['select_option_value'],
            'select_options_multi': fieldMap['select_option_multi_value'],
            'extra_mobile_info': fieldMap['extra_mobile_info'],
          });
        }
      }
    }

    // Fallback: if no mobile fields found, show some important fields
    if (mobileFields.isEmpty && fallbackFields != null) {
      for (final field in fields) {
        if (field is Map) {
          final fieldMap = field as Map<String, dynamic>;
          final fieldName = fieldMap['field_name'];

          if (fallbackFields.contains(fieldName)) {
            mobileFields.add({
              'field': fieldMap['field_name'],
              'label': fieldMap['description'],
              'data_type': fieldMap['data_type'],
              'editable': fieldMap['editable'],
              'select_options': fieldMap['select_option_value'],
              'select_options_multi': fieldMap['select_option_multi_value'],
              'extra_mobile_info': fieldMap['extra_mobile_info'],
            });
          }
        }
      }
    }

    return mobileFields;
  }

  /// Helper để check field dependency
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
        final dependencyFieldName = entry.key;
        final allowedValues = entry.value;
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

  /// Helper method to check if values match (supports different types)
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
}
