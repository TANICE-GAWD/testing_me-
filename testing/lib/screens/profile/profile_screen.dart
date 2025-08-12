import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User data
  String _userName = 'Sarah Johnson';
  String _userEmail = 'sarah.johnson@email.com';
  String _userBio = 'On a journey to better mental health and wellness.';
  DateTime _memberSince = DateTime(2024, 12, 1);
  
  // Stats data
  int _dayStreak = 7;
  int _moodLogs = 42;
  int _achievements = 5;
  double _averageMood = 3.8;
  int _bestStreak = 7;
  int _insightsSaved = 12;
  
  // Goals data
  Map<String, double> _wellnessGoals = {
    'Daily Mood Check-in': 0.8,
    'Weekly Reflection': 0.6,
    'Mindfulness Practice': 0.4,
  };
  
  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Sarah Johnson';
        _userEmail = prefs.getString('user_email') ?? 'sarah.johnson@email.com';
        _userBio = prefs.getString('user_bio') ?? 'On a journey to better mental health and wellness.';
        
        // Load member since date
        final memberSinceString = prefs.getString('member_since');
        if (memberSinceString != null) {
          _memberSince = DateTime.parse(memberSinceString);
        }
        
        // Load stats
        _dayStreak = prefs.getInt('day_streak') ?? 7;
        _moodLogs = prefs.getInt('mood_logs') ?? 42;
        _achievements = prefs.getInt('achievements') ?? 5;
        _averageMood = prefs.getDouble('average_mood') ?? 3.8;
        _bestStreak = prefs.getInt('best_streak') ?? 7;
        _insightsSaved = prefs.getInt('insights_saved') ?? 12;
        
        // Load goals
        _wellnessGoals['Daily Mood Check-in'] = prefs.getDouble('goal_mood_checkin') ?? 0.8;
        _wellnessGoals['Weekly Reflection'] = prefs.getDouble('goal_weekly_reflection') ?? 0.6;
        _wellnessGoals['Mindfulness Practice'] = prefs.getDouble('goal_mindfulness') ?? 0.4;
        
        _isLoading = false;
      });
      
      // Update controllers
      _nameController.text = _userName;
      _emailController.text = _userEmail;
      _bioController.text = _userBio;
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        NotificationService.showError(context, 'Failed to load profile data');
      }
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('user_bio', _userBio);
      await prefs.setString('member_since', _memberSince.toIso8601String());
      
      // Save stats
      await prefs.setInt('day_streak', _dayStreak);
      await prefs.setInt('mood_logs', _moodLogs);
      await prefs.setInt('achievements', _achievements);
      await prefs.setDouble('average_mood', _averageMood);
      await prefs.setInt('best_streak', _bestStreak);
      await prefs.setInt('insights_saved', _insightsSaved);
      
      // Save goals
      await prefs.setDouble('goal_mood_checkin', _wellnessGoals['Daily Mood Check-in'] ?? 0.0);
      await prefs.setDouble('goal_weekly_reflection', _wellnessGoals['Weekly Reflection'] ?? 0.0);
      await prefs.setDouble('goal_mindfulness', _wellnessGoals['Mindfulness Practice'] ?? 0.0);
      
      if (mounted) {
        NotificationService.showSuccess(context, 'Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showError(context, 'Failed to save profile data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: _cancelEditing,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
          ] else
            IconButton(
              onPressed: _startEditing,
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit Profile',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: 24),
              _buildWellnessGoals(context),
              const SizedBox(height: 20),
              _buildAchievements(context),
              const SizedBox(height: 20),
              _buildStats(context),
              const SizedBox(height: 20),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // Reset controllers to original values
      _nameController.text = _userName;
      _emailController.text = _userEmail;
      _bioController.text = _userBio;
    });
  }

  Future<void> _saveProfile() async {
    // Validate input
    if (_nameController.text.trim().isEmpty) {
      NotificationService.showError(context, 'Name cannot be empty');
      return;
    }
    
    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      NotificationService.showError(context, 'Please enter a valid email');
      return;
    }

    // Update data
    setState(() {
      _userName = _nameController.text.trim();
      _userEmail = _emailController.text.trim();
      _userBio = _bioController.text.trim();
      _isEditing = false;
    });

    // Save to SharedPreferences
    await _saveUserData();
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _changeProfilePicture,
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        iconSize: 16,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Name field
            if (_isEditing)
              TextField(
                controller: _nameController,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              )
            else
              Text(
                _userName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            
            const SizedBox(height: 8),
            
            // Email field
            if (_isEditing)
              TextField(
                controller: _emailController,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              )
            else
              Text(
                _userEmail,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            
            const SizedBox(height: 8),
            
            Text(
              'Member since ${_formatMemberSince()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bio field
            if (_isEditing)
              TextField(
                controller: _bioController,
                maxLines: 2,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Tell us about your wellness journey...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              )
            else
              Text(
                _userBio,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProfileStat(context, _dayStreak.toString(), 'Day Streak'),
                _buildProfileStat(context, _moodLogs.toString(), 'Mood Logs'),
                _buildProfileStat(context, _achievements.toString(), 'Achievements'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMemberSince() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[_memberSince.month - 1]} ${_memberSince.year}';
  }

  void _changeProfilePicture() {
    NotificationService.showInfo(
      context, 
      'Profile picture feature coming soon!',
    );
  }

  Widget _buildProfileStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildWellnessGoals(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wellness Goals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_isEditing)
                  TextButton.icon(
                    onPressed: _addNewGoal,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Goal'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ..._wellnessGoals.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGoalItem(context, entry.key, entry.value),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, String goal, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(goal, style: Theme.of(context).textTheme.bodyMedium),
            ),
            if (_isEditing) ...[
              IconButton(
                onPressed: () => _editGoal(goal, progress),
                icon: const Icon(Icons.edit, size: 16),
                iconSize: 16,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed: () => _deleteGoal(goal),
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                iconSize: 16,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ] else
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (_isEditing)
          Slider(
            value: progress,
            onChanged: (value) {
              setState(() {
                _wellnessGoals[goal] = value;
              });
            },
            divisions: 10,
            label: '${(progress * 100).toInt()}%',
          )
        else
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }

  void _addNewGoal() {
    _showGoalDialog();
  }

  void _editGoal(String currentGoal, double currentProgress) {
    _showGoalDialog(
      initialGoal: currentGoal,
      initialProgress: currentProgress,
      isEditing: true,
    );
  }

  void _showGoalDialog({
    String? initialGoal,
    double? initialProgress,
    bool isEditing = false,
  }) {
    final goalController = TextEditingController(text: initialGoal ?? '');
    double progress = initialProgress ?? 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Goal' : 'Add New Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: goalController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g., Daily Exercise',
                ),
              ),
              const SizedBox(height: 16),
              Text('Progress: ${(progress * 100).toInt()}%'),
              Slider(
                value: progress,
                onChanged: (value) {
                  setDialogState(() {
                    progress = value;
                  });
                },
                divisions: 10,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final goalName = goalController.text.trim();
                if (goalName.isNotEmpty) {
                  setState(() {
                    if (isEditing && initialGoal != null && initialGoal != goalName) {
                      _wellnessGoals.remove(initialGoal);
                    }
                    _wellnessGoals[goalName] = progress;
                  });
                  Navigator.pop(context);
                  NotificationService.showSuccess(
                    context,
                    isEditing ? 'Goal updated!' : 'Goal added!',
                  );
                }
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteGoal(String goal) {
    NotificationService.showConfirmDialog(
      context,
      title: 'Delete Goal',
      message: 'Are you sure you want to delete "$goal"?',
      confirmText: 'Delete',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _wellnessGoals.remove(goal);
        });
        NotificationService.showSuccess(context, 'Goal deleted');
      }
    });
  }

  Widget _buildAchievements(BuildContext context) {
    final achievements = [
      {'icon': '🔥', 'title': 'Week Warrior', 'description': '7-day streak'},
      {'icon': '🌟', 'title': 'First Steps', 'description': 'First mood log'},
      {'icon': '💙', 'title': 'Self-Care Champion', 'description': '30 mood logs'},
      {'icon': '🎯', 'title': 'Goal Setter', 'description': 'Set wellness goals'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        achievement['icon']!,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement['title']!,
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        achievement['description']!,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Journey',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow(context, 'Total Mood Logs', _moodLogs.toString()),
            _buildStatRow(context, 'Average Mood', '${_averageMood.toStringAsFixed(1)}/5'),
            _buildStatRow(context, 'Best Streak', '$_bestStreak days'),
            _buildStatRow(context, 'Insights Saved', _insightsSaved.toString()),
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

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportData,
                icon: const Icon(Icons.download),
                label: const Text('Export My Data'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetStats,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Statistics'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearAllData,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    NotificationService.showInfo(
      context,
      'Data export feature coming soon! You\'ll be able to download all your wellness data.',
    );
  }

  void _resetStats() {
    NotificationService.showConfirmDialog(
      context,
      title: 'Reset Statistics',
      message: 'This will reset your mood logs, streaks, and other statistics. Your profile information will be kept.',
      confirmText: 'Reset',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _dayStreak = 0;
          _moodLogs = 0;
          _achievements = 0;
          _averageMood = 0.0;
          _bestStreak = 0;
          _insightsSaved = 0;
        });
        _saveUserData();
        NotificationService.showSuccess(context, 'Statistics reset successfully');
      }
    });
  }

  void _clearAllData() {
    NotificationService.showConfirmDialog(
      context,
      title: 'Clear All Data',
      message: 'This will permanently delete ALL your data including profile, mood logs, goals, and statistics. This action cannot be undone.',
      confirmText: 'Delete Everything',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        _showFinalConfirmation();
      }
    });
  }

  void _showFinalConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Final Warning'),
        content: const Text(
          'You are about to permanently delete ALL your wellness data. This includes:\n\n'
          '• Your profile information\n'
          '• All mood logs and history\n'
          '• Wellness goals and progress\n'
          '• Statistics and achievements\n'
          '• Chat history\n\n'
          'This action is IRREVERSIBLE. Are you absolutely sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDataClear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Delete Everything'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDataClear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset to default values
      setState(() {
        _userName = 'New User';
        _userEmail = 'user@email.com';
        _userBio = 'Welcome to your wellness journey!';
        _memberSince = DateTime.now();
        _dayStreak = 0;
        _moodLogs = 0;
        _achievements = 0;
        _averageMood = 0.0;
        _bestStreak = 0;
        _insightsSaved = 0;
        _wellnessGoals = {
          'Daily Mood Check-in': 0.0,
          'Weekly Reflection': 0.0,
          'Mindfulness Practice': 0.0,
        };
      });
      
      // Update controllers
      _nameController.text = _userName;
      _emailController.text = _userEmail;
      _bioController.text = _userBio;
      
      NotificationService.showSuccess(context, 'All data cleared successfully');
    } catch (e) {
      NotificationService.showError(context, 'Failed to clear data');
    }
  }
}