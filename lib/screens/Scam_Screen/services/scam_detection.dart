import 'dart:convert';

import '../../../services/groq_service.dart';

class ScamAnalysisResult {
  const ScamAnalysisResult({
    required this.isScam,
    required this.isUncertain,
    required this.resultText,
  });

  final bool isScam;
  final bool isUncertain;
  final String resultText;
}

class ScamDetectionService {
  static const List<String> _scamKeywords = [
    'won',
    'prize',
    'click here',
    'urgent',
    'bank account',
    'otp',
    'verify',
    'free money',
    'congratulations',
    'claim now',
    'limited time',
    'winner',
    'lucky',
    'confirm your account',
    'suspended',
    'unusual activity',
    'act now',
    'expires today',
  ];

  Future<ScamAnalysisResult> analyze(String inputText) async {
    try {
      return await _analyzeWithGrok(inputText);
    } catch (_) {
      return _analyzeWithKeywords(inputText.toLowerCase());
    }
  }

  Map<String, dynamic>? tryParseAiJson(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final cleaned = trimmed
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

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

  Future<ScamAnalysisResult> _analyzeWithGrok(String message) async {
    if (!GroqService.instance.isConfigured) {
      throw StateError('GROQ_API_KEY is not configured.');
    }

    final prompt =
        '''
You are a scam detection assistant.
Analyze the message and return ONLY valid JSON.

Required JSON format:
{
	"verdict": "scam" | "safe" | "uncertain",
	"explanation": "short explanation in simple English",
	"suspicious_signs": ["sign 1", "sign 2", "sign 3"]
}

Rules:
- Keep explanation under 45 words.
- suspicious_signs must have at most 3 items.
- Do not include markdown or code fences.
- Use "scam" only when there are clear fraud/phishing indicators.
- Use "safe" when the text appears normal or harmless.
- Use "uncertain" only if there is not enough context to decide.

Message:
$message
''';

    final raw = await GroqService.instance.generateText(prompt);
    final parsed = tryParseAiJson(raw);
    if (parsed == null) {
      return _analyzeWithKeywords(message.toLowerCase());
    }

    final verdict = (parsed['verdict'] ?? '').toString().toLowerCase();
    final explanation = (parsed['explanation'] ?? '').toString().trim();
    final signs = (parsed['suspicious_signs'] is List)
        ? (parsed['suspicious_signs'] as List)
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .take(3)
              .toList()
        : <String>[];

    final isScam = verdict == 'scam';
    final isUncertain = verdict == 'uncertain';
    final explanationText = explanation.isNotEmpty
        ? explanation
        : 'This message includes patterns often used in fraud attempts.';

    final resultText = isScam
        ? 'This looks like a SCAM!\n\n$explanationText'
              '${signs.isNotEmpty ? '\n\nSuspicious signs: ${signs.join(", ")}.' : ''}'
              '\n\nDo NOT click any links. Do NOT share your password or bank details. Delete this message and stay safe!'
        : isUncertain
        ? 'This might be risky.\n\n$explanationText'
              '${signs.isNotEmpty ? '\n\nPossible signs: ${signs.join(", ")}.' : ''}'
              '\n\nTreat this carefully and verify with the official source before taking action.'
        : 'This message looks safe.\n\n${explanation.isNotEmpty ? explanation : 'No strong scam patterns were detected.'}'
              '\n\nStill be careful: never share your password, OTP, or bank details.';

    return ScamAnalysisResult(
      isScam: isScam,
      isUncertain: isUncertain,
      resultText: resultText,
    );
  }

  ScamAnalysisResult _analyzeWithKeywords(String text) {
    final foundKeywords = _scamKeywords
        .where((keyword) => text.contains(keyword))
        .toList();

    final isScam = foundKeywords.isNotEmpty;
    final resultText = isScam
        ? 'This looks like a SCAM!\n\nWe found suspicious words: ${foundKeywords.take(3).join(", ")}.\n\nDo NOT click any links. Do NOT share your password or bank details. Delete this message and stay safe!'
        : 'This message looks safe.\n\nWe did not find any obvious scam signs. But always be careful - never share your passwords or bank details with anyone, even if they seem trustworthy.';

    return ScamAnalysisResult(
      isScam: isScam,
      isUncertain: false,
      resultText: resultText,
    );
  }
}
