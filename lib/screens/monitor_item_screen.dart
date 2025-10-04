import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/monitor_item_crud_service.dart';
import 'base_crud_screen.dart';

class MonitorItemScreen extends BaseCrudScreen {
  const MonitorItemScreen({super.key});

  @override
  State<MonitorItemScreen> createState() => _MonitorItemScreenState();
}

class _MonitorItemScreenState extends BaseCrudScreenState<MonitorItemScreen> {
  @override
  String get screenTitle => 'Monitor Items';

  @override
  String get itemName => 'Monitor Item';

  @override
  String get addButtonText => AppLocalizations.of(context)!.monitorAddItem;

  @override
  String get editButtonText => AppLocalizations.of(context)!.monitorEditItem;

  @override
  Future<Map<String, dynamic>> initializeConfig() async {
    // Always reload config to get latest field changes
    print('[RELOAD] Reloading Monitor Items config from server...');
    return await MonitorItemCrudService.reloadConfig();
  }

  @override
  List<Map<String, dynamic>> getFormFields({bool isEditMode = false}) {
    return MonitorItemCrudService.getFormFields(isEditMode: isEditMode);
  }

  @override
  List<Map<String, dynamic>> getMobileFields() {
    return MonitorItemCrudService.getMobileFields();
  }

  @override
  Future<Map<String, dynamic>> loadItems() async {
    return await MonitorItemCrudService.getMonitorItems();
  }

  @override
  Future<Map<String, dynamic>> deleteItems(List<int> ids) async {
    return await MonitorItemCrudService.deleteMonitorItems(ids);
  }

  @override
  Future<Map<String, dynamic>> getItem(int id) async {
    return await MonitorItemCrudService.getMonitorItem(id);
  }

  @override
  Future<Map<String, dynamic>> saveItem(
    int? id,
    Map<String, dynamic> data,
  ) async {
    if (id != null) {
      return await MonitorItemCrudService.updateMonitorItem(id, data);
    } else {
      return await MonitorItemCrudService.addMonitorItem(data);
    }
  }

  @override
  bool shouldShowField(
    Map<String, dynamic> field,
    Map<String, dynamic>? itemData,
  ) {
    return MonitorItemCrudService.shouldShowField(field, itemData);
  }

  @override
  Color getNameColor(Map<String, dynamic> item) {
    // CHECK ENABLE FIRST - If item is disabled, always return grey
    final enable = item['enable'];
    if (enable != null) {
      final enableValue = enable.toString();
      final isEnabled =
          enableValue == '1' || enableValue.toLowerCase() == 'true';
      if (!isEnabled) {
        return Colors.grey; // Disabled items show grey
      }
    }

    // Get all field definitions to find error_status field
    final allFields = MonitorItemCrudService.getMobileFields();

    // Find error_status field
    final errorStatusField = allFields.firstWhere(
      (field) => field['data_type']?.toString().toLowerCase() == 'error_status',
      orElse: () => <String, dynamic>{},
    );

    if (errorStatusField.isEmpty) {
      // If not found in mobile fields, check all field details
      final fieldDetails = MonitorItemCrudService.fieldDetails;
      if (fieldDetails is List) {
        for (final field in fieldDetails) {
          if (field is Map &&
              field['data_type']?.toString().toLowerCase() == 'error_status') {
            final fieldName = field['field_name'] as String?;
            if (fieldName != null) {
              final value = item[fieldName]?.toString() ?? '';
              final intValue = int.tryParse(value) ?? 0;

              if (intValue < 0) return Colors.red.shade700;
              if (intValue > 0) return Colors.green.shade700;
            }
            break;
          }
        }
      }
      return Colors.black87; // Default color
    }

    final fieldName = errorStatusField['field'] as String?;
    if (fieldName == null) {
      return Colors.black87;
    }

    final value = item[fieldName]?.toString() ?? '';
    final intValue = int.tryParse(value) ?? 0;

    if (intValue < 0) return Colors.red.shade700;
    if (intValue > 0) return Colors.green.shade700;

    return Colors.black87; // Default for 0 or null
  }
}
