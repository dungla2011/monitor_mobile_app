import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('vi', ''); // Default to Vietnamese

  Locale get currentLocale => _currentLocale;

  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('vi', ''), // Vietnamese
    Locale('en', ''), // English
  ];

  static const Map<String, String> languageNames = {
    'vi': 'Tiếng Việt',
    'en': 'English',
  };

  LanguageManager() {
    _loadSavedLanguage();
  }

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage, '');
        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved language: $e');
    }
  }

  // Change language and save to SharedPreferences
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);

      _currentLocale = locale;
      notifyListeners();
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  // Get language name for display
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  // Check if language is supported
  bool isSupported(Locale locale) {
    return supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }
}
