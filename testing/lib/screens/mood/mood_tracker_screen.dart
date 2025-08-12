import 'package:flutter/material.dart';
import '../../widgets/mood_calendar.dart';
import '../../widgets/mood_trends_chart.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            ElevatedButton(
              onPressed: () {
                _logMood();
              },
              child: const Text('Log Mood'),
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
        Slider(
          value: 3,
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildMoodOption(String emoji, String label, int value) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
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
                return FilterChip(
                  label: Text(emotion),
                  selected: false,
                  onSelected: (selected) {},
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
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind today?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logMood() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mood logged successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}