import 'package:flutter/material.dart';
import '../services/monitor_config_crud_service.dart';

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
      print('🔄 Loading monitor configs...');
      final result = await MonitorConfigCrudService.getMonitorConfigs();
      print('📥 Monitor configs result: $result');

      if (result['success']) {
        final data = result['data'];
        print('📊 Monitor configs data type: ${data.runtimeType}');
        print('📊 Monitor configs data: $data');

        // Handle pagination format: extract 'data' array from pagination object
        final paginationData = result['data'];
        final actualData =
            paginationData is Map && paginationData.containsKey('data')
                ? paginationData['data']
                : paginationData;

        setState(() {
          _monitorConfigs = List<Map<String, dynamic>>.from(actualData ?? []);
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

  void _showAddEditDialog({Map<String, dynamic>? item}) {
    final isEditMode = item != null;
    final dialogFields = MonitorConfigCrudService.getFormFields(
      isEditMode: isEditMode,
    );

    showDialog(
      context: context,
      builder:
          (context) => MonitorConfigDialog(
            item: item,
            fields: dialogFields,
            onSaved: () async {
              Navigator.of(context).pop();
              await _loadMonitorConfigs();
            },
          ),
    );
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

  // Get icon for mobile field based on data type
  IconData _getFieldIcon(String dataType) {
    final lowerDataType = dataType.toLowerCase();

    if (lowerDataType == 'error_status') return Icons.info_outline;
    if (lowerDataType.contains('boolean')) return Icons.toggle_on;
    if (lowerDataType.contains('datetime')) return Icons.access_time;
    if (lowerDataType.contains('url') || lowerDataType.contains('link'))
      return Icons.link;

    return Icons.text_fields;
  }

  // Get color for mobile field value
  Color _getFieldColor(String value, String dataType) {
    if (dataType.toLowerCase() == 'error_status') {
      final intValue = int.tryParse(value) ?? 0;
      if (intValue < 0) return Colors.red;
      if (intValue > 0) return Colors.green;
      return Colors.grey;
    }

    return Colors.black87;
  }

  // Get name color based on error_status field
  Color _getNameColor(Map<String, dynamic> item) {
    // Get all field definitions to find error_status field
    final allFields = MonitorConfigCrudService.getMobileFields();

    // Find error_status field
    final errorStatusField = allFields.firstWhere(
      (field) => field['data_type']?.toString().toLowerCase() == 'error_status',
      orElse: () => <String, dynamic>{},
    );

    if (errorStatusField.isEmpty) {
      // If not found in mobile fields, check all field details
      final fieldDetails = MonitorConfigCrudService.fieldDetails;
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
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
            const Text('Nhấn nút + để thêm config mới'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddEditDialog(),
              child: const Text('Thêm config đầu tiên'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMonitorConfigs,
      child: ListView.builder(
        itemCount: _monitorConfigs.length,
        itemBuilder: (context, index) {
          final item = _monitorConfigs[index];
          final itemId = item['id'] as int? ?? 0;
          final isSelected = _selectedItems.contains(itemId);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading:
                  _isSelectionMode
                      ? Checkbox(
                        value: isSelected,
                        onChanged: (value) => _toggleItemSelection(itemId),
                      )
                      : null,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with edit button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['name']?.toString() ?? 'Config #$itemId',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _getNameColor(item),
                          ),
                        ),
                      ),
                      if (!_isSelectionMode)
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
                                _showAddEditDialog(item: item);
                                break;
                              case 'delete':
                                _selectedItems = {itemId};
                                _deleteSelectedItems();
                                break;
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Sửa'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Xóa'),
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
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Mobile fields
                  ..._mobileFields
                      .where(
                        (field) =>
                            field['field'] != 'name' && field['field'] != 'id',
                      )
                      .map((field) {
                        final fieldName = field['field'] as String;
                        final fieldLabel = field['label'] as String;
                        final dataType = field['data_type'] as String;
                        final selectOptions =
                            field['select_options'] as Map<String, dynamic>?;
                        final value = item[fieldName]?.toString() ?? '';
                        final formattedValue = _formatMobileValue(
                          value,
                          dataType,
                          selectOptions,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                _getFieldIcon(dataType),
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
                                  color: _getFieldColor(value, dataType),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ],
              ),
              trailing: null,
              onTap:
                  _isSelectionMode
                      ? () => _toggleItemSelection(itemId)
                      : () => _showAddEditDialog(item: item),
            ),
          );
        },
      ),
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
  final Map<String, bool> _booleanValues = {}; // Track boolean field states
  final Map<String, DateTime?> _dateTimeValues =
      {}; // Track datetime field states
  bool _isLoading = false;
  Map<String, dynamic> _currentItemData =
      {}; // Track current form data for dependency checking

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize current item data for dependency checking
    _currentItemData = Map<String, dynamic>.from(widget.item ?? {});

    for (final field in widget.fields) {
      final fieldName = field['field'] as String;
      final currentValue = widget.item?[fieldName]?.toString() ?? '';
      final dataType = field['data_type']?.toString().toLowerCase() ?? '';
      final isBooleanField =
          dataType.contains('boolean') ||
          dataType.contains('tinyint') ||
          (fieldName == 'enable');
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
    final currentValue = widget.item?[fieldName]?.toString() ?? '';
    final displayValue = _formatDisplayValue(currentValue, dataType);
    final isErrorStatus = dataType.toLowerCase() == 'error_status';

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
              child:
                  isErrorStatus
                      ? _buildErrorStatusDisplay(currentValue)
                      : Text(
                        displayValue.isNotEmpty
                            ? displayValue
                            : 'Chưa có dữ liệu',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              displayValue.isNotEmpty
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                          fontWeight:
                              displayValue.isNotEmpty
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

  // Build error status display with icon
  Widget _buildErrorStatusDisplay(String value) {
    if (value.isEmpty || value == 'null') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.help_outline, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            'N/A',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }

    final intValue = int.tryParse(value) ?? 0;

    if (intValue < 0) {
      // Error status - Red X
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close, size: 14, color: Colors.red.shade700),
          ),
          const SizedBox(width: 6),
          Text(
            'Lỗi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else if (intValue > 0) {
      // Success status - Green check
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 14, color: Colors.green.shade700),
          ),
          const SizedBox(width: 6),
          Text(
            'Thành công',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      // Neutral status - Gray circle
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '?',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'N/A',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }
  }

  // Format display value based on data type
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

  String _formatDateTime(DateTime dateTime) {
    // Format: YYYY-MM-DD HH:mm:ss
    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{};
      for (final entry in _controllers.entries) {
        // Only include editable fields in save data
        final field = widget.fields.firstWhere(
          (f) => f['field'] == entry.key,
          orElse: () => {'editable': 'yes'}, // Default to editable if not found
        );

        if (field['editable'] == 'yes') {
          data[entry.key] = entry.value.text;
        }
      }

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
          SnackBar(content: Text(result['message'] ?? 'Lưu thành công')),
        );
        widget.onSaved();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Lỗi khi lưu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                                    ? _buildToggleSwitch(
                                      fieldName,
                                      label,
                                      required,
                                    )
                                    : isDateTimeField
                                    ? _buildDateTimePicker(
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
                                                return null;
                                              }
                                              : null,
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
              onPressed: _isLoading ? null : _save,
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
}
