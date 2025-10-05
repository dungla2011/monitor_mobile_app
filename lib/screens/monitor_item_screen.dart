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
  bool _showSuccessItemsOnly = false;
  String _nameFilterText = '';
  final TextEditingController _nameFilterController = TextEditingController();
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
    var filtered = sourceItems;

    // Filter by error status (last_check_status = -1 AND enable = 1)
    if (_showErrorItemsOnly) {
      filtered = filtered.where((item) {
        final enable = item['enable'];
        final enableValue = enable?.toString() ?? '';
        final isEnabled = enableValue == '1' || enableValue.toLowerCase() == 'true';
        
        final lastCheckStatus = item['last_check_status'];
        final statusValue = int.tryParse(lastCheckStatus?.toString() ?? '0') ?? 0;
        
        return statusValue == -1 && isEnabled;
      }).toList();
    }

    // Filter by success status (last_check_status = 1 AND enable = 1)
    if (_showSuccessItemsOnly) {
      filtered = filtered.where((item) {
        final enable = item['enable'];
        final enableValue = enable?.toString() ?? '';
        final isEnabled = enableValue == '1' || enableValue.toLowerCase() == 'true';
        
        final lastCheckStatus = item['last_check_status'];
        final statusValue = int.tryParse(lastCheckStatus?.toString() ?? '0') ?? 0;
        
        return statusValue == 1 && isEnabled;
      }).toList();
    }

    // Filter by name text
    if (_nameFilterText.isNotEmpty) {
      final searchText = _nameFilterText.toLowerCase();
      filtered = filtered.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        return name.contains(searchText);
      }).toList();
    }

    return filtered;
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
    // Initialize controller with current filter text
    _nameFilterController.text = _nameFilterText;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.blue),
                SizedBox(width: 8),
                Text('Filters'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name filter TextField
                  Text(
                    'Filter by name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nameFilterController,
                    decoration: InputDecoration(
                      hintText: 'Enter name to search...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _nameFilterController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setDialogState(() {
                                  _nameFilterController.clear();
                                });
                                setState(() {
                                  _nameFilterText = '';
                                  _updateFilteredItems();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        // Update dialog UI
                      });
                      setState(() {
                        _nameFilterText = value;
                        _updateFilteredItems();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 8),
                  // Status filters - Exclusive selection
                  Text(
                    'Filter by status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Error filter checkbox
                  CheckboxListTile(
                    title: Text(
                      'Show error monitors only',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    subtitle: Text(
                      'Items with errors (status = -1) and enabled',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    value: _showErrorItemsOnly,
                    onChanged: (value) {
                      setDialogState(() {
                        _showErrorItemsOnly = value ?? false;
                        if (_showErrorItemsOnly) {
                          _showSuccessItemsOnly = false; // Uncheck success when error is checked
                        }
                      });
                      setState(() {
                        _showErrorItemsOnly = value ?? false;
                        if (_showErrorItemsOnly) {
                          _showSuccessItemsOnly = false;
                        }
                        _updateFilteredItems();
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Success filter checkbox
                  CheckboxListTile(
                    title: Text(
                      'Show success monitors only',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                    subtitle: Text(
                      'Items with success (status = 1) and enabled',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    value: _showSuccessItemsOnly,
                    onChanged: (value) {
                      setDialogState(() {
                        _showSuccessItemsOnly = value ?? false;
                        if (_showSuccessItemsOnly) {
                          _showErrorItemsOnly = false; // Uncheck error when success is checked
                        }
                      });
                      setState(() {
                        _showSuccessItemsOnly = value ?? false;
                        if (_showSuccessItemsOnly) {
                          _showErrorItemsOnly = false;
                        }
                        _updateFilteredItems();
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Space for more filters in the future
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Reset all filters
                  setDialogState(() {
                    _showErrorItemsOnly = false;
                    _showSuccessItemsOnly = false;
                    _nameFilterController.clear();
                  });
                  setState(() {
                    _showErrorItemsOnly = false;
                    _showSuccessItemsOnly = false;
                    _nameFilterText = '';
                    _nameFilterController.clear();
                    _updateFilteredItems();
                  });
                },
                child: Text('Reset All'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameFilterController.dispose();
    super.dispose();
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
                if (_showErrorItemsOnly || _showSuccessItemsOnly || _nameFilterText.isNotEmpty)
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
    final hasActiveFilters = _showErrorItemsOnly || _showSuccessItemsOnly || _nameFilterText.isNotEmpty;

    return Column(
      children: [
        // Filter status bar
        if (hasActiveFilters)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16, color: Colors.orange.shade700),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Showing ${displayItems.length} of ${items.length} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_nameFilterText.isNotEmpty || _showErrorItemsOnly || _showSuccessItemsOnly)
                        Text(
                          [
                            if (_nameFilterText.isNotEmpty)
                              'Name: "$_nameFilterText"',
                            if (_showErrorItemsOnly) 'Error items only',
                            if (_showSuccessItemsOnly) 'Success items only',
                          ].join(' • '),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showErrorItemsOnly = false;
                      _showSuccessItemsOnly = false;
                      _nameFilterText = '';
                      _nameFilterController.clear();
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
                            _showSuccessItemsOnly = false;
                            _nameFilterText = '';
                            _nameFilterController.clear();
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
