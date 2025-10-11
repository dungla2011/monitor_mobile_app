import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_flags/country_flags.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/web_auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/dynamic_localization_service.dart';
import '../l10n/app_localizations.dart';
import '../l10n/dynamic_app_localizations.dart';
import '../utils/language_manager.dart';
import '../utils/error_dialog_utils.dart';
import '../config/app_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController(); // Cho đăng ký
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  late TabController _tabController;

  // Language selection
  List<LanguageInfo> _availableLanguages = [];
  bool _isLoadingLanguages = false; // Flag to prevent multiple calls

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAvailableLanguages();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableLanguages() async {
    // Prevent multiple simultaneous calls
    if (_isLoadingLanguages) {
      print('⏭️ Already loading languages, skipping...');
      return;
    }

    _isLoadingLanguages = true;
    try {
      final languages =
          await DynamicLocalizationService.getAvailableLanguages();
      if (mounted) {
        setState(() {
          _availableLanguages =
              languages.where((lang) => lang.isActive).toList();
        });
      }
    } catch (e) {
      print('❌ Error loading languages: $e');
      // Fallback to default languages
      if (mounted) {
        setState(() {
          _availableLanguages = [
            LanguageInfo(
                code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt'),
            LanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
          ];
        });
      }
    } finally {
      _isLoadingLanguages = false;
    }
  }

  Future<void> _signInWithUsername() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await WebAuthService.signInWithUsernameAndPassword(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result['success'] == true) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Check error type
          final statusCode = result['statusCode'] as int?;
          final responseBody = result['responseBody'] as String?;
          final isApiError = result['isApiError'] as bool?;

          if (isApiError == true) {
            // API business logic error (HTTP 200 but code != 1)
            // Show simple error dialog with message
            _showErrorDialog(result['message'] ?? 'Đăng nhập không thành công');
          } else if (statusCode != null && statusCode >= 400) {
            // HTTP error - show detailed dialog
            await ErrorDialogUtils.showHttpErrorDialog(
              context,
              statusCode,
              result['message'],
              technicalDetails: responseBody,
            );
          } else {
            // Other error - show simple dialog
            _showErrorDialog(result['message'] ?? 'Đăng nhập không thành công');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialogUtils.showErrorDialog(
          context,
          'Lỗi kết nối: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_usernameController.text.trim().isEmpty) {
      _showErrorDialog('Vui lòng nhập username để reset mật khẩu');
      return;
    }

    // TODO: Implement password reset với API của bạn
    _showErrorDialog(
      'Chức năng reset password chưa được hỗ trợ.\nVui lòng liên hệ admin.',
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final result = await GoogleAuthService.signInWithGoogle();

      if (mounted) {
        if (result['success'] == true) {
          // Lưu token vào WebAuthService
          final token = result['token'] as String;
          final email = result['email'] as String?;
          final username = result['username'] as String?;

          // Tạo fake user info để lưu
          await WebAuthService.saveGoogleUser(
            token: token,
            email: email ?? '',
            username: username ?? 'google_user',
          );

          // Chuyển sang màn hình chính
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          _showErrorDialog(result['message'] ?? 'Đăng nhập thất bại');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi đăng nhập Google: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Consumer<LanguageManager>(
      builder: (context, languageManager, child) {
        try {
          // Safe check for available languages
          if (_availableLanguages.isEmpty) {
            // Re-trigger load if needed
            if (mounted) {
              Future.microtask(() => _loadAvailableLanguages());
            }

            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final currentLanguageCode =
              languageManager.currentLocale.languageCode;
          final currentLang = _availableLanguages.firstWhere(
            (lang) => lang.code == currentLanguageCode,
            orElse: () => _availableLanguages.first,
          );

          return PopupMenuButton<String>(
            offset: const Offset(0, 40),
            tooltip: 'Change Language',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryFlag.fromCountryCode(
                    currentLang.flagCode?.toUpperCase() ?? 'US',
                    height: 16,
                    width: 24,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
            itemBuilder: (context) {
              return _availableLanguages.map((lang) {
                final isSelected = lang.code == currentLanguageCode;
                return PopupMenuItem<String>(
                  value: lang.code,
                  child: SizedBox(
                    width: 180,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CountryFlag.fromCountryCode(
                          lang.flagCode?.toUpperCase() ?? 'US',
                          height: 18,
                          width: 27,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                lang.nativeName,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                lang.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, color: Colors.blue, size: 18),
                      ],
                    ),
                  ),
                );
              }).toList();
            },
            onSelected: (languageCode) async {
              if (languageCode != currentLanguageCode) {
                // Show loading
                if (mounted) {
                  setState(() => _isLoading = true);
                }

                // Change language
                final result = await languageManager
                    .changeLanguage(Locale(languageCode, ''));

                if (mounted) {
                  setState(() => _isLoading = false);

                  if (result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Language changed to ${languageCode.toUpperCase()}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              }
            },
          );
        } catch (e) {
          // If any error occurs, show a simple fallback
          print('❌ Error building language selector: $e');
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Wrap in Consumer to rebuild when language changes
    return Consumer<LanguageManager>(
      builder: (context, languageManager, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade400, Colors.blue.shade800],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Header với tiêu đề và language selector
                      Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Ping365 [${languageManager.currentLocale.languageCode.toUpperCase()}]',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            // Language Selector
                            _buildLanguageSelector(),
                          ],
                        ),
                      ),

                      // Tab Bar
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blue,
                          tabs: [
                            Tab(text: localizations.authLogin),
                            Tab(text: localizations.authRegister),
                          ],
                        ),
                      ),

                      // Tab Bar View - Expanded để fill remaining space
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [_buildLoginForm(), _buildRegisterForm()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ); // Close Scaffold
      }, // Close Consumer builder
    ); // Close Consumer
  }

  Widget _buildLoginForm() {
    final localizations = AppLocalizations.of(context)!;

    return Form(
      key: _loginFormKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Username field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: localizations.authUsername,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.authPleaseEnterUsername;
                }
                if (value.trim().length < 3) {
                  return 'Username phải có ít nhất 3 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: localizations.authPassword,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.authPleaseEnterPassword;
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
            ),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resetPassword,
                child: Text(
                  '${localizations.authForgotPassword}?',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signInWithUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        localizations.authLogin,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),

            // Divider "hoặc"
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(localizations.authOr,
                        style: const TextStyle(color: Colors.grey)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),

            // Nút Google Sign-In
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.login, color: Colors.red),
                label: Text(
                  '${localizations.authLoginWith} Google',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    final localizations = AppLocalizations.of(context)!;

    // Show button to open registration page in browser
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.app_registration,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              localizations.authRegisterNewAccount,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.authRegisterDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final registerUrl =
                      Uri.parse('${AppConfig.apiBaseUrl}/register');

                  try {
                    // Try to launch the URL
                    if (await canLaunchUrl(registerUrl)) {
                      await launchUrl(
                        registerUrl,
                        mode: LaunchMode
                            .externalApplication, // Always open in external browser
                      );

                      // Show success message
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening registration page...'),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      // If can't launch, show error
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                localizations.authCouldNotOpenRegistration),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // Handle error
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${localizations.appError}: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: Icon(Icons.open_in_browser, size: 24),
                label: Text(
                  localizations.authOpenRegistrationPage,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.authAfterRegistration,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
