import 'package:flutter/material.dart';
import '../../widgets/mood_calendar.dart';
import '../../widgets/mood_trends_chart.dart';
import '../../services/mood_data_service.dart';
import '../../services/notification_service.dart';


enum LoggingStep { rating, emotions, notes, completed }

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  
  LoggingStep _currentStep = LoggingStep.rating;

  
  double _currentMoodValue = 3.0;
  final Set<String> _selectedEmotions = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isLogging = false;
  bool _showAllEmotions = false;
  bool _isWritingNote = false;

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
          
          _currentStep = LoggingStep.completed;
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

  void _resetLoggingProcess() {
    setState(() {
      _currentStep = LoggingStep.rating;
      _currentMoodValue = 3.0;
      _selectedEmotions.clear();
      _notesController.clear();
      _showAllEmotions = false;
      _isWritingNote = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'Today'),
            Tab(icon: Icon(Icons.calendar_today_rounded), text: 'Calendar'),
            Tab(icon: Icon(Icons.auto_graph_rounded), text: 'Trends'),
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _buildCurrentStep(),
      ),
    );
  }
  
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case LoggingStep.rating:
        return _buildMoodRatingStep();
      case LoggingStep.emotions:
        return _buildEmotionsStep();
      case LoggingStep.notes:
        return _buildNotesStep();
      case LoggingStep.completed:
        return _buildCompletedStep();
    }
  }

  Widget _buildMoodRatingStep() {
    return Card(
      key: const ValueKey('rating_step'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How are you feeling right now?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildMoodScale(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = LoggingStep.emotions),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildEmotionsStep() {
    final primaryEmotions = ['Happy', 'Sad', 'Anxious', 'Calm', 'Tired', 'Stressed'];
    final secondaryEmotions = ['Excited', 'Grateful', 'Peaceful', 'Overwhelmed', 'Lonely', 'Hopeful'];

    
    List<String> suggestedEmotions;
    if (_currentMoodValue <= 2.5) { 
      suggestedEmotions = ['Sad', 'Anxious', 'Tired', 'Stressed', 'Overwhelmed', 'Lonely'];
    } else if (_currentMoodValue >= 4.0) { 
      suggestedEmotions = ['Happy', 'Calm', 'Excited', 'Grateful', 'Peaceful', 'Hopeful'];
    } else {
      suggestedEmotions = primaryEmotions;
    }

    return Card(
      key: const ValueKey('emotions_step'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What emotions are you experiencing?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestedEmotions.map((emotion) => _buildEmotionChip(emotion)).toList(),
            ),
            if (_showAllEmotions)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: secondaryEmotions.map((emotion) => _buildEmotionChip(emotion)).toList(),
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _showAllEmotions = !_showAllEmotions),
              child: Text(_showAllEmotions ? 'Show Less' : 'Show More'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _currentStep = LoggingStep.notes),
                  child: const Text('Skip'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => setState(() => _currentStep = LoggingStep.notes),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildNotesStep() {
    return Card(
      key: const ValueKey('notes_step'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isWritingNote)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Add a private note?'),
                  onPressed: () => setState(() => _isWritingNote = true),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What\'s on your mind? (Optional)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Describe your feelings or recent events...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (_isWritingNote)
                  TextButton(
                    onPressed: _logMood,
                    child: const Text('Skip Note'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLogging ? null : _logMood,
                  child: _isLogging
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Entry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedStep() {
    return Card(
      key: const ValueKey('completed_step'),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Theme.of(context).colorScheme.secondary, size: 48),
            const SizedBox(height: 16),
            Text('You\'ve logged your mood for today.', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Come back tomorrow to check in again.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _resetLoggingProcess,
              child: const Text('Edit Today\'s Entry'),
            )
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
            _buildMoodOption('😢', 1),
            _buildMoodOption('😔', 2),
            _buildMoodOption('😐', 3),
            _buildMoodOption('😊', 4),
            _buildMoodOption('😄', 5),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: _currentMoodValue,
          min: 1,
          max: 5,
          divisions: 4,
          label: _getMoodLabel(_currentMoodValue),
          onChanged: (value) => setState(() => _currentMoodValue = value),
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
    if (value <= 1.5) return 'Very Low';
    if (value <= 2.5) return 'Low';
    if (value <= 3.5) return 'Neutral';
    if (value <= 4.5) return 'Good';
    return 'Very Good';
  }

  Widget _buildMoodOption(String emoji, int value) {
    final isSelected = _currentMoodValue.round() == value;
    return GestureDetector(
      onTap: () => setState(() => _currentMoodValue = value.toDouble()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(emoji, style: TextStyle(fontSize: isSelected ? 28 : 24)),
      ),
    );
  }

  Widget _buildEmotionChip(String emotion) {
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
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildCalendarTab() => const Padding(padding: EdgeInsets.all(20), child: MoodCalendar());
  Widget _buildTrendsTab() => const Padding(padding: EdgeInsets.all(20), child: MoodTrendsChart());

  Future<void> _logMood() async {
    setState(() => _isLogging = true);
    try {
      await MoodDataService.saveMoodEntry(
        moodValue: _currentMoodValue,
        emotions: _selectedEmotions.toList(),
        note: _notesController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isLogging = false;
          _currentStep = LoggingStep.completed;
        });
        NotificationService.showSuccess(
          context,
          'Mood logged successfully!',
          action: 'View Calendar',
          onAction: () => _tabController.animateTo(1),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLogging = false);
        NotificationService.showError(context, 'Failed to save mood entry.');
      }
    }
  }
}
