import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  NotificationDetails platformChannelSpecifics;

  static final NotificationService _notificationServiceSingleton =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationServiceSingleton;
  }
  NotificationService._internal();

  void init() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      initializationSettingsAndroid,
      initializationSettingsIOS,
    );

    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'ru.utopicnarwhal.flibustabrowser',
      'downloading progress',
      'displaying download progress',
    );

    platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
  }

  static Future onSelectNotification(String payload) async {}

  Future showNotification({
    int notificationId,
    String notificationTitle,
    String notificationBody,
    String payload,
  }) async {
    if (flutterLocalNotificationsPlugin == null)
      throw Exception('NotificationService is not initialized');

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notificationTitle,
      notificationBody,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
