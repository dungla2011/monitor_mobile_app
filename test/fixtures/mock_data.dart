/// Mock data cho testing
class MockData {
  // Mock field details cho monitor_configs
  static const List<Map<String, dynamic>> mockMonitorConfigFieldDetails = [
    {
      "field_name": "id",
      "description": "Id",
      "data_type": "bigint(20)",
      "editable": "no",
      "show_in_api_edit_one": "yes",
      "show_in_api_list": "yes",
      "show_dependency": null,
      "show_mobile_field": "yes",
      "required": "yes",
    },
    {
      "field_name": "name",
      "description": "Name",
      "data_type": "varchar(128)",
      "editable": "yes",
      "show_in_api_edit_one": "yes",
      "show_in_api_list": "yes",
      "show_dependency": null,
      "show_mobile_field": "yes",
      "required": "yes",
    },
    {
      "field_name": "status",
      "description": "Status",
      "data_type": "boolean",
      "editable": "yes",
      "show_in_api_edit_one": "yes",
      "show_in_api_list": "yes",
      "show_dependency": null,
      "show_mobile_field": 0,
      "required": "no",
    },
    {
      "field_name": "alert_type",
      "description": "Alert_type",
      "data_type": "varchar(64)",
      "editable": "yes",
      "show_in_api_edit_one": "yes",
      "show_in_api_list": "yes",
      "show_dependency": null,
      "show_mobile_field": 0,
      "select_option_value": {
        "0": "-Chọn-",
        "email": "Gửi Email",
        "sms": "Gửi SMS",
        "telegram": "Gửi Telegram",
        "webhook": "Gọi Webhook",
      },
      "required": "no",
    },
  ];

  // Mock API list response
  static const Map<String, dynamic> mockApiListResponse = {
    "code": 1,
    "guide": "code = 1 => success; code !=1 =>  error",
    "message": "success",
    "payload": {
      "data": [
        {
          "id": 1,
          "status": true,
          "name": "Test Config 1",
          "created_at": "2025-09-30T00:00:00.000000Z",
          "alert_type": "email",
        },
        {
          "id": 2,
          "status": false,
          "name": "Test Config 2",
          "created_at": "2025-09-30T01:00:00.000000Z",
          "alert_type": "sms",
        },
      ],
      "current_page": 1,
      "total": 2,
      "per_page": 20,
    },
  };

  // Mock API get one response
  static const Map<String, dynamic> mockApiGetOneResponse = {
    "code": 1,
    "guide": "code = 1 => success; code !=1 =>  error",
    "message": "success",
    "payload": {
      "id": 1,
      "status": true,
      "name": "Test Config 1",
      "created_at": "2025-09-30T00:00:00.000000Z",
      "alert_type": "email",
      "alert_config": "test@example.com",
    },
  };

  // Mock error response
  static const Map<String, dynamic> mockErrorResponse = {
    "code": 0,
    "message": "Test error message",
    "payload": null,
  };

  // Mock monitor items data
  static const List<Map<String, dynamic>> mockMonitorItemFieldDetails = [
    {
      "field_name": "id",
      "description": "Id",
      "data_type": "bigint(20)",
      "editable": "no",
      "show_in_api_edit_one": "yes",
      "show_in_api_list": "yes",
      "show_mobile_field": "yes",
      "required": "yes",
    },
    {
      "field_name": "name",
      "description": "Name",
      "data_type": "varchar(128)",
      "editable": "yes",
      "show_in_api_edit_one": "yes",
      "show_in_api_list": "yes",
      "show_mobile_field": "yes",
      "required": "yes",
    },
    {
      "field_name": "url_check",
      "description": "URL Check",
      "data_type": "text",
      "editable": "yes",
      "show_in_api_edit_one": "yes",
      "show_in_api_list": "yes",
      "show_mobile_field": "yes",
      "required": "yes",
    },
    {
      "field_name": "enable",
      "description": "Enable",
      "data_type": "boolean",
      "editable": "yes",
      "show_in_api_edit_one": "yes",
      "show_in_api_list": "yes",
      "show_mobile_field": "yes",
      "required": "no",
    },
  ];

  // Mock HTTP responses
  static const String mockSuccessResponseBody = '''
  {
    "code": 1,
    "message": "Success",
    "payload": {"test": "data"}
  }
  ''';

  static const String mockErrorResponseBody = '''
  {
    "code": 0,
    "message": "Error occurred",
    "payload": null
  }
  ''';

  static const String mockInvalidJsonResponseBody = 'Invalid JSON';
}
