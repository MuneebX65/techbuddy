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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
