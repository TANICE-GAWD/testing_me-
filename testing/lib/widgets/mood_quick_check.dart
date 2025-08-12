import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoodQuickCheck extends StatefulWidget {
  const MoodQuickCheck({super.key});

  @override
  State<MoodQuickCheck> createState() => _MoodQuickCheckState();
}

class _MoodQuickCheckState extends State<MoodQuickCheck> with TickerProviderStateMixin {
  int? selectedMood;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<MoodOption> moods = [
    MoodOption(1, '😢', 'Struggling', AppTheme.reflectiveGray),
    MoodOption(2, '😔', 'Low', AppTheme.peacefulBlue),
    MoodOption(3, '😐', 'Okay', AppTheme.mediumGray),
    MoodOption(4, '😊', 'Good', AppTheme.joyfulYellow),
    MoodOption(5, '😄', 'Great', AppTheme.energeticOrange),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Mood Check',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'How are you feeling right now?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: moods.map((mood) => _buildMoodButton(mood)).toList(),
            ),
            if (selectedMood != null) ...[
              const SizedBox(height: 24),
              _buildMoodFeedback(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoodButton(MoodOption mood) {
    final isSelected = selectedMood == mood.value;
    
    return GestureDetector(
      onTap: _isLoading ? null : () => _handleMoodSelection(mood),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? mood.color : mood.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: mood.color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Center(
                child: _isLoading && isSelected
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : Text(
                        mood.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleMoodSelection(MoodOption mood) async {
    setState(() {
      selectedMood = mood.value;
      _isLoading = true;
    });

    _animationController.forward();
    
    // Simulate saving mood data
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _animationController.reverse();
      _showMoodConfirmation(mood);
    }
  }

  Widget _buildMoodFeedback() {
    final mood = moods.firstWhere((m) => m.value == selectedMood);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mood.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            mood.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feeling ${mood.label.toLowerCase()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getMoodMessage(mood.value),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodMessage(int moodValue) {
    switch (moodValue) {
      case 1:
        return 'It\'s okay to have difficult days. You\'re not alone.';
      case 2:
        return 'Take it one step at a time. Small progress counts.';
      case 3:
        return 'Neutral days are perfectly normal. Be gentle with yourself.';
      case 4:
        return 'Great to see you\'re doing well! Keep up the positive energy.';
      case 5:
        return 'Wonderful! Your positive energy is inspiring.';
      default:
        return 'Thank you for checking in with yourself.';
    }
  }

  void _showMoodConfirmation(MoodOption mood) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Mood logged: ${mood.label}'),
            ),
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'View Trends',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to mood tracker
            DefaultTabController.of(context)?.animateTo(1);
          },
        ),
      ),
    );
  }
}

class MoodOption {
  final int value;
  final String emoji;
  final String label;
  final Color color;

  MoodOption(this.value, this.emoji, this.label, this.color);
}