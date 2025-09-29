import 'package:flutter/material.dart';
import '../services/monitor_config_crud_service.dart';
import '../services/base_crud_service.dart';
import '../utils/error_dialog_utils.dart';

class MonitorConfigScreen extends StatefulWidget {
  const MonitorConfigScreen({super.key});

  @override
  State<MonitorConfigScreen> createState() => _MonitorConfigScreenState();
}

class _MonitorConfigScreenState extends State<MonitorConfigScreen> {
  List<Map<String, dynamic>> _monitorConfigs = [];
  List<Map<String, dynamic>> _formFields = [];
  List<Map<String, dynamic>> _mobileFields = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Selected items for bulk actions
  Set<int> _selectedItems = <int>{};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Initialize config if not loaded
      if (!MonitorConfigCrudService.isConfigLoaded) {
        print('📋 Loading Monitor Config CRUD...');
        final configResult = await MonitorConfigCrudService.initializeConfig();

        if (!configResult['success']) {
          setState(() {
            _errorMessage = configResult['message'];
            _isLoading = false;
          });
          return;
        }

        try {
          _formFields = MonitorConfigCrudService.getFormFields();
          _mobileFields = MonitorConfigCrudService.getMobileFields();
          print(
            '✅ Config loaded. Fields: ${_formFields.length}, Mobile Fields: ${_mobileFields.length}',
          );
        } catch (e, stackTrace) {
          print('❌ Error getting fields: $e');
          print('❌ Stack trace: $stackTrace');
          setState(() {
            _errorMessage = 'Lỗi xử lý cấu hình fields: $e';
            _isLoading = false;
          });
          return;
        }
      }

      // Load monitor configs
      await _loadMonitorConfigs();
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khởi tạo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMonitorConfigs() async {
    try {
      final result = await MonitorConfigCrudService.getMonitorConfigs();

      if (result['success']) {
        final data = result['data'];
        print('📊 Monitor configs data type: ${data.runtimeType}');
        print('📊 Monitor configs data: $data');

        // Use base service helper to extract pagination data
        final extractedData = BaseCrudService.extractPaginationData(
          result['data'],
        );

        setState(() {
          _monitorConfigs = extractedData;
          _isLoading = false;
          _errorMessage = null;
        });
        print('✅ Monitor configs loaded: ${_monitorConfigs.length} items');
      } else {
        print('❌ Failed to load monitor configs: ${result['message']}');
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading monitor configs: $e');
      print('❌ Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedItems.clear();
    });
  }

  void _toggleItemSelection(int itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  Future<void> _deleteSelectedItems() async {
    if (_selectedItems.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc muốn xóa ${_selectedItems.length} config(s)?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final result = await MonitorConfigCrudService.deleteMonitorConfigs(
          _selectedItems.toList(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Thao tác hoàn thành'),
              backgroundColor: result['success'] ? Colors.green : Colors.red,
            ),
          );

          if (result['success']) {
            _selectedItems.clear();
            _toggleSelectionMode();
            await _loadMonitorConfigs();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  void _showAddEditDialog({Map<String, dynamic>? item}) async {
    final isEditMode = item != null;
    final dialogFields = MonitorConfigCrudService.getFormFields(
      isEditMode: isEditMode,
    );

    // If editing, load full item data from API
    Map<String, dynamic>? fullItemData = item;
    if (isEditMode) {
      final itemId = item['id'] as int;

      // Show loading dialog while fetching full data
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
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
        final result = await MonitorConfigCrudService.getMonitorConfig(itemId);

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
              result['message'] ?? 'Không thể tải dữ liệu config',
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
        builder:
            (context) => MonitorConfigDialog(
              item: fullItemData,
              fields: dialogFields,
              onSaved: () async {
                Navigator.of(context).pop();
                await _loadMonitorConfigs();
              },
            ),
      );
    }
  }

  // Format value for mobile field display
  String _formatMobileValue(
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

  // Get name color based on error_status
  Color _getNameColor(Map<String, dynamic> item) {
    final errorStatus = item['error_status'];
    if (errorStatus != null) {
      final intValue = int.tryParse(errorStatus.toString()) ?? 0;
      if (intValue < 0) return Colors.red; // Error
      if (intValue > 0) return Colors.green; // OK
    }

    return Colors.black87; // Default for 0 or null
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor Configs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed:
                  _selectedItems.isNotEmpty ? _deleteSelectedItems : null,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSelectionMode,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed:
                  _monitorConfigs.isNotEmpty ? _toggleSelectionMode : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMonitorConfigs,
            ),
          ],
        ],
      ),
      body: _buildBody(),
      floatingActionButton:
          _isSelectionMode
              ? null
              : FloatingActionButton(
                onPressed: () => _showAddEditDialog(),
                child: const Icon(Icons.add),
              ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_errorMessage',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeScreen,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_monitorConfigs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có monitor config nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _monitorConfigs.length,
      itemBuilder: (context, index) {
        final item = _monitorConfigs[index];
        final itemId = item['id'] as int;
        final isSelected = _selectedItems.contains(itemId);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading:
                _isSelectionMode
                    ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleItemSelection(itemId),
                    )
                    : null,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item['name']?.toString() ?? 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _getNameColor(item),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showAddEditDialog(item: item),
                  tooltip: 'Sửa',
                ),
              ],
            ),
            subtitle:
                _mobileFields.isNotEmpty
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _mobileFields
                              .where(
                                (field) =>
                                    field['field'] != 'id' &&
                                    field['field'] != 'name',
                              ) // Skip id and name
                              .map((field) {
                                final fieldName = field['field'] as String;
                                final label = field['label'] as String;
                                final dataType = field['data_type'] as String;
                                final selectOptions =
                                    field['select_options']
                                        as Map<String, dynamic>?;
                                final rawValue =
                                    item[fieldName]?.toString() ?? '';
                                final formattedValue = _formatMobileValue(
                                  rawValue,
                                  dataType,
                                  selectOptions,
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '$label: $formattedValue',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              })
                              .toList(),
                    )
                    : null,
            onTap:
                _isSelectionMode
                    ? () => _toggleItemSelection(itemId)
                    : () => _showAddEditDialog(item: item),
          ),
        );
      },
    );
  }
}

// Dialog for Add/Edit Monitor Config
class MonitorConfigDialog extends StatefulWidget {
  final Map<String, dynamic>? item;
  final List<Map<String, dynamic>> fields;
  final VoidCallback onSaved;

  const MonitorConfigDialog({
    super.key,
    this.item,
    required this.fields,
    required this.onSaved,
  });

  @override
  State<MonitorConfigDialog> createState() => _MonitorConfigDialogState();
}

class _MonitorConfigDialogState extends State<MonitorConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _booleanValues = {};
  final Map<String, DateTime?> _dateTimeValues = {};
  bool _isLoading = false;

  // Track current item data for dependency checking
  Map<String, dynamic> _currentItemData = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final field in widget.fields) {
      final fieldName = field['field'] as String;
      final currentValue = widget.item?[fieldName]?.toString() ?? '';

      // Update current item data
      _currentItemData[fieldName] = currentValue;

      final dataType = field['data_type']?.toString().toLowerCase() ?? '';
      final isBooleanField =
          dataType.contains('boolean') ||
          dataType.contains('tinyint') ||
          (fieldName == 'enable'); // Special case for enable field
      final isDateTimeField =
          dataType.contains('datetime') && field['editable'] == 'yes';

      if (isBooleanField) {
        // Initialize boolean value: 1, "1", true -> true; others -> false
        final rawValue = widget.item?[fieldName];
        _booleanValues[fieldName] =
            rawValue == 1 ||
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

  // Build read-only field widget
  Widget _buildReadOnlyField(String fieldName, String label, String dataType) {
    final value = widget.item?[fieldName]?.toString() ?? 'N/A';
    String displayValue = value;

    // Format read-only field values
    if (dataType.toLowerCase().contains('datetime') && value != 'N/A') {
      try {
        final dateTime = DateTime.parse(value);
        displayValue = _formatDateTime(dateTime);
      } catch (e) {
        displayValue = value;
      }
    } else if (dataType.toLowerCase().contains('boolean') ||
        dataType.toLowerCase().contains('tinyint')) {
      if (value == '1' || value.toLowerCase() == 'true') {
        displayValue = 'Có';
      } else if (value == '0' || value.toLowerCase() == 'false') {
        displayValue = 'Không';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(displayValue, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDateTime(String fieldName) async {
    final currentDateTime = _dateTimeValues[fieldName] ?? DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && mounted) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDateTime),
      );

      if (selectedTime != null && mounted) {
        final newDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        setState(() {
          _dateTimeValues[fieldName] = newDateTime;
          _controllers[fieldName]!.text = _formatDateTime(newDateTime);
          _updateFieldValue(fieldName, _formatDateTime(newDateTime));
        });
      }
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{};

      for (final field in widget.fields) {
        final fieldName = field['field'] as String;
        final isEditable = field['editable'] == 'yes';

        if (isEditable) {
          final controller = _controllers[fieldName];
          if (controller != null) {
            final value = controller.text.trim();
            data[fieldName] = value.isEmpty ? null : value;
          }
        }
      }

      print('📤 Sending data to server: $data');

      Map<String, dynamic> result;
      if (widget.item != null) {
        // Update existing item
        final itemId = widget.item!['id'] as int;
        result = await MonitorConfigCrudService.updateMonitorConfig(
          itemId,
          data,
        );
      } else {
        // Add new item
        result = await MonitorConfigCrudService.addMonitorConfig(data);
      }

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Lưu thành công'),
            backgroundColor: Colors.green,
          ),
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

  // Helper method to get field helper text
  String? _getFieldHelperText(String fieldName, String dataType) {
    if (fieldName == 'alert_config') {
      return 'Ví dụ: user@example.com hoặc user1@domain.com,user2@domain.com';
    }
    return null;
  }

  // Validate alert config field (email format)
  String? _validateAlertConfig(String value) {
    if (value.trim().isEmpty) return null;

    // Split by comma for multiple emails
    final emails = value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    for (final email in emails) {
      if (!emailRegex.hasMatch(email)) {
        return 'Email không hợp lệ: "$email". Định dạng đúng: user@example.com';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        padding: const EdgeInsets.only(top: 8),
        child:
            widget.item != null
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sửa Monitor Config'),
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
                : const Text('Thêm Monitor Config'),
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
                children:
                    widget.fields
                        .where((field) {
                          // Check if field should be shown based on show_dependency
                          return MonitorConfigCrudService.shouldShowField(
                            field,
                            _currentItemData,
                          );
                        })
                        .map((field) {
                          final fieldName = field['field'] as String;
                          final label = field['label'] as String? ?? fieldName;
                          final required = field['required'] == true;
                          final selectOptions =
                              field['select_options'] as Map<String, dynamic>?;
                          final dataType =
                              field['data_type']?.toString().toLowerCase() ??
                              '';
                          final isBooleanField =
                              dataType.contains('boolean') ||
                              dataType.contains('tinyint') ||
                              (fieldName ==
                                  'enable'); // Special case for enable field
                          final isDateTimeField =
                              dataType.contains('datetime') &&
                              field['editable'] == 'yes';
                          final isReadOnly = field['editable'] == 'no';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child:
                                isReadOnly
                                    ? _buildReadOnlyField(
                                      fieldName,
                                      label,
                                      dataType,
                                    )
                                    : isBooleanField
                                    ? _buildBooleanField(
                                      fieldName,
                                      label,
                                      required,
                                    )
                                    : isDateTimeField
                                    ? _buildDateTimeField(
                                      fieldName,
                                      label,
                                      required,
                                    )
                                    : selectOptions != null
                                    ? DropdownButtonFormField<String>(
                                      value:
                                          _controllers[fieldName]
                                                      ?.text
                                                      .isNotEmpty ==
                                                  true
                                              ? _controllers[fieldName]!.text
                                              : null,
                                      decoration: InputDecoration(
                                        labelText:
                                            required ? '$label *' : label,
                                        border: const OutlineInputBorder(),
                                      ),
                                      items:
                                          selectOptions.entries.map((entry) {
                                            return DropdownMenuItem<String>(
                                              value: entry.key,
                                              child: Text(
                                                entry.value.toString(),
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        _controllers[fieldName]?.text =
                                            value ?? '';
                                        _updateFieldValue(
                                          fieldName,
                                          value ?? '',
                                        );
                                      },
                                      validator:
                                          required
                                              ? (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty ||
                                                    value == '0') {
                                                  return 'Vui lòng chọn $label';
                                                }
                                                return null;
                                              }
                                              : null,
                                    )
                                    : TextFormField(
                                      controller: _controllers[fieldName],
                                      decoration: InputDecoration(
                                        labelText:
                                            required ? '$label *' : label,
                                        border: const OutlineInputBorder(),
                                        helperText: _getFieldHelperText(
                                          fieldName,
                                          dataType,
                                        ),
                                        helperMaxLines: 2,
                                      ),
                                      maxLines:
                                          dataType.contains('text') ? 3 : 1,
                                      onChanged: (value) {
                                        _updateFieldValue(fieldName, value);
                                      },
                                      validator:
                                          required
                                              ? (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Vui lòng nhập $label';
                                                }
                                                // Add email validation for alert_config
                                                if (fieldName ==
                                                    'alert_config') {
                                                  return _validateAlertConfig(
                                                    value,
                                                  );
                                                }
                                                return null;
                                              }
                                              : (value) {
                                                // Add email validation for alert_config even if not required
                                                if (fieldName ==
                                                        'alert_config' &&
                                                    value != null &&
                                                    value.trim().isNotEmpty) {
                                                  return _validateAlertConfig(
                                                    value,
                                                  );
                                                }
                                                return null;
                                              },
                                    ),
                          );
                        })
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
              onPressed: _isLoading ? null : _saveItem,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(widget.item != null ? 'Cập nhật' : 'Thêm'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBooleanField(String fieldName, String label, bool required) {
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

  Widget _buildDateTimeField(String fieldName, String label, bool required) {
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
              IconButton(
                onPressed: () => _selectDateTime(fieldName),
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Chọn ngày giờ',
              ),
              if (selectedDateTime != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _dateTimeValues[fieldName] = null;
                      _controllers[fieldName]?.text = '';
                      _updateFieldValue(fieldName, '');
                    });
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: 'Xóa',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
