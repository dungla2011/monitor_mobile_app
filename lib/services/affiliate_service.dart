import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service để track affiliate/referrer tracking
/// Lưu affiliate_code vào SharedPreferences và gửi kèm mọi API request
class AffiliateService {
  static const String _affiliateCodeKey = 'affiliate_code';
  static const String _referrerKey = 'install_referrer';
  static const String _affiliateTimestampKey = 'affiliate_timestamp';
  
  // In-memory cache
  static String? _cachedAffiliateCode;
  static DateTime? _lastChecked;
  
  /// Khởi tạo - Load affiliate code từ storage
  static Future<void> initialize() async {
    await _loadAffiliateCode();
    
    // Chỉ capture referrer trên Android (không phải web)
    if (!kIsWeb) {
      await _captureInstallReferrer();
    }
  }
  
  /// Load affiliate code từ SharedPreferences
  static Future<void> _loadAffiliateCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedAffiliateCode = prefs.getString(_affiliateCodeKey);
      
      if (_cachedAffiliateCode != null) {
        final timestamp = prefs.getInt(_affiliateTimestampKey);
        if (timestamp != null) {
          _lastChecked = DateTime.fromMillisecondsSinceEpoch(timestamp);
          print('✅ Loaded affiliate code: $_cachedAffiliateCode (saved at $_lastChecked)');
        }
      }
    } catch (e) {
      print('❌ Error loading affiliate code: $e');
    }
  }
  
  /// Capture Install Referrer từ Google Play (Android only)
  /// 
  /// Note: Hiện tại chưa implement vì cần thêm package android_play_install_referrer.
  /// Affiliate code có thể được set qua:
  /// 1. Deep links: parseFromUrl()
  /// 2. Manual: setAffiliateCode()
  /// 3. Tương lai: Implement method này khi cần tracking chính xác hơn
  static Future<void> _captureInstallReferrer() async {
    try {
      // TODO: Implement khi cần tracking chính xác từ Google Play
      // Yêu cầu thêm package: android_play_install_referrer: ^0.3.0
      
      // Example implementation:
      // final referrer = await AndroidPlayInstallReferrer.installReferrer;
      // if (referrer != null && referrer.isNotEmpty) {
      //   print('📊 Raw referrer: $referrer');
      //   final params = Uri.splitQueryString(referrer);
      //   final affiliateCode = params['affiliate'] ?? 
      //                        params['ref'] ?? 
      //                        params['utm_campaign'];
      //   if (affiliateCode != null) {
      //     await setAffiliateCode(affiliateCode);
      //   }
      // }
      
      print('ℹ️ Install referrer capture not implemented yet (use deep links instead)');
    } catch (e) {
      print('❌ Error capturing install referrer: $e');
    }
  }
  
  /// Set affiliate code thủ công (cho testing hoặc deep link)
  static Future<void> setAffiliateCode(String code) async {
    try {
      if (code.isEmpty) return;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_affiliateCodeKey, code);
      await prefs.setInt(_affiliateTimestampKey, DateTime.now().millisecondsSinceEpoch);
      
      _cachedAffiliateCode = code;
      _lastChecked = DateTime.now();
      
      print('✅ Affiliate code saved: $code');
    } catch (e) {
      print('❌ Error saving affiliate code: $e');
    }
  }
  
  /// Lấy affiliate code hiện tại
  static Future<String?> getAffiliateCode() async {
    // Return cached value nếu có
    if (_cachedAffiliateCode != null) {
      return _cachedAffiliateCode;
    }
    
    // Load từ storage nếu cache trống
    await _loadAffiliateCode();
    return _cachedAffiliateCode;
  }
  
  /// Xóa affiliate code (khi cần reset)
  static Future<void> clearAffiliateCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_affiliateCodeKey);
      await prefs.remove(_referrerKey);
      await prefs.remove(_affiliateTimestampKey);
      
      _cachedAffiliateCode = null;
      _lastChecked = null;
      
      print('🗑️ Affiliate code cleared');
    } catch (e) {
      print('❌ Error clearing affiliate code: $e');
    }
  }
  
  /// Lấy cookie string để thêm vào header
  /// Format: "affiliate_code=ABC123"
  static Future<String?> getAffiliateCookie() async {
    final code = await getAffiliateCode();
    if (code != null && code.isNotEmpty) {
      return 'affiliate_code=$code';
    }
    return null;
  }
  
  /// Parse affiliate code từ URL (cho deep linking)
  static Future<void> parseFromUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final params = uri.queryParameters;
      
      // Tìm affiliate code từ query parameters
      final affiliateCode = params['affiliate'] ?? 
                           params['ref'] ?? 
                           params['utm_campaign'];
      
      if (affiliateCode != null && affiliateCode.isNotEmpty) {
        await setAffiliateCode(affiliateCode);
        print('✅ Affiliate code parsed from URL: $affiliateCode');
      }
    } catch (e) {
      print('❌ Error parsing URL: $e');
    }
  }
  
  /// Debug info
  static Future<Map<String, dynamic>> getDebugInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'affiliate_code': _cachedAffiliateCode,
      'referrer': prefs.getString(_referrerKey),
      'timestamp': _lastChecked?.toIso8601String(),
      'has_code': _cachedAffiliateCode != null,
    };
  }
}
