import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

// Abstract browser notifications behind a conditional import
import 'browser_notification_stub.dart'
    if (dart.library.html) 'browser_notification_web.dart'
    as bn;

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      await _messaging.requestPermission();

      if (kIsWeb) {
        // Request browser notification permission asynchronously
        _requestBrowserPermission();
      }

      // On web, getToken requires a vapidKey.
      try {
        String? token = await _messaging.getToken();
        debugPrint("FCM Token: $token");
      } catch (e) {
        debugPrint("FCM GetToken Error (likely no VAPID key on web): $e");
      }

      if (!kIsWeb) {
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const InitializationSettings settings = InitializationSettings(
          android: androidSettings,
        );

        await _localNotifications.initialize(settings: settings);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (!kIsWeb) {
          _localNotifications.show(
            id: message.hashCode,
            title: message.notification?.title,
            body: message.notification?.body,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'weather_channel',
                'Weather Updates',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          );
        } else {
          debugPrint("Received message on web: ${message.notification?.title}");
        }
      });
    } catch (e) {
      debugPrint("NotificationService initialization failed: $e");
    }
  }

  // Request browser notification permission on Web
  static void _requestBrowserPermission() {
    if (!kIsWeb) return;
    try {
      bn.requestBrowserPermission();
    } catch (e) {
      debugPrint("Error requesting browser notification permission: $e");
    }
  }

  // Show a native browser notification on Web
  static void _showBrowserNotification(String title, String body) {
    if (!kIsWeb) return;
    try {
      bn.showBrowserNotification(title, body);
    } catch (e) {
      debugPrint("Error showing browser notification: $e");
    }
  }

  static Future<bool> requestPermissionAndCheck() async {
    try {
      if (kIsWeb) {
        // On web, request permission and return its status
        _requestBrowserPermission();
        return true; // Let alerts proceed; browser handles permission display
      }

      final settings = await _messaging.requestPermission();

      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      bool? localGranted = true;
      if (androidImplementation != null) {
        localGranted = await androidImplementation
            .requestNotificationsPermission();
      }

      return (settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus ==
                  AuthorizationStatus.provisional) &&
          (localGranted ?? true);
    } catch (e) {
      return false;
    }
  }

  static Future<void> showRainAlert() async {
    debugPrint("NotificationService: showRainAlert called (Web: $kIsWeb)");
    if (kIsWeb) {
      // 1. Native browser notification (works when app is in background)
      _showBrowserNotification(
        '🌧️ Rain Alert',
        'Rain expected in your area. Take precautions!',
      );

      // 2. SnackBar (when app is in foreground)
      if (scaffoldMessengerKey.currentState == null) {
        debugPrint(
          "NotificationService: scaffoldMessengerKey is NULL — SnackBar skipped.",
        );
      }
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            '🌧️ Rain Alert: Rain expected in your area. Take precautions!',
          ),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 6),
        ),
      );
      return;
    }

    try {
      await _localNotifications.show(
        id: 1001,
        title: '🌧️ Rain Alert',
        body: 'Rain expected in your area. Take precautions!',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'weather_channel',
            'Weather Updates',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Failed to show rain alert: $e");
    }
  }

  static Future<void> showTemperatureAlert(String title, String body) async {
    debugPrint(
      "NotificationService: showTemperatureAlert called: $title (Web: $kIsWeb)",
    );
    if (kIsWeb) {
      // 1. Native browser notification
      _showBrowserNotification(title, body);

      // 2. SnackBar
      if (scaffoldMessengerKey.currentState == null) {
        debugPrint(
          "NotificationService: scaffoldMessengerKey is NULL — SnackBar skipped.",
        );
      }
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(body),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }

    try {
      await _localNotifications.show(
        id: 1002,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'weather_channel',
            'Weather Updates',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Failed to show temperature alert: $e");
    }
  }
}
