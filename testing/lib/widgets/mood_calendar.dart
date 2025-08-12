import 'package:flutter/material.dart';

class MoodCalendar extends StatelessWidget {
  const MoodCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Calendar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildCalendarHeader(context),
            const SizedBox(height: 16),
            _buildCalendarGrid(context),
            const SizedBox(height: 16),
            _buildMoodLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          'December 2024',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Column(
      children: [
        // Days of week header
        Row(
          children: daysOfWeek.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Calendar days
        ...List.generate(5, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex + 1;
                if (dayNumber > 31) return const Expanded(child: SizedBox());
                
                return Expanded(
                  child: _buildCalendarDay(context, dayNumber),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCalendarDay(BuildContext context, int day) {
    // Mock mood data
    final moodColors = {
      5: Colors.green.shade200,
      10: Colors.blue.shade200,
      15: Colors.orange.shade200,
      20: Colors.purple.shade200,
      25: Colors.yellow.shade200,
    };
    
    final hasMood = moodColors.containsKey(day);
    final moodColor = moodColors[day];
    
    return GestureDetector(
      onTap: () {
        _showDayDetails(context, day);
      },
      child: Container(
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: hasMood ? moodColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: day == DateTime.now().day
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontWeight: day == DateTime.now().day 
                  ? FontWeight.bold 
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodLegend(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Legend',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildLegendItem('😄', Colors.green.shade200, 'Great'),
            const SizedBox(width: 16),
            _buildLegendItem('😊', Colors.blue.shade200, 'Good'),
            const SizedBox(width: 16),
            _buildLegendItem('😐', Colors.orange.shade200, 'Okay'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String emoji, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(emoji),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showDayDetails(BuildContext context, int day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('December $day, 2024'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood: 😊 Good'),
            SizedBox(height: 8),
            Text('Emotions: Happy, Grateful'),
            SizedBox(height: 8),
            Text('Note: Had a productive day at work and enjoyed dinner with friends.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}