import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotService {
  
  static const String _geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent';
  
  
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  
  static const Map<String, List<String>> _healthcareKnowledge = {
    'anxiety': [
      "Anxiety is a normal response to stress, but when it becomes overwhelming, there are effective ways to manage it:",
      "• **Breathing Technique**: Try the 4-7-8 method - inhale for 4, hold for 7, exhale for 8",
      "• **Grounding Exercise**: Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste",
      "If anxiety persists or interferes with daily life, please consult a mental health professional."
    ],
    'depression': [
      "Depression affects millions of people and is a treatable condition. Here are some evidence-based strategies:",
      "• **Behavioral Activation**: Engage in activities you used to enjoy, even if you don't feel like it",
      "• **Sleep Hygiene**: Maintain regular sleep schedule (7-9 hours nightly)",
      "Depression is not a personal weakness. Professional help from a therapist or psychiatrist can be very effective."
    ],
    'stress': [
      "Chronic stress affects both mental and physical health. Here are proven stress management techniques:",
      "• **Time Management**: Break large tasks into smaller, manageable steps",
      "• **Boundary Setting**: Learn to say no to non-essential commitments",
      "• **Support System**: Talk to trusted friends, family, or a counselor"
    ],
    'sleep': [
      "Quality sleep is essential for mental health. Here's evidence-based sleep hygiene:",
      "• **Sleep Schedule**: Go to bed and wake up at the same time daily, even weekends",
      "• **Environment**: Keep bedroom cool (65-68°F), dark, and quiet",
      "If sleep problems persist for more than 2 weeks, consult a healthcare provider."
    ],
    'panic': [
      "Panic attacks are intense but temporary. Here's how to manage them:",
      "• **Immediate Response**: Remind yourself 'This will pass, I am safe'",
      "• **Box Breathing**: Inhale 4 counts, hold 4, exhale 4, hold 4 - repeat",
      "Panic attacks typically peak within 10 minutes. If frequent, please see a mental health professional."
    ]
  };

  static Future<String> getChatResponse(String userMessage, List<Map<String, String>> conversationHistory) async {
    
    if (_detectCrisis(userMessage)) {
      return _getCrisisResponse();
    }

    try {
      final response = await _callGeminiApi(userMessage, conversationHistory);
      return response;
    } catch (e) {
      print('Gemini API error: $e');
      return "I'm sorry, I'm having a little trouble connecting right now. Please try again in a moment.";
    }
  }

  static Future<String> _callGeminiApi(String userMessage, List<Map<String, String>> history) async {
    final uri = Uri.parse('$_geminiApiUrl?key=$_apiKey');
    
    
    final systemInstruction = {
      'parts': [{
        'text': '''You are a compassionate, supportive, and non-judgmental wellness companion. Your name is Aura.

Your Core Principles:
1.  **Validate First**: Always start by acknowledging the user's feelings. Use phrases like "That sounds really tough," or "I hear you."
2.  **Be Brief and Gentle**: Keep your responses concise, warm, and easy to read. Aim for 2-4 sentences. Offer one simple suggestion at a time.
3.  **Be a Guide, Not a Doctor**: You are not a medical professional. You MUST NOT diagnose or give medical advice.
4.  **Safety is Paramount**: Always gently recommend professional help for serious or persistent issues.
5.  **Use Markdown**: Use **bolding** for emphasis to make responses scannable.

Example Interaction:
User: "I'm so anxious I can't think straight."
You: "It sounds like you're carrying a lot of anxiety right now, and that's a heavy feeling. I'm here with you.

Sometimes focusing on the breath can help. Would you like to try a simple breathing exercise?"
'''
      }]
    };

    
    final contents = <Map<String, dynamic>>[];
    
    for (var message in history) {
      
      contents.add({
        'role': message['role'] == 'user' ? 'user' : 'model',
        'parts': [{'text': message['message']!}]
      });
    }

    contents.add({
      'role': 'user',
      'parts': [{'text': userMessage}]
    });

    
    final payload = {
      'systemInstruction': systemInstruction,
      'contents': contents,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text']?.trim() ?? "I'm not sure how to respond to that. Could you try rephrasing?";
    } else {
      print('API Error: ${response.body}');
      throw Exception('Failed to get response from Gemini API');
    }
  }

  static bool _detectCrisis(String message) {
    final crisisKeywords = [
      'suicide', 'kill myself', 'end it all', 'not worth living', 'want to die',
      'hurt myself', 'self harm', 'cutting', 'overdose', 'can\'t go on'
    ];
    final lowerCaseMessage = message.toLowerCase();
    return crisisKeywords.any((keyword) => lowerCaseMessage.contains(keyword));
  }

  static String _getCrisisResponse() {
    return '''It sounds like you are in a lot of pain, and it's so important that you get support right now. Please know you are not alone in this.

Help is available, and you can connect with someone who can support you by calling or texting **988** in the US and Canada, or **111** in the UK. These services are free, confidential, and available 24/7.

Please reach out to them. They are there to help.''';
  }

  static List<String> getConversationStarters() {
    return [
      "I'm feeling anxious and overwhelmed",
      "How can I manage stress better?",
      "I'm having trouble sleeping lately",
      "I'm feeling unmotivated and down",
      "What are some simple self-care ideas?",
      "How can I practice mindfulness?",
    ];
  }
}
