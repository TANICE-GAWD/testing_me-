import 'package:flutter/material.dart';

class MoodCalendar extends StatefulWidget {
  const MoodCalendar({super.key});

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  DateTime _currentMonth = DateTime.now();
  int? _selectedDay;

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
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left),
        ),
        GestureDetector(
          onTap: () => _showMonthPicker(context),
          child: Text(
            '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _showMonthPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: YearPicker(
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            selectedDate: _currentMonth,
            onChanged: (date) {
              setState(() {
                _currentMonth = date;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
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
    // Mock mood data based on current month
    final moodColors = {
      5: Colors.green.shade200,
      10: Colors.blue.shade200,
      15: Colors.orange.shade200,
      20: Colors.purple.shade200,
      25: Colors.yellow.shade200,
    };
    
    final hasMood = moodColors.containsKey(day);
    final moodColor = moodColors[day];
    final isToday = _isToday(day);
    final isSelected = _selectedDay == day;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
        _showDayDetails(context, day);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : hasMood 
                  ? moodColor 
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1)
                  : null,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontWeight: isToday || isSelected
                  ? FontWeight.bold 
                  : FontWeight.normal,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return now.year == _currentMonth.year && 
           now.month == _currentMonth.month && 
           now.day == day;
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
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    // Mock data based on day
    final moodData = _getMoodDataForDay(day);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${monthNames[_currentMonth.month - 1]} $day, ${_currentMonth.year}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (moodData != null) ...[
              Row(
                children: [
                  Text('Mood: ${moodData['emoji']} ${moodData['mood']}'),
                ],
              ),
              const SizedBox(height: 8),
              Text('Emotions: ${moodData['emotions']}'),
              const SizedBox(height: 8),
              Text('Note: ${moodData['note']}'),
            ] else ...[
              const Text('No mood data recorded for this day.'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to mood tracker
                  DefaultTabController.of(context)?.animateTo(1);
                },
                child: const Text('Log Mood'),
              ),
            ],
          ],
        ),
        actions: [
          if (moodData != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditMoodDialog(context, day);
              },
              child: const Text('Edit'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Map<String, String>? _getMoodDataForDay(int day) {
    // Mock mood data for certain days
    final moodData = {
      5: {
        'emoji': '😊',
        'mood': 'Good',
        'emotions': 'Happy, Grateful',
        'note': 'Had a productive day at work and enjoyed dinner with friends.',
      },
      10: {
        'emoji': '😐',
        'mood': 'Neutral',
        'emotions': 'Calm, Focused',
        'note': 'Regular day, stayed focused on tasks.',
      },
      15: {
        'emoji': '😔',
        'mood': 'Low',
        'emotions': 'Tired, Overwhelmed',
        'note': 'Feeling a bit overwhelmed with work deadlines.',
      },
      20: {
        'emoji': '😄',
        'mood': 'Great',
        'emotions': 'Excited, Energetic',
        'note': 'Amazing day! Completed a big project and celebrated with friends.',
      },
      25: {
        'emoji': '😊',
        'mood': 'Good',
        'emotions': 'Peaceful, Content',
        'note': 'Spent quality time with family. Feeling grateful.',
      },
    };
    
    return moodData[day];
  }

  void _showEditMoodDialog(BuildContext context, int day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Mood Entry'),
        content: const Text('Mood editing feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}