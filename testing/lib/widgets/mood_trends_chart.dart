import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:intl/intl.dart';
import '../services/mood_data_service.dart';

class MoodTrendsChart extends StatefulWidget {
  const MoodTrendsChart({super.key});

  @override
  State<MoodTrendsChart> createState() => _MoodTrendsChartState();
}

class _MoodTrendsChartState extends State<MoodTrendsChart> {
  String _selectedRange = 'Last 7 days';
  bool _isLoading = true;
  List<double> _moodData = [];
  List<String> _dayLabels = [];

  @override
  void initState() {
    super.initState();
    _fetchMoodData();
  }

  // This method now fetches and processes real data based on the selected date range.
  Future<void> _fetchMoodData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final List<double> newData = [];
    final List<String> newLabels = [];

    int numberOfDays;
    if (_selectedRange == 'Last 7 days') {
      numberOfDays = 7;
    } else { // 'Last 30 days'
      numberOfDays = 30;
    }

    final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: numberOfDays - 1));

    for (int i = 0; i < numberOfDays; i++) {
      final date = startDate.add(Duration(days: i));
      
      // This is where we fetch the entry for each specific day,
      // just like the calendar would.
      final entry = await MoodDataService.getMoodEntryForDate(date);

      if (entry != null) {
        newData.add(entry.moodValue);
      } else {
        // Use 0.0 to represent a day with no entry.
        // The chart painter will create a gap for this.
        newData.add(0.0);
      }

      // Create appropriate labels for the x-axis
      if (numberOfDays == 7) {
        newLabels.add(DateFormat('E').format(date)); // 'Mon', 'Tue'
      } else {
        // For 30 days, label key dates to avoid clutter
        if (i == 0 || i == numberOfDays - 1 || date.day == 1 || date.day == 15) {
          newLabels.add(DateFormat('d').format(date)); // '1', '15'
        } else {
          newLabels.add('');
        }
      }
    }

    if (mounted) {
      setState(() {
        _moodData = newData;
        _dayLabels = newLabels;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTrendsCard(context),
          const SizedBox(height: 20),
          _buildInsightsCard(context),
        ],
      ),
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
                  'Your Mood Journey',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                DropdownButton<String>(
                  value: _selectedRange,
                  items: const [
                    DropdownMenuItem(value: 'Last 7 days', child: Text('Last 7 days')),
                    DropdownMenuItem(value: 'Last 30 days', child: Text('Last 30 days')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRange = value;
                      });
                      _fetchMoodData();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(heightFactor: 5, child: CircularProgressIndicator())
                : _moodData.where((d) => d > 0).isEmpty
                    ? const Center(heightFactor: 5, child: Text('No mood data for this period.'))
                    : _buildLineChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: CustomPaint(
            painter: LineChartPainter(
              moodData: _moodData,
              lineColor: Theme.of(context).colorScheme.primary,
              fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _dayLabels.map((day) => Text(day, style: Theme.of(context).textTheme.bodySmall)).toList(),
        ),
      ],
    );
  }

  Widget _buildInsightsCard(BuildContext context) {
    final validMoods = _moodData.where((d) => d > 0).toList();
    double highestMood = 0;
    double lowestMood = 5;

    if (validMoods.isNotEmpty) {
      highestMood = validMoods.reduce(max);
      lowestMood = validMoods.reduce(min);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gentle Reflections',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (validMoods.isNotEmpty) ...[
              _buildInsightItem(
                context,
                '☀️',
                'Brighter Moments',
                'Your highest mood was ${highestMood.toStringAsFixed(1)}/5. What was happening on those brighter days?',
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ),
              const SizedBox(height: 12),
              _buildInsightItem(
                context,
                '☁️',
                'Tougher Days',
                'Your toughest mood was ${lowestMood.toStringAsFixed(1)}/5. Remember to be gentle with yourself on those days.',
                Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
              ),
            ],
            const SizedBox(height: 12),
            _buildInsightItem(
              context,
              '💡',
              'A Gentle Question',
              'What is one small thing, no matter how simple, that could bring you a moment of comfort right now?',
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the Line Chart
class LineChartPainter extends CustomPainter {
  final List<double> moodData;
  final Color lineColor;
  final Color fillColor;

  LineChartPainter({
    required this.moodData,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (moodData.length < 2) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()..color = lineColor;
    final fillPaint = Paint()..color = fillColor;

    final double xStep = size.width / (moodData.length - 1);
    final double yStep = size.height / 4; // Mood range is 1-5, so 4 intervals

    Path linePath = Path();
    Path? currentFillPath;
    bool drawingLine = false;

    for (int i = 0; i < moodData.length; i++) {
      final x = i * xStep;
      if (moodData[i] > 0) {
        final y = size.height - (moodData[i] - 1) * yStep;
        
        // Handle line path
        if (!drawingLine) {
          linePath.moveTo(x, y);
          drawingLine = true;
        } else {
          linePath.lineTo(x, y);
        }

        // Handle fill path
        if (currentFillPath == null) {
          currentFillPath = Path();
          currentFillPath.moveTo(x, size.height);
        }
        currentFillPath.lineTo(x, y);

        // Draw point
        canvas.drawCircle(Offset(x, y), 5, pointPaint);

      } else {
        drawingLine = false;
        if (currentFillPath != null) {
          final prevX = (i - 1) * xStep;
          currentFillPath.lineTo(prevX, size.height);
          currentFillPath.close();
          canvas.drawPath(currentFillPath, fillPaint);
          currentFillPath = null;
        }
      }
    }

    // Close any remaining fill path
    if (currentFillPath != null) {
      final lastX = (moodData.length - 1) * xStep;
      currentFillPath.lineTo(lastX, size.height);
      currentFillPath.close();
      canvas.drawPath(currentFillPath, fillPaint);
    }
    
    // Draw the line path on top of all fills
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
