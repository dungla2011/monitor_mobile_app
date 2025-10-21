import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../utils/language_manager.dart';
import '../utils/user_agent_utils.dart';

/// Language information from server
class LanguageInfo {
  final String code; // 'vi', 'en', 'ja', etc.
  final String name; // 'Tiếng Việt', 'English', etc.
  final String nativeName; // Native language name
  final bool isActive; // Is language enabled on server
  final String? flagCode; // Country code for flag (e.g., 'VN', 'US')
  final DateTime? lastUpdated; // Last update timestamp

  LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isActive = true,
    this.flagCode,
    this.lastUpdated,
  });

  factory LanguageInfo.fromJson(Map<String, dynamic> json) {
    return LanguageInfo(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['native_name'] as String,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      flagCode: json['flag_code'] as String?,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'native_name': nativeName,
      'is_active': isActive,
      'flag_code': flagCode,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}

/// Service for dynamic language loading from server
class DynamicLocalizationService {
  static const String _baseUrl = '${AppConfig.apiBaseUrl}/api';
  static const String _cachePrefix = 'lang_cache_';
  static const String _lastSyncKey = 'lang_last_sync_';
  static const String _availableLangsKey = 'lang_available';
  static const int _cacheDurationHours =
      1; // Changed from 24 to 1 hour for easier testing

  // In-memory cache for available languages
  static List<LanguageInfo>? _cachedAvailableLanguages;
  static DateTime? _cachedAvailableLanguagesTime;
  static const int _memoryCacheDurationMinutes =
      5; // Cache in memory for 5 minutes

  // Prevent multiple simultaneous API calls
  static Future<List<LanguageInfo>>? _ongoingAvailableLanguagesRequest;

  /// Get authentication headers
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Check if language cache is expired
  static Future<bool> shouldSyncLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt('$_lastSyncKey$languageCode');

    if (lastSync == null) {
      print('📥 [$languageCode] No cache found - need to download');
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final hoursSinceSync = (now - lastSync) / (1000 * 60 * 60);
    final isExpired = hoursSinceSync >= _cacheDurationHours;

    if (isExpired) {
      print(
          '🔄 [$languageCode] Cache expired (${hoursSinceSync.toStringAsFixed(1)}h ago) - need to re-download');
    } else {
      print(
          '✅ [$languageCode] Cache valid (${hoursSinceSync.toStringAsFixed(1)}h ago, expires in ${(_cacheDurationHours - hoursSinceSync).toStringAsFixed(1)}h)');
    }

    return isExpired;
  }

  /// Get list of available languages from server
  static Future<List<LanguageInfo>> getAvailableLanguages() async {
    // Check if server loading is disabled
    if (AppConfig.enableLoadLanguage == 0) {
      print('🚫 Server language loading is disabled - returning default languages');
      return [
        LanguageInfo(
          code: 'en',
          name: 'English',
          nativeName: 'English',
          flagCode: 'GB',
        ),
        LanguageInfo(
          code: 'vi',
          name: 'Tiếng Việt',
          nativeName: 'Tiếng Việt',
          flagCode: 'VN',
        ),
      ];
    }

    // Check in-memory cache first
    if (_cachedAvailableLanguages != null &&
        _cachedAvailableLanguagesTime != null) {
      final age = DateTime.now().difference(_cachedAvailableLanguagesTime!);
      if (age.inMinutes < _memoryCacheDurationMinutes) {
        print(
            '✅ Using cached available languages (${_cachedAvailableLanguages!.length} languages, ${age.inSeconds}s old)');
        return _cachedAvailableLanguages!;
      }
    }

    // If there's already an ongoing request, wait for it instead of making a new one
    if (_ongoingAvailableLanguagesRequest != null) {
      print('⏳ Waiting for ongoing available languages request...');
      return await _ongoingAvailableLanguagesRequest!;
    }

    // Start new request and store the future
    _ongoingAvailableLanguagesRequest = _fetchAvailableLanguagesFromServer();

    try {
      final result = await _ongoingAvailableLanguagesRequest!;
      return result;
    } finally {
      // Clear the ongoing request
      _ongoingAvailableLanguagesRequest = null;
    }
  }

  /// Internal method to fetch from server
  static Future<List<LanguageInfo>> _fetchAvailableLanguagesFromServer() async {
    try {
      print('🌍 Fetching available languages from server...');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/get-available-languages'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 1 && data['payload'] != null) {
          final List<dynamic> langs = data['payload'];
          final languages = langs
              .map((lang) => LanguageInfo.fromJson(lang))
              .where((lang) => lang.isActive)
              .toList();

          // Cache in memory
          _cachedAvailableLanguages = languages;
          _cachedAvailableLanguagesTime = DateTime.now();

          // Cache to disk
          await _cacheAvailableLanguages(languages);

          print('✅ Loaded ${languages.length} active languages from server');
          return languages;
        }
      }

      print('⚠️ Server response not successful, using cache');
    } catch (e) {
      print('❌ Error fetching languages: $e');
    }

    // Fallback to disk cache or default
    return await _getCachedAvailableLanguages();
  }

  /// Download language translations from server
  static Future<Map<String, String>?> downloadLanguage(
    String languageCode,
  ) async {
    // Check if server loading is disabled
    if (AppConfig.enableLoadLanguage == 0) {
      print('🚫 Server language download is blocked (enableLoadLanguage = 0)');
      return null;
    }

    try {
      print('📥 Downloading language: $languageCode');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/get-language'),
            headers: await _getHeaders(),
            body: jsonEncode({
              'language_code': languageCode,
              'format': 'arb', // Request ARB format
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 1 && data['payload'] != null) {
          final Map<String, dynamic> translations = data['payload'];

          // Convert to Map<String, String>
          final result = <String, String>{};
          translations.forEach((key, value) {
            if (key.startsWith('@')) return; // Skip metadata
            result[key] = value.toString();
          });

          // Cache translations
          await _cacheLanguageTranslations(languageCode, result);

          print('✅ Downloaded ${result.length} translations for $languageCode');
          return result;
        }
      }

      print('⚠️ Failed to download language, using cache');
    } catch (e) {
      print('❌ Error downloading language: $e');
    }

    // Fallback to cached
    return await loadCachedLanguage(languageCode);
  }

  /// Load cached language translations
  static Future<Map<String, String>?> loadCachedLanguage(
    String languageCode,
  ) async {
    // Check if server loading is disabled
    if (AppConfig.enableLoadLanguage == 0) {
      print('🚫 Server language cache is blocked (enableLoadLanguage = 0)');
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$languageCode';
      final cached = prefs.getString(cacheKey);

      if (cached != null) {
        final Map<String, dynamic> decoded = jsonDecode(cached);
        print(
            '📦 Loaded ${decoded.length} cached translations for $languageCode');
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      print('❌ Error loading cached language: $e');
    }
    return null;
  }

  /// Cache language translations
  static Future<void> _cacheLanguageTranslations(
    String languageCode,
    Map<String, String> translations,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$languageCode';

    await prefs.setString(cacheKey, jsonEncode(translations));
    await prefs.setInt(
      '$_lastSyncKey$languageCode',
      DateTime.now().millisecondsSinceEpoch,
    );

    print('💾 Cached $languageCode translations');
  }

  /// Cache available languages list
  static Future<void> _cacheAvailableLanguages(
    List<LanguageInfo> languages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final json = languages.map((lang) => lang.toJson()).toList();
    await prefs.setString(_availableLangsKey, jsonEncode(json));
  }

  /// Get cached available languages
  static Future<List<LanguageInfo>> _getCachedAvailableLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_availableLangsKey);

      if (cached != null) {
        final List<dynamic> decoded = jsonDecode(cached);
        final languages =
            decoded.map((lang) => LanguageInfo.fromJson(lang)).toList();
        print('📦 Loaded ${languages.length} cached languages');
        return languages;
      }
    } catch (e) {
      print('❌ Error loading cached languages: $e');
    }

    // Return default languages if no cache
    return _getDefaultLanguages();
  }

  /// Get default built-in languages
  static List<LanguageInfo> _getDefaultLanguages() {
    return [
      LanguageInfo(
        code: 'vi',
        name: 'Vietnamese',
        nativeName: 'Tiếng Việt',
        flagCode: 'VN',
      ),
      LanguageInfo(
        code: 'en',
        name: 'English',
        nativeName: 'English',
        flagCode: 'US',
      ),
      LanguageInfo(
        code: 'ja',
        name: 'Japanese',
        nativeName: '日本語',
        flagCode: 'JP',
      ),
      LanguageInfo(
        code: 'ko',
        name: 'Korean',
        nativeName: '한국어',
        flagCode: 'KR',
      ),
      LanguageInfo(
        code: 'fr',
        name: 'French',
        nativeName: 'Français',
        flagCode: 'FR',
      ),
      LanguageInfo(
        code: 'de',
        name: 'German',
        nativeName: 'Deutsch',
        flagCode: 'DE',
      ),
      LanguageInfo(
        code: 'es',
        name: 'Spanish',
        nativeName: 'Español',
        flagCode: 'ES',
      ),
    ];
  }

  /// Sync all languages in background
  ///
  /// [forceSync] If true, ignore cache and download all languages.
  /// Useful for manual sync button in Settings.
  ///
  /// Returns list of language codes that were successfully synced.
  static Future<List<String>> syncAllLanguages({bool forceSync = false}) async {
    // Check if server loading is disabled
    if (AppConfig.enableLoadLanguage == 0) {
      print('🚫 Server language sync is blocked (enableLoadLanguage = 0)');
      return [];
    }

    print('🔄 Starting language sync... (force: $forceSync)');

    final syncedLanguages = <String>[];

    try {
      // Get available languages from server
      final languages = await getAvailableLanguages();
      print(
          '📋 Found ${languages.length} available languages: ${languages.map((l) => l.code).join(", ")}');

      // Download each language if needed
      for (final lang in languages) {
        final shouldSync = forceSync || await shouldSyncLanguage(lang.code);

        if (shouldSync) {
          print('⬇️ Downloading ${lang.code} (${lang.nativeName})...');
          final translations = await downloadLanguage(lang.code);
          if (translations != null && translations.isNotEmpty) {
            syncedLanguages.add(lang.code);
            print('✅ Downloaded ${lang.code}: ${translations.length} keys');
          } else {
            print('⚠️ Failed to download ${lang.code}');
          }
        } else {
          print('⏭️ Skipping ${lang.code} - cache still valid');
          // Still add to list if cache exists
          final cached = await loadCachedLanguage(lang.code);
          if (cached != null && cached.isNotEmpty) {
            syncedLanguages.add(lang.code);
            print('💾 Using cached ${lang.code}: ${cached.length} keys');
          }
        }
      }

      print(
          '✅ Language sync completed: ${syncedLanguages.length}/${languages.length} languages available');
    } catch (e) {
      print('❌ Language sync error: $e');
    }

    return syncedLanguages;
  }

  /// Clear all language cache (for debugging)
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_cachePrefix) ||
          key.startsWith(_lastSyncKey) ||
          key == _availableLangsKey) {
        await prefs.remove(key);
      }
    }

    print('🗑️ Language cache cleared');
  }
}
