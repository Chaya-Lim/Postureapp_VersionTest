import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {

    await FirebaseMessaging.instance.requestPermission();

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: android);

    await flutterLocalNotificationsPlugin.initialize(settings);

    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });
  }

  static Future showNotification(RemoteMessage message) async {

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

  /// ✅ เพิ่มอันนี้
  static Future showIncorrectPostureLocal() async {

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'posture_channel',
      'Posture Alert',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      "Incorrect Posture",
      "Incorrect posture detected 3 times consecutively.",
      details,
    );
  }
}