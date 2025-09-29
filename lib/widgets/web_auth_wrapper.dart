import 'package:flutter/material.dart';
import '../services/web_auth_service.dart';
import '../screens/login_screen.dart';
import '../main.dart';

class WebAuthWrapper extends StatefulWidget {
  const WebAuthWrapper({super.key});

  @override
  State<WebAuthWrapper> createState() => _WebAuthWrapperState();
}

class _WebAuthWrapperState extends State<WebAuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
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
