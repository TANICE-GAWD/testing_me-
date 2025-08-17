import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';

class ConversationStarters extends StatefulWidget {
  final Function(String)? onStarterTapped;

  const ConversationStarters({
    super.key,
    this.onStarterTapped,
  });

  @override
  State<ConversationStarters> createState() => _ConversationStartersState();
}

class _ConversationStartersState extends State<ConversationStarters> {
  
  bool _isTipsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final starters = ChatbotService.getConversationStarters();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Wellness Companion',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'I\'m here to provide general wellness advice and emotional support. Feel free to share how you\'re feeling or ask about self-care tips.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          
          Text(
            'Popular topics to explore:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          
          const SizedBox(height: 16),
          
          ...starters.map((starter) => _buildStarterCard(context, starter)),
          
          const SizedBox(height: 24),
          
          
          _buildQuickTipsSection(context),
          
          const SizedBox(height: 24),
          
          
          _buildDisclaimerSection(context),
        ],
      ),
    );
  }

  Widget _buildStarterCard(BuildContext context, String starter) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _sendStarterMessage(context, starter),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForStarter(starter),
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    starter,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildQuickTipsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isTipsExpanded = !_isTipsExpanded;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quick Wellness Tips',
                    style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.secondary,
                        ),
                  ),
                ),
                Icon(
                  _isTipsExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isTipsExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      '• Take 3 deep breaths when feeling overwhelmed\n'
                      '• Stay hydrated throughout the day\n'
                      '• Take short breaks every hour\n'
                      '• Practice gratitude daily\n'
                      '• Connect with friends and family regularly',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  
  Widget _buildDisclaimerSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'A Gentle Reminder', 
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This chat provides general wellness information only. For medical emergencies or mental health crises, please contact emergency services or a mental health professional immediately.',
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForStarter(String starter) {
    if (starter.toLowerCase().contains('stress')) {
      return Icons.psychology_rounded;
    } else if (starter.toLowerCase().contains('anxious')) {
      return Icons.favorite_rounded;
    } else if (starter.toLowerCase().contains('sleep')) {
      return Icons.bedtime_rounded;
    } else if (starter.toLowerCase().contains('self-care')) {
      return Icons.spa_rounded;
    } else if (starter.toLowerCase().contains('motivated')) {
      return Icons.trending_up_rounded;
    } else if (starter.toLowerCase().contains('emotions')) {
      return Icons.emoji_emotions_rounded;
    }
    return Icons.chat_bubble_rounded;
  }

  void _sendStarterMessage(BuildContext context, String message) {
    if (widget.onStarterTapped != null) {
      widget.onStarterTapped!(message);
    }
  }
}
