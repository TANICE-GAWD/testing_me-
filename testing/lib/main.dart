import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';
import 'theme/app_theme.dart';
import 'services/push_notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.init();
  
  
  await pushNotificationService.checkForLaunchAction();
  
  
  await dotenv.load(fileName: ".env");

  
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final bool remindersEnabled = prefs.getBool('dailyRemindersEnabled') ?? true;

    if (remindersEnabled) {
      final int hour = prefs.getInt('reminderHour') ?? 9;
      final int minute = prefs.getInt('reminderMinute') ?? 0;
      print('SCHEDULING NOTIFICATION ON STARTUP for $hour:$minute');
      await pushNotificationService.scheduleDailyReminder(TimeOfDay(hour: hour, minute: minute));
    }
  } catch (e) {
    print('Error scheduling notification on startup: $e');
  }
  

  runApp(const MindfulMeApp());
}

class MindfulMeApp extends StatelessWidget {
  const MindfulMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindfulMe - Self Care',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
