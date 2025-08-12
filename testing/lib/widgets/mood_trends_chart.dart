import 'package:flutter/material.dart';

class MoodTrendsChart extends StatelessWidget {
  const MoodTrendsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTrendsCard(context),
        const SizedBox(height: 20),
        _buildInsightsCard(context),
      ],
    );
  }

  Widget _buildTrendsCard(BuildContext context) {
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
                  'Mood Trends',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DropdownButton<String>(
                  value: 'Last 7 days',
                  items: const [
                    DropdownMenuItem(value: 'Last 7 days', child: Text('Last 7 days')),
                    DropdownMenuItem(value: 'Last 30 days', child: Text('Last 30 days')),
                    DropdownMenuItem(value: 'Last 3 months', child: Text('Last 3 months')),
                  ],
                  onChanged: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSimpleChart(context),
            const SizedBox(height: 16),
            _buildChartLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart(BuildContext context) {
    // Mock data for the last 7 days
    final moodData = [3.0, 4.0, 2.0, 4.5, 3.5, 4.0, 4.5];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(moodData.length, (index) {
                final height = (moodData[index] / 5.0) * 150;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: _getMoodColor(moodData[index]),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[index],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(double mood) {
    if (mood >= 4.5) return Colors.green.shade400;
    if (mood >= 3.5) return Colors.blue.shade400;
    if (mood >= 2.5) return Colors.orange.shade400;
    if (mood >= 1.5) return Colors.red.shade300;
    return Colors.grey.shade400;
  }

  Widget _buildChartLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('😄', Colors.green.shade400, '4.5-5.0'),
        _buildLegendItem('😊', Colors.blue.shade400, '3.5-4.4'),
        _buildLegendItem('😐', Colors.orange.shade400, '2.5-3.4'),
        _buildLegendItem('😔', Colors.red.shade300, '1.0-2.4'),
      ],
    );
  }

  Widget _buildLegendItem(String emoji, Color color, String range) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
        Text(emoji, style: const TextStyle(fontSize: 12)),
        Text(range, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildInsightsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Insights',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              context,
              '📈',
              'Mood Improvement',
              'Your mood has improved by 15% this week compared to last week.',
              Colors.green.shade100,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              context,
              '🌟',
              'Best Day',
              'Sunday was your best day with a mood score of 4.5/5.',
              Colors.blue.shade100,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              context,
              '💡',
              'Pattern Noticed',
              'You tend to feel better on weekends. Consider what makes those days special.',
              Colors.orange.shade100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    String emoji,
    String title,
    String description,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}