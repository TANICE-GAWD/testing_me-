import 'package:flutter/material.dart';

// RECOMMENDATION 1: Reframe the entire concept.
// The widget is renamed to reflect a more gentle approach.
class WellnessJourneyCard extends StatelessWidget {
  const WellnessJourneyCard({super.key});

  // Example data: 5 out of the last 7 days were completed.
  final int completedDays = 5;
  final List<bool> lastSevenDays = const [true, true, false, true, true, false, true];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      // The overall card styling is kept, but the content is what changes.
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // Using softer, theme-aligned colors for the gradient.
              colorScheme.secondary.withOpacity(0.1),
              colorScheme.tertiary.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // Using the secondary color for a calmer feel.
                    color: colorScheme.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.secondary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    // RECOMMENDATION 1: Use a calmer icon.
                    Icons.spa_rounded, // Changed from fire icon to a leaf.
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  // RECOMMENDATION 1: Change the title.
                  'Wellness Journey', // Changed from "Wellness Streak".
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$completedDays',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'days this week',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              // RECOMMENDATION 2: Change the encouragement message.
              'You\'ve dedicated time to your well-being. Every step counts.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // RECOMMENDATION 3: Create a more forgiving visualization.
            _buildJourneyVisualization(context, lastSevenDays),
          ],
        ),
      ),
    );
  }

  /// Builds a visualization of the last 7 days, showing completed vs. missed days.
  /// This feels less like a fragile "chain" that can be broken.
  Widget _buildJourneyVisualization(BuildContext context, List<bool> weekData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isCompleted = weekData[index];
        return Column(
          children: [
            Text(
              daysOfWeek[index],
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 32,
              height: 8,
              decoration: BoxDecoration(
                color: isCompleted
                    ? colorScheme.secondary // A solid, rewarding color for completed days.
                    : colorScheme.secondary.withOpacity(0.2), // A faint color for missed days.
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      }),
    );
  }
}
