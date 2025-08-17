import 'package:flutter/material.dart';

class DailyInsightCard extends StatelessWidget {
  const DailyInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      // The card itself already uses theme colors, so no changes are needed here.
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // RECOMMENDATION 1: Use theme colors instead of hardcoded blue.
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    // RECOMMENDATION 1: Use theme colors.
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Daily Insight',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // RECOMMENDATION 1: Use theme colors.
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  // RECOMMENDATION 1: Use theme colors.
                  color: colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💙 Mindful Moment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      // Using the primary color for the title makes it feel more integrated.
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take three deep breaths and notice how your body feels right now. This simple practice can help ground you in the present moment.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      // Using a slightly less prominent color for the body text.
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // RECOMMENDATION 2 & 3: Simplify the call to action and use softer language.
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showBreathingExercise(context);
                          },
                          icon: const Icon(Icons.air_rounded, size: 18),
                          label: const Text('Start Guided Breath'),
                          style: ElevatedButton.styleFrom(
                            // Use a softer, secondary color for less pressure.
                            backgroundColor: colorScheme.secondary.withOpacity(0.8),
                            foregroundColor: theme.colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Secondary actions are now subtle icons.
                      IconButton(
                        onPressed: () {
                          _openWellnessChat(context);
                        },
                        icon: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: colorScheme.secondary,
                        ),
                        tooltip: 'Ask chat for more tips',
                      ),
                      IconButton(
                        onPressed: () {
                          _saveInsight(context);
                        },
                        icon: Icon(
                          Icons.bookmark_border_rounded,
                          color: colorScheme.secondary,
                        ),
                        tooltip: 'Save insight',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBreathingExercise(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Breathing Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.air_rounded,
              size: 48,
              // Use theme color in the dialog.
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Follow this simple breathing pattern:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              '• Breathe in slowly for 4 counts\n'
              '• Hold for 4 counts\n'
              '• Breathe out slowly for 6 counts\n'
              '• Repeat 3 times',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _openWellnessChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💬 Wellness Chat'),
        content: const Text(
          'You can ask our wellness assistant about mindfulness, self-care tips, and emotional support. Tap the Chat tab at the bottom to start a conversation!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _saveInsight(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Insight saved to your collection'),
        // Use a theme color for the SnackBar.
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
