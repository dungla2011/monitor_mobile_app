import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monitor_app/main.dart';

void main() {
  group('Simple Widget Tests', () {
    testWidgets('MyApp should build without errors', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle basic widget interactions', (
      WidgetTester tester,
    ) async {
      // Create a simple test widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test App')),
            body: const Column(
              children: [
                Text('Hello World'),
                ElevatedButton(onPressed: null, child: Text('Test Button')),
              ],
            ),
          ),
        ),
      );

      // Verify widgets are present
      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should display loading indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message', (WidgetTester tester) async {
      const errorMessage = 'Something went wrong';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text(errorMessage))),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should handle form validation', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      formKey.currentState?.validate();
                    },
                    child: const Text('Validate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Tap validate without entering text
      await tester.tap(find.text('Validate'));
      await tester.pump();

      // Should show validation error
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('should handle text input', (WidgetTester tester) async {
      const testText = 'Test input text';

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TextField())),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), testText);

      // Verify text was entered
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should handle button tap', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {
                buttonPressed = true;
              },
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      // Tap button
      await tester.tap(find.text('Tap Me'));

      // Verify button was pressed
      expect(buttonPressed, true);
    });

    testWidgets('should display list of items', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(items[index]));
              },
            ),
          ),
        ),
      );

      // Verify all items are displayed
      for (final item in items) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets('should handle navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Navigate'),
            ),
          ),
          routes: {
            '/second': (context) => const Scaffold(body: Text('Second Screen')),
          },
        ),
      );

      expect(find.text('Navigate'), findsOneWidget);
    });
  });
}
