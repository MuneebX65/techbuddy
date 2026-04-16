class LessonTopicMapper {
  static const List<String> defaultTopics = <String>[
    'How to use WhatsApp?',
    'How to open Google Maps?',
    'How to send email?',
    'How to avoid scam links?',
    'How to use UPI safely?',
    'How to change phone settings?',
  ];

  static const List<String> timeEstimates = <String>[
    '6 min',
    '8 min',
    '10 min',
    '12 min',
  ];

  static String titleFromTopic(String topic) {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) {
      return 'Custom Lesson';
    }

    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  static String topicSummary(String topic) {
    final normalized = topic.toLowerCase();
    if (normalized.contains('whatsapp')) {
      return 'Learn chats, voice notes, and sharing photos safely.';
    }
    if (normalized.contains('map')) {
      return 'Find places, start directions, and avoid wrong turns.';
    }
    if (normalized.contains('email')) {
      return 'Write, send, and reply to emails with confidence.';
    }
    if (normalized.contains('scam')) {
      return 'Spot risky messages and avoid unsafe links.';
    }
    if (normalized.contains('upi')) {
      return 'Do payments securely and verify before sending money.';
    }
    if (normalized.contains('setting')) {
      return 'Adjust phone options to make your device easier to use.';
    }
    return 'A simple step-by-step guide made for beginners.';
  }

  static String topicLevel(String topic) {
    final normalized = topic.toLowerCase();
    if (normalized.contains('scam') || normalized.contains('upi')) {
      return 'Beginner+';
    }
    return 'Beginner';
  }

  static String topicDuration(int index) {
    return timeEstimates[index % timeEstimates.length];
  }

  static String topicEmoji(String topic) {
    final normalized = topic.toLowerCase();
    if (normalized.contains('whatsapp')) return '💬';
    if (normalized.contains('map')) return '🗺️';
    if (normalized.contains('email')) return '📧';
    if (normalized.contains('scam')) return '🛡️';
    if (normalized.contains('upi')) return '💳';
    if (normalized.contains('setting')) return '⚙️';
    return '📘';
  }
}
