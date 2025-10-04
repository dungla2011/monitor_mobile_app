import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/web_auth_service.dart';
import '../config/app_config.dart';

class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('vi', ''); // Default to Vietnamese

  Locale get currentLocale => _currentLocale;

  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('vi', ''), // Vietnamese
    Locale('en', ''), // English
    Locale('fr', ''), // French
    Locale('de', ''), // German
    Locale('es', ''), // Spanish
    Locale('ja', ''), // Japanese
    Locale('ko', ''), // Korean
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'vi': 'Tiếng Việt',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
    'ja': '日本語',
    'ko': '한국어',
  };

  LanguageManager() {
    _initializeLanguage();
  }

  // Initialize language - load from API first, then fallback to local
  Future<void> _initializeLanguage() async {
    // First try to load from API if user is logged in
    final apiResult = await _loadLanguageFromAPI();

    if (apiResult['success']) {
      print('✅ Loaded language from API: ${apiResult['language']}');
      // Language already updated by _loadLanguageFromAPI
    } else {
      print('⚠️ API load failed, using local: ${apiResult['message']}');
      // Fallback to local saved language
      await _loadSavedLanguage();
    }
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

  // Change language and save to SharedPreferences + update API
  Future<Map<String, dynamic>> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) {
      return {'success': true, 'messageKey': 'languageAlreadySelected'};
    }

    try {
      // 1. Save to SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);

      // 2. Update local state
      _currentLocale = locale;
      notifyListeners();

      // 3. Update to API if user is logged in
      final apiResult = await _updateLanguageToAPI(locale.languageCode);

      if (apiResult['success']) {
        return {
          'success': true,
          'messageKey': 'languageUpdateSuccess',
        };
      } else {
        // API failed but local change succeeded
        return {
          'success': true,
          'messageKey': 'languageChangedNotSynced',
          'warning': apiResult['message'],
        };
      }
    } catch (e) {
      print('Error changing language: $e');
      return {
        'success': false,
        'messageKey': 'languageChangeError',
        'error': e.toString(),
      };
    }
  }

  // Update language preference to API
  Future<Map<String, dynamic>> _updateLanguageToAPI(String languageCode) async {
    try {
      // Check if user is logged in
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'messageKey': 'languageUserNotLoggedIn',
        };
      }

      final String apiUrl = '${AppConfig.memberUrl}/update-member';

      print('🌐 Updating language to API: $languageCode');

      final headers = await WebAuthService.getAuthenticatedHeaders();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({
          'language': languageCode,
        }),
      );

      print('📥 Language API response status: ${response.statusCode}');
      print('📥 Language API response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Check API response format
        if (jsonResponse['code'] == 1) {
          return {
            'success': true,
            'messageKey': 'languageUpdateSuccess',
            'apiMessage': jsonResponse['message'],
          };
        } else {
          return {
            'success': false,
            'messageKey': 'languageApiError',
            'apiMessage': jsonResponse['message'],
          };
        }
      } else if (response.statusCode == 401) {
        // Token expired
        return {
          'success': false,
          'messageKey': 'languageSessionExpired',
          'statusCode': 401,
        };
      } else {
        return {
          'success': false,
          'messageKey': 'languageHttpError',
          'statusCode': response.statusCode,
          'responseBody': response.body,
        };
      }
    } catch (e) {
      print('❌ Error updating language to API: $e');
      return {
        'success': false,
        'messageKey': 'languageConnectionError',
        'error': e.toString(),
      };
    }
  }

  // Get language name for display
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  // Load language preference from API
  Future<Map<String, dynamic>> _loadLanguageFromAPI() async {
    try {
      // Check if user is logged in
      if (!WebAuthService.hasValidToken()) {
        return {
          'success': false,
          'message': 'You need to log in first',
        };
      }

      final String apiUrl = '${AppConfig.memberUrl}/get-member';

      print('🌐 Loading user info from API...');

      final headers = await WebAuthService.getAuthenticatedHeaders();
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      print('📥 Get member API response status: ${response.statusCode}');
      print('📥 Get member API response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Check API response format
        if (jsonResponse['code'] == 1 && jsonResponse['payload'] != null) {
          final payload = jsonResponse['payload'];
          final apiLanguage = payload['language'] ?? 'vi';

          print('🌍 User language from API: $apiLanguage');

          // Update local language if different
          final newLocale = Locale(apiLanguage, '');
          if (_currentLocale.languageCode != apiLanguage) {
            // Save to SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_languageKey, apiLanguage);

            // Update current locale
            _currentLocale = newLocale;
            notifyListeners();

            print('✅ Language updated from API: $apiLanguage');
          }

          return {
            'success': true,
            'language': apiLanguage,
            'userInfo': payload,
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'API returned invalid data',
          };
        }
      } else if (response.statusCode == 401) {
        // Token expired
        return {
          'success': false,
          'message': 'Your session has expired, please log in again',
        };
      } else {
        return {
          'success': false,
          'message': 'Error HTTPx ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error loading language from API1: $e');
      return {
        'success': false,
        'message': 'Error connecting1: $e',
      };
    }
  }

  // Public method to manually refresh language from API
  Future<Map<String, dynamic>> refreshLanguageFromAPI() async {
    return await _loadLanguageFromAPI();
  }

  // Sync language from user info (called after user info is loaded)
  Future<void> syncLanguageFromUserInfo() async {
    try {
      final userInfo = WebAuthService.currentUser;
      if (userInfo != null && userInfo['language'] != null) {
        final apiLanguage = userInfo['language'] as String;
        final newLocale = Locale(apiLanguage, '');

        if (_currentLocale.languageCode != apiLanguage) {
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_languageKey, apiLanguage);

          // Update current locale
          _currentLocale = newLocale;
          notifyListeners();

          print('🌍 Language synced from user info1: $apiLanguage');
        }
      }
    } catch (e) {
      print('❌ Error syncing language from user info1: $e');
    }
  }

  // Check if language is supported
  bool isSupported(Locale locale) {
    return supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }
}
