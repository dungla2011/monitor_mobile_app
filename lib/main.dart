import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:monitor_app/l10n/app_localizations.dart';
import 'package:monitor_app/l10n/server_app_localizations_delegate.dart';
import 'package:monitor_app/services/dynamic_localization_service.dart';
import 'package:monitor_app/l10n/dynamic_app_localizations.dart';
import 'package:country_flags/country_flags.dart';
import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';
import 'services/web_auth_service.dart';
import 'utils/language_manager.dart';
import 'widgets/web_auth_wrapper.dart';
import 'screens/profile_screen.dart';
import 'screens/monitor_item_screen.dart';
import 'screens/monitor_config_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tạm thời disable Firebase trên web để test Monitor CRUD
  if (!kIsWeb) {
    // Khởi tạo Firebase với options cho web
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }

    // Khởi tạo Firebase Messaging
    await FirebaseMessagingService.initialize();
  }

  // Đăng ký background message handler (chỉ cho mobile)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadInitialLanguage();
    _autoSyncLanguagesAfterDelay();
  }

  /// Auto-sync languages from server after 10 seconds
  Future<void> _autoSyncLanguagesAfterDelay() async {
    await Future.delayed(const Duration(seconds: 10));
    try {
      print('🔄 Auto-syncing languages from server (10s delay)...');

      // Sync all languages from server
      final syncedLanguages = await DynamicLocalizationService.syncAllLanguages(
        forceSync: false, // Only sync if cache expired
      );

      // Load synced languages into memory
      for (final langCode in syncedLanguages) {
        await DynamicAppLocalizations.loadServerTranslations(
          Locale(langCode),
        );
      }

      print('✅ Auto-sync completed: ${syncedLanguages.length} languages');

      // Trigger rebuild to apply new translations if on current locale
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('⚠️ Auto-sync error (non-blocking): $e');
    }
  }

  /// Load server translations for initial language
  Future<void> _loadInitialLanguage() async {
    final languageManager = context.read<LanguageManager>();
    await DynamicAppLocalizations.loadServerTranslations(
      languageManager.currentLocale,
    );
    // Trigger rebuild if server translations loaded
    if (mounted &&
        DynamicAppLocalizations.hasServerTranslations(
          languageManager.currentLocale.languageCode,
        )) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (context, languageManager, child) {
        return MaterialApp(
          title: 'Monitor App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
              labelStyle: TextStyle(color: Color(0xFFAAAAAA)),
              floatingLabelStyle: TextStyle(color: Colors.blue),
            ),
          ),
          // Internationalization support
          localizationsDelegates: const [
            ServerAppLocalizationsDelegate(), // ⭐ Custom delegate for server translations
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LanguageManager.supportedLocales,
          // Use current locale from provider
          locale: languageManager.currentLocale,
          home: const WebAuthWrapper(),
          routes: {'/home': (context) => const MainScreen()},
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<LanguageInfo> _availableLanguages = [];
  bool _isLoadingLanguages = true;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Use a key to force rebuild of screens when language changes
  Key _screensKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadAvailableLanguages();
  }

  Future<void> _loadAvailableLanguages() async {
    try {
      final languages =
          await DynamicLocalizationService.getAvailableLanguages();
      setState(() {
        _availableLanguages = languages.where((lang) => lang.isActive).toList();
        _isLoadingLanguages = false;
      });
    } catch (e) {
      print('❌ Error loading available languages: $e');
      setState(() {
        _availableLanguages = [
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
        ];
        _isLoadingLanguages = false;
      });
    }
  }

  // Create screens dynamically to allow rebuild
  List<Widget> get _screens => [
        MonitorItemScreen(key: ValueKey('monitor_$_screensKey')),
        MonitorConfigScreen(key: ValueKey('config_$_screensKey')),
        ProfileScreen(key: ValueKey('profile_$_screensKey')),
        SettingsScreen(key: ValueKey('settings_$_screensKey')),
        AboutScreen(key: ValueKey('about_$_screensKey')),
      ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.appTitle),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            // Language Selector with Flag
            Consumer<LanguageManager>(
              builder: (context, languageManager, child) {
                final currentLanguageCode =
                    languageManager.currentLocale.languageCode;

                if (_isLoadingLanguages) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final currentLang = _availableLanguages.firstWhere(
                  (lang) => lang.code == currentLanguageCode,
                  orElse: () => _availableLanguages.first,
                );

                return PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  tooltip: 'Change Language',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CountryFlag.fromCountryCode(
                          currentLang.flagCode?.toUpperCase() ?? 'US',
                          height: 20,
                          width: 30,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentLang.code.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  itemBuilder: (context) {
                    return _availableLanguages.map((lang) {
                      final isSelected = lang.code == currentLanguageCode;
                      return PopupMenuItem<String>(
                        value: lang.code,
                        child: SizedBox(
                          width: 200, // Fixed width to prevent overflow
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CountryFlag.fromCountryCode(
                                lang.flagCode?.toUpperCase() ?? 'US',
                                height: 20,
                                width: 30,
                              ),
                              const SizedBox(width: 12),
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
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      lang.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check,
                                    color: Colors.blue, size: 20),
                            ],
                          ),
                        ),
                      );
                    }).toList();
                  },
                  onSelected: (languageCode) async {
                    if (languageCode != currentLanguageCode) {
                      await _changeLanguage(
                          languageManager, Locale(languageCode, ''));
                    }
                  },
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      localizations.appTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Text(
                      WebAuthService.currentUser?['displayName'] ??
                          WebAuthService.currentUser?['username'] ??
                          localizations.navigationWelcome,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.monitor),
                title: Text(localizations.navigationMonitorItems),
                selected: _selectedIndex == 0,
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_applications),
                title: Text(localizations.navigationMonitorConfigs),
                selected: _selectedIndex == 1,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(localizations.navigationProfile),
                selected: _selectedIndex == 2,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                  Navigator.pop(context);
                },
              ),
              // Notifications menu hidden - auto-managed by system
              // ListTile(
              //   leading: const Icon(Icons.notifications),
              //   title: Text(localizations.translate('navigation.notifications')),
              //   selected: _selectedIndex == 3,
              //   onTap: () {
              //     setState(() {
              //       _selectedIndex = 3;
              //     });
              //     Navigator.pop(context);
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(localizations.navigationSettings),
                selected: _selectedIndex == 3,
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(localizations.navigationAbout),
                selected: _selectedIndex == 4,
                onTap: () {
                  setState(() {
                    _selectedIndex = 4;
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  localizations.authLogout,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final shouldSignOut = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(localizations.authLogout),
                      content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(localizations.appCancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(localizations.authLogout),
                        ),
                      ],
                    ),
                  );

                  if (shouldSignOut == true) {
                    try {
                      // Show loading indicator using GlobalKey
                      _scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(
                          content: Text('Đang đăng xuất...'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      await WebAuthService.signOut();

                      // Navigate to WebAuthWrapper (root) to trigger auth check
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const WebAuthWrapper()),
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      print('❌ Logout error: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Lỗi đăng xuất: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
        body: _screens[_selectedIndex],
      ),
    );
  }

  /// Change language and reload current view
  Future<void> _changeLanguage(
      LanguageManager languageManager, Locale locale) async {
    try {
      // Show loading indicator using GlobalKey
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.appLoading),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Load server translations for selected language
      await DynamicAppLocalizations.loadServerTranslations(locale);

      // Change language in LanguageManager (this triggers rebuild of entire app)
      await languageManager.changeLanguage(locale);

      // Wait a bit for the language change to propagate
      await Future.delayed(const Duration(milliseconds: 100));

      // Force rebuild of current screen by changing the screens key
      // This will recreate all screens with new translations
      if (mounted) {
        setState(() {
          _screensKey = UniqueKey(); // Generate new key to force rebuild
        });
      }

      // Show success message using GlobalKey
      _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.appSuccess),
            ],
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error changing language: $e');

      // Show error message using GlobalKey
      _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('${AppLocalizations.of(context)!.appError}: $e'),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Các màn hình cho từng mục trong menu
// MonitorItemScreen đã được chuyển sang file riêng và thay thế HomeScreen
// ProfileScreen đã được chuyển sang file riêng

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? _fcmToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    try {
      final token = await FirebaseMessagingService.getToken();
      setState(() {
        _fcmToken = token;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _fcmToken = 'Lỗi khi lấy token: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý thông báo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // FCM Token Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FCM Token:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    SelectableText(
                      _fcmToken ?? 'Không có token',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadFCMToken,
                    child: const Text('Làm mới Token'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Topic Subscription Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đăng ký Topic:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            FirebaseMessagingService.subscribeToTopic(
                              'general',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã đăng ký topic "general"'),
                              ),
                            );
                          },
                          child: const Text('Đăng ký "general"'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            FirebaseMessagingService.unsubscribeFromTopic(
                              'general',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã hủy đăng ký topic "general"'),
                              ),
                            );
                          },
                          child: const Text('Hủy "general"'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            FirebaseMessagingService.subscribeToTopic('news');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã đăng ký topic "news"'),
                              ),
                            );
                          },
                          child: const Text('Đăng ký "news"'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            FirebaseMessagingService.unsubscribeFromTopic(
                              'news',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã hủy đăng ký topic "news"'),
                              ),
                            );
                          },
                          child: const Text('Hủy "news"'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Instructions
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hướng dẫn:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. Copy FCM Token để sử dụng trong PHP script'),
                  Text('2. Đăng ký/hủy các topic để nhận thông báo theo nhóm'),
                  Text('3. Sử dụng PHP script để gửi thông báo từ web server'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info, size: 100, color: Colors.purple),
          const SizedBox(height: 20),
          Text(
            l10n.aboutTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '${l10n.aboutAppVersion}\n${l10n.aboutCopyright}\n\n${l10n.aboutDescription}\n\n${l10n.aboutDeveloper}',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
