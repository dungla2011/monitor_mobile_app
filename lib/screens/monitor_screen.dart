import 'package:flutter/material.dart';
import '../services/monitor_config_service.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  List<Map<String, dynamic>> _monitorItems = [];
  List<Map<String, dynamic>> _formFields = [];
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
      if (!MonitorConfigService.isConfigLoaded) {
        print('📋 Loading Monitor Config...');
        final configResult = await MonitorConfigService.initializeConfig();

        if (!configResult['success']) {
          setState(() {
            _errorMessage = configResult['message'];
            _isLoading = false;
          });
          return;
        }

        _formFields = MonitorConfigService.getFormFields();
        print('✅ Config loaded. Fields: ${_formFields.length}');
      }

      // Load monitor items
      await _loadMonitorItems();
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khởi tạo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMonitorItems() async {
    try {
      final result = await MonitorConfigService.getMonitorItems();

      if (result['success']) {
        setState(() {
          _monitorItems = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });

        if (result['needReauth'] == true) {
          _showReauthDialog();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  void _showReauthDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.clear();
      }
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
              'Bạn có chắc chắn muốn xóa ${_selectedItems.length} item(s)?',
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
        final result = await MonitorConfigService.deleteMonitorItems(
          _selectedItems.toList(),
        );

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Xóa thành công')),
          );

          setState(() {
            _selectedItems.clear();
            _isSelectionMode = false;
          });

          await _loadMonitorItems();
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

  void _showAddEditDialog({Map<String, dynamic>? item}) {
    showDialog(
      context: context,
      builder:
          (context) => MonitorItemDialog(
            item: item,
            fields: _formFields,
            onSaved: () async {
              Navigator.of(context).pop();
              await _loadMonitorItems();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor Items'),
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
              onPressed: _monitorItems.isNotEmpty ? _toggleSelectionMode : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMonitorItems,
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

    if (_monitorItems.isEmpty) {
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
              onPressed: () => _showAddEditDialog(),
              child: const Text('Thêm item đầu tiên'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMonitorItems,
      child: ListView.builder(
        itemCount: _monitorItems.length,
        itemBuilder: (context, index) {
          final item = _monitorItems[index];
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
                      : CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text('${index + 1}'),
                      ),
              title: Text(
                item['name']?.toString() ?? 'Item #$itemId',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item['description'] != null)
                    Text(item['description'].toString()),
                  const SizedBox(height: 4),
                  Text(
                    'ID: $itemId',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing:
                  _isSelectionMode
                      ? null
                      : PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _showAddEditDialog(item: item);
                              break;
                            case 'delete':
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

// Dialog for Add/Edit Monitor Item
class MonitorItemDialog extends StatefulWidget {
  final Map<String, dynamic>? item;
  final List<Map<String, dynamic>> fields;
  final VoidCallback onSaved;

  const MonitorItemDialog({
    super.key,
    this.item,
    required this.fields,
    required this.onSaved,
  });

  @override
  State<MonitorItemDialog> createState() => _MonitorItemDialogState();
}

class _MonitorItemDialogState extends State<MonitorItemDialog> {
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
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
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
        data[entry.key] = entry.value.text;
      }

      Map<String, dynamic> result;
      if (widget.item != null) {
        // Update existing item
        final itemId = widget.item!['id'] as int;
        result = await MonitorConfigService.updateMonitorItem(itemId, data);
      } else {
        // Add new item
        result = await MonitorConfigService.addMonitorItem(data);
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
      title: Text(
        widget.item != null ? 'Sửa Monitor Item' : 'Thêm Monitor Item',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  widget.fields
                      .where((field) {
                        // Check if field should be shown based on show_dependency
                        return MonitorConfigService.shouldShowField(
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
                            field['data_type']?.toString().toLowerCase() ?? '';
                        final isBooleanField =
                            dataType.contains('boolean') ||
                            dataType.contains('tinyint') ||
                            (fieldName ==
                                'enable'); // Special case for enable field
                        final isDateTimeField =
                            dataType.contains('datetime') &&
                            field['editable'] == 'yes';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child:
                              isBooleanField
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
                                      labelText: required ? '$label *' : label,
                                      border: const OutlineInputBorder(),
                                    ),
                                    items:
                                        selectOptions.entries.map((entry) {
                                          return DropdownMenuItem<String>(
                                            value: entry.key,
                                            child: Text(entry.value.toString()),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      _controllers[fieldName]?.text =
                                          value ?? '';
                                      _updateFieldValue(fieldName, value ?? '');
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
                                      labelText: required ? '$label *' : label,
                                      border: const OutlineInputBorder(),
                                    ),
                                    maxLines: dataType.contains('text') ? 3 : 1,
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
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
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
    );
  }
}
