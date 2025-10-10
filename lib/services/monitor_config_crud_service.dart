import 'base_crud_service.dart';

class MonitorConfigCrudService extends BaseCrudService {
  static const String _tableName = 'monitor_configs';

  // API Endpoints
  static String get _listApiUrl =>
      '${BaseCrudService.baseUrl}/api/member-monitor-config/list';
  static String get _addApiUrl =>
      '${BaseCrudService.baseUrl}/api/member-monitor-config/add';
  static String _getApiUrl(int id) =>
      '${BaseCrudService.baseUrl}/api/member-monitor-config/get/$id';
  static String _updateApiUrl(int id) =>
      '${BaseCrudService.baseUrl}/api/member-monitor-config/update/$id';
  static String get _deleteApiUrl =>
      '${BaseCrudService.baseUrl}/api/member-monitor-config/delete';

  // Cached config data
  static dynamic _fieldDetails;

  // Getters
  static dynamic get fieldDetails => _fieldDetails;

  // Fetch all configuration data
  static Future<Map<String, dynamic>> initializeConfig() async {
    try {
      print('🔄 Initializing Monitor Config CRUD...');

      // Fetch field details only
      final fieldDetailsResult = await BaseCrudService.fetchConfig(
        _tableName,
        'field_details',
      );
      if (!fieldDetailsResult['success']) {
        return fieldDetailsResult;
      }
      _fieldDetails = fieldDetailsResult['data'];

      print('✅ Monitor Config CRUD initialized successfully');
      return {
        'success': true,
        'message': 'Config loaded successfully',
        'data': {
          'field_details': _fieldDetails,
        },
      };
    } catch (e) {
      print('❌ Error initializing config: $e');
      return {'success': false, 'message': 'Error initializing config: $e'};
    }
  }

  // CRUD Operations

  // Get list of Config Alerts
  static Future<Map<String, dynamic>> getMonitorConfigs({
    int page = 1,
    int limit = 20,
  }) async {
    final url = '$_listApiUrl?page=$page&limit=$limit';
    return BaseCrudService.getRequest(url, 'List Config Alerts');
  }

  // Get single monitor config
  static Future<Map<String, dynamic>> getMonitorConfig(int id) async {
    return BaseCrudService.getRequest(
      _getApiUrl(id),
      'Get Monitor Config',
    );
  }

  // Add new monitor config
  static Future<Map<String, dynamic>> addMonitorConfig(
    Map<String, dynamic> data,
  ) async {
    return BaseCrudService.postRequest(
      _addApiUrl,
      data,
      'Add Monitor Config',
    );
  }

  // Update monitor config
  static Future<Map<String, dynamic>> updateMonitorConfig(
    int id,
    Map<String, dynamic> data,
  ) async {
    return BaseCrudService.postRequest(
      _updateApiUrl(id),
      data,
      'Update Monitor Config',
    );
  }

  // Delete Config Alerts
  static Future<Map<String, dynamic>> deleteMonitorConfigs(
    List<int> ids,
  ) async {
    return BaseCrudService.deleteRequest(
      _deleteApiUrl,
      ids,
      'Delete Config Alerts',
    );
  }

  // Helper method to get field configuration for forms
  static List<Map<String, dynamic>> getFormFields({bool isEditMode = false}) {
    return BaseCrudService.getFormFields(_fieldDetails, isEditMode: isEditMode);
  }

  // Helper method to get mobile fields for list display
  static List<Map<String, dynamic>> getMobileFields() {
    return BaseCrudService.getMobileFields(
      _fieldDetails,
      fallbackFields: ['name', 'status', 'alert_type', 'created_at'],
    );
  }

  // Helper method to check if field should be shown based on show_dependency
  static bool shouldShowField(
    Map<String, dynamic> field,
    Map<String, dynamic>? itemData,
  ) {
    return BaseCrudService.shouldShowField(field, itemData);
  }

  // Helper method to check if config is loaded
  static bool get isConfigLoaded {
    return _fieldDetails != null;
  }

  // Force reload config from server
  static Future<Map<String, dynamic>> reloadConfig() async {
    print('[RELOAD] Force reloading Monitor Config field_details...');
    return await initializeConfig();
  }

  // Reload only field_details from server
  static Future<Map<String, dynamic>> reloadFieldDetails() async {
    try {
      // Fetch field details
      final fieldDetailsResult = await BaseCrudService.fetchConfig(
        _tableName,
        'field_details',
      );
      if (!fieldDetailsResult['success']) {
        return fieldDetailsResult;
      }
      _fieldDetails = fieldDetailsResult['data'];

      print('✅ Monitor Config field_details reloaded successfully');
      return {
        'success': true,
        'message': 'Field details reloaded successfully',
        'data': {'field_details': _fieldDetails},
      };
    } catch (e) {
      print('❌ Error reloading Monitor Config field_details: $e');
      return {
        'success': false,
        'message': 'Failed to reload field details: $e',
      };
    }
  }
}
