import 'package:flutter/material.dart';
import '../../widgets/mood_calendar.dart';
import '../../widgets/mood_trends_chart.dart';
import '../../services/mood_data_service.dart';
import '../../services/notification_service.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _currentMoodValue = 3.0;
  final Set<String> _selectedEmotions = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isLogging = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTodaysMood();
  }

  Future<void> _loadTodaysMood() async {
    try {
      final todaysMood = await MoodDataService.getTodaysMoodEntry();
      if (todaysMood != null && mounted) {
        setState(() {
          _currentMoodValue = todaysMood.moodValue;
          _selectedEmotions.clear();
          _selectedEmotions.addAll(todaysMood.emotions);
          _notesController.text = todaysMood.note;
        });
      }
    } catch (e) {
      print('Error loading today\'s mood: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Calendar'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildCalendarTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoodEntryCard(),
          const SizedBox(height: 20),
          _buildEmotionTagsCard(),
          const SizedBox(height: 20),
          _buildNotesCard(),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: MoodCalendar(),
    );
  }

  Widget _buildTrendsTab() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: MoodTrendsChart(),
    );
  }

  Widget _buildMoodEntryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildMoodScale(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLogging ? null : _logMood,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLogging
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Log Mood', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodScale() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMoodOption('😢', 'Very Low', 1),
            _buildMoodOption('😔', 'Low', 2),
            _buildMoodOption('😐', 'Neutral', 3),
            _buildMoodOption('😊', 'Good', 4),
            _buildMoodOption('😄', 'Very Good', 5),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            thumbColor: Theme.of(context).colorScheme.primary,
            overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: _currentMoodValue,
            min: 1,
            max: 5,
            divisions: 4,
            label: _getMoodLabel(_currentMoodValue),
            onChanged: (value) {
              setState(() {
                _currentMoodValue = value;
              });
            },
          ),
        ),
        Text(
          _getMoodLabel(_currentMoodValue),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getMoodLabel(double value) {
    if (value <= 1.5) return 'Very Low 😢';
    if (value <= 2.5) return 'Low 😔';
    if (value <= 3.5) return 'Neutral 😐';
    if (value <= 4.5) return 'Good 😊';
    return 'Very Good 😄';
  }

  Widget _buildMoodOption(String emoji, String label, int value) {
    final isSelected = _currentMoodValue.round() == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMoodValue = value.toDouble();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: isSelected 
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  emoji, 
                  style: TextStyle(
                    fontSize: isSelected ? 28 : 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionTagsCard() {
    final emotions = [
      'Happy', 'Sad', 'Anxious', 'Calm', 'Excited',
      'Tired', 'Grateful', 'Stressed', 'Peaceful', 'Overwhelmed'
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What emotions are you experiencing?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: emotions.map((emotion) {
                final isSelected = _selectedEmotions.contains(emotion);
                return FilterChip(
                  label: Text(emotion),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedEmotions.add(emotion);
                      } else {
                        _selectedEmotions.remove(emotion);
                      }
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a note (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind today?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logMood() async {
    setState(() {
      _isLogging = true;
    });

    try {
      
      await MoodDataService.saveMoodEntry(
        moodValue: _currentMoodValue,
        emotions: _selectedEmotions.toList(),
        note: _notesController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLogging = false;
        });

        
        NotificationService.showSuccess(
          context,
          'Mood logged successfully!',
          action: 'View Calendar',
          onAction: () {
            _tabController.animateTo(1);
          },
        );

        
        
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLogging = false;
        });
        
        NotificationService.showError(
          context,
          'Failed to save mood entry. Please try again.',
        );
      }
    }
  }
}