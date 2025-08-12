import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminders = true;
  bool _weeklyReports = true;
  bool _dataBackup = false;
  String _reminderTime = '9:00 AM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildNotificationSettings(context),
            const SizedBox(height: 20),
            _buildPrivacySettings(context),
            const SizedBox(height: 20),
            _buildAppSettings(context),
            const SizedBox(height: 20),
            _buildSupportSection(context),
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
                  Icons.notifications_rounded,
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
              title: const Text('Daily Mood Reminders'),
              subtitle: const Text('Get gentle reminders to check in with yourself'),
              value: _dailyReminders,
              onChanged: (value) {
                setState(() {
                  _dailyReminders = value;
                });
              },
            ),
            if (_dailyReminders) ...[
              ListTile(
                title: const Text('Reminder Time'),
                subtitle: Text(_reminderTime),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  _showTimePicker();
                },
              ),
            ],
            SwitchListTile(
              title: const Text('Weekly Reports'),
              subtitle: const Text('Receive weekly mood pattern summaries'),
              value: _weeklyReports,
              onChanged: (value) {
                setState(() {
                  _weeklyReports = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettings(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Privacy & Data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Cloud Backup'),
              subtitle: const Text('Securely backup your data to the cloud'),
              value: _dataBackup,
              onChanged: (value) {
                setState(() {
                  _dataBackup = value;
                });
              },
            ),
            ListTile(
              title: const Text('Export Data'),
              subtitle: const Text('Download your mood data'),
              trailing: const Icon(Icons.download_rounded),
              onTap: () {
                _showExportDialog();
              },
            ),
            ListTile(
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently delete your account and data'),
              trailing: const Icon(Icons.delete_rounded),
              onTap: () {
                _showDeleteAccountDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettings(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'App Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Theme'),
              subtitle: const Text('System default'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                _showThemeDialog();
              },
            ),
            ListTile(
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            ListTile(
              title: const Text('App Integrations'),
              subtitle: const Text('Connect with other wellness apps'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                _showIntegrationsDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Support',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Help Center'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Contact Support'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
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
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    ).then((time) {
      if (time != null) {
        setState(() {
          _reminderTime = time.format(context);
        });
      }
    });
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('System Default'),
              value: 'system',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: 'system',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showIntegrationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Integrations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Google Calendar'),
              subtitle: const Text('Not connected'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Connect'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Apple Health'),
              subtitle: const Text('Not connected'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Connect'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your mood data will be exported as a CSV file. This includes all your mood logs, notes, and insights.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export started')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}