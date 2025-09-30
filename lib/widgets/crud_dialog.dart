import 'package:flutter/material.dart';
import '../utils/crud_utils.dart';
import '../utils/error_dialog_utils.dart';

/// Generic CRUD Dialog for Add/Edit operations
class CrudDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? item;
  final List<Map<String, dynamic>> fields;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> data) onSave;
  final VoidCallback onSaved;

  const CrudDialog({
    super.key,
    required this.title,
    this.item,
    required this.fields,
    required this.onSave,
    required this.onSaved,
  });

  @override
  State<CrudDialog> createState() => _CrudDialogState();
}

class _CrudDialogState extends State<CrudDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _booleanValues = {};
  final Map<String, DateTime?> _dateTimeValues = {};
  bool _isLoading = false;

  // Track current item data for dependency checking
  final Map<String, dynamic> _currentItemData = {};

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
      final data = CrudUtils.prepareSaveData(_controllers, widget.fields);

      print('📤 Sending data to server: $data');

      final result = await widget.onSave(data);

      if (result['success']) {
        CrudUtils.showSnackBar(
          context,
          message: result['message'] ?? 'Lưu thành công',
          isSuccess: true,
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
      title: Container(
        padding: const EdgeInsets.only(top: 8),
        child: widget.item != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sửa ${widget.title}'),
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
            : Text('Thêm ${widget.title}'),
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
                      return CrudUtils.shouldShowField(
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
              onPressed: _isLoading ? null : _saveItem,
              child: _isLoading
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

  Widget _buildField(Map<String, dynamic> field) {
    final fieldName =
        field['field']?.toString() ?? field['field_name']?.toString() ?? '';
    final label = field['label']?.toString() ??
        field['description']?.toString() ??
        fieldName;
    final required = field['required'] == true;

    // Try to get select options from multiple sources
    Map<String, dynamic>? selectOptions =
        field['select_options'] as Map<String, dynamic>?;

    // If not found, try to get from item data (API response might include it)
    if (selectOptions == null && widget.item != null) {
      final optionsKey = '_$fieldName';
      if (widget.item!.containsKey(optionsKey) &&
          widget.item![optionsKey] is Map) {
        selectOptions = widget.item![optionsKey] as Map<String, dynamic>?;
      }
    }

    final dataType = field['data_type']?.toString().toLowerCase() ?? '';
    final isBooleanField = dataType.contains('boolean') ||
        dataType.contains('tinyint') ||
        (fieldName == 'enable');
    final isDateTimeField =
        dataType.contains('datetime') && field['editable'] == 'yes';
    final isReadOnly = field['editable'] == 'no';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isReadOnly
          ? _buildReadOnlyField(fieldName, label, dataType)
          : isBooleanField
              ? _buildBooleanField(fieldName, label, required)
              : isDateTimeField
                  ? _buildDateTimeField(fieldName, label, required)
                  : selectOptions != null
                      ? _buildDropdownField(
                          fieldName, label, required, selectOptions)
                      : _buildTextField(fieldName, label, required, dataType),
    );
  }

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

  Widget _buildDropdownField(
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
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Vui lòng nhập $label';
        }
        return CrudUtils.validateField(value, {
          'field': fieldName,
          'label': label,
          'data_type': dataType,
          'required': required ? 'yes' : 'no',
        });
      },
    );
  }
}
