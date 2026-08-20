import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/constants.dart';

class NotificationManager {
  NotificationManager._internal();
  static final NotificationManager instance = NotificationManager._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  static const AndroidNotificationChannel criticalChannel = AndroidNotificationChannel(
    'critical_alerts',
    'Critical Alerts',
    description: 'High-importance water quality hazards',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('notification'),
    enableLights: true,
  );
  static const AndroidNotificationChannel systemChannel = AndroidNotificationChannel(
    'system_warnings',
    'System Warnings',
    description: 'System notifications and warning messages',
    importance: Importance.defaultImportance,
    playSound: true,
    enableLights: true,
  );
  static const AndroidNotificationChannel summaryChannel = AndroidNotificationChannel(
    'daily_summaries',
    'Daily Summaries',
    description: 'Daily digest and summary notifications',
    importance: Importance.low,
    playSound: false,
    enableLights: false,
  );

  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _requestPermissions();
    await _registerFCMToken();
    _setupForegroundHandler();
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      requestProvisionalPermission: false,
      requestCriticalPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );

    final settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        if (payload != null) {
          _navigateFromPayload(payload);
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(criticalChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(systemChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(summaryChannel);
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    debugPrint('Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _registerFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
      if (_fcmToken != null) {
        await _registerTokenWithBackend(_fcmToken!, Platform.operatingSystem);
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to obtain FCM token: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _registerTokenWithBackend(String token, String platform) async {
    try {
      final url = Uri.parse('${AppConfig.backendBaseUrl}/api/register-token');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceId': 'mobile_client',
          'token': token,
          'platform': platform,
        }),
      );
      if (response.statusCode != 200) {
        debugPrint('Token registration failed: ${response.body}');
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to register token with backend: $error');
      debugPrint('$stackTrace');
    }
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground push received: ${message.messageId}');
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;

    if (notification == null) return;
    final channelId = android?.channelId ?? 'system_warnings';
    final channel = channelId == 'critical_alerts'
        ? criticalChannel
        : channelId == 'daily_summaries'
            ? summaryChannel
            : systemChannel;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.high,
          playSound: channel.playSound,
          channelShowBadge: true,
          tag: message.collapseKey,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      payload: json.encode(message.data),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      _navigateFromPayload(json.encode(message.data));
    }
  }

  void _navigateFromPayload(String payload) {
    debugPrint('App opened from notification: $payload');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background push received: ${message.messageId}');
}
