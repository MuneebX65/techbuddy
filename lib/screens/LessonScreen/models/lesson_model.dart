import 'dart:convert';

import 'package:techbuddy/services/groq_service.dart';

import '../mappers/lesson_topic_mapper.dart';

class LessonModel {
  static Future<List<String>> loadDailyTopics() async {
    if (!GroqService.instance.isConfigured) {
      return LessonTopicMapper.defaultTopics;
    }

    try {
      const prompt =
          '''Generate 6 varied beginner-friendly topics for older adults.
Return ONLY valid JSON:
{"topics": ["How to use WhatsApp?", "How to open Google Maps?"]}
Rules: Keep topics short, start with "How to", end with "?". Vary topics each time.
''';
      final raw = await GroqService.instance.generateText(prompt);
      final topics = _extractStringList(_parseJsonObject(raw)?['topics']);
      return applyDailyTopics(
        topics.isEmpty
            ? LessonTopicMapper.defaultTopics
            : topics.take(6).toList(),
      );
    } catch (_) {
      return LessonTopicMapper.defaultTopics;
    }
  }

  static List<String> applyDailyTopics(List<String> topics) {
    final result = topics
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    return result.isEmpty ? LessonTopicMapper.defaultTopics : result;
  }

  static Future<Map<String, dynamic>?> createLessonFromTopic({
    required String topic,
    required Future<Map<String, dynamic>> Function(String topic)
    generateLessonWithAi,
    required Map<String, dynamic> Function(String topic) fallbackLesson,
  }) async {
    final normalizedTopic = topic.trim();
    if (normalizedTopic.isEmpty) {
      return null;
    }

    try {
      return await generateLessonWithAi(normalizedTopic);
    } catch (_) {
      return fallbackLesson(normalizedTopic);
    }
  }

  static int createCustomLessonFromPrompt(String topic) {
    return topic.trim().toLowerCase().hashCode.abs();
  }

  static Map<String, dynamic>? _parseJsonObject(String raw) {
    final cleaned = raw
        .trim()
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    if (cleaned.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static List<String> _extractStringList(dynamic value) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
