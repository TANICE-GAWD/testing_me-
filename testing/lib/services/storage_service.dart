import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _moodLogsKey = 'mood_logs';
  static const String _streakKey = 'wellness_streak';
  static const String _settingsKey = 'app_settings';
  static const String _chatHistoryKey = 'chat_history';

  // Mood logging
  static Future<void> saveMoodLog(Map<String, dynamic> moodLog) async {
    final prefs = await SharedPreferences.getInstance();
    final existingLogs = await getMoodLogs();
    existingLogs.add(moodLog);
    
    final jsonString = jsonEncode(existingLogs);
    await prefs.setString(_moodLogsKey, jsonString);
  }

  static Future<List<Map<String, dynamic>>> getMoodLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_moodLogsKey);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // Wellness streak
  static Future<void> updateWellnessStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, streak);
  }

  static Future<int> getWellnessStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  // App settings
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings);
    await prefs.setString(_settingsKey, jsonString);
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);
    
    if (jsonString == null) {
      return {
        'dailyReminders': true,
        'weeklyReports': true,
        'dataBackup': false,
        'reminderTime': '9:00 AM',
        'theme': 'system',
      };
    }
    
    return jsonDecode(jsonString);
  }

  // Chat history
  static Future<void> saveChatMessage(Map<String, String> message) async {
    final prefs = await SharedPreferences.getInstance();
    final existingHistory = await getChatHistory();
    existingHistory.add(message);
    
    // Keep only last 50 messages
    if (existingHistory.length > 50) {
      existingHistory.removeRange(0, existingHistory.length - 50);
    }
    
    final jsonString = jsonEncode(existingHistory);
    await prefs.setString(_chatHistoryKey, jsonString);
  }

  static Future<List<Map<String, String>>> getChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_chatHistoryKey);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => Map<String, String>.from(item)).toList();
  }

  static Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatHistoryKey);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Export data
  static Future<Map<String, dynamic>> exportAllData() async {
    return {
      'moodLogs': await getMoodLogs(),
      'wellnessStreak': await getWellnessStreak(),
      'settings': await getSettings(),
      'chatHistory': await getChatHistory(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }
}