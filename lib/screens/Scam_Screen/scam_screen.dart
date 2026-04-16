// ignore_for_file: unused_element

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../services/groq_service.dart';
import 'services/scam_detection.dart';
import 'widgets/TipCard.dart';

class ScamScreen extends StatefulWidget {
  const ScamScreen({super.key, this.onBackRequested});

  final VoidCallback? onBackRequested;

  @override
  State<ScamScreen> createState() => _ScamScreenState();
}

class _ScamScreenState extends State<ScamScreen> {
  final ScamDetectionService _scamDetectionService = ScamDetectionService();
  final TextEditingController _controller = TextEditingController();
  static const List<String> _tipIcons = <String>[
    '🎁',
    '🔐',
    '⏰',
    '🔗',
    '📞',
    '💳',
  ];
  static const List<String> _fallbackTips = <String>[
    '"You won a prize!" - Real prizes rarely come from random messages.',
    'Asking for your password or OTP - Never share these with anyone.',
    '"Act now or lose it!" - Scammers create fake urgency to rush you.',
    'Suspicious links - Never click links from unknown senders.',
    'Unknown caller asking money transfer - Verify with family first.',
    'Bank detail update messages - Call official support numbers only.',
  ];

  String? _resultText;
  bool _isScam = false;
  bool _isUncertain = false;
  bool _isLoading = false;
  bool _hasResult = false;
  bool _isLoadingTips = true;
  List<_ScamTip> _commonScamTips = const <_ScamTip>[];

  @override
  void initState() {
    super.initState();
    _loadCommonScamTips();
  }

  Future<void> _loadCommonScamTips() async {
    final aiTips = await _fetchAiScamTips();
    final resolved = aiTips.isNotEmpty ? aiTips : _fallbackScamTips();
    if (!mounted) {
      return;
    }
    setState(() {
      _commonScamTips = resolved.take(4).toList();
      _isLoadingTips = false;
    });
  }

  Future<List<_ScamTip>> _fetchAiScamTips() async {
    if (!GroqService.instance.isConfigured) {
      return <_ScamTip>[];
    }

    const prompt = '''Generate 6 practical scam warning signs for senior users.
Return ONLY valid JSON in this exact format:
{"tips": ["tip 1", "tip 2", "tip 3", "tip 4", "tip 5", "tip 6"]}
Rules:
- Each tip under 16 words.
- Keep language simple and clear.
- No markdown.
''';

    try {
      final raw = await GroqService.instance.generateText(prompt);
      final decoded = _scamDetectionService.tryParseAiJson(raw);
      final tipsRaw = decoded?['tips'];
      if (tipsRaw is! List) {
        return <_ScamTip>[];
      }

      final tips = tipsRaw
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();

      return List<_ScamTip>.generate(tips.length, (index) {
        return _ScamTip(
          icon: _tipIcons[index % _tipIcons.length],
          tip: tips[index],
        );
      });
    } catch (_) {
      return <_ScamTip>[];
    }
  }

  List<_ScamTip> _fallbackScamTips() {
    final shuffled = List<String>.from(_fallbackTips)..shuffle();
    return List<_ScamTip>.generate(shuffled.length, (index) {
      return _ScamTip(
        icon: _tipIcons[index % _tipIcons.length],
        tip: shuffled[index],
      );
    });
  }

  Future<void> _checkScam() async {
    final inputText = _controller.text.trim();
    final normalizedText = inputText.toLowerCase();

    if (normalizedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste a message first!'),
          backgroundColor: AppColors.secondary,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasResult = false;
    });

    final analysis = await _scamDetectionService.analyze(inputText);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _hasResult = true;
      _isScam = analysis.isScam;
      _isUncertain = analysis.isUncertain;
      _resultText = analysis.resultText;
    });
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _hasResult = false;
      _isScam = false;
      _isUncertain = false;
      _isLoading = false;
      _resultText = null;
    });
  }

  void _handleBackPressed() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
      return;
    }
    widget.onBackRequested?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.cardBg,
        surfaceTintColor: AppColors.cardBg,
        shadowColor: AppColors.textDark.withOpacity(0.14),
        elevation: 8,
        title: const Text(
          'Scam Checker 🛡️',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(
                  color: const Color(0xFFFBBF24).withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Received a suspicious message? Paste it below and we will check if it is a scam.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF92400E),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Paste the message here:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 6,
                style: const TextStyle(fontSize: 16, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText:
                      'Example: Congratulations! You have won a prize. Click here to claim now...',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: SizedBox(
                width: 280,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkScam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Check This Message ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_hasResult)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isScam
                      ? AppColors.dangerBg
                      : _isUncertain
                      ? const Color(0xFFFFF7E6)
                      : AppColors.successBg,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  border: Border.all(
                    color: _isScam
                        ? const Color(0xFFFCA5A5)
                        : _isUncertain
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF6EE7B7),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isScam
                          ? '🚨 WARNING: This is a Scam!'
                          : _isUncertain
                          ? '⚠️ CAUTION: Needs Verification'
                          : '✅ This looks Safe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _isScam
                            ? AppColors.dangerText
                            : _isUncertain
                            ? const Color(0xFF92400E)
                            : AppColors.successText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _resultText!,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: _isScam
                            ? AppColors.dangerText
                            : _isUncertain
                            ? const Color(0xFF92400E)
                            : AppColors.successText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _reset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isScam
                                ? const Color(0xFFFCA5A5)
                                : _isUncertain
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF6EE7B7),
                          ),
                        ),
                        child: Text(
                          'Check another message',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _isScam
                                ? AppColors.dangerText
                                : _isUncertain
                                ? const Color(0xFF92400E)
                                : AppColors.successText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            const Text(
              'Common Scam Signs:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingTips)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                ),
              )
            else
              ..._commonScamTips.map(
                (tip) => TipCard(icon: tip.icon, tip: tip.tip),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScamTip {
  const _ScamTip({required this.icon, required this.tip});

  final String icon;
  final String tip;
}
