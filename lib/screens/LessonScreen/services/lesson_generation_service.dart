import 'dart:convert';

import 'package:techbuddy/core/constants.dart';
import 'package:techbuddy/services/groq_service.dart';

import '../mappers/lesson_topic_mapper.dart';

class LessonGenerationService {
  Future<List<String>> loadDailyTopics() async {
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
      final topics = extractStringList(_parseJsonObject(raw)?['topics']);
      return topics.isEmpty
          ? LessonTopicMapper.defaultTopics
          : topics.take(6).toList();
    } catch (_) {
      return LessonTopicMapper.defaultTopics;
    }
  }

  Future<Map<String, dynamic>> generateLessonWithAi(String topic) async {
    if (!GroqService.instance.isConfigured) {
      return fallbackLesson(topic);
    }

    final prompt =
        '''
Create a beginner digital lesson in small steps for older adults.
Topic: $topic
Return ONLY valid JSON:
{
	"title": "Short title",
	"icon": "single emoji",
	"steps": [
		"Step 1 instruction",
		"Step 2 instruction",
		"Step 3 instruction",
		"Step 4 instruction",
		"Step 5 instruction",
		"Step 6 instruction",
		"Step 7 instruction",
		"Step 8 instruction"
	]
}
Rules:
- 7 to 8 steps.
- Each step must be clear and practical, max 12 words.
- No technical jargon.
- No markdown.
''';

    final raw = await GroqService.instance.generateText(prompt);
    final parsed = _parseJsonObject(raw);

    final title = (parsed?['title'] ?? '').toString().trim();
    final icon = (parsed?['icon'] ?? '').toString().trim();
    final steps = extractStringList(parsed?['steps']);

    if (steps.length < 3) {
      return fallbackLesson(topic);
    }

    return <String, dynamic>{
      'title': title.isNotEmpty
          ? title
          : LessonTopicMapper.titleFromTopic(topic),
      'steps': steps.take(8).toList(),
      'color': AppColors.accent,
      'icon': icon.isNotEmpty ? icon : '📘',
    };
  }

  List<String> extractStringList(dynamic value) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> fallbackLesson(String topic) {
    return <String, dynamic>{
      'title': LessonTopicMapper.titleFromTopic(topic),
      'steps': <String>[
        'Open your phone and unlock it.',
        'Find the app or service related to "$topic".',
        'Tap it once and wait for it to open.',
        'Look for the main option or button you need.',
        'Tap gently on that option.',
        'Follow on-screen instructions slowly, one by one.',
        'Take your time and do not rush.',
        'If unsure at any point, stop and ask a trusted person.',
      ],
      'color': AppColors.primary,
      'icon': '📱',
    };
  }

  Map<String, dynamic>? _parseJsonObject(String raw) {
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
}
