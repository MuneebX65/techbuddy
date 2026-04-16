import 'package:flutter/material.dart';
import 'package:techbuddy/core/constants.dart';
import 'package:techbuddy/services/groq_service.dart';
import 'package:techbuddy/services/app_preferences.dart';
import 'package:techbuddy/core/main_tex_field.dart';
import 'package:techbuddy/screens/ChatScreen/widgets/animated_msg.dart';
import 'package:techbuddy/screens/ChatScreen/widgets/typing_ind.dart';
import 'package:techbuddy/screens/ChatScreen/widgets/chat_bubble.dart';
import 'package:techbuddy/screens/ChatScreen/widgets/welcome_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.initialPrompt});

  final String? initialPrompt;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final initialPrompt = widget.initialPrompt?.trim() ?? '';
    if (initialPrompt.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendPrompt(initialPrompt);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendPrompt(String prompt) async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _messages.add(_ChatMessage(text: prompt, isUser: true));
    });
    await AppPreferences.incrementChatCount();
    _scrollToBottom();

    if (!GroqService.instance.isConfigured) {
      setState(() {
        _isLoading = false;
        _messages.add(
          const _ChatMessage(
            text: 'Set GROQ_API_KEY to use Groq.',
            isUser: false,
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    try {
      final priorMessages = _messages.isNotEmpty
          ? _messages.sublist(0, _messages.length - 1)
          : const <_ChatMessage>[];

      final history = priorMessages
          .map(
            (m) => <String, String>{
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            },
          )
          .toList();

      final reply = await GroqService.instance.generateChatReply(
        prompt: prompt,
        history: history,
      );
      final formattedReply = _formatAssistantReply(reply);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: formattedReply, isUser: false));
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: 'Groq error: $error', isUser: false));
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  String _formatAssistantReply(String raw) {
    final cleaned = raw.replaceAll('**', '').replaceAll('\r\n', '\n').trim();

    final lines = cleaned.split('\n');

    if (lines.length == 1 && cleaned.contains('. ')) {
      final sentences = cleaned
          .split(RegExp(r'(?<=[.!?])\s+'))
          .map((sentence) => sentence.trim())
          .where((sentence) => sentence.isNotEmpty)
          .toList();

      if (sentences.length >= 2) {
        return sentences
            .map((sentence) => '• ${sentence.replaceAll('*', '')}')
            .join('\n');
      }
    }

    final formatted = lines.map((line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        return '';
      }

      if (RegExp(r'^[-*]\s+').hasMatch(trimmed)) {
        final body = trimmed.replaceFirst(RegExp(r'^[-*]\s+'), '').trim();
        return '• $body';
      }

      if (RegExp(r'^\d+\.\s*\*').hasMatch(trimmed)) {
        return trimmed.replaceAll('*', '');
      }

      return '• ${trimmed.replaceAll('*', '')}';
    }).toList();

    return formatted.join('\n').trim();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF2F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        surfaceTintColor: AppColors.cardBg,
        shadowColor: AppColors.textDark.withOpacity(0.14),
        elevation: 8,
        title: const Text(
          'TechBuddy Chat',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEAF0FF), Color(0xFFF8F9FC)],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty && !_isLoading
                    ? const WelcomeState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isLoading && index == _messages.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TypingIndicatorBubble(),
                              ),
                            );
                          }

                          final message = _messages[index];
                          return AnimatedMessageEntry(
                            key: ValueKey('m_${index}_${message.isUser}'),
                            child: ChatBubble(
                              text: message.text,
                              isUser: message.isUser,
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              MainTexField(onPromptSubmitted: _sendPrompt),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}
