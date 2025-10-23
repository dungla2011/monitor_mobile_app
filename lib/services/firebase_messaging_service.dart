import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_settings.dart' as app_settings;
import 'notification_sound_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Khởi tạo Firebase Messaging
  static Future<void> initialize() async {
    // Firebase đã được khởi tạo trong main.dart

    // Yêu cầu quyền thông báo (iOS và web)
    await _requestPermission();

    // Khởi tạo local notifications (chỉ cho mobile)
    if (!kIsWeb) {
      await _initializeLocalNotifications();
    }

    // Lấy FCM token
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print("FCM Token: $token");
    }

    // Lắng nghe tin nhắn khi app đang chạy foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Lắng nghe tin nhắn khi app được mở từ notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Xử lý tin nhắn khi app được khởi chạy từ notification (terminated state)
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  // Yêu cầu quyền thông báo
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Notification permission status: ${settings.authorizationStatus}');
    }
  }

  // Khởi tạo local notifications (chỉ cho mobile)
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Tạo notification channel cho Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  // Tạo notification channel cho Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true, // Channel hỗ trợ âm thanh
      enableVibration: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (kDebugMode) {
      print('✅ Notification channel created: ${channel.id}');
    }
  }

  // Xử lý tin nhắn khi app đang chạy foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Foreground message received: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Phát âm thanh thông báo custom (chỉ phát 1 lần)
    if (!kIsWeb) {
      await NotificationSoundService.playNotificationSound();
    }

    // Hiển thị local notification (KHÔNG phát âm thanh vì đã phát ở trên)
    if (!kIsWeb) {
      await _showLocalNotification(message, playSound: false);
    }
    // Trên web, browser sẽ tự động hiển thị notification
  }

  // Hiển thị local notification
  static Future<void> _showLocalNotification(
    RemoteMessage message, {
    bool playSound = true, // Mặc định phát âm thanh cho background
  }) async {
    // Lấy cài đặt thông báo
    final settings = await NotificationSoundService.getSettings();

    // Kiểm tra xem notification có được bật không
    if (!settings.notificationEnabled) {
      if (kDebugMode) {
        print('Notifications are disabled in settings');
      }
      return;
    }

    // Xác định âm thanh
    String? soundFileName;
    bool shouldPlaySound = playSound &&
        settings.notificationSound !=
            app_settings.NotificationSettings.soundNone;

    if (settings.notificationSound ==
        app_settings.NotificationSettings.soundDefault) {
      // Sử dụng âm thanh mặc định của hệ điều hành
      soundFileName = null; // Null = default sound
    } else if (settings.notificationSound ==
        app_settings.NotificationSettings.soundNone) {
      // Không có âm thanh
      soundFileName = null;
      shouldPlaySound = false;
    } else {
      // Custom sound - dùng tên file (không có .mp3)
      soundFileName = settings.notificationSound;
    }

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: shouldPlaySound,
      sound: soundFileName != null
          ? RawResourceAndroidNotificationSound(soundFileName)
          : null, // null = default sound
      enableVibration: settings.notificationVibrate,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? 'You have a new message',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Xử lý khi người dùng tap vào notification
  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    // Thêm logic điều hướng tại đây
  }

  // Xử lý tin nhắn khi app được mở từ notification
  static void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Message opened app: ${message.messageId}');
      print('Data: ${message.data}');
    }
    // Thêm logic điều hướng tại đây
  }

  // Lấy FCM token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  }
}

// Background message handler (phải là top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('🔔 Background message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }

  // Hiển thị local notification với custom sound khi app ở background
  if (!kIsWeb && Platform.isAndroid) {
    await _showBackgroundNotification(message);
  }
}

// Helper function để hiển thị notification trong background
Future<void> _showBackgroundNotification(RemoteMessage message) async {
  // Khởi tạo local notifications plugin
  final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Lấy cài đặt notification
  final settings = await NotificationSoundService.getSettings();

  if (!settings.notificationEnabled) {
    if (kDebugMode) {
      print('⚠️ Background: Notifications are disabled in settings');
    }
    return;
  }

  // Xác định âm thanh
  String? soundFileName;
  bool shouldPlaySound = settings.notificationSound !=
      app_settings.NotificationSettings.soundNone;

  if (settings.notificationSound ==
      app_settings.NotificationSettings.soundDefault) {
    soundFileName = null; // Default sound
  } else if (settings.notificationSound ==
      app_settings.NotificationSettings.soundNone) {
    soundFileName = null;
    shouldPlaySound = false;
  } else {
    // Custom sound
    soundFileName = settings.notificationSound;
  }

  if (kDebugMode) {
    print('🔊 Background: Using sound: ${soundFileName ?? "default"}');
    print('🔊 Background: Should play sound: $shouldPlaySound');
  }

  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.high,
    priority: Priority.high,
    playSound: shouldPlaySound,
    sound: soundFileName != null
        ? RawResourceAndroidNotificationSound(soundFileName)
        : null,
    enableVibration: settings.notificationVibrate,
  );

  const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  // Lấy title và body từ notification hoặc data
  final title = message.notification?.title ?? 
                message.data['title'] ?? 
                'Notification';
  final body = message.notification?.body ?? 
               message.data['body'] ?? 
               message.data['message'] ?? 
               'You have a new message';

  await localNotificationsPlugin.show(
    message.hashCode,
    title,
    body,
    platformChannelSpecifics,
    payload: message.data.toString(),
  );

  if (kDebugMode) {
    print('✅ Background notification shown with custom sound');
  }
}
