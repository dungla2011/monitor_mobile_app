import 'base_crud_service.dart';

class MonitorItemCrudService extends BaseCrudService {
  static const String _tableName = 'monitor_items';

  // API Endpoints
  static String get _listApiUrl =>
      '${BaseCrudService.baseUrl}/api/member-monitor-item/list';
  static String get _addApiUrl =>
      '${BaseCrudService.baseUrl}/api/member-monitor-item/add';
  static String _getApiUrl(int id) =>
      '${BaseCrudService.baseUrl}/api/member-monitor-item/get/$id';
  static String _updateApiUrl(int id) =>
      '${BaseCrudService.baseUrl}/api/member-monitor-item/update/$id';
  static String get _deleteApiUrl =>
      '${BaseCrudService.baseUrl}/api/member-monitor-item/delete';

  // Cached config data
  static dynamic _fieldDetails;

  // Getters
  static dynamic get fieldDetails => _fieldDetails;

  // Fetch all configuration data
  static Future<Map<String, dynamic>> initializeConfig() async {
    try {
      print('🔄 Initializing Ping Item CRUD Service...');

      // Fetch field details only
      final fieldDetailsResult = await BaseCrudService.fetchConfig(
        _tableName,
        'field_details',
      );
      if (!fieldDetailsResult['success']) {
        return fieldDetailsResult;
      }
      _fieldDetails = fieldDetailsResult['data'];

      print('✅ Ping Item CRUD Service initialized successfully');
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

  // Get list of ping items
  static Future<Map<String, dynamic>> getMonitorItems({
    int page = 1,
    int limit = 20,
  }) async {
    final url = '$_listApiUrl?page=$page&limit=$limit';
    return BaseCrudService.getRequest(url, 'List Ping Items');
  }

  // Get single ping item
  static Future<Map<String, dynamic>> getMonitorItem(int id) async {
    return BaseCrudService.getRequest(
      _getApiUrl(id),
      'Get Ping Item',
    );
  }

  // Add new ping item
  static Future<Map<String, dynamic>> addMonitorItem(
    Map<String, dynamic> data,
  ) async {
    return BaseCrudService.postRequest(
      _addApiUrl,
      data,
      'Add Ping Item',
    );
  }

  // Update ping item
  static Future<Map<String, dynamic>> updateMonitorItem(
    int id,
    Map<String, dynamic> data,
  ) async {
    return BaseCrudService.postRequest(
      _updateApiUrl(id),
      data,
      'Update Ping Item',
    );
  }

  // Delete ping items
  static Future<Map<String, dynamic>> deleteMonitorItems(List<int> ids) async {
    return BaseCrudService.deleteRequest(
      _deleteApiUrl,
      ids,
      'Delete Ping Items',
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
      fallbackFields: ['name', 'url', 'status', 'error_status', 'created_at'],
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
    print('[RELOAD] Force reloading Ping Items field_details...');
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

      print('✅ Ping Items field_details reloaded successfully');
      return {
        'success': true,
        'message': 'Field details reloaded successfully',
        'data': {'field_details': _fieldDetails},
      };
    } catch (e) {
      print('❌ Error reloading Ping Items field_details: $e');
      return {
        'success': false,
        'message': 'Failed to reload field details: $e',
      };
    }
  }
}
