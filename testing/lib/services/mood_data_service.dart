import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodEntry {
  final DateTime date;
  final double moodValue;
  final List<String> emotions;
  final String note;
  final String emoji;
  final String moodLabel;

  MoodEntry({
    required this.date,
    required this.moodValue,
    required this.emotions,
    required this.note,
    required this.emoji,
    required this.moodLabel,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'moodValue': moodValue,
      'emotions': emotions,
      'note': note,
      'emoji': emoji,
      'moodLabel': moodLabel,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      moodValue: json['moodValue']?.toDouble() ?? 3.0,
      emotions: List<String>.from(json['emotions'] ?? []),
      note: json['note'] ?? '',
      emoji: json['emoji'] ?? '😐',
      moodLabel: json['moodLabel'] ?? 'Neutral',
    );
  }

  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class MoodDataService {
  static const String _moodEntriesKey = 'mood_entries';

  static String _getMoodEmoji(double moodValue) {
    if (moodValue <= 1.5) return '😢';
    if (moodValue <= 2.5) return '😔';
    if (moodValue <= 3.5) return '😐';
    if (moodValue <= 4.5) return '😊';
    return '😄';
  }

  static String _getMoodLabel(double moodValue) {
    if (moodValue <= 1.5) return 'Very Low';
    if (moodValue <= 2.5) return 'Low';
    if (moodValue <= 3.5) return 'Neutral';
    if (moodValue <= 4.5) return 'Good';
    return 'Very Good';
  }

  static Color _getMoodColor(double moodValue) {
    if (moodValue <= 1.5) return const Color(0xFFFFCDD2); 
    if (moodValue <= 2.5) return const Color(0xFFFFE0B2); 
    if (moodValue <= 3.5) return const Color(0xFFF0F4C3); 
    if (moodValue <= 4.5) return const Color(0xFFC8E6C9); 
    return const Color(0xFFA5D6A7); 
  }

  
  static Future<void> saveMoodEntry({
    required double moodValue,
    required List<String> emotions,
    required String note,
  }) async {
    final today = DateTime.now();
    await saveMoodEntryForDate(
      date: DateTime(today.year, today.month, today.day),
      moodValue: moodValue,
      emotions: emotions,
      note: note,
    );
  }

  
  static Future<void> saveMoodEntryForDate({
    required DateTime date,
    required double moodValue,
    required List<String> emotions,
    required String note,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final moodEntry = MoodEntry(
        date: DateTime(date.year, date.month, date.day), 
        moodValue: moodValue,
        emotions: emotions,
        note: note,
        emoji: _getMoodEmoji(moodValue),
        moodLabel: _getMoodLabel(moodValue),
      );

      
      final existingEntries = await getAllMoodEntries();
      
      
      existingEntries.removeWhere((entry) => 
        entry.date.year == date.year &&
        entry.date.month == date.month &&
        entry.date.day == date.day
      );
      existingEntries.add(moodEntry);

      
      final jsonList = existingEntries.map((entry) => entry.toJson()).toList();
      await prefs.setString(_moodEntriesKey, jsonEncode(jsonList));
      
    } catch (e) {
      print('Error saving mood entry: $e');
      rethrow;
    }
  }

  
  static Future<List<MoodEntry>> getAllMoodEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_moodEntriesKey);
      
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => MoodEntry.fromJson(json)).toList();
    } catch (e) {
      print('Error loading mood entries: $e');
      return [];
    }
  }

  
  static Future<MoodEntry?> getMoodEntryForDate(DateTime date) async {
    try {
      final allEntries = await getAllMoodEntries();
      
      for (final entry in allEntries) {
        if (entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day) {
          return entry;
        }
      }
      return null;
    } catch (e) {
      print('Error getting mood entry for date: $e');
      return null;
    }
  }

  
  static Future<Map<int, MoodEntry>> getMoodEntriesForMonth(int year, int month) async {
    try {
      final allEntries = await getAllMoodEntries();
      final monthEntries = <int, MoodEntry>{};
      
      for (final entry in allEntries) {
        if (entry.date.year == year && entry.date.month == month) {
          monthEntries[entry.date.day] = entry;
        }
      }
      
      return monthEntries;
    } catch (e) {
      print('Error getting mood entries for month: $e');
      return {};
    }
  }

  
  static Future<MoodEntry?> getTodaysMoodEntry() async {
    final today = DateTime.now();
    return await getMoodEntryForDate(today);
  }

  
  static Future<void> deleteMoodEntry(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allEntries = await getAllMoodEntries();
      
      allEntries.removeWhere((entry) => 
        entry.date.year == date.year &&
        entry.date.month == date.month &&
        entry.date.day == date.day
      );

      final jsonList = allEntries.map((entry) => entry.toJson()).toList();
      await prefs.setString(_moodEntriesKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error deleting mood entry: $e');
      rethrow;
    }
  }

  
  static Future<Map<String, dynamic>> getMoodStatistics() async {
    try {
      final allEntries = await getAllMoodEntries();
      
      if (allEntries.isEmpty) {
        return {
          'totalEntries': 0,
          'averageMood': 0.0,
          'currentStreak': 0,
          'longestStreak': 0,
        };
      }

      
      final totalMood = allEntries.fold<double>(0, (sum, entry) => sum + entry.moodValue);
      final averageMood = totalMood / allEntries.length;

      
      int currentStreak = 0;
      final today = DateTime.now();
      DateTime checkDate = DateTime(today.year, today.month, today.day);
      
      while (true) {
        final entry = await getMoodEntryForDate(checkDate);
        if (entry != null) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      
      int longestStreak = currentStreak; 

      return {
        'totalEntries': allEntries.length,
        'averageMood': averageMood,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      };
    } catch (e) {
      print('Error calculating mood statistics: $e');
      return {
        'totalEntries': 0,
        'averageMood': 0.0,
        'currentStreak': 0,
        'longestStreak': 0,
      };
    }
  }

  
  static Future<void> clearAllMoodData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_moodEntriesKey);
    } catch (e) {
      print('Error clearing mood data: $e');
      rethrow;
    }
  }

  
  static Color getMoodColor(double moodValue) {
    return _getMoodColor(moodValue);
  }
}