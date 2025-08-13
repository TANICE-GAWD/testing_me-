import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';
import 'theme/app_theme.dart';

import 'services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService().init();
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
