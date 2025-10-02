import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/utils/language_manager.dart';

void main() {
  group('Pure Language Manager Tests (No API Dependencies)', () {
    late LanguageManager languageManager;

    setUpAll(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      languageManager = LanguageManager();
    });

    test('Should have default Vietnamese locale', () {
      expect(languageManager.currentLocale.languageCode, 'vi');
    });

    test('Should change language from Vietnamese to English', () async {
      // Initial state
      expect(languageManager.currentLocale.languageCode, 'vi');

      // Change to English
      final result =
          await languageManager.changeLanguage(const Locale('en', ''));

      // Should succeed (even if API fails, local change should work)
      expect(result['success'], true);
      expect(languageManager.currentLocale.languageCode, 'en');
    });

    test('Should change language from English back to Vietnamese', () async {
      // Set to English first
      await languageManager.changeLanguage(const Locale('en', ''));
      expect(languageManager.currentLocale.languageCode, 'en');

      // Change back to Vietnamese
      final result =
          await languageManager.changeLanguage(const Locale('vi', ''));

      expect(result['success'], true);
      expect(languageManager.currentLocale.languageCode, 'vi');
    });

    test('Should not change if same language is selected', () async {
      // Start with Vietnamese
      expect(languageManager.currentLocale.languageCode, 'vi');

      // Try to change to Vietnamese again
      final result =
          await languageManager.changeLanguage(const Locale('vi', ''));

      expect(result['success'], true);
      expect(result['message'], 'Ngôn ngữ đã được chọn');
      expect(languageManager.currentLocale.languageCode, 'vi');
    });

    test('Should support all defined locales', () {
      final supportedLocales = LanguageManager.supportedLocales;

      expect(supportedLocales.length, 2);
      expect(supportedLocales[0].languageCode, 'vi');
      expect(supportedLocales[1].languageCode, 'en');
    });

    test('Should have correct language names mapping', () {
      final languageNames = LanguageManager.languageNames;

      expect(languageNames['vi'], 'Tiếng Việt');
      expect(languageNames['en'], 'English');
    });

    test('Should handle language change notifications', () async {
      bool notificationReceived = false;

      // Listen to changes
      languageManager.addListener(() {
        notificationReceived = true;
      });

      // Change language
      await languageManager.changeLanguage(const Locale('en', ''));

      // Should have notified listeners
      expect(notificationReceived, true);
      expect(languageManager.currentLocale.languageCode, 'en');
    });

    test('API failure should not prevent local language change', () async {
      // This test verifies that even if API calls fail (like in test environment),
      // the local language change should still work

      final result =
          await languageManager.changeLanguage(const Locale('en', ''));

      // Should succeed locally regardless of API status
      expect(result['success'], true);
      expect(languageManager.currentLocale.languageCode, 'en');

      // Message might indicate API failure but local success
      expect(result['message'], isNotNull);
    });
  });
}
