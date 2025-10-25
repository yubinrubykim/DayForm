import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static const String channelId = 'daily_questions_channel';
  static const String channelName = 'Daily Questions';
  static const String taskName = 'showNotificationTask';

  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  Future<void> init() async {
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Notifications for daily motivation questions',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Request notification permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'Notifications for daily motivation questions',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      0,
      '오늘의 질문이 준비되었어요!',
      '당신의 하루를 되돌아볼 시간입니다.',
      details,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - will be handled by the app
    print('Notification tapped: ${response.payload}');
  }

  // Initialize WorkManager for background tasks
  Future<void> initBackgroundWork() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  // Schedule notification to show after 10 seconds when app goes to background
  Future<void> scheduleNotification() async {
    await Workmanager().registerOneOffTask(
      'notification_task_${DateTime.now().millisecondsSinceEpoch}',
      taskName,
      initialDelay: const Duration(seconds: 5),
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    await Workmanager().cancelAll();
  }
}

// Top-level function for WorkManager callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == NotificationService.taskName) {
      // Show notification
      final notifications = FlutterLocalNotificationsPlugin();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            NotificationService.channelId,
            NotificationService.channelName,
            channelDescription: 'Notifications for daily motivation questions',
            importance: Importance.high,
            priority: Priority.high,
          );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      await notifications.show(
        0,
        '오늘의 질문이 준비되었어요!',
        '당신의 하루를 되돌아볼 시간입니다.',
        details,
      );
    }
    return Future.value(true);
  });
}
