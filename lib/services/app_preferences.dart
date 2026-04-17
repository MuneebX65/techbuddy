import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String lessonsCompletedKey = 'lessons_completed';
  static const String userNameKey = 'user_name';
  static const String userAgeKey = 'user_age';
  static const String isFirstTimeKey = 'is_first_time';
  static const String chatCountKey = 'chat_count';
  static const String selectedPageIndexKey = 'selected_page_index';

  static final ValueNotifier<String?> userNameNotifier = ValueNotifier<String?>(
    null,
  );

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static Future<bool> isFirstTimeOpening() async {
    final prefs = await _prefs();
    return prefs.getBool(isFirstTimeKey) ?? true;
  }

  static Future<void> saveUserProfile({
    required String name,
    required int age,
  }) async {
    final normalizedName = name.trim();
    final prefs = await _prefs();
    await prefs.setString(userNameKey, normalizedName);
    await prefs.setInt(userAgeKey, age);
    await prefs.setBool(isFirstTimeKey, false);
    userNameNotifier.value = normalizedName;
  }

  static Future<String?> getUserName() async {
    final prefs = await _prefs();
    final name = prefs.getString(userNameKey)?.trim();
    if (name == null || name.isEmpty) {
      return null;
    }
    userNameNotifier.value = name;
    return name;
  }

  static Future<int?> getUserAge() async {
    final prefs = await _prefs();
    return prefs.getInt(userAgeKey);
  }

  static Future<int> incrementChatCount() async {
    final prefs = await _prefs();
    final current = prefs.getInt(chatCountKey) ?? 0;
    final updated = current + 1;
    await prefs.setInt(chatCountKey, updated);
    return updated;
  }

  static Future<void> saveSelectedPageIndex(int index) async {
    final prefs = await _prefs();
    await prefs.setInt(selectedPageIndexKey, index);
  }

  static Future<int> getSelectedPageIndex() async {
    final prefs = await _prefs();
    final index = prefs.getInt(selectedPageIndexKey) ?? 0;
    if (index < 0) {
      return 0;
    }
    return index;
  }

  static Future<List<int>> getCompletedLessons() async {
    final prefs = await _prefs();
    final raw = prefs.getStringList(lessonsCompletedKey) ?? <String>[];
    return raw.map(int.tryParse).whereType<int>().toSet().toList()..sort();
  }

  static Future<void> markLessonCompleted(int lessonId) async {
    final prefs = await _prefs();
    final completed = await getCompletedLessons();
    if (completed.contains(lessonId)) {
      return;
    }
    completed.add(lessonId);
    completed.sort();
    final encoded = completed.map((e) => e.toString()).toList();
    await prefs.setStringList(lessonsCompletedKey, encoded);
  }
}
