import 'package:flutter/material.dart';
import 'package:monitor_app/l10n/app_localizations.dart';
import '../services/monitor_config_crud_service.dart';
import 'base_crud_screen.dart';

class MonitorConfigScreen extends BaseCrudScreen {
  const MonitorConfigScreen({super.key});

  @override
  State<MonitorConfigScreen> createState() => _MonitorConfigScreenState();
}

class _MonitorConfigScreenState
    extends BaseCrudScreenState<MonitorConfigScreen> {
  @override
  String get screenTitle => 'Config Alerts';

  @override
  String get itemName => 'Monitor Alert';

  @override
  String get addButtonText => AppLocalizations.of(context)!.monitorAddConfig;

  @override
  String get editButtonText => AppLocalizations.of(context)!.monitorEditConfig;

  @override
  Future<Map<String, dynamic>> initializeConfig() async {
    // Always reload config to get latest field changes
    print('[RELOAD] Reloading Monitor Config from server...');
    return await MonitorConfigCrudService.reloadConfig();
  }

  @override
  List<Map<String, dynamic>> getFormFields({bool isEditMode = false}) {
    return MonitorConfigCrudService.getFormFields(isEditMode: isEditMode);
  }

  @override
  List<Map<String, dynamic>> getMobileFields() {
    return MonitorConfigCrudService.getMobileFields();
  }

  @override
  Future<Map<String, dynamic>> loadItems() async {
    return await MonitorConfigCrudService.getMonitorConfigs();
  }

  @override
  Future<Map<String, dynamic>> deleteItems(List<int> ids) async {
    return await MonitorConfigCrudService.deleteMonitorConfigs(ids);
  }

  @override
  Future<Map<String, dynamic>> getItem(int id) async {
    return await MonitorConfigCrudService.getMonitorConfig(id);
  }

  @override
  Future<Map<String, dynamic>> saveItem(
    int? id,
    Map<String, dynamic> data,
  ) async {
    if (id != null) {
      return await MonitorConfigCrudService.updateMonitorConfig(id, data);
    } else {
      return await MonitorConfigCrudService.addMonitorConfig(data);
    }
  }

  @override
  bool shouldShowField(
    Map<String, dynamic> field,
    Map<String, dynamic>? itemData,
  ) {
    return MonitorConfigCrudService.shouldShowField(field, itemData);
  }

  @override
  Color getNameColor(Map<String, dynamic> item) {
    final errorStatus = item['error_status'];
    if (errorStatus != null) {
      final intValue = int.tryParse(errorStatus.toString()) ?? 0;
      if (intValue < 0) return Colors.red.shade700;
      if (intValue > 0) return Colors.green.shade700;
    }

    return Colors.black87; // Default for 0 or null
  }
}
