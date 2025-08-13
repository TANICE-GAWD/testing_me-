import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class PushNotificationService {
  PushNotificationService._internal();
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  final List<String> _healthFacts = [
    'Drinking enough water daily supports overall health. 💧',
    'Regular exercise boosts mental health and mood. 🏃‍♂️',
    'A balanced diet strengthens your immune system. 🥗',
    'Quality sleep is essential for brain function. 😴',
    'Meditation reduces stress and anxiety levels. 🧘',
    'Walking 30 minutes a day lowers heart disease risk. 🚶',
    'Sitting less and moving more improves circulation. 🩺',
    'Fresh fruits provide vital vitamins and antioxidants. 🍎',
    'Deep breathing exercises can lower blood pressure. 🌬️',
    'Spending time in nature improves wellbeing. 🌳',
  ];

  Future<void> init() async {
    // Initialize timezone database for zoned scheduling
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings);

    // Cancel any existing notifications to avoid duplicates after hot restart
    await _plugin.cancelAll();

    // Schedule notifications for the next hour (60 notifications, 1 per minute)
    await _scheduleMinuteNotifications(count: 60);
  }

  Future<void> _scheduleMinuteNotifications({int count = 60}) async {
    final now = tz.TZDateTime.now(tz.local);
    final rnd = Random();

    for (int i = 1; i <= count; i++) {
      final id = i; // simple id
      final fact = _healthFacts[rnd.nextInt(_healthFacts.length)];
      final scheduledDate = now.add(Duration(minutes: i));

      await _plugin.zonedSchedule(
        id,
        'MindfulMe Health Fact',
        fact,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'health_fact_channel',
            'Health Facts',
            channelDescription: 'Periodic healthcare facts',
            importance: Importance.high,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // ensures exact time scheduling
      );
    }
  }
}
