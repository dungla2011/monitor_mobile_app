/// Utility functions for CRUD operations
class CrudUtils {
  /// Validates if a field should be shown based on dependency conditions
  static bool shouldShowField(
    Map<String, dynamic> field,
    Map<String, dynamic> currentData,
  ) {
    final showDependency = field['show_dependency'] as String?;

    if (showDependency == null || showDependency.isEmpty) {
      return true; // No dependency, always show
    }

    // Parse dependency format: "field_name:value" or "field_name:!value"
    final parts = showDependency.split(':');
    if (parts.length != 2) {
      return true; // Invalid format, show by default
    }

    final dependencyField = parts[0];
    final expectedValue = parts[1];
    final currentValue = currentData[dependencyField]?.toString() ?? '';

    // Handle negation (!)
    if (expectedValue.startsWith('!')) {
      final notValue = expectedValue.substring(1);
      return currentValue != notValue;
    }

    return currentValue == expectedValue;
  }

  /// Formats a value for display based on field type
  static String formatDisplayValue(
    dynamic value,
    String dataType,
    Map<String, dynamic>? selectOptions,
  ) {
    if (value == null || value.toString().isEmpty) {
      return '-';
    }

    final stringValue = value.toString();

    // Handle select options
    if (selectOptions != null && selectOptions.containsKey(stringValue)) {
      return selectOptions[stringValue].toString();
    }

    // Handle boolean
    if (dataType.toLowerCase().contains('boolean')) {
      if (stringValue == '1' || stringValue.toLowerCase() == 'true') {
        return 'Có';
      } else if (stringValue == '0' || stringValue.toLowerCase() == 'false') {
        return 'Không';
      }
    }

    // Handle datetime
    if (dataType.toLowerCase().contains('datetime') ||
        dataType.toLowerCase().contains('timestamp')) {
      try {
        final date = DateTime.parse(stringValue);
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        return stringValue;
      }
    }

    return stringValue;
  }

  /// Gets appropriate icon for field type
  static String getFieldIcon(String dataType) {
    final type = dataType.toLowerCase();

    if (type.contains('varchar') || type.contains('text')) {
      return 'text_fields';
    } else if (type.contains('int') || type.contains('number')) {
      return 'numbers';
    } else if (type.contains('boolean')) {
      return 'check_box';
    } else if (type.contains('datetime') || type.contains('timestamp')) {
      return 'schedule';
    } else if (type.contains('email')) {
      return 'email';
    } else if (type.contains('url')) {
      return 'link';
    } else {
      return 'help_outline';
    }
  }

  /// Validates required fields
  static Map<String, dynamic> validateRequiredFields(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> fieldDetails,
  ) {
    final errors = <String>[];

    for (final field in fieldDetails) {
      final fieldName = field['field_name'] as String;
      final required = field['required'] as String?;
      final description = field['description'] as String? ?? fieldName;

      if (required == 'yes') {
        final value = data[fieldName];
        if (value == null || value.toString().trim().isEmpty) {
          errors.add('$description là bắt buộc');
        }
      }
    }

    if (errors.isNotEmpty) {
      return {
        'success': false,
        'message': errors.join(', '),
        'errors': errors,
      };
    }

    return {
      'success': true,
      'message': 'Validation passed',
    };
  }

  /// Filters data to only include editable fields
  static Map<String, dynamic> filterEditableData(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> fieldDetails,
  ) {
    final filteredData = <String, dynamic>{};

    for (final field in fieldDetails) {
      final fieldName = field['field_name'] as String;
      final editable = field['editable'] as String?;

      if (editable == 'yes' && data.containsKey(fieldName)) {
        filteredData[fieldName] = data[fieldName];
      }
    }

    return filteredData;
  }
}
