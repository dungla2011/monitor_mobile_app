import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/web_auth_service.dart';

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

  // Change language and save to SharedPreferences + update API
  Future<Map<String, dynamic>> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) {
      return {'success': true, 'message': 'Ngôn ngữ đã được chọn'};
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
          'message': 'Đã cập nhật ngôn ngữ thành công',
        };
      } else {
        // API failed but local change succeeded
        return {
          'success': true,
          'message': 'Đã thay đổi ngôn ngữ (chưa đồng bộ lên server)',
          'warning': apiResult['message'],
        };
      }
    } catch (e) {
      print('Error changing language: $e');
      return {
        'success': false,
        'message': 'Lỗi khi thay đổi ngôn ngữ: $e',
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
          'message': 'Người dùng chưa đăng nhập',
        };
      }

      const String apiUrl = 'https://mon.lad.vn/api/member-user/update-member';
      
      print('🌐 Updating language to API: $languageCode');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: WebAuthService.getAuthenticatedHeaders(),
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
            'message': jsonResponse['message'] ?? 'Cập nhật ngôn ngữ thành công',
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'API trả về lỗi',
          };
        }
      } else if (response.statusCode == 401) {
        // Token expired
        return {
          'success': false,
          'message': 'Phiên đăng nhập hết hạn',
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error updating language to API: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
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
