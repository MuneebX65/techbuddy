import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:techbuddy/core/app_env.dart';

class GroqService {
  GroqService._();

  static final GroqService instance = GroqService._();

  static const String _apiKeyFromDefine = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  static String get _apiKey {
    final envKey = AppEnv.get('GROQ_API_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    return _apiKeyFromDefine.trim();
  }

  static String get _model {
    final modelFromEnv = AppEnv.get('GROQ_MODEL');
    return modelFromEnv.isNotEmpty ? modelFromEnv : 'llama-3.1-8b-instant';
  }

  static const String _assistantStylePrompt =
      'You are TechBuddy, an assistant for older adults. '
      'Give concise, practical answers in plain language. '
      'Keep responses to 3-5 short lines or up to 5 bullet points. '
      'Avoid long paragraphs, avoid jargon, and focus only on the asked task. '
      'If steps are needed, give only the minimum steps.';

  static const String _chatDetailedStylePrompt =
      'You are TechBuddy, a friendly digital guide for older adults. '
      'Answer in plain, supportive language with useful detail. '
      'When helpful, include step-by-step guidance and short examples. '
      'If the user asks a follow-up, use previous conversation context to continue naturally. '
      'Always answer in medium-length bullet points when possible. '
      'Aim for 4-7 bullets for most questions, with enough detail to be useful. '
      'Start with a brief one-line intro, then continue with bullets. '
      'Never use markdown formatting symbols like **, *, #, or code fences. '
      'If you need bullets, use plain bullet lines starting with a hyphen and space. '
      'Avoid jargon, avoid unnecessary verbosity, and keep advice safe and actionable.';

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> generateText(String prompt) async {
    if (_apiKey.isEmpty) {
      throw StateError('GROQ_API_KEY is not configured.');
    }

    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': 0.3,
        'max_tokens': 180,
        'messages': [
          {'role': 'system', 'content': _assistantStylePrompt},
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    final data = _tryParseJson(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final choices = data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final firstChoice = choices.first;
        if (firstChoice is Map<String, dynamic>) {
          final message = firstChoice['message'];
          if (message is Map<String, dynamic>) {
            final content = message['content'];
            if (content is String && content.trim().isNotEmpty) {
              return content.trim();
            }
          }
        }
      }
      return 'No response returned from Groq.';
    }

    final apiMessage = _extractErrorMessage(data);
    throw StateError('Groq API error (${response.statusCode}): $apiMessage');
  }

  Future<String> generateChatReply({
    required String prompt,
    required List<Map<String, String>> history,
  }) async {
    if (_apiKey.isEmpty) {
      throw StateError('GROQ_API_KEY is not configured.');
    }

    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final trimmedHistory = history.length > 16
        ? history.sublist(history.length - 16)
        : history;

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _chatDetailedStylePrompt},
      ...trimmedHistory,
      {'role': 'user', 'content': prompt},
    ];

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': 0.45,
        'max_tokens': 420,
        'messages': messages,
      }),
    );

    final data = _tryParseJson(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final choices = data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final firstChoice = choices.first;
        if (firstChoice is Map<String, dynamic>) {
          final message = firstChoice['message'];
          if (message is Map<String, dynamic>) {
            final content = message['content'];
            if (content is String && content.trim().isNotEmpty) {
              return content.trim();
            }
          }
        }
      }
      return 'No response returned from Groq.';
    }

    final apiMessage = _extractErrorMessage(data);
    throw StateError('Groq API error (${response.statusCode}): $apiMessage');
  }

  Map<String, dynamic> _tryParseJson(String raw) {
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
    } catch (_) {
      // Return an empty map for non-JSON responses.
    }
    return <String, dynamic>{};
  }

  String _extractErrorMessage(Map<String, dynamic> json) {
    final error = json['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return 'Request failed.';
  }
}
