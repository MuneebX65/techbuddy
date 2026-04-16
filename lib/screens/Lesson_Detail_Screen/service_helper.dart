import 'package:techbuddy/services/app_preferences.dart';

class LessonDetailServiceHelper {
  static const List<String> _microDurations = <String>[
    '1 min',
    '2 min',
    '3 min',
  ];

  static List<String> parseSteps(Map<String, dynamic> lesson) {
    final stepsData = lesson['steps'];
    if (stepsData is List) {
      final parsed = stepsData
          .map((step) => step.toString().trim())
          .where((step) => step.isNotEmpty)
          .toList();
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }
    return <String>['No steps available.'];
  }

  static String stepDuration(int index) {
    return _microDurations[index % _microDurations.length];
  }

  static String stepCategory(String step) {
    final text = step.toLowerCase();
    if (text.contains('open') || text.contains('find')) {
      return 'Locate';
    }
    if (text.contains('tap') || text.contains('click')) {
      return 'Action';
    }
    if (text.contains('check') || text.contains('verify')) {
      return 'Confirm';
    }
    if (text.contains('safe') ||
        text.contains('secure') ||
        text.contains('scam')) {
      return 'Safety';
    }
    return 'Practice';
  }

  static String stepTip(String step) {
    final text = step.toLowerCase();
    if (text.contains('open') || text.contains('app')) {
      return 'Tip: If you cannot find the app, use your phone search bar.';
    }
    if (text.contains('tap')) {
      return 'Tip: Tap once and wait a moment before tapping again.';
    }
    if (text.contains('password') || text.contains('pin')) {
      return 'Tip: Never share passwords or PINs, even with unknown callers.';
    }
    if (text.contains('link') ||
        text.contains('payment') ||
        text.contains('upi')) {
      return 'Tip: Double-check names and amounts before you continue.';
    }
    return 'Tip: Read each line on screen slowly before taking action.';
  }

  static Future<bool> handleNextStepCompletion({
    required int currentStep,
    required int totalSteps,
    required int lessonId,
  }) async {
    if (currentStep < totalSteps - 1) {
      return false;
    }
    await AppPreferences.markLessonCompleted(lessonId);
    return true;
  }
}
