import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyReminder {
  static const reminderHour = 12;
  static const scheduledDays = 7;
  static const _channelId = 'daily_challenge';
  static const _channelName = 'Défi du jour';
  static const _title = 'Défi du jour';
  static const _body =
      'Une vraie journée de bourse vous attend. Que feriez-vous à la place '
      'des investisseurs ?';

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize({required VoidCallback onOpened}) async {
    tz.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (_) => onOpened(),
    );
  }

  Future<bool> wasAppOpenedByReminder() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false;
  }

  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final isGranted =
        await ios?.requestPermissions(alert: true, sound: true) ??
        await android?.requestNotificationsPermission();
    return isGranted ?? false;
  }

  Future<void> scheduleNextDays({required bool hasPlayedToday}) async {
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    for (var day = 0; day < scheduledDays; day++) {
      final reminderTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + day,
        reminderHour,
      );
      final isToday = day == 0;
      if (reminderTime.isBefore(now) || (isToday && hasPlayedToday)) continue;
      await _plugin.zonedSchedule(
        id: day,
        scheduledDate: reminderTime,
        title: _title,
        body: _body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(_channelId, _channelName),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
