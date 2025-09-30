/// Test configuration và utilities
library test_config;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Test configuration class
class TestConfig {
  static const String baseUrl = 'https://mon.lad.vn';
  static const String testToken = 'test_token_12345';

  // Test timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration longTimeout = Duration(minutes: 2);

  // Test data
  static const Map<String, String> testHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $testToken',
  };
}

/// Test utilities
class TestUtils {
  /// Tạo MaterialApp wrapper cho widget testing
  static Widget createTestApp({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: child),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }

  /// Tạo MaterialApp với navigation cho integration testing
  static Widget createTestAppWithNavigation({
    required Widget home,
    Map<String, WidgetBuilder>? routes,
  }) {
    return MaterialApp(
      home: home,
      routes: routes ?? {},
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }

  /// Pump widget và chờ animations hoàn thành
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Tìm widget theo text với timeout
  static Future<Finder> findByTextWithTimeout(
    WidgetTester tester,
    String text, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      await tester.pump(const Duration(milliseconds: 100));
      final finder = find.text(text);
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
    }

    throw TestFailure('Could not find text "$text" within timeout');
  }

  /// Create mock HTTP response for testing
  static http.Response createMockResponse(int statusCode, String responseBody) {
    return http.Response(responseBody, statusCode);
  }

  /// Create successful API response
  static http.Response createSuccessResponse(Map<String, dynamic> payload) {
    final response = {'code': 1, 'message': 'Success', 'payload': payload};
    return http.Response(response.toString(), 200);
  }

  /// Create error API response
  static http.Response createErrorResponse(String message, {int code = 0}) {
    final response = {'code': code, 'message': message, 'payload': null};
    return http.Response(response.toString(), 200);
  }

  /// Create HTTP error response
  static http.Response createHttpErrorResponse(int statusCode, String message) {
    final response = {'error': message};
    return http.Response(response.toString(), statusCode);
  }

  /// Verify widget exists và visible
  static void verifyWidgetVisible(Finder finder) {
    expect(finder, findsOneWidget);
    // Additional visibility checks could be added here
  }

  /// Verify widget không tồn tại
  static void verifyWidgetNotExists(Finder finder) {
    expect(finder, findsNothing);
  }

  /// Wait for condition với timeout
  static Future<void> waitForCondition(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (condition()) {
        return;
      }
      await Future.delayed(pollInterval);
    }

    throw TestFailure('Condition not met within timeout');
  }

  /// Log test step
  static void logTestStep(String step) {
    print('🧪 Test Step: $step');
  }

  /// Log test result
  static void logTestResult(String result, bool success) {
    final icon = success ? '✅' : '❌';
    print('$icon Test Result: $result');
  }
}

/// Custom matchers cho testing
class CustomMatchers {
  /// Matcher để check response format
  static Matcher hasApiResponseFormat() {
    return predicate<Map<String, dynamic>>((response) {
      return response.containsKey('success') &&
          response.containsKey('message') &&
          (response.containsKey('data') || response.containsKey('error'));
    }, 'has API response format');
  }

  /// Matcher để check successful API response
  static Matcher isSuccessfulApiResponse() {
    return predicate<Map<String, dynamic>>((response) {
      return response['success'] == true && response.containsKey('data');
    }, 'is successful API response');
  }

  /// Matcher để check error API response
  static Matcher isErrorApiResponse() {
    return predicate<Map<String, dynamic>>((response) {
      return response['success'] == false && response.containsKey('message');
    }, 'is error API response');
  }
}

/// Test data generators
class TestDataGenerator {
  static Map<String, dynamic> generateMonitorConfig({
    int? id,
    String? name,
    bool? status,
    String? alertType,
  }) {
    return {
      'id': id ?? 1,
      'name': name ?? 'Test Config ${DateTime.now().millisecondsSinceEpoch}',
      'status': status ?? true,
      'alert_type': alertType ?? 'email',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> generateMonitorItem({
    int? id,
    String? name,
    String? urlCheck,
    bool? enable,
  }) {
    return {
      'id': id ?? 1,
      'name': name ?? 'Test Item ${DateTime.now().millisecondsSinceEpoch}',
      'url_check': urlCheck ?? 'https://example.com',
      'enable': enable ?? true,
      'type': 'ping_web',
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}
