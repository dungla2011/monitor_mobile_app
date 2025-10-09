import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:monitor_app/main.dart';
import 'package:monitor_app/utils/language_manager.dart';
import 'package:monitor_app/widgets/web_auth_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monitor_app/l10n/app_localizations.dart';
import 'package:monitor_app/l10n/server_app_localizations_delegate.dart';

/// Helper widget to wrap MainScreen with all required dependencies
Widget createTestableWidget() {
  return ChangeNotifierProvider(
    create: (_) => LanguageManager(),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        ServerAppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],
      home: const MainScreen(),
    ),
  );
}

void main() {
  group('Logout Functionality Tests', () {
    setUp(() async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'bearer_token': 'mock_token_12345',
        'user_email': 'test@example.com',
        'selected_language': 'en',
      });
    });

    testWidgets('MainScreen should have logout button in drawer', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(createTestableWidget());

      // Wait for app to build
      await tester.pumpAndSettle();

      // Open drawer
      final drawerFinder = find.byType(Drawer);
      expect(drawerFinder, findsNothing); // Drawer is closed initially

      // Find and tap menu button
      final menuButton = find.byIcon(Icons.menu);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Verify drawer is open
      expect(find.byType(Drawer), findsOneWidget);

      // Find logout button
      final logoutButton = find.widgetWithIcon(ListTile, Icons.logout);
      expect(logoutButton, findsOneWidget);
    });

    testWidgets('Logout button should show confirmation dialog', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(createTestableWidget());

      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap logout button
      final logoutButton = find.widgetWithIcon(ListTile, Icons.logout);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);

      // Verify dialog has Cancel and Logout buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Logout'),
          findsAtLeastNWidgets(1)); // At least 1 (may have multiple)
    });

    testWidgets('Cancel button should close dialog without logout', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(createTestableWidget());

      await tester.pumpAndSettle();

      // Open drawer and tap logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithIcon(ListTile, Icons.logout));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(AlertDialog), findsNothing);

      // Verify still on MainScreen (not logged out)
      expect(find.byType(MainScreen), findsOneWidget);
    });

    testWidgets('Confirm logout should show loading indicator', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(createTestableWidget());

      await tester.pumpAndSettle();

      // Open drawer and tap logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithIcon(ListTile, Icons.logout));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap Logout button (confirm)
      final logoutButtons = find.text('Logout');
      await tester.tap(logoutButtons.last); // Tap the one in dialog
      await tester.pump(); // Start logout process

      // Verify loading SnackBar appears
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Successful logout should clear data and navigate', (
      WidgetTester tester,
    ) async {
      // Set up initial token
      SharedPreferences.setMockInitialValues({
        'bearer_token': 'test_token_logout',
        'user_email': 'logout@test.com',
      });

      // Build the app
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Verify we start on MainScreen
      expect(find.byType(MainScreen), findsOneWidget);

      // Get SharedPreferences to verify token exists
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('bearer_token'), isNotNull);

      // Open drawer and tap logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithIcon(ListTile, Icons.logout));
      await tester.pumpAndSettle();

      // Confirm logout dialog
      final confirmButton = find.text('Logout');
      expect(confirmButton, findsWidgets);
      await tester.tap(confirmButton.last);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify token was cleared (main goal of logout)
      final refreshedPrefs = await SharedPreferences.getInstance();
      expect(refreshedPrefs.getString('bearer_token'), isNull);

      // After navigation, MainScreen should be removed from widget tree
      // (it navigates to WebAuthWrapper with pushAndRemoveUntil)
      expect(find.byType(MainScreen), findsNothing);
    });

    testWidgets('Logout should clear bearer token', (
      WidgetTester tester,
    ) async {
      // Set up mock with token
      SharedPreferences.setMockInitialValues({
        'bearer_token': 'test_token_xyz',
        'user_email': 'user@test.com',
      });

      final prefs = await SharedPreferences.getInstance();

      // Verify token exists before logout
      expect(prefs.getString('bearer_token'), isNotNull);
      expect(prefs.getString('bearer_token'), equals('test_token_xyz'));

      // Build app
      await tester.pumpWidget(createTestableWidget());

      await tester.pumpAndSettle();

      // Open drawer and logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithIcon(ListTile, Icons.logout));
      await tester.pumpAndSettle();

      // Confirm logout
      final logoutButtons = find.text('Logout');
      await tester.tap(logoutButtons.last);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify token is cleared
      final refreshedPrefs = await SharedPreferences.getInstance();
      expect(refreshedPrefs.getString('bearer_token'), isNull);
    });

    testWidgets('Multiple logout attempts should be handled gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());

      await tester.pumpAndSettle();

      // First logout attempt
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithIcon(ListTile, Icons.logout));
      await tester.pumpAndSettle();

      // Cancel first attempt
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Second logout attempt
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithIcon(ListTile, Icons.logout));
      await tester.pumpAndSettle();

      // Verify dialog shows again
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('Logout Error Handling Tests', () {
    testWidgets('Should handle logout errors gracefully', (
      WidgetTester tester,
    ) async {
      // Setup mock that will cause errors
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(createTestableWidget());

      await tester.pumpAndSettle();

      // Attempt logout
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithIcon(ListTile, Icons.logout));
      await tester.pumpAndSettle();

      // Confirm logout
      final logoutButtons = find.text('Logout');
      if (logoutButtons.evaluate().isNotEmpty) {
        await tester.tap(logoutButtons.last);
        await tester.pump();

        // Even with errors, should not crash
        // Just verify app is still running
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });
}
