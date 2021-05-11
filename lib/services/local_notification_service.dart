import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static final NotificationService _notificationServiceSingleton =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationServiceSingleton;
  }
  NotificationService._internal();

  void init() {
    var initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: IOSInitializationSettings(),
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static Future onSelectNotification(String payload) async {}

  Future showNotificationWithProgress({
    int notificationId,
    String notificationTitle,
    String notificationBody,
    double progress,
  }) async {
    if (flutterLocalNotificationsPlugin == null)
      throw Exception('NotificationService is not initialized');

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'ru.utopicnarwhal.flibustabrowser',
      'Прогресс скачивания',
      'Отображение прогресса скачивания книги',
      playSound: false,
      enableVibration: false,
      autoCancel: false,
      ongoing: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress.round(),
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notificationTitle,
      notificationBody,
      platformChannelSpecifics,
    );
  }

  Future cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
