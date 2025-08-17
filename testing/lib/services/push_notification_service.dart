

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_notification_tap', DateTime.now().toIso8601String());
  print('DEBUG (Background): Notification tapped at ${DateTime.now()}');
}

class PushNotificationService {
  PushNotificationService._internal();
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  final List<String> _reminderMessages = [
    'Just a gentle nudge to check in with yourself. How are you feeling? 🧡',
    'Taking a moment for yourself is a beautiful act of self-care. ✨',
    'A quick hello to remind you that your feelings are valid. 💙',
    'How is your heart today? A gentle moment to reflect. 🌱',
    'Remember to be kind to yourself today. You\'re doing great. 💖',
  ];

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        print('DEBUG (Foreground): Notification tapped at ${DateTime.now()}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  Future<void> checkForLaunchAction() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTap = prefs.getString('last_notification_tap');
    if (lastTap != null) {
      print('APP LAUNCHED FROM NOTIFICATION: Tapped at $lastTap');
      await prefs.remove('last_notification_tap');
    }
  }

  
  
  Future<void> showTestNotification() async {
    print('DEBUG: Firing a test notification.');
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel', 
      'Test Notifications',
      channelDescription: 'A channel for sending test notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(), 
    );

    await _plugin.show(
      99, 
      'Test Notification',
      'If you can see this, your setup is working! 🎉',
      notificationDetails,
    );
  }
  


  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await cancelAllNotifications();

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);
    final rnd = Random();
    final message = _reminderMessages[rnd.nextInt(_reminderMessages.length)];

    print('DEBUG: Notification scheduled to be sent at: $scheduledDate');

    await _plugin.zonedSchedule(
      0,
      'Your Daily Check-in',
      message,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Gentle daily reminders to check in with your mood.',
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}