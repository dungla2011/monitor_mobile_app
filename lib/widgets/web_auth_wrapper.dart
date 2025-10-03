import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/web_auth_service.dart';
import '../screens/login_screen.dart';
import '../utils/language_manager.dart';
import '../main.dart';

class WebAuthWrapper extends StatefulWidget {
  const WebAuthWrapper({super.key});

  @override
  State<WebAuthWrapper> createState() => _WebAuthWrapperState();
}

class _WebAuthWrapperState extends State<WebAuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  Timer? _authStatusTimer;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();

    // Listen for auth status changes every few seconds to detect logout
    _startAuthStatusListener();
  }

  @override
  void dispose() {
    _authStatusTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      await WebAuthService.initialize();
      final isLoggedIn = await WebAuthService.checkAuthStatus();

      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });

        // If user is logged in, load user info and language from API
        // Do this after setState to ensure context is ready
        if (isLoggedIn) {
          _loadUserInfoAndLanguage();
        }
      }
    } catch (e) {
      print('❌ Error checking auth status: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserInfoAndLanguage() async {
    try {
      print('✅ User is logged in, loading user info from API...');
      final userInfoResult = await WebAuthService.loadUserInfo();

      if (userInfoResult['success'] && mounted) {
        print('🌍 User info loaded, syncing language...');

        // Sync language with LanguageManager
        final languageManager =
            Provider.of<LanguageManager>(context, listen: false);
        await languageManager.syncLanguageFromUserInfo();

        print('✅ Language synced successfully');
      } else {
        print('⚠️ Failed to load user info: ${userInfoResult['message']}');
      }
    } catch (e) {
      print('❌ Error loading user info and language: $e');
    }
  }

  void _startAuthStatusListener() {
    // Check auth status every 2 seconds to detect logout
    _authStatusTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final currentAuthStatus = WebAuthService.isLoggedIn;
      if (_isLoggedIn != currentAuthStatus) {
        setState(() {
          _isLoggedIn = currentAuthStatus;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Đang tải
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang kiểm tra đăng nhập...'),
            ],
          ),
        ),
      );
    }

    // Kiểm tra trạng thái đăng nhập
    if (_isLoggedIn && WebAuthService.isLoggedIn) {
      // User đã đăng nhập
      return const MainScreen();
    } else {
      // User chưa đăng nhập
      return const LoginScreen();
    }
  }
}
