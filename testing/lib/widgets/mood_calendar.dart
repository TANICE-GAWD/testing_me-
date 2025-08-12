import 'package:flutter/material.dart';
import '../services/mood_data_service.dart';
import '../services/notification_service.dart';
import 'mood_entry_dialog.dart';

class MoodCalendar extends StatefulWidget {
  const MoodCalendar({super.key});

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  DateTime _currentMonth = DateTime.now();
  int? _selectedDay;
  Map<int, MoodEntry> _monthMoodData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final moodData = await MoodDataService.getMoodEntriesForMonth(
        _currentMonth.year,
        _currentMonth.month,
      );
      
      if (mounted) {
        setState(() {
          _monthMoodData = moodData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        NotificationService.showError(context, 'Failed to load mood data');
      }
    }
  }

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
            _loadMonthData();
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
            _loadMonthData();
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
              _loadMonthData();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Convert to 0-6 where Sunday = 0
    
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
        ...List.generate(6, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex + 1 - firstWeekday;
                
                if (dayNumber <= 0 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                
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
    final moodEntry = _monthMoodData[day];
    final hasMood = moodEntry != null;
    final moodColor = hasMood ? MoodDataService.getMoodColor(moodEntry.moodValue) : null;
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
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day.toString(),
                style: TextStyle(
                  fontWeight: isToday || isSelected
                      ? FontWeight.bold 
                      : FontWeight.normal,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  fontSize: 12,
                ),
              ),
              if (hasMood)
                Text(
                  moodEntry.emoji,
                  style: const TextStyle(fontSize: 12),
                ),
            ],
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
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildLegendItem('😄', MoodDataService.getMoodColor(5.0), 'Very Good'),
            _buildLegendItem('😊', MoodDataService.getMoodColor(4.0), 'Good'),
            _buildLegendItem('😐', MoodDataService.getMoodColor(3.0), 'Neutral'),
            _buildLegendItem('😔', MoodDataService.getMoodColor(2.0), 'Low'),
            _buildLegendItem('😢', MoodDataService.getMoodColor(1.0), 'Very Low'),
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
    
    final moodEntry = _monthMoodData[day];
    final selectedDate = DateTime(_currentMonth.year, _currentMonth.month, day);
    final isToday = _isToday(day);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${monthNames[_currentMonth.month - 1]} $day, ${_currentMonth.year}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (moodEntry != null) ...[
              Row(
                children: [
                  Text('Mood: ${moodEntry.emoji} ${moodEntry.moodLabel}'),
                ],
              ),
              const SizedBox(height: 8),
              Text('Emotions: ${moodEntry.emotions.isEmpty ? 'None selected' : moodEntry.emotions.join(', ')}'),
              const SizedBox(height: 8),
              Text('Note: ${moodEntry.note.isEmpty ? 'No note added' : moodEntry.note}'),
            ] else ...[
              const Text('No mood data recorded for this day.'),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (isToday) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to mood tracker today tab
                          DefaultTabController.of(context)?.animateTo(0);
                        },
                        icon: const Icon(Icons.today, size: 16),
                        label: const Text('Today Tab'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddMoodDialog(context, selectedDate);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(isToday ? 'Quick Add' : 'Add Entry'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          if (moodEntry != null) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditMoodDialog(context, selectedDate, moodEntry);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteMoodEntry(selectedDate);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddMoodDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => MoodEntryDialog(
        date: date,
        onSaved: () {
          _loadMonthData(); // Refresh the calendar after saving
        },
      ),
    );
  }

  void _showEditMoodDialog(BuildContext context, DateTime date, MoodEntry moodEntry) {
    showDialog(
      context: context,
      builder: (context) => MoodEntryDialog(
        date: date,
        existingEntry: moodEntry,
        onSaved: () {
          _loadMonthData(); // Refresh the calendar after saving
        },
      ),
    );
  }

  Future<void> _deleteMoodEntry(DateTime date) async {
    final confirmed = await NotificationService.showConfirmDialog(
      context,
      title: 'Delete Mood Entry',
      message: 'Are you sure you want to delete this mood entry?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        await MoodDataService.deleteMoodEntry(date);
        await _loadMonthData(); // Refresh the calendar
        NotificationService.showSuccess(context, 'Mood entry deleted');
      } catch (e) {
        NotificationService.showError(context, 'Failed to delete mood entry');
      }
    }
  }
}