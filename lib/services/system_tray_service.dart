import 'dart:io';
import 'package:flutter/material.dart' show Colors, Size;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

class SystemTrayService {
  static bool _initialized = false;

  /// Initialize system tray (Windows/macOS/Linux only)
  static Future<void> initialize() async {
    if (kIsWeb || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return;
    }

    if (_initialized) return;

    try {
      // Setup window manager
      await windowManager.ensureInitialized();
      
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1280, 720),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: 'Ping365 - Monitor',
      );
      
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        // Prevent window from closing (minimize to tray instead)
        await windowManager.setPreventClose(true);
      });

      // Setup tray icon
      await _setupTrayIcon();

      // Setup auto-start
      await _setupAutoStart();

      _initialized = true;
      print('✅ System Tray initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize System Tray: $e');
    }
  }

  /// Setup system tray icon with menu
  static Future<void> _setupTrayIcon() async {
    // Set tray icon - use PNG for now (ICO is better for Windows but PNG works)
    String iconPath = 'assets/icon/tray_icon.png';

    await trayManager.setIcon(iconPath);
    
    // Set tray menu
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show',
          label: 'Show Window',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'monitors',
          label: 'Monitor Items',
        ),
        MenuItem(
          key: 'configs',
          label: 'Monitor Configs',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'settings',
          label: 'Settings',
        ),
        MenuItem(
          key: 'about',
          label: 'About',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit',
          label: 'Exit',
        ),
      ],
    );
    
    await trayManager.setContextMenu(menu);
    await trayManager.setToolTip('Ping365 - Monitor');
  }

  /// Setup auto-start with Windows
  static Future<void> _setupAutoStart() async {
    if (!Platform.isWindows) return;

    try {
      // Configure launch at startup
      launchAtStartup.setup(
        appName: 'Ping365Monitor',
        appPath: Platform.resolvedExecutable,
        // Optional: add arguments
        args: ['--minimized'],
      );

      // Check if already enabled
      bool isEnabled = await launchAtStartup.isEnabled();
      print('🚀 Auto-start is ${isEnabled ? "enabled" : "disabled"}');
    } catch (e) {
      print('⚠️ Failed to setup auto-start: $e');
    }
  }

  /// Enable auto-start
  static Future<void> enableAutoStart() async {
    if (kIsWeb || !Platform.isWindows) return;

    try {
      await launchAtStartup.enable();
      print('✅ Auto-start enabled');
    } catch (e) {
      print('❌ Failed to enable auto-start: $e');
    }
  }

  /// Disable auto-start
  static Future<void> disableAutoStart() async {
    if (kIsWeb || !Platform.isWindows) return;

    try {
      await launchAtStartup.disable();
      print('✅ Auto-start disabled');
    } catch (e) {
      print('❌ Failed to disable auto-start: $e');
    }
  }

  /// Check if auto-start is enabled
  static Future<bool> isAutoStartEnabled() async {
    if (kIsWeb || !Platform.isWindows) return false;

    try {
      return await launchAtStartup.isEnabled();
    } catch (e) {
      print('❌ Failed to check auto-start status: $e');
      return false;
    }
  }

  /// Show window
  static Future<void> showWindow() async {
    if (kIsWeb) return;
    
    try {
      await windowManager.show();
      await windowManager.focus();
    } catch (e) {
      print('❌ Failed to show window: $e');
    }
  }

  /// Hide window
  static Future<void> hideWindow() async {
    if (kIsWeb) return;
    
    try {
      await windowManager.hide();
    } catch (e) {
      print('❌ Failed to hide window: $e');
    }
  }

  /// Minimize to tray
  static Future<void> minimizeToTray() async {
    if (kIsWeb) return;
    
    try {
      await windowManager.hide();
      // Optional: show notification
      print('💼 App minimized to tray');
    } catch (e) {
      print('❌ Failed to minimize to tray: $e');
    }
  }
}

/// Tray event listener
class AppTrayListener extends TrayListener {
  @override
  void onTrayIconMouseDown() {
    SystemTrayService.showWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        SystemTrayService.showWindow();
        break;
      case 'exit':
        windowManager.destroy();
        break;
      case 'monitors':
        SystemTrayService.showWindow();
        // Navigate to monitors tab
        break;
      case 'configs':
        SystemTrayService.showWindow();
        // Navigate to configs tab
        break;
      case 'settings':
        SystemTrayService.showWindow();
        // Navigate to settings tab
        break;
      case 'about':
        SystemTrayService.showWindow();
        // Navigate to about tab
        break;
    }
  }
}
