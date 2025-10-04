import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/base_crud_service.dart';
import '../utils/error_dialog_utils.dart';
import 'monitor_config_screen.dart';
import 'monitor_item_screen.dart';

/// Abstract base class for CRUD screens
abstract class BaseCrudScreen<T> extends StatefulWidget {
  const BaseCrudScreen({super.key});
}

abstract class BaseCrudScreenState<T extends BaseCrudScreen> extends State<T> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> formFields = [];
  List<Map<String, dynamic>> mobileFields = [];
  bool isLoading = true;
  String? errorMessage;

  // Selected items for bulk actions
  Set<int> selectedItems = <int>{};
  bool isSelectionMode = false;

  // Localization getter
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // Abstract methods that must be implemented by subclasses
  String get screenTitle;
  String get itemName; // e.g., "Monitor Item", "Monitor Config"
  String get addButtonText;
  String get editButtonText;

  // Service methods
  Future<Map<String, dynamic>> initializeConfig();
  List<Map<String, dynamic>> getFormFields({bool isEditMode = false});
  List<Map<String, dynamic>> getMobileFields();
  Future<Map<String, dynamic>> loadItems();
  Future<Map<String, dynamic>> deleteItems(List<int> ids);
  Future<Map<String, dynamic>> getItem(int id);
  Future<Map<String, dynamic>> saveItem(int? id, Map<String, dynamic> data);
  bool shouldShowField(
    Map<String, dynamic> field,
    Map<String, dynamic>? itemData,
  );

  @override
  void initState() {
    super.initState();
    initializeScreen();
  }

  Future<void> initializeScreen() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Initialize config
      final configResult = await initializeConfig();

      if (!configResult['success']) {
        setState(() {
          errorMessage = configResult['message'];
          isLoading = false;
        });
        return;
      }

      formFields = getFormFields();
      mobileFields = getMobileFields();
      print(
        '✅ Config loaded. Fields: ${formFields.length}, Mobile Fields: ${mobileFields.length}',
      );

      // Load items
      await loadItemsData();
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi khởi tạo: $e';
        isLoading = false;
      });
    }
  }

  Future<void> loadItemsData() async {
    try {
      final result = await loadItems();

      if (result['success']) {
        // Use base service helper to extract pagination data
        final extractedData = BaseCrudService.extractPaginationData(
          result['data'],
        );

        setState(() {
          items = extractedData;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = result['message'];
          isLoading = false;
        });

        if (result['needReauth'] == true) {
          showReauthDialog();
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi tải dữ liệu: $e';
        isLoading = false;
      });
    }
  }

  void showReauthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phiên đăng nhập hết hạn'),
        content: const Text('Vui lòng đăng nhập lại để tiếp tục.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedItems.clear();
      }
    });
  }

  void toggleItemSelection(int itemId) {
    setState(() {
      if (selectedItems.contains(itemId)) {
        selectedItems.remove(itemId);
      } else {
        selectedItems.add(itemId);
      }
    });
  }

  Future<void> deleteSelectedItems() async {
    if (selectedItems.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa ${selectedItems.length} item(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await deleteItems(selectedItems.toList());

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Xóa thành công')),
          );

          setState(() {
            selectedItems.clear();
            isSelectionMode = false;
          });

          await loadItemsData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Lỗi khi xóa')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  void showAddEditDialog({Map<String, dynamic>? item}) async {
    final isEditMode = item != null;

    // If editing, reload field_details config first
    if (isEditMode) {
      print('[RELOAD] Reloading field_details before editing item...');

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải cấu hình...'),
            ],
          ),
        ),
      );

      try {
        // Reload config to get latest field_details
        final configResult = await initializeConfig();

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (!configResult['success']) {
          if (mounted) {
            await ErrorDialogUtils.showErrorDialog(
              context,
              'Không thể tải cấu hình: ${configResult['message']}',
            );
          }
          return;
        }

        print('[RELOAD] Field details reloaded successfully');
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (mounted) {
          await ErrorDialogUtils.showErrorDialog(
            context,
            'Lỗi khi tải cấu hình: $e',
          );
        }
        return;
      }
    }

    // Get form fields after config reload
    final dialogFields = getFormFields(isEditMode: isEditMode);

    // If editing, load full item data from API
    Map<String, dynamic>? fullItemData = item;
    if (isEditMode) {
      final itemId = item['id'] as int;

      // Show loading dialog while fetching full data
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải dữ liệu...'),
            ],
          ),
        ),
      );

      try {
        final result = await getItem(itemId);

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (result['success']) {
          fullItemData = result['data'];
          print('📥 Full item data loaded: $fullItemData');
        } else {
          // Show error and return
          if (mounted) {
            await ErrorDialogUtils.showErrorDialog(
              context,
              result['message'] ?? 'Không thể tải dữ liệu item',
            );
          }
          return;
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show error and return
        if (mounted) {
          await ErrorDialogUtils.showErrorDialog(
            context,
            'Lỗi khi tải dữ liệu: $e',
          );
        }
        return;
      }
    }

    // Show edit/add dialog with full data
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => BaseCrudDialog(
          title: isEditMode
              ? '${l10n.appEdit} $itemName'
              : '${l10n.appAdd} $itemName',
          item: fullItemData,
          fields: dialogFields,
          onSave: (data) => saveItem(fullItemData?['id'], data),
          onSaved: () async {
            Navigator.of(context).pop();
            await loadItemsData();
          },
          shouldShowField: shouldShowField,
        ),
      );
    }
  }

  // Format value for mobile field display
  String formatMobileValue(
    String value,
    String dataType,
    Map<String, dynamic>? selectOptions,
  ) {
    if (value.isEmpty || value == 'null') {
      return 'N/A';
    }

    // Handle select options first
    if (selectOptions != null && selectOptions.isNotEmpty) {
      final displayText = selectOptions[value]?.toString();
      if (displayText != null && displayText != '-Chọn-') {
        // Truncate long select option text
        if (displayText.length > 50) {
          return '${displayText.substring(0, 47)}...';
        }
        return displayText;
      }
    }

    final lowerDataType = dataType.toLowerCase();

    if (lowerDataType == 'error_status') {
      final intValue = int.tryParse(value) ?? 0;
      if (intValue < 0) return 'Lỗi';
      if (intValue > 0) return 'OK';
      return 'N/A';
    }

    if (lowerDataType.contains('boolean') ||
        lowerDataType.contains('tinyint')) {
      if (value == '1' || value.toLowerCase() == 'true') {
        return 'Có';
      } else if (value == '0' || value.toLowerCase() == 'false') {
        return 'Không';
      }
    }

    if (lowerDataType.contains('datetime')) {
      try {
        final dateTime = DateTime.parse(value);
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return value;
      }
    }

    // Truncate long strings
    if (value.length > 30) {
      return '${value.substring(0, 27)}...';
    }

    return value;
  }

  // Get icon for mobile field based on data type
  IconData getFieldIcon(String dataType) {
    final lowerDataType = dataType.toLowerCase();

    if (lowerDataType == 'error_status') return Icons.info_outline;
    if (lowerDataType.contains('boolean')) return Icons.toggle_on;
    if (lowerDataType.contains('datetime')) return Icons.access_time;
    if (lowerDataType.contains('url') || lowerDataType.contains('link')) {
      return Icons.link;
    }

    return Icons.text_fields;
  }

  // Get color for mobile field value
  Color getFieldColor(String value, String dataType) {
    if (dataType.toLowerCase() == 'error_status') {
      final intValue = int.tryParse(value) ?? 0;
      if (intValue < 0) return Colors.red;
      if (intValue > 0) return Colors.green;
      return Colors.grey;
    }

    return Colors.black87;
  }

  // Get name color based on error_status field
  Color getNameColor(Map<String, dynamic> item) {
    final errorStatus = item['error_status'];
    if (errorStatus != null) {
      final intValue = int.tryParse(errorStatus.toString()) ?? 0;
      if (intValue < 0) return Colors.red.shade700;
      if (intValue > 0) return Colors.green.shade700;
    }

    return Colors.black87; // Default for 0 or null
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
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
      body: buildBody(),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => showAddEditDialog(),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải...'),
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
            Text('Lỗi', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: initializeScreen,
              child: const Text('Thử lại'),
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
            const Text(
              'Chưa có dữ liệu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Nhấn nút + để thêm item mới'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showAddEditDialog(),
              child: Text('Thêm ${itemName.toLowerCase()} đầu tiên'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadItemsData,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final itemId = item['id'] as int? ?? 0;
          final isSelected = selectedItems.contains(itemId);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: isSelectionMode
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (value) => toggleItemSelection(itemId),
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
    );
  }

  Widget buildItemTitle(Map<String, dynamic> item, int itemId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name with edit button
        Row(
          children: [
            Expanded(
              child: Text(
                item['name']?.toString() ?? 'Item #$itemId',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: getNameColor(item),
                ),
              ),
            ),
            if (!isSelectionMode)
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      showAddEditDialog(item: item);
                      break;
                    case 'delete':
                      selectedItems = {itemId};
                      deleteSelectedItems();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text(l10n.appEdit),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text(l10n.appDelete),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 2),
        // ID (always under name)
        Text(
          'ID: $itemId',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildItemSubtitle(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Mobile fields
        ...mobileFields
            .where(
          (field) => field['field'] != 'name' && field['field'] != 'id',
        )
            .map((field) {
          final fieldName = field['field'] as String? ?? '';
          final fieldLabel = field['label'] as String? ?? '';
          final dataType = field['data_type'] as String? ?? '';
          final selectOptions =
              field['select_options'] as Map<String, dynamic>?;
          final value = item[fieldName]?.toString() ?? '';
          final formattedValue = formatMobileValue(
            value,
            dataType,
            selectOptions,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  getFieldIcon(dataType),
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$fieldLabel: ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  formattedValue,
                  style: TextStyle(
                    fontSize: 12,
                    color: getFieldColor(value, dataType),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Base CRUD Dialog
class BaseCrudDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? item;
  final List<Map<String, dynamic>> fields;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> data) onSave;
  final VoidCallback onSaved;
  final bool Function(
    Map<String, dynamic> field,
    Map<String, dynamic>? itemData,
  ) shouldShowField;

  const BaseCrudDialog({
    super.key,
    required this.title,
    this.item,
    required this.fields,
    required this.onSave,
    required this.onSaved,
    required this.shouldShowField,
  });

  @override
  State<BaseCrudDialog> createState() => _BaseCrudDialogState();
}

class _BaseCrudDialogState extends State<BaseCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _booleanValues = {};
  final Map<String, DateTime?> _dateTimeValues = {};
  bool _isLoading = false;

  // Track current item data for dependency checking
  final Map<String, dynamic> _currentItemData = {};

  // Localization getter
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final field in widget.fields) {
      final fieldName =
          field['field']?.toString() ?? field['field_name']?.toString() ?? '';
      final currentValue = widget.item?[fieldName]?.toString() ?? '';

      // Update current item data
      _currentItemData[fieldName] = currentValue;

      final dataType = field['data_type']?.toString().toLowerCase() ?? '';
      final isBooleanField = dataType.contains('boolean') ||
          dataType.contains('tinyint') ||
          (fieldName == 'enable'); // Special case for enable field
      final isDateTimeField =
          dataType.contains('datetime') && field['editable'] == 'yes';

      if (isBooleanField) {
        // Initialize boolean value: 1, "1", true -> true; others -> false
        final rawValue = widget.item?[fieldName];
        _booleanValues[fieldName] = rawValue == 1 ||
            rawValue == "1" ||
            rawValue == true ||
            rawValue?.toString().toLowerCase() == 'true';
        _controllers[fieldName] = TextEditingController(
          text: _booleanValues[fieldName]! ? '1' : '0',
        );
        // Update current data
        _currentItemData[fieldName] = _booleanValues[fieldName]! ? '1' : '0';
      } else if (isDateTimeField) {
        // Initialize datetime value
        DateTime? dateTime;
        if (currentValue.isNotEmpty && currentValue != 'null') {
          try {
            dateTime = DateTime.parse(currentValue);
          } catch (e) {
            dateTime = null;
          }
        }
        _dateTimeValues[fieldName] = dateTime;
        _controllers[fieldName] = TextEditingController(
          text: dateTime != null ? _formatDateTime(dateTime) : '',
        );
        // Update current data
        _currentItemData[fieldName] =
            dateTime != null ? _formatDateTime(dateTime) : '';
      } else {
        _controllers[fieldName] = TextEditingController(text: currentValue);
        // Update current data
        _currentItemData[fieldName] = currentValue;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Update current item data and refresh UI when field changes
  void _updateFieldValue(String fieldName, String value) {
    setState(() {
      _currentItemData[fieldName] = value;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    // Format: YYYY-MM-DD HH:mm:ss
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{};
      for (final entry in _controllers.entries) {
        // Only include editable fields in save data
        final field = widget.fields.firstWhere(
          (f) => (f['field'] ?? f['field_name']) == entry.key,
          orElse: () => {'editable': 'yes'}, // Default to editable if not found
        );

        if (field['editable'] == 'yes') {
          final fieldName = entry.key;
          final value = entry.value.text;

          // Check if this is a multi-select field
          final hasMultiSelect = field['select_options_multi'] != null;

          if (hasMultiSelect && value.isNotEmpty) {
            // Try to parse as JSON array for multi-select fields
            try {
              final decoded = jsonDecode(value);
              if (decoded is List) {
                // Convert to array of strings/numbers
                data[fieldName] = decoded;
              } else {
                // Single value, wrap in array
                data[fieldName] = [decoded];
              }
            } catch (e) {
              // If not valid JSON, treat as comma-separated or single value
              if (value.contains(',')) {
                data[fieldName] =
                    value.split(',').map((e) => e.trim()).toList();
              } else {
                data[fieldName] = [value];
              }
            }
          } else {
            // Regular field, use as string
            data[fieldName] = value;
          }
        }
      }

      final result = await widget.onSave(data);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Lưu thành công')),
        );
        widget.onSaved();
      } else {
        // Show detailed error dialog instead of snackbar
        await ErrorDialogUtils.showErrorDialog(
          context,
          result['message'] ?? 'Lỗi khi lưu',
        );
      }
    } catch (e) {
      await ErrorDialogUtils.showErrorDialog(context, 'Lỗi kết nối: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Reduce horizontal padding to 10px from each side
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      // Reduce content padding (default is 24px all sides)
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Container(
        padding: const EdgeInsets.only(top: 8),
        child: widget.item != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Text(
                      '#${widget.item!['id']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              )
            : Text(widget.title),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.fields
                    .where((field) {
                      // Check if field should be shown based on show_dependency
                      return widget.shouldShowField(
                        field,
                        _currentItemData,
                      );
                    })
                    .map((field) => _buildField(field))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.item != null ? l10n.appUpdate : l10n.appAdd),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    final fieldName =
        field['field']?.toString() ?? field['field_name']?.toString() ?? '';
    final label = field['label']?.toString() ??
        field['description']?.toString() ??
        fieldName;
    final required = field['required'] == true;
    final selectOptions = field['select_options'] as Map<String, dynamic>?;
    final selectOptionsMulti =
        field['select_options_multi'] as Map<String, dynamic>?;
    Map<String, dynamic>? mobileAction =
        field['mobile_action'] as Map<String, dynamic>?;
    final dataType = field['data_type']?.toString().toLowerCase() ?? '';

    print('🔥 BaseCrudDialog._buildField called for: $fieldName ($label)');
    if (mobileAction != null) {
      print('🎯 Found mobile_action: $mobileAction');
    } else {
      print('🧪 Adding test mobile_action for field: $fieldName');
      // Test: Add mobile action for ALL fields
      mobileAction = {
        'text_info': '+',
        'action_cmd': 'open_config',
      };
    }
    final isBooleanField = dataType.contains('boolean') ||
        dataType.contains('tinyint') ||
        (fieldName == 'enable'); // Special case for enable field
    final isDateTimeField =
        dataType.contains('datetime') && field['editable'] == 'yes';
    final isReadOnly = field['editable'] == 'no';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isReadOnly
          ? _buildReadOnlyField(fieldName, label, dataType)
          : isBooleanField
              ? _buildToggleSwitch(fieldName, label, required)
              : isDateTimeField
                  ? _buildDateTimePicker(fieldName, label, required)
                  : selectOptionsMulti != null
                      ? _buildMultiSelectField(fieldName, label, required,
                          selectOptionsMulti, mobileAction)
                      : selectOptions != null
                          ? _buildDropdown(
                              fieldName, label, required, selectOptions)
                          : _buildTextField(
                              fieldName, label, required, dataType),
    );
  }

  Widget _buildReadOnlyField(String fieldName, String label, String dataType) {
    final currentValue = widget.item?[fieldName]?.toString() ?? '';
    final displayValue = _formatDisplayValue(currentValue, dataType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label bên trái
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Separator
          Container(
            width: 1,
            height: 20,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          // Data bên phải
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                displayValue.isNotEmpty ? displayValue : 'Chưa có dữ liệu',
                style: TextStyle(
                  fontSize: 14,
                  color: displayValue.isNotEmpty
                      ? Colors.black87
                      : Colors.grey.shade500,
                  fontWeight: displayValue.isNotEmpty
                      ? FontWeight.w400
                      : FontWeight.w300,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDisplayValue(String value, String dataType) {
    if (value.isEmpty || value == 'null') {
      return '';
    }

    final lowerDataType = dataType.toLowerCase();

    // Format datetime
    if (lowerDataType.contains('datetime')) {
      try {
        final dateTime = DateTime.parse(value);
        return _formatDateTime(dateTime);
      } catch (e) {
        return value;
      }
    }

    // Format boolean/tinyint
    if (lowerDataType.contains('boolean') ||
        lowerDataType.contains('tinyint')) {
      if (value == '1' || value.toLowerCase() == 'true') {
        return 'Có';
      } else if (value == '0' || value.toLowerCase() == 'false') {
        return 'Không';
      }
    }

    return value;
  }

  Widget _buildToggleSwitch(String fieldName, String label, bool required) {
    final isEnabled = _booleanValues[fieldName] ?? false;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  required ? '$label *' : label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnabled ? 'Đã bật' : 'Đã tắt',
                  style: TextStyle(
                    fontSize: 14,
                    color: isEnabled ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              setState(() {
                _booleanValues[fieldName] = value;
                _controllers[fieldName]?.text = value ? '1' : '0';
                _updateFieldValue(fieldName, value ? '1' : '0');
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker(String fieldName, String label, bool required) {
    final selectedDateTime = _dateTimeValues[fieldName];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            required ? '$label *' : label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedDateTime != null
                      ? _formatDateTime(selectedDateTime)
                      : 'Chưa chọn thời gian',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        selectedDateTime != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _pickDateTime(fieldName),
                    icon: const Icon(Icons.calendar_today),
                    tooltip: 'Chọn ngày giờ',
                  ),
                  if (selectedDateTime != null)
                    IconButton(
                      onPressed: () => _clearDateTime(fieldName),
                      icon: const Icon(Icons.clear),
                      tooltip: 'Xóa',
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime(String fieldName) async {
    final now = DateTime.now();
    final initialDate = _dateTimeValues[fieldName] ?? now;

    // Pick date first
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && mounted) {
      // Pick time
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null && mounted) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          _dateTimeValues[fieldName] = selectedDateTime;
          _controllers[fieldName]?.text = _formatDateTime(selectedDateTime);
          _updateFieldValue(fieldName, _formatDateTime(selectedDateTime));
        });
      }
    }
  }

  void _clearDateTime(String fieldName) {
    setState(() {
      _dateTimeValues[fieldName] = null;
      _controllers[fieldName]?.text = '';
      _updateFieldValue(fieldName, '');
    });
  }

  Widget _buildDropdown(
    String fieldName,
    String label,
    bool required,
    Map<String, dynamic> selectOptions,
  ) {
    return DropdownButtonFormField<String>(
      value: _controllers[fieldName]?.text.isNotEmpty == true
          ? _controllers[fieldName]!.text
          : null,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: selectOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value.toString()),
        );
      }).toList(),
      onChanged: (value) {
        _controllers[fieldName]?.text = value ?? '';
        _updateFieldValue(fieldName, value ?? '');
      },
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty || value == '0') {
                return 'Vui lòng chọn $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildTextField(
    String fieldName,
    String label,
    bool required,
    String dataType,
  ) {
    return TextFormField(
      controller: _controllers[fieldName],
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      maxLines: dataType.contains('text') ? 3 : 1,
      onChanged: (value) {
        _updateFieldValue(fieldName, value);
      },
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildMultiSelectField(
    String fieldName,
    String label,
    bool required,
    Map<String, dynamic> selectOptions,
    Map<String, dynamic>? mobileAction,
  ) {
    // Get current selected values (could be string or array)
    List<String> selectedValues = [];
    final currentValue = _controllers[fieldName]?.text ?? '';

    if (currentValue.isNotEmpty) {
      try {
        // Try to parse as JSON array first
        final decoded = jsonDecode(currentValue);
        if (decoded is List) {
          selectedValues = decoded.map((e) => e.toString()).toList();
        } else {
          selectedValues = [currentValue];
        }
      } catch (e) {
        // If not JSON, treat as single value or comma-separated
        if (currentValue.contains(',')) {
          selectedValues =
              currentValue.split(',').map((e) => e.trim()).toList();
        } else {
          selectedValues = [currentValue];
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                required ? '$label *' : label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Mobile Action Button
            if (mobileAction != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final actionCmd = mobileAction['action_cmd'] as String?;
                  if (actionCmd != null) {
                    _handleMobileAction(context, actionCmd);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.blue.shade300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    mobileAction['text_info'] as String? ?? '+',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: selectOptions.entries.map((entry) {
              final optionKey = entry.key;
              final optionValue = entry.value.toString();
              final isSelected = selectedValues.contains(optionKey);

              // Skip the default "-Chọn-" option
              if (optionKey == '0' && optionValue.contains('-Chọn')) {
                return const SizedBox.shrink();
              }

              return CheckboxListTile(
                title: Text(optionValue),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      if (!selectedValues.contains(optionKey)) {
                        selectedValues.add(optionKey);
                      }
                    } else {
                      selectedValues.remove(optionKey);
                    }

                    // Update controller with JSON array
                    final jsonArray = jsonEncode(selectedValues);
                    _controllers[fieldName]?.text = jsonArray;
                    _updateFieldValue(fieldName, jsonArray);
                  });
                },
              );
            }).toList(),
          ),
        ),
        if (required && selectedValues.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Vui lòng chọn ít nhất một $label',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  /// Handle mobile action commands
  void _handleMobileAction(BuildContext context, String cmd) {
    switch (cmd.toLowerCase().trim()) {
      case 'open_config':
      case 'monitor_config':
        // Navigate to Monitor Config screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MonitorConfigScreen(),
          ),
        );
        break;

      case 'open_items':
      case 'monitor_items':
        // Navigate to Monitor Items screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MonitorItemScreen(),
          ),
        );
        break;

      case 'back':
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        break;

      default:
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.mobileActionCommandNotFound(cmd)),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        break;
    }
  }
}
