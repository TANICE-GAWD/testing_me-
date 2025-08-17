// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';
import '../../services/push_notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminders = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = true;

  final PushNotificationService _pushNotificationService = PushNotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminders = prefs.getBool('dailyRemindersEnabled') ?? true;
      final hour = prefs.getInt('reminderHour') ?? 9;
      final minute = prefs.getInt('reminderMinute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  Future<void> _updateReminderSettings(bool isEnabled, TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyRemindersEnabled', isEnabled);
    await prefs.setInt('reminderHour', time.hour);
    await prefs.setInt('reminderMinute', time.minute);

    if (isEnabled) {
      await _pushNotificationService.scheduleDailyReminder(time);
      if (mounted) {
        NotificationService.showInfo(context, 'Reminders are now set for ${time.format(context)}.');
      }
    } else {
      await _pushNotificationService.cancelAllNotifications();
      if (mounted) {
        NotificationService.showInfo(context, 'Daily reminders have been turned off.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildNotificationSettings(context),
                  const SizedBox(height: 20),
                  _buildSettingsAndSupport(context),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Gentle Daily Reminders'),
              subtitle: const Text('Get a kind nudge to check in'),
              value: _dailyReminders,
              onChanged: (value) {
                setState(() {
                  _dailyReminders = value;
                });
                _updateReminderSettings(value, _reminderTime);
              },
            ),
            if (_dailyReminders)
              ListTile(
                title: const Text('Reminder Time'),
                subtitle: Text(_reminderTime.format(context)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _showTimePicker,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsAndSupport(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Settings & Support',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Theme'),
              subtitle: const Text('System default'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => NotificationService.showInfo(context, 'Theme options are coming soon!'),
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => NotificationService.showInfo(context, 'You can view our privacy policy on our website.'),
            ),
            ListTile(
              title: const Text('Help Center'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => NotificationService.showInfo(context, 'Our help center is coming soon.'),
            ),

            // --- NEW BUTTON ADDED HERE ---
            ListTile(
              leading: const Icon(Icons.notification_add_rounded),
              title: const Text('Send Test Notification'),
              subtitle: const Text('Check if notifications are working'),
              onTap: () {
                _pushNotificationService.showTestNotification();
                NotificationService.showInfo(
                  context,
                  'Test notification triggered. It should appear shortly.',
                );
              },
            ),
            // --- END OF NEW BUTTON ---

            ListTile(
              title: const Text('Account Management'),
              subtitle: const Text('Export or delete your data'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _navigateToAccountManagement(context),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'MindfulMe v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _reminderTime,
    ).then((time) {
      if (time != null) {
        setState(() {
          _reminderTime = time;
        });
        _updateReminderSettings(true, time);
      }
    });
  }

  void _navigateToAccountManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccountManagementScreen(),
      ),
    );
  }
}


class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Your Data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Here you can export or permanently delete your account and all associated data.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Export My Data'),
                  subtitle: const Text('Download all your wellness data as a CSV file.'),
                  onTap: () => NotificationService.showInfo(context, 'Data export feature coming soon!'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.delete_forever_rounded, color: Theme.of(context).colorScheme.error),
                  title: Text('Delete Account', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  subtitle: const Text('This action is permanent and cannot be undone.'),
                  onTap: () {
                    NotificationService.showConfirmDialog(
                      context,
                      title: 'Delete Your Account?',
                      message: 'This will permanently delete all your wellness data. This action is irreversible.',
                      confirmText: 'Yes, Delete',
                      isDestructive: true,
                    ).then((confirmed) {
                      if (confirmed == true) {
                        NotificationService.showSuccess(context, 'Your account has been deleted.');
                        Navigator.of(context).pop();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}