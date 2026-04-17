import 'package:flutter/material.dart';
import 'package:techbuddy/core/constants.dart';
import 'package:techbuddy/screens/ChatScreen/chat_screen.dart';
import 'package:techbuddy/services/app_preferences.dart';
import 'package:techbuddy/screens/HomeScreen/widgets/Prompt_chips.dart';
import 'package:techbuddy/core/main_tex_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Friend';

  static const List<_SmartAction> _smartActions = [
    _SmartAction(
      icon: Icons.shield_outlined,
      title: 'Scam Shield Check',
      prompt: 'Give me one fast scam check before I click a link.',
    ),
    _SmartAction(
      icon: Icons.text_snippet_outlined,
      title: 'Message Polisher',
      prompt: 'Help me rewrite a message in clear and polite English.',
    ),
    _SmartAction(
      icon: Icons.translate_outlined,
      title: 'Easy Translator',
      prompt: 'Translate this sentence into simple Urdu and English.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppPreferences.userNameNotifier.addListener(_onUserNameChanged);
    _loadUserName();
  }

  @override
  void dispose() {
    AppPreferences.userNameNotifier.removeListener(_onUserNameChanged);
    super.dispose();
  }

  void _onUserNameChanged() {
    final latestName = AppPreferences.userNameNotifier.value;
    if (!mounted || latestName == null || latestName.isEmpty) {
      return;
    }
    if (_userName == latestName) {
      return;
    }
    setState(() {
      _userName = latestName;
    });
  }

  Future<void> _loadUserName() async {
    final savedName = await AppPreferences.getUserName();
    if (!mounted || savedName == null) {
      return;
    }
    setState(() {
      _userName = savedName;
    });
  }

  Future<void> _openChatFromPrompt(String prompt) async {
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ChatScreen(initialPrompt: prompt);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(fadeAnimation);

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
      ),
    );
  }

  Widget _buildSmartActionsPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF3FCF8), Color(0xFFE8F2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology_alt_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'AI Power Moves',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Try one tap actions to start a helpful conversation instantly.',
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          ..._smartActions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openChatFromPrompt(action.prompt),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.78),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          action.icon,
                          color: AppColors.primary,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          action.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        surfaceTintColor: AppColors.cardBg,
        shadowColor: AppColors.textDark.withOpacity(0.14),
        elevation: 8,
        title: const Text(
          'TechBuddy',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi $_userName',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Where should we start?',
                        style: TextStyle(
                          fontSize: 46,
                          height: 1.05,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 22),
                      MainTexField(
                        onPromptSubmitted: _openChatFromPrompt,
                        horizontalInset: 0,
                      ),
                      const SizedBox(height: 12),
                      PromptChips(onChipTap: _openChatFromPrompt),
                      _buildSmartActionsPanel(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmartAction {
  final IconData icon;
  final String title;
  final String prompt;

  const _SmartAction({
    required this.icon,
    required this.title,
    required this.prompt,
  });
}
