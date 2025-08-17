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
    setState(() => _isLoading = true);
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
        setState(() => _isLoading = false);
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mood Calendar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildCalendarHeader(context),
            const SizedBox(height: 16),
            _buildCalendarGrid(context),
            const SizedBox(height: 24),
            _buildMoodLegend(context),
            const SizedBox(height: 24),
            
            _buildEffortSummary(context),
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
            setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1));
            _loadMonthData();
          },
          icon: const Icon(Icons.chevron_left),
        ),
        GestureDetector(
          onTap: () => _showMonthPicker(context),
          child: Text(
            '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1));
            _loadMonthData();
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void _showMonthPicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    ).then((date) {
      if (date != null) {
        setState(() => _currentMonth = DateTime(date.year, date.month));
        _loadMonthData();
      }
    });
  }

  Widget _buildCalendarGrid(BuildContext context) {
    if (_isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }

    final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        Row(
          children: daysOfWeek.map((day) => Expanded(
            child: Center(
              child: Text(day, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate(6, (weekIndex) {
          if ((weekIndex * 7) - firstWeekday + 1 > daysInMonth) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex + 1 - firstWeekday;
                if (dayNumber <= 0 || dayNumber > daysInMonth) return const Expanded(child: SizedBox());
                return Expanded(child: _buildCalendarDay(context, dayNumber));
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
    final moodColor = hasMood ? MoodDataService.getMoodColor(moodEntry.moodValue) : Colors.transparent;
    final isToday = _isToday(day);
    final isSelected = _selectedDay == day;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDay = day);
        _showDayDetails(context, day);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                fontSize: 14,
              ),
            ),
            if (hasMood)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: moodColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return now.year == _currentMonth.year && now.month == _currentMonth.month && now.day == day;
  }

  
  Widget _buildMoodLegend(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mood Legend', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendItem(MoodDataService.getMoodColor(5.0), 'Very Good', 'Feeling great'),
            _buildLegendItem(MoodDataService.getMoodColor(4.0), 'Good', 'A positive day'),
            _buildLegendItem(MoodDataService.getMoodColor(3.0), 'Neutral', 'A steady day'),
            _buildLegendItem(MoodDataService.getMoodColor(2.0), 'Low', 'Tough moments'),
            _buildLegendItem(MoodDataService.getMoodColor(1.0), 'Very Low', 'It\'s okay to not be okay'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, String subtitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(subtitle, style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7))),
          ],
        ),
      ],
    );
  }

  Widget _buildEffortSummary(BuildContext context) {
    final checkInCount = _monthMoodData.length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 18, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text(
            'You checked in on $checkInCount days this month. Well done!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, int day) {
    final moodEntry = _monthMoodData[day];
    final selectedDate = DateTime(_currentMonth.year, _currentMonth.month, day);
    
    showDialog(
      context: context,
      builder: (context) => MoodEntryDialog(
        date: selectedDate,
        existingEntry: moodEntry,
        onSaved: () => _loadMonthData(),
        
        onDeleted: () async {
          Navigator.of(context).pop(); 
          final confirmed = await NotificationService.showConfirmDialog(
            context,
            title: 'Remove Mood Entry',
            message: 'Are you sure you want to remove this entry?',
            confirmText: 'Remove',
          );
          if (confirmed == true) {
            try {
              await MoodDataService.deleteMoodEntry(selectedDate);
              await _loadMonthData();
              NotificationService.showSuccess(context, 'Mood entry removed');
            } catch (e) {
              NotificationService.showError(context, 'Failed to remove entry');
            }
          }
        },
      ),
    );
  }
}
