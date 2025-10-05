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
  // Filter states
  bool _showErrorItemsOnly = false;
  List<Map<String, dynamic>> _filteredItems = [];

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

  // Apply filters to items list
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> sourceItems) {
    if (!_showErrorItemsOnly) {
      return sourceItems; // No filters active
    }

    return sourceItems.where((item) {
      // Filter: Show error items (last_check_status = -1 AND enable = 1)
      if (_showErrorItemsOnly) {
        final enable = item['enable'];
        final enableValue = enable?.toString() ?? '';
        final isEnabled = enableValue == '1' || enableValue.toLowerCase() == 'true';
        
        final lastCheckStatus = item['last_check_status'];
        final statusValue = int.tryParse(lastCheckStatus?.toString() ?? '0') ?? 0;
        
        if (!(statusValue == -1 && isEnabled)) {
          return false; // Filter out non-error or disabled items
        }
      }

      return true; // Item passes all filters
    }).toList();
  }

  // Update filtered items when source items change
  void _updateFilteredItems() {
    setState(() {
      _filteredItems = _applyFilters(items);
    });
  }

  @override
  Future<void> loadItemsData() async {
    await super.loadItemsData();
    _updateFilteredItems();
  }

  // Show filter menu
  void _showFilterMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.filter_list, color: Colors.blue),
            SizedBox(width: 8),
            Text('Filters'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text('Show error monitors only'),
              subtitle: Text(
                'Items with errors and enabled',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              value: _showErrorItemsOnly,
              onChanged: (value) {
                setState(() {
                  _showErrorItemsOnly = value ?? false;
                  _updateFilteredItems();
                });
                Navigator.of(context).pop(); // Close dialog after selection
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            // Space for more filters in the future
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reset all filters
              setState(() {
                _showErrorItemsOnly = false;
                _updateFilteredItems();
              });
              Navigator.of(context).pop();
            },
            child: Text('Reset All'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Filter button
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.filter_list),
                if (_showErrorItemsOnly)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterMenu,
            tooltip: 'Filter',
          ),
          if (isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: selectedItems.isNotEmpty ? deleteSelectedItems : null,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: toggleSelectionMode,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: items.isNotEmpty ? toggleSelectionMode : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loadItemsData,
            ),
          ],
        ],
      ),
      body: buildBodyWithFilters(),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => showAddEditDialog(),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget buildBodyWithFilters() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.crudLoading),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(l10n.appError,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: initializeScreen,
              child: Text(l10n.appRetry),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.crudNoData,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.crudAddFirstItem),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showAddEditDialog(),
              child: Text(l10n.crudAddFirstButton(itemName.toLowerCase())),
            ),
          ],
        ),
      );
    }

    // Use filtered items
    final displayItems = _filteredItems;

    return Column(
      children: [
        // Filter status bar
        if (_showErrorItemsOnly)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16, color: Colors.orange.shade700),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing ${displayItems.length} of ${items.length} items (error items only)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showErrorItemsOnly = false;
                      _updateFilteredItems();
                    });
                  },
                  child: Text('Clear', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        // List view
        Expanded(
          child: displayItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No items match the filter',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showErrorItemsOnly = false;
                            _updateFilteredItems();
                          });
                        },
                        child: Text('Clear filters'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadItemsData,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 150),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      final itemId = item['id'] as int? ?? 0;
                      final isSelected = selectedItems.contains(itemId);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: isSelectionMode
                              ? Checkbox(
                                  value: isSelected,
                                  onChanged: (value) =>
                                      toggleItemSelection(itemId),
                                )
                              : null,
                          title: buildItemTitle(item, itemId),
                          subtitle: buildItemSubtitle(item),
                          trailing: null,
                          onTap: isSelectionMode
                              ? () => toggleItemSelection(itemId)
                              : () => showAddEditDialog(item: item),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
