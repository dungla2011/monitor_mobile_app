import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/web_auth_service.dart';
import '../services/dynamic_localization_service.dart';
import '../l10n/dynamic_app_localizations.dart';
import '../config/app_config.dart';

class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _cachedLanguagesKey = 'cached_available_languages';

  Locale _currentLocale = const Locale('vi', ''); // Default to Vietnamese

  Locale get currentLocale => _currentLocale;

  // Dynamic list of supported locales loaded from server
  List<Locale> _supportedLocales = [
    const Locale('vi', ''), // Vietnamese (default)
    const Locale('en', ''), // English (default)
  ];

  List<Locale> get supportedLocales => _supportedLocales;

  // Dynamic map of language names loaded from server
  Map<String, String> _languageNames = {
    'vi': 'Tiếng Việt',
    'en': 'English',
  };

  Map<String, String> get languageNames => _languageNames;

  // Fallback static values for when API is not available
  static const List<Locale> _fallbackLocales = [
    Locale('vi', ''), // Vietnamese
    Locale('en', ''), // English
    Locale('ja', ''), // Japanese
    Locale('ko', ''), // Korean
    Locale('fr', ''), // French
    Locale('de', ''), // German
    Locale('es', ''), // Spanish
    Locale('km', ''), // Khmer
  ];

  static const Map<String, String> _fallbackLanguageNames = {
    'vi': 'Tiếng Việt',
    'en': 'English',
    'ja': '日本語',
    'ko': '한국어',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
    'km': 'ភាសាខ្មែរ',
  };

  LanguageManager() {
    _initializeLanguage();
    _loadAvailableLanguagesFromServer();
  }

  // Load available languages from server API
  Future<void> _loadAvailableLanguagesFromServer() async {
    try {
      final String apiUrl = '${AppConfig.apiUrl}/get-available-languages';
      
      print('🌍 Loading available languages from server...');
      
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['code'] == 1 && jsonResponse['payload'] != null) {
          final List<dynamic> languages = jsonResponse['payload'];
          
          // Build dynamic lists
          final List<Locale> newLocales = [];
          final Map<String, String> newNames = {};
          
          for (var lang in languages) {
            if (lang['is_active'] == 1) {
              final code = lang['code'] as String;
              final nativeName = lang['native_name'] as String;
              
              newLocales.add(Locale(code, ''));
              newNames[code] = nativeName;
            }
          }
          
          if (newLocales.isNotEmpty) {
            _supportedLocales = newLocales;
            _languageNames = newNames;
            
            // Cache to SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_cachedLanguagesKey, jsonEncode({
              'locales': newLocales.map((l) => l.languageCode).toList(),
              'names': newNames,
            }));
            
            print('✅ Loaded ${newLocales.length} languages from server');
            notifyListeners();
            
            // Download ARB files for all languages in background
            _downloadAllLanguageARBFiles(newLocales);
          }
        }
      } else {
        print('⚠️ Failed to load languages from server, using fallback');
        _useFallbackLanguages();
      }
    } catch (e) {
      print('❌ Error loading languages from server: $e');
      _useFallbackLanguages();
      
      // Try to load from cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(_cachedLanguagesKey);
        if (cached != null) {
          final data = jsonDecode(cached);
          final List<String> codes = List<String>.from(data['locales']);
          final Map<String, String> names = Map<String, String>.from(data['names']);
          
          _supportedLocales = codes.map((code) => Locale(code, '')).toList();
          _languageNames = names;
          
          print('✅ Loaded ${_supportedLocales.length} languages from cache');
          notifyListeners();
        }
      } catch (cacheError) {
        print('❌ Error loading from cache: $cacheError');
      }
    }
  }

  // Download ARB files for all available languages in background
  void _downloadAllLanguageARBFiles(List<Locale> locales) async {
    print('📥 Starting background download of ARB files for ${locales.length} languages...');
    
    for (final locale in locales) {
      try {
        final languageCode = locale.languageCode;
        
        // Check if already cached recently (within 24 hours)
        final shouldDownload = await DynamicLocalizationService.shouldSyncLanguage(languageCode);
        
        if (shouldDownload) {
          print('📥 Downloading ARB file for: $languageCode');
          final translations = await DynamicLocalizationService.downloadLanguage(languageCode);
          
          if (translations != null && translations.isNotEmpty) {
            print('✅ Downloaded ${translations.length} keys for $languageCode');
            
            // Load into DynamicAppLocalizations for immediate use
            await DynamicAppLocalizations.loadServerTranslations(locale);
          }
        } else {
          print('⏭️ Skipping $languageCode (recently synced)');
        }
      } catch (e) {
        print('❌ Error downloading ARB for ${locale.languageCode}: $e');
      }
    }
    
    print('✅ Completed background ARB download');
  }

  // Use fallback languages when server is not available
  void _useFallbackLanguages() {
    _supportedLocales = List.from(_fallbackLocales);
    _languageNames = Map.from(_fallbackLanguageNames);
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
        // Check if it's an HTTP error (statusCode >= 400)
        final statusCode = apiResult['statusCode'] as int?;
        if (statusCode != null && statusCode >= 400) {
          // Return HTTP error for UI to show error dialog
          return {
            'success': false,
            'messageKey': apiResult['messageKey'] ?? 'languageHttpError',
            'statusCode': statusCode,
            'responseBody': apiResult['responseBody'],
          };
        } else {
          // Non-HTTP error (network, timeout, etc.) - local change succeeded
          return {
            'success': true,
            'messageKey': 'languageChangedNotSynced',
            'warning': apiResult['message'] ?? apiResult['messageKey'],
          };
        }
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
    return _supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  // Public method to refresh available languages from server
  Future<void> refreshAvailableLanguages() async {
    await _loadAvailableLanguagesFromServer();
  }
}
