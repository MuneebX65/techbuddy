import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:techbuddy/core/constants.dart';
import 'package:techbuddy/services/groq_service.dart';

class PromptChips extends StatefulWidget {
  const PromptChips({super.key, this.onChipTap});

  final ValueChanged<String>? onChipTap;

  @override
  State<PromptChips> createState() => _PromptChipsState();
}

class _PromptChipsState extends State<PromptChips> {
  static const List<String> _fallbackPrompts = <String>[
    'How can I use WhatsApp safely?',
    'Show me one scam trick to avoid.',
    'Teach me Google Maps basics.',
    'How do I send photos clearly?',
    'Help me write a simple email.',
    'What should I check before UPI payment?',
    'How can I make my phone easier to read?',
    'Give me a confidence tip for today.',
  ];

  bool _isLoading = true;
  List<String> _chips = const <String>[];

  @override
  void initState() {
    super.initState();
    _loadPrompts();
  }

  Future<void> _loadPrompts() async {
    final aiPrompts = await _fetchAIPrompts();
    final prompts = aiPrompts.isNotEmpty
        ? aiPrompts
        : _fallbackShuffledPrompts();
    if (!mounted) {
      return;
    }
    setState(() {
      _chips = prompts.take(4).toList();
      _isLoading = false;
    });
  }

  Future<List<String>> _fetchAIPrompts() async {
    if (!GroqService.instance.isConfigured) {
      return <String>[];
    }

    const prompt =
        '''Generate 4 short beginner-friendly prompt suggestions for a tech assistant app.
Return ONLY valid JSON in this exact format:
{"chips": ["Prompt 1", "Prompt 2", "Prompt 3", "Prompt 4"]}
Rules:
- Keep each prompt under 8 words.
- Make each prompt practical and different.
- No markdown, no numbering.
''';

    try {
      final raw = await GroqService.instance.generateText(prompt);
      final cleaned = raw
          .trim()
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final decoded = cleaned.isEmpty ? null : _tryDecode(cleaned);
      if (decoded is! Map<String, dynamic>) {
        return <String>[];
      }
      final chips = decoded['chips'];
      if (chips is! List) {
        return <String>[];
      }
      return chips
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();
    } catch (_) {
      return <String>[];
    }
  }

  Object? _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  List<String> _fallbackShuffledPrompts() {
    final prompts = List<String>.from(_fallbackPrompts);
    prompts.shuffle();
    return prompts;
  }

  @override
  Widget build(BuildContext context) {
    final chips = _chips;
    final palettes = <List<Color>>[
      <Color>[const Color(0xFFFFFFFF), const Color(0xFFF0FDF4)],
      <Color>[const Color(0xFFFFFFFF), const Color(0xFFECFEFF)],
      <Color>[const Color(0xFFFFFFFF), const Color(0xFFEEF2FF)],
      <Color>[const Color(0xFFFFFFFF), const Color(0xFFFFF7ED)],
    ];

    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final chipWidth = (constraints.maxWidth - spacing) / 2;

        return Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            alignment: WrapAlignment.end,
            runAlignment: WrapAlignment.end,
            spacing: spacing,
            runSpacing: spacing,
            children: List<Widget>.generate(chips.length, (index) {
              final label = chips[index];
              final gradient = palettes[index % palettes.length];
              return SizedBox(
                width: chipWidth,
                child: Material(
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => widget.onChipTap?.call(label),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.16),
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
