import 'package:flutter/material.dart';
import '../services/mood_data_service.dart';
import '../services/notification_service.dart';

class MoodEntryDialog extends StatefulWidget {
  final DateTime date;
  final MoodEntry? existingEntry;
  final VoidCallback? onSaved;
  // RECOMMENDATION: Add the missing onDeleted parameter
  final VoidCallback? onDeleted; 

  const MoodEntryDialog({
    super.key,
    required this.date,
    this.existingEntry,
    this.onSaved,
    this.onDeleted, // Added to constructor
  });

  @override
  State<MoodEntryDialog> createState() => _MoodEntryDialogState();
}

class _MoodEntryDialogState extends State<MoodEntryDialog> {
  double _currentMoodValue = 3.0;
  final Set<String> _selectedEmotions = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  final List<String> _availableEmotions = [
    'Happy', 'Sad', 'Anxious', 'Calm', 'Excited',
    'Tired', 'Grateful', 'Stressed', 'Peaceful', 'Overwhelmed',
    'Angry', 'Hopeful', 'Lonely', 'Confident', 'Worried'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _currentMoodValue = widget.existingEntry!.moodValue;
      _selectedEmotions.addAll(widget.existingEntry!.emotions);
      _notesController.text = widget.existingEntry!.note;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Mood Entry' : 'Add Mood Entry',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          '${monthNames[widget.date.month - 1]} ${widget.date.day}, ${widget.date.year}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMoodSection(),
                    const SizedBox(height: 24),
                    _buildEmotionsSection(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // RECOMMENDATION: Add the "Remove Entry" button
                  if (isEditing && widget.onDeleted != null)
                    TextButton(
                      onPressed: widget.onDeleted,
                      child: Text(
                        'Remove Entry',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveMoodEntry,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(isEditing ? 'Update' : 'Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How were you feeling?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMoodOption('😢', 'Very Low', 1),
            _buildMoodOption('😔', 'Low', 2),
            _buildMoodOption('😐', 'Neutral', 3),
            _buildMoodOption('😊', 'Good', 4),
            _buildMoodOption('😄', 'Very Good', 5),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            thumbColor: Theme.of(context).colorScheme.primary,
            overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
        Center(
          child: Text(
            _getMoodLabel(_currentMoodValue),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
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
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
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
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What emotions were you experiencing?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply (optional)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableEmotions.map((emotion) {
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
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a note (optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'What happened that day? How did you feel?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'What was on your mind that day?',
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
    );
  }

  String _getMoodLabel(double value) {
    if (value <= 1.5) return 'Very Low 😢';
    if (value <= 2.5) return 'Low 😔';
    if (value <= 3.5) return 'Neutral 😐';
    if (value <= 4.5) return 'Good 😊';
    return 'Very Good 😄';
  }

  Future<void> _saveMoodEntry() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // CORRECTED: Changed to the correct method name that accepts a 'date' parameter.
      await MoodDataService.saveMoodEntryForDate(
        date: widget.date,
        moodValue: _currentMoodValue,
        emotions: _selectedEmotions.toList(),
        note: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        NotificationService.showSuccess(
          context,
          widget.existingEntry != null
              ? 'Mood entry updated successfully!'
              : 'Mood entry saved successfully!',
        );
        
        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        NotificationService.showError(
          context,
          'Failed to save mood entry. Please try again.',
        );
      }
    }
  }
}
