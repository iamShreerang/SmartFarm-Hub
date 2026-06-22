import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/farm_task.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  static Future<void> scheduleTaskReminder(FarmTask task) async {
    if (!task.notificationEnabled) return;
    final scheduledTime = tz.TZDateTime.from(
      task.scheduledDate.subtract(const Duration(hours: 1)),
      tz.local,
    );
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      task.id.hashCode,
      '🌱 Farm Reminder: ${task.title}',
      task.description ?? 'Scheduled in 1 hour',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'farm_tasks',
          'Farm Tasks',
          channelDescription: 'SmartFarm Hub task reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelTaskReminder(String taskId) =>
      _plugin.cancel(taskId.hashCode);

  static Future<void> cancelAll() => _plugin.cancelAll();
}
