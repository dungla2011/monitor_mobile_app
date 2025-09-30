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
  static Map<String, dynamic>? _apiList;
  static Map<String, dynamic>? _apiGetOne;

  // Getters
  static dynamic get fieldDetails => _fieldDetails;
  static Map<String, dynamic>? get apiList => _apiList;
  static Map<String, dynamic>? get apiGetOne => _apiGetOne;

  // Fetch all configuration data
  static Future<Map<String, dynamic>> initializeConfig() async {
    try {
      print('🔄 Initializing Monitor Item CRUD Service...');

      // Fetch field details
      final fieldDetailsResult = await BaseCrudService.fetchConfig(
        _tableName,
        'field_details',
      );
      if (!fieldDetailsResult['success']) {
        return fieldDetailsResult;
      }
      _fieldDetails = fieldDetailsResult['data'];

      // Fetch API list
      final apiListResult = await BaseCrudService.fetchConfig(
        _tableName,
        'api_list',
      );
      if (!apiListResult['success']) {
        return apiListResult;
      }
      _apiList = apiListResult['data'];

      // Fetch API get one
      final apiGetOneResult = await BaseCrudService.fetchConfig(
        _tableName,
        'api_get_one',
      );
      if (!apiGetOneResult['success']) {
        return apiGetOneResult;
      }
      _apiGetOne = apiGetOneResult['data'];

      print('✅ Monitor Item CRUD Service initialized successfully');
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

  // CRUD Operations

  // Get list of monitor items
  static Future<Map<String, dynamic>> getMonitorItems({
    int page = 1,
    int limit = 20,
  }) async {
    final url = '$_listApiUrl?page=$page&limit=$limit';
    return BaseCrudService.getRequest(url, 'List Monitor Items');
  }

  // Get single monitor item
  static Future<Map<String, dynamic>> getMonitorItem(int id) async {
    return BaseCrudService.getRequest(
      _getApiUrl(id),
      'Get Monitor Item',
      errorMessage: 'Không tìm thấy monitor item',
    );
  }

  // Add new monitor item
  static Future<Map<String, dynamic>> addMonitorItem(
    Map<String, dynamic> data,
  ) async {
    return BaseCrudService.postRequest(
      _addApiUrl,
      data,
      'Add Monitor Item',
      successMessage: 'Thêm thành công',
      errorMessage: 'Lỗi khi thêm',
    );
  }

  // Update monitor item
  static Future<Map<String, dynamic>> updateMonitorItem(
    int id,
    Map<String, dynamic> data,
  ) async {
    return BaseCrudService.postRequest(
      _updateApiUrl(id),
      data,
      'Update Monitor Item',
      successMessage: 'Cập nhật thành công',
      errorMessage: 'Lỗi khi cập nhật',
    );
  }

  // Delete monitor items
  static Future<Map<String, dynamic>> deleteMonitorItems(List<int> ids) async {
    return BaseCrudService.deleteRequest(
      _deleteApiUrl,
      ids,
      'Delete Monitor Items',
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
    return _fieldDetails != null && _apiList != null && _apiGetOne != null;
  }
}
