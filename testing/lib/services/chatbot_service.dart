import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String _openAIUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _cohereUrl = 'https://api.cohere.ai/v1/generate';
  static const String _huggingFaceUrl = 'https://api-inference.huggingface.co/models';
  static const String _healthcareModel = 'microsoft/BioGPT-Large';
  static const String _conversationModel = 'facebook/blenderbot-400M-distill';
  static const String _openAIKey = 'sk_your_openai_key_here';
  static const String _cohereKey = 'your_cohere_key_here';
  static const String _huggingFaceKey = 'hf_your_huggingface_key_here';
  
  static const Map<String, List<String>> _healthcareKnowledge = {
    'anxiety': [
      "Anxiety is a normal response to stress, but when it becomes overwhelming, there are effective ways to manage it:",
      "• **Breathing Technique**: Try the 4-7-8 method - inhale for 4, hold for 7, exhale for 8",
      "• **Grounding Exercise**: Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste",
      "• **Progressive Muscle Relaxation**: Tense and release each muscle group for 5 seconds",
      "• **Mindfulness**: Focus on the present moment without judgment",
      "If anxiety persists or interferes with daily life, please consult a mental health professional."
    ],
    'depression': [
      "Depression affects millions of people and is a treatable condition. Here are some evidence-based strategies:",
      "• **Behavioral Activation**: Engage in activities you used to enjoy, even if you don't feel like it",
      "• **Sleep Hygiene**: Maintain regular sleep schedule (7-9 hours nightly)",
      "• **Physical Activity**: Even 10 minutes of walking can boost mood through endorphins",
      "• **Social Connection**: Reach out to one person today, even briefly",
      "• **Nutrition**: Eat regular meals with omega-3 rich foods, fruits, and vegetables",
      "Depression is not a personal weakness. Professional help from a therapist or psychiatrist can be very effective."
    ],
    'stress': [
      "Chronic stress affects both mental and physical health. Here are proven stress management techniques:",
      "• **Time Management**: Break large tasks into smaller, manageable steps",
      "• **Boundary Setting**: Learn to say no to non-essential commitments",
      "• **Relaxation Response**: Practice deep breathing, meditation, or yoga daily",
      "• **Physical Release**: Exercise, stretch, or take a walk to release tension",
      "• **Cognitive Reframing**: Challenge negative thoughts with realistic alternatives",
      "• **Support System**: Talk to trusted friends, family, or a counselor"
    ],
    'sleep': [
      "Quality sleep is essential for mental health. Here's evidence-based sleep hygiene:",
      "• **Sleep Schedule**: Go to bed and wake up at the same time daily, even weekends",
      "• **Environment**: Keep bedroom cool (65-68°F), dark, and quiet",
      "• **Pre-sleep Routine**: No screens 1 hour before bed, try reading or gentle stretching",
      "• **Avoid**: Caffeine after 2 PM, large meals 3 hours before bed, alcohol before sleep",
      "• **Natural Light**: Get 15-30 minutes of morning sunlight to regulate circadian rhythm",
      "If sleep problems persist for more than 2 weeks, consult a healthcare provider."
    ],
    'panic': [
      "Panic attacks are intense but temporary. Here's how to manage them:",
      "• **Immediate Response**: Remind yourself 'This will pass, I am safe'",
      "• **Box Breathing**: Inhale 4 counts, hold 4, exhale 4, hold 4 - repeat",
      "• **Grounding**: Focus on physical sensations - feel your feet on the ground",
      "• **Cool Water**: Splash cold water on face or hold ice cubes",
      "• **Movement**: Gentle walking can help metabolize stress hormones",
      "Panic attacks typically peak within 10 minutes. If frequent, please see a mental health professional."
    ]
  };

  static Future<String> getChatResponse(String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      String? response;
      
      if (_openAIKey != 'sk_your_openai_key_here') {
        response = await _callOpenAIAPI(userMessage, conversationHistory);
        if (response != null) {
          return _sanitizeHealthcareResponse(response);
        }
      }
      
      if (_cohereKey != 'your_cohere_key_here') {
        response = await _callCohereAPI(userMessage, conversationHistory);
        if (response != null) {
          return _sanitizeHealthcareResponse(response);
        }
      }
      
      if (_huggingFaceKey != 'hf_your_huggingface_key_here') {
        response = await _callHuggingFaceAPI(userMessage, conversationHistory);
        if (response != null) {
          return _sanitizeHealthcareResponse(response);
        }
      }
      
      return _getEnhancedRuleBasedResponse(userMessage, conversationHistory);
    } catch (e) {
      print('Chatbot service error: $e');
      return _getEnhancedRuleBasedResponse(userMessage, conversationHistory);
    }
  }

  static Future<String?> _callOpenAIAPI(String userMessage, List<Map<String, String>> history) async {
    try {
      List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content': '''You are a compassionate wellness assistant with knowledge of mental health, self-care, and general wellness practices. 

Guidelines:
- Provide evidence-based advice when possible
- Be empathetic and supportive
- Always recommend professional help for serious concerns
- Focus on practical, actionable strategies
- Acknowledge when something is outside your scope
- Never diagnose or prescribe medication
- Emphasize that you provide general wellness information, not medical advice

Remember: You're here to support and guide, not replace professional healthcare.'''
        }
      ];
      
      int startIndex = history.length > 6 ? history.length - 6 : 0;
      for (int i = startIndex; i < history.length; i++) {
        messages.add({
          'role': history[i]['role'] == 'user' ? 'user' : 'assistant',
          'content': history[i]['message']!
        });
      }
      
      messages.add({'role': 'user', 'content': userMessage});

      final response = await http.post(
        Uri.parse(_openAIUrl),
        headers: {
          'Authorization': 'Bearer $_openAIKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 200,
          'temperature': 0.7,
          'presence_penalty': 0.1,
          'frequency_penalty': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.trim();
      }
    } catch (e) {
      print('OpenAI API error: $e');
    }
    return null;
  }

  static Future<String?> _callCohereAPI(String userMessage, List<Map<String, String>> history) async {
    try {
      String prompt = '''You are a supportive wellness assistant providing mental health and self-care guidance.

Context: You help people with stress, anxiety, depression, sleep issues, and general wellness. Always be empathetic and recommend professional help when needed.

Conversation:
''';
      
      int startIndex = history.length > 4 ? history.length - 4 : 0;
      for (int i = startIndex; i < history.length; i++) {
        prompt += "${history[i]['role'] == 'user' ? 'Human' : 'Assistant'}: ${history[i]['message']}\n";
      }
      
      prompt += "Human: $userMessage\nAssistant:";

      final response = await http.post(
        Uri.parse(_cohereUrl),
        headers: {
          'Authorization': 'Bearer $_cohereKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'command-light',
          'prompt': prompt,
          'max_tokens': 180,
          'temperature': 0.7,
          'k': 0,
          'stop_sequences': ['Human:', 'Assistant:'],
          'return_likelihoods': 'NONE',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['generations'][0]['text']?.trim();
      }
    } catch (e) {
      print('Cohere API error: $e');
    }
    return null;
  }

  static Future<String?> _callHuggingFaceAPI(String userMessage, List<Map<String, String>> history) async {
    try {
      String conversationContext = _buildHealthcareContext(history, userMessage);
      
      final response = await http.post(
        Uri.parse('$_huggingFaceUrl/$_conversationModel'),
        headers: {
          'Authorization': 'Bearer $_huggingFaceKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': conversationContext,
          'parameters': {
            'max_length': 180,
            'temperature': 0.7,
            'do_sample': true,
            'top_p': 0.9,
            'repetition_penalty': 1.1,
          },
          'options': {
            'wait_for_model': true,
            'use_cache': false,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          String generatedText = data[0]['generated_text'] ?? '';
          return _extractNewResponse(generatedText, conversationContext);
        }
      }
    } catch (e) {
      print('Hugging Face API error: $e');
    }
    return null;
  }

  static String _buildHealthcareContext(List<Map<String, String>> history, String newMessage) {
    String context = '''You are a compassionate wellness assistant specializing in mental health support and self-care guidance. 

Your role:
- Provide evidence-based wellness strategies
- Offer emotional support and validation
- Suggest practical coping techniques
- Always recommend professional help for serious concerns
- Never diagnose or prescribe medication

Conversation:
''';
    
    int startIndex = history.length > 6 ? history.length - 6 : 0;
    for (int i = startIndex; i < history.length; i++) {
      context += "${history[i]['role'] == 'user' ? 'Human' : 'Assistant'}: ${history[i]['message']}\n";
    }
    
    context += "Human: $newMessage\nAssistant:";
    return context;
  }

  static String _extractNewResponse(String generatedText, String context) {
    if (generatedText.length > context.length) {
      return generatedText.substring(context.length).trim();
    }
    return generatedText.trim();
  }

  static String _getEnhancedRuleBasedResponse(String userMessage, List<Map<String, String>> conversationHistory) {
    String message = userMessage.toLowerCase().trim();
    print('Processing message: "$message"');
    
    bool isFollowUp = conversationHistory.length > 1;
    String? lastTopic = isFollowUp ? _identifyLastTopic(conversationHistory) : null;
    
    if (_detectCrisis(message)) {
      print('Crisis detected');
      return _getCrisisResponse();
    }
    
    if (_containsAny(message, ['panic', 'panic attack', 'panicking'])) {
      print('Panic detected');
      return _formatHealthcareResponse('panic');
    }
    
    if (_containsAny(message, ['anxious', 'anxiety', 'worried', 'nervous', 'fear', 'scared', 'worry'])) {
      print('Anxiety detected');
      return _formatHealthcareResponse('anxiety');
    }
    
    if (_containsAny(message, ['sad', 'depressed', 'depression', 'down', 'hopeless', 'empty', 'numb', 'worthless'])) {
      print('Depression detected');
      return _formatHealthcareResponse('depression');
    }
    
    if (_containsAny(message, ['stress', 'stressed', 'overwhelmed', 'pressure', 'burnout', 'exhausted', 'overworked'])) {
      print('Stress detected');
      return _formatHealthcareResponse('stress');
    }
    
    if (_containsAny(message, ['sleep', 'sleeping', 'tired', 'insomnia', 'can\'t sleep', 'sleepless', 'restless', 'fatigue'])) {
      print('Sleep issues detected');
      return _formatHealthcareResponse('sleep');
    }
    
    if (_containsAny(message, ['angry', 'anger', 'rage', 'furious', 'mad', 'irritated', 'frustrated'])) {
      print('Anger detected');
      return _getAngerManagementResponse();
    }
    
    if (_containsAny(message, ['lonely', 'loneliness', 'isolated', 'alone', 'friendless', 'disconnected'])) {
      print('Loneliness detected');
      return _getLonelinessResponse();
    }
    
    if (_containsAny(message, ['grief', 'grieving', 'loss', 'died', 'death', 'mourning', 'bereavement'])) {
      print('Grief detected');
      return _getGriefResponse();
    }
    
    if (_containsAny(message, ['work', 'job', 'career', 'workplace', 'boss', 'office', 'colleague', 'employment'])) {
      print('Work stress detected');
      return _getWorkStressResponse();
    }
    
    if (_containsAny(message, ['relationship', 'partner', 'spouse', 'dating', 'boyfriend', 'girlfriend', 'marriage'])) {
      print('Relationship detected');
      return _getRelationshipResponse();
    }
    
    if (_containsAny(message, ['family', 'parents', 'children', 'kids', 'mother', 'father', 'sibling'])) {
      print('Family detected');
      return _getFamilyResponse();
    }
    
    if (_containsAny(message, ['self-care', 'self care', 'wellness', 'healthy habits', 'wellbeing', 'self help'])) {
      print('Self-care detected');
      return _getSelfCareResponse();
    }
    
    if (_containsAny(message, ['exercise', 'workout', 'fitness', 'physical activity', 'gym', 'running', 'walking'])) {
      print('Exercise detected');
      return _getExerciseResponse();
    }
    
    if (_containsAny(message, ['nutrition', 'diet', 'eating', 'food', 'hungry', 'appetite', 'meal'])) {
      print('Nutrition detected');
      return _getNutritionResponse();
    }
    
    if (_containsAny(message, ['meditation', 'mindfulness', 'breathing', 'breathe', 'mindful', 'meditate'])) {
      print('Mindfulness detected');
      return _getMindfulnessResponse();
    }
    
    if (_containsAny(message, ['motivation', 'unmotivated', 'lazy', 'procrastination', 'procrastinate', 'no energy'])) {
      print('Motivation detected');
      return _getMotivationResponse();
    }
    
    if (_containsAny(message, ['goals', 'goal', 'achievement', 'success', 'progress', 'accomplish'])) {
      print('Goals detected');
      return _getGoalSettingResponse();
    }
    
    if (_containsAny(message, ['hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening'])) {
      print('Greeting detected');
      return _getGreetingResponse();
    }
    
    if (_containsAny(message, ['help', 'advice', 'support', 'guidance', 'tips', 'how to', 'what should', 'can you help'])) {
      print('General help detected');
      return _getGeneralHelpResponse();
    }
    
    if (isFollowUp && lastTopic != null) {
      print('Follow-up detected for topic: $lastTopic');
      return _getFollowUpResponse(lastTopic, message);
    }
    
    print('No specific topic detected, using general support');
    return _getGeneralSupportResponse();
  }


  static bool _containsAny(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }

  static bool _detectCrisis(String message) {
    List<String> crisisKeywords = [
      'suicide', 'kill myself', 'end it all', 'not worth living', 'want to die',
      'hurt myself', 'self harm', 'cutting', 'overdose', 'can\'t go on'
    ];
    return crisisKeywords.any((keyword) => message.contains(keyword));
  }
  
  static String _getCrisisResponse() {
    return '''🚨 **I'm concerned about you and want to help.**

If you're having thoughts of suicide or self-harm, please reach out for immediate support:

**Crisis Resources:**
• **National Suicide Prevention Lifeline**: 988 or 1-800-273-8255
• **Crisis Text Line**: Text HOME to 741741
• **Emergency Services**: 911

**You are not alone.** These feelings can be temporary, and professional help is available. Please consider:
• Calling a trusted friend or family member
• Going to your nearest emergency room
• Contacting your mental health provider

Your life has value, and there are people who want to help you through this difficult time.''';
  }
  
  static String _formatHealthcareResponse(String topic) {
    if (_healthcareKnowledge.containsKey(topic)) {
      return _healthcareKnowledge[topic]!.join('\n\n');
    }
    return _getGeneralSupportResponse();
  }
  
  static String _getAngerManagementResponse() {
    return '''**Managing Anger Effectively:**

Anger is a normal emotion, but how we express it matters:

• **Immediate Techniques:**
  - Count to 10 (or 100) before responding
  - Take deep breaths or step away from the situation
  - Use "I" statements instead of "you" statements

• **Physical Release:**
  - Go for a brisk walk or run
  - Do jumping jacks or push-ups
  - Squeeze a stress ball or punch a pillow

• **Long-term Strategies:**
  - Identify your anger triggers
  - Practice regular stress management
  - Consider anger management counseling if needed

Remember: It's okay to feel angry, but it's important to express it in healthy ways.''';
  }
  
  static String _getLonelinessResponse() {
    return '''**Coping with Loneliness:**

Loneliness is a common human experience. Here are ways to reconnect:

• **Immediate Actions:**
  - Call or text someone you care about
  - Join online communities with shared interests
  - Practice self-compassion - treat yourself kindly

• **Building Connections:**
  - Volunteer for causes you care about
  - Join clubs, classes, or hobby groups
  - Consider adopting a pet if circumstances allow

• **Quality over Quantity:**
  - Focus on deepening existing relationships
  - Be vulnerable and authentic with others
  - Practice active listening

Remember: Being alone doesn't always mean being lonely, and feeling lonely doesn't mean you're truly alone.''';
  }
  
  static String _getGriefResponse() {
    return '''**Navigating Grief and Loss:**

Grief is a natural response to loss, and everyone grieves differently:

• **Understanding Grief:**
  - There's no "right" timeline for grieving
  - Emotions may come in waves - this is normal
  - Physical symptoms (fatigue, appetite changes) are common

• **Healthy Coping:**
  - Allow yourself to feel without judgment
  - Maintain routines when possible
  - Accept help from others
  - Honor your loved one's memory in meaningful ways

• **When to Seek Help:**
  - If grief interferes with daily functioning for extended periods
  - If you're having thoughts of self-harm
  - If you're using substances to cope

Grief counseling or support groups can provide valuable guidance during this difficult time.''';
  }
  
  static String _getWorkStressResponse() {
    return '''**Managing Work-Related Stress:**

Work stress is common, but manageable with the right strategies:

• **Immediate Relief:**
  - Take regular breaks (even 5 minutes helps)
  - Practice desk stretches or breathing exercises
  - Step outside for fresh air when possible

• **Boundary Setting:**
  - Learn to say no to non-essential tasks
  - Set clear work hours and stick to them
  - Avoid checking emails outside work hours

• **Long-term Solutions:**
  - Communicate with supervisors about workload
  - Develop time management skills
  - Consider if job changes are needed for your wellbeing

Remember: Your mental health is more important than any job. If work stress is severe, consider speaking with HR or a career counselor.''';
  }
  
  static String _getRelationshipResponse() {
    return '''**Building Healthy Relationships:**

Strong relationships are built on mutual respect and communication:

• **Communication Skills:**
  - Practice active listening without interrupting
  - Use "I feel" statements instead of blame
  - Address issues directly but kindly

• **Healthy Boundaries:**
  - It's okay to say no to requests
  - Maintain your individual identity and interests
  - Respect each other's need for space

• **Conflict Resolution:**
  - Focus on the issue, not personal attacks
  - Take breaks if discussions get heated
  - Seek to understand before being understood

If relationship issues persist, couples counseling can provide valuable tools and perspectives.''';
  }
  
  static String _getFamilyResponse() {
    return '''**Navigating Family Relationships:**

Family dynamics can be complex, but healthy boundaries and communication help:

• **Setting Boundaries:**
  - It's okay to limit contact with toxic family members
  - You can love someone and still protect your mental health
  - Choose your battles wisely

• **Improving Communication:**
  - Focus on your own behavior, not changing others
  - Express appreciation for positive interactions
  - Consider family therapy for persistent issues

• **Self-Care:**
  - Don't feel guilty for prioritizing your wellbeing
  - Build a support network outside your family
  - Remember: you can't control others, only your responses

Family relationships take work from all parties. Professional family therapy can help when needed.''';
  }
  
  static String _getSelfCareResponse() {
    return '''**Comprehensive Self-Care Guide:**

Self-care isn't selfish - it's essential for your wellbeing:

• **Physical Self-Care:**
  - Regular exercise (even 10 minutes daily)
  - Nutritious meals and adequate hydration
  - 7-9 hours of quality sleep

• **Emotional Self-Care:**
  - Practice gratitude journaling
  - Set healthy boundaries
  - Allow yourself to feel emotions without judgment

• **Mental Self-Care:**
  - Engage in activities you enjoy
  - Learn something new
  - Practice mindfulness or meditation

• **Social Self-Care:**
  - Spend time with supportive people
  - Join communities with shared interests
  - Practice saying no to draining relationships

Start small - even 5 minutes of self-care daily can make a difference!''';
  }
  
  static String _getExerciseResponse() {
    return '''**Exercise for Mental Health:**

Physical activity is one of the most effective mood boosters:

• **Mental Health Benefits:**
  - Releases endorphins (natural mood elevators)
  - Reduces stress hormones like cortisol
  - Improves sleep quality and self-esteem

• **Getting Started:**
  - Start with just 10 minutes daily
  - Choose activities you enjoy (dancing, walking, swimming)
  - Exercise with friends for accountability

• **Types of Exercise:**
  - **Cardio**: Walking, running, cycling, dancing
  - **Strength**: Bodyweight exercises, weights, resistance bands
  - **Mind-Body**: Yoga, tai chi, stretching

Remember: Any movement is better than none. Find what you enjoy and start there!''';
  }
  
  static String _getNutritionResponse() {
    return '''**Nutrition for Mental Wellness:**

What you eat directly affects how you feel:

• **Mood-Boosting Foods:**
  - **Omega-3 rich**: Salmon, walnuts, flaxseeds
  - **Complex carbs**: Oats, quinoa, sweet potatoes
  - **Protein**: Eggs, beans, lean meats
  - **Antioxidants**: Berries, dark chocolate, green tea

• **Foods to Limit:**
  - Excessive caffeine (can increase anxiety)
  - Processed foods high in sugar
  - Alcohol (depresses the nervous system)

• **Healthy Habits:**
  - Eat regular meals to stabilize blood sugar
  - Stay hydrated (dehydration affects mood)
  - Consider a vitamin D supplement if deficient

Small changes in diet can lead to significant improvements in mood and energy levels.''';
  }
  
  static String _getMindfulnessResponse() {
    return '''**Mindfulness and Meditation:**

Mindfulness helps you stay present and reduce anxiety:

• **Simple Breathing Exercise:**
  - Inhale for 4 counts, hold for 4, exhale for 6
  - Focus only on your breath
  - Practice for 5-10 minutes daily

• **Mindful Activities:**
  - **Body scan**: Notice sensations from head to toe
  - **Mindful walking**: Focus on each step
  - **Gratitude practice**: List 3 things you're grateful for

• **Apps and Resources:**
  - Headspace, Calm, Insight Timer
  - YouTube guided meditations
  - Local meditation groups

Start with just 5 minutes daily. Consistency matters more than duration.''';
  }
  
  static String _getMotivationResponse() {
    return '''**Overcoming Low Motivation:**

Motivation often follows action, not the other way around:

• **Start Tiny:**
  - Break tasks into 2-minute actions
  - Use the "just 5 minutes" rule
  - Celebrate small wins

• **Build Momentum:**
  - Create a morning routine
  - Set up your environment for success
  - Use accountability partners

• **Address Root Causes:**
  - Are you overwhelmed? Break things down
  - Are you perfectionist? Aim for "good enough"
  - Are you depressed? Consider professional help

• **Motivation Boosters:**
  - Connect tasks to your values
  - Visualize the benefits of completion
  - Reward yourself for progress

Remember: You don't need to feel motivated to take action. Action often creates motivation.''';
  }
  
  static String _getGoalSettingResponse() {
    return '''**Effective Goal Setting:**

Well-set goals provide direction and motivation:

• **SMART Goals:**
  - **Specific**: Clear and well-defined
  - **Measurable**: Track your progress
  - **Achievable**: Realistic given your resources
  - **Relevant**: Aligned with your values
  - **Time-bound**: Has a deadline

• **Implementation:**
  - Write goals down and review regularly
  - Break large goals into smaller steps
  - Create accountability systems
  - Plan for obstacles

• **Staying on Track:**
  - Track progress weekly
  - Adjust goals as needed
  - Celebrate milestones
  - Learn from setbacks without self-judgment

Remember: Progress, not perfection, is the goal. Small consistent steps lead to big changes.''';
  }
  
  static String? _identifyLastTopic(List<Map<String, String>> history) {
    if (history.isEmpty) return null;
    
    String lastMessage = history.last['message']?.toLowerCase() ?? '';
    
    if (lastMessage.contains('anxiety') || lastMessage.contains('anxious')) return 'anxiety';
    if (lastMessage.contains('depression') || lastMessage.contains('sad')) return 'depression';
    if (lastMessage.contains('stress') || lastMessage.contains('overwhelmed')) return 'stress';
    if (lastMessage.contains('sleep') || lastMessage.contains('tired')) return 'sleep';
    
    return null;
  }
  
  static String _getFollowUpResponse(String topic, String message) {
    Map<String, String> followUps = {
      'anxiety': "How are those breathing exercises working for you? Remember, managing anxiety is a process - be patient with yourself.",
      'depression': "I'm glad you're continuing to reach out. Small steps forward are still progress. Have you been able to try any of the suggestions?",
      'stress': "Stress management takes practice. Which techniques have you found most helpful so far?",
      'sleep': "Sleep improvements can take time. How has your sleep routine been going?",
    };
    
    return followUps[topic] ?? _getGeneralSupportResponse();
  }
  
  static String _getGreetingResponse() {
    List<String> greetings = [
      "Hello! I'm your wellness companion. I'm here to provide support and guidance on mental health, self-care, and emotional wellbeing. How are you feeling today?",
      "Hi there! I'm glad you're here. I can help with stress, anxiety, sleep issues, relationships, and many other wellness topics. What's on your mind?",
      "Hey! Welcome to your wellness space. I'm here to offer evidence-based strategies and emotional support. How can I help you today?",
      "Good to see you! I'm your personal wellness assistant, ready to help with any mental health or self-care concerns. What would you like to talk about?",
    ];
    
    return greetings[DateTime.now().millisecondsSinceEpoch % greetings.length];
  }

  static String _getGeneralHelpResponse() {
    return '''**I'm here to help with your wellness journey!**

I can provide support and guidance on many topics:

• **Mental Health**: Anxiety, depression, stress management, panic attacks
• **Sleep & Rest**: Sleep hygiene, insomnia, fatigue management
• **Relationships**: Communication, boundaries, family dynamics
• **Work-Life Balance**: Job stress, burnout prevention, workplace wellness
• **Self-Care**: Daily wellness routines, mindfulness, exercise
• **Emotional Support**: Loneliness, grief, anger management
• **Goal Setting**: Motivation, habit building, personal growth

**What specific area would you like to explore?** You can ask me about any of these topics, and I'll provide evidence-based strategies and emotional support.

Remember: I'm here to provide general wellness guidance. For serious mental health concerns, please consider speaking with a qualified professional.''';
  }

  static String _getGeneralSupportResponse() {
    List<String> responses = [
      "I'm here to support you with your wellness journey. I can help with anxiety, depression, stress, sleep issues, relationships, and much more. What specific area would you like to explore today?",
      "Thank you for reaching out. I provide evidence-based guidance on mental health, self-care, and emotional wellness. What's on your mind that I can help you with?",
      "I'm glad you're here. I can offer support with stress management, mood concerns, relationship issues, work-life balance, and many other wellness topics. What would be most helpful right now?",
      "Your mental health matters, and I'm here to help. I can provide strategies for anxiety, depression, sleep problems, anger management, and more. What specific challenge are you facing?",
      "I'm your wellness companion, ready to help with practical strategies and emotional support. Whether it's stress, relationships, self-care, or other concerns - what can I assist you with today?",
    ];
    
    return responses[DateTime.now().millisecondsSinceEpoch % responses.length];
  }
  
  static String _sanitizeHealthcareResponse(String response) {
    String sanitized = response.trim();
    
    if (sanitized.toLowerCase().contains('diagnose') || 
        sanitized.toLowerCase().contains('medication') ||
        sanitized.toLowerCase().contains('prescription') ||
        sanitized.toLowerCase().contains('cure')) {
      return "I can provide general wellness support, but for medical concerns, diagnosis, or treatment, please consult with a qualified healthcare professional who can give you personalized advice.";
    }
    
    List<String> seriousTopics = ['suicide', 'self-harm', 'severe depression', 'psychosis', 'addiction'];
    if (seriousTopics.any((topic) => sanitized.toLowerCase().contains(topic))) {
      sanitized += "\n\n**Important**: For serious mental health concerns, please contact a mental health professional or crisis hotline immediately.";
    }
    
    if (sanitized.length > 500) {
      sanitized = sanitized.substring(0, 500) + "...\n\nFor more detailed guidance, consider speaking with a mental health professional.";
    }
    
    return sanitized;
  }

  // Get conversation starters
  static List<String> getConversationStarters() {
    return [
      "I'm feeling anxious and overwhelmed",
      "How can I manage work stress better?",
      "I'm having trouble sleeping lately",
      "Feeling unmotivated and down",
      "Need help with relationship issues",
      "Looking for self-care strategies",
      "Dealing with anger management",
      "Coping with loneliness",
      "Tips for better mental health",
      "How to build healthy habits",
    ];
  }
}  