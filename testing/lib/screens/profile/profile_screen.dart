import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:intl/intl.dart';
import '../../services/notification_service.dart';


class YourJourneyScreen extends StatefulWidget {
  const YourJourneyScreen({super.key});

  @override
  State<YourJourneyScreen> createState() => _YourJourneyScreenState();
}

class _YourJourneyScreenState extends State<YourJourneyScreen> {
  String _userName = 'Sarah Johnson';
  String _userBio = 'On a journey to better mental health and wellness.';
  DateTime _memberSince = DateTime(2024, 12, 1);

  
  int _momentsOfReflection = 42;
  int _wisdomCollected = 12;

  
  List<String> _wellnessIntentions = [
    'Practice daily mood check-ins',
    'Take time for weekly reflection',
    'Engage in mindfulness practice',
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    
    setState(() {
      _nameController.text = _userName;
      _bioController.text = _userBio;
      _isLoading = false;
    });
  }

  Future<void> _saveUserData() async {
    
    NotificationService.showSuccess(context, 'Your journey has been updated!');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Journey')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Journey'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancel'),
            )
          else
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_note_rounded),
              tooltip: 'Edit Journey',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildJourneyHeader(context),
            const SizedBox(height: 24),
            _buildWellnessIntentions(context),
            const SizedBox(height: 20),
            _buildJourneyStats(context),
            const SizedBox(height: 20),
            
            _buildAccountSettings(context),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(
                Icons.person_rounded,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              TextField(
                controller: _nameController,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'Enter your name'),
              )
            else
              Text(_userName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (_isEditing)
              TextField(
                controller: _bioController,
                maxLines: 2,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'Describe your journey...'),
              )
            else
              Text(
                _userBio,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            Text(
              'Member since ${DateFormat.yMMMM().format(_memberSince)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
             if (_isEditing) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _userName = _nameController.text;
                    _userBio = _bioController.text;
                    _isEditing = false;
                  });
                  _saveUserData();
                },
                child: const Text('Save Changes'),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessIntentions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Wellness Intentions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            for (var intention in _wellnessIntentions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 18, color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(intention, style: Theme.of(context).textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Progress', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildStatRow(context, 'Moments of Reflection', _momentsOfReflection.toString()),
            _buildStatRow(context, 'Wisdom Collected', _wisdomCollected.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.download_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              title: const Text('Export My Data'),
              onTap: () => NotificationService.showInfo(context, 'Data export feature coming soon!'),
            ),
            ListTile(
              leading: Icon(Icons.delete_sweep_rounded, color: Theme.of(context).colorScheme.error),
              title: Text('Clear All Data', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: _clearAllData,
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllData() {
    NotificationService.showConfirmDialog(
      context,
      title: 'Clear All Your Data?',
      message: 'This will permanently delete all your wellness data, including your mood logs and intentions. This action cannot be undone.',
      confirmText: 'Yes, Clear Data',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        
        NotificationService.showSuccess(context, 'All your data has been cleared.');
      }
    });
  }
}
