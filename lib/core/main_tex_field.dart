import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:techbuddy/core/constants.dart';
import 'package:techbuddy/services/web_speech_bridge.dart';
import 'package:techbuddy/widgets/techbuddy_text_input.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MainTexField extends StatefulWidget {
  const MainTexField({
    super.key,
    required this.onPromptSubmitted,
    this.horizontalInset = 20,
    this.resetNonce = 0,
  });

  final Future<void> Function(String prompt) onPromptSubmitted;
  final double horizontalInset;
  final int resetNonce;

  @override
  State<MainTexField> createState() => _MainTexFieldState();
}

class _MainTexFieldState extends State<MainTexField> {
  static const String _idleVoiceStatus = 'Tap the mic to speak';
  static const String _stoppedVoiceStatus = 'Voice input stopped';
  static const String _listeningVoiceStatus = 'Listening...';

  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  final SpeechToText _speechToText = SpeechToText();
  final WebSpeechFallback _webSpeech = WebSpeechFallback();

  late final bool _speechSupported;
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _useWebFallback = false;
  String _voiceStatus = _idleVoiceStatus;

  @override
  void initState() {
    super.initState();
    _speechSupported =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void dispose() {
    _webSpeech.stop();
    _speechToText.stop();
    _promptFocusNode.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MainTexField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetNonce != widget.resetNonce) {
      _promptController.clear();
    }
  }

  Future<void> _initSpeech() async {
    if (!_speechSupported) {
      _speechEnabled = false;
      if (mounted) {
        setState(() {});
      }
      return;
    }

    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() {
                _isListening = false;
                _voiceStatus = _idleVoiceStatus;
              });
            }
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _voiceStatus = _stoppedVoiceStatus;
            });
          }
        },
      );
    } catch (_) {
      _speechEnabled = false;
    }

    if (!_speechEnabled && kIsWeb && _webSpeech.isSupported) {
      _speechEnabled = await _webSpeech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
              _voiceStatus = _idleVoiceStatus;
            });
          }
        },
        onResult: (words, isFinal) {
          if (!mounted) return;
          setState(() {
            _promptController.text = words;
            _promptController.selection = TextSelection.collapsed(
              offset: _promptController.text.length,
            );
            _isListening = !isFinal;
          });
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _voiceStatus = _stoppedVoiceStatus;
          });
        },
      );
      _useWebFallback = _speechEnabled;
    } else {
      _useWebFallback = false;
    }

    if (!mounted) {
      return;
    }

    if (!_speechEnabled) {
      _voiceStatus = _speechUnavailableMessage();
      setState(() {});
      return;
    }

    setState(() {});
  }

  String _speechUnavailableMessage() {
    return kIsWeb
        ? 'Chrome voice needs mic permission and localhost/https'
        : 'Voice input is not available here';
  }

  Future<void> _toggleListening() async {
    if (!_speechSupported) {
      return;
    }

    if (_isListening) {
      if (_useWebFallback) {
        await _webSpeech.stop();
      } else {
        await _speechToText.stop();
      }
      if (mounted) {
        setState(() {
          _isListening = false;
          _voiceStatus = _idleVoiceStatus;
        });
      }
      return;
    }

    if (!_speechEnabled) {
      await _initSpeech();
    }

    if (!_speechEnabled) {
      if (mounted) {
        setState(() {
          _voiceStatus = _speechUnavailableMessage();
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isListening = true;
      _voiceStatus = _listeningVoiceStatus;
    });

    if (_useWebFallback) {
      await _webSpeech.start();
      return;
    }

    await _speechToText.listen(
      listenMode: ListenMode.confirmation,
      partialResults: true,
      pauseFor: const Duration(seconds: 2),
      listenFor: const Duration(seconds: 30),
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _promptController.text = result.recognizedWords;
          _promptController.selection = TextSelection.collapsed(
            offset: _promptController.text.length,
          );
          _isListening = result.finalResult ? false : _isListening;
        });
      },
    );
  }

  Future<void> _submitPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      return;
    }
    _promptController.clear();
    if (!mounted) return;
    await widget.onPromptSubmitted(prompt);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _promptFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalInset),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          constraints: BoxConstraints(minHeight: height * 0.14),
          padding: const EdgeInsets.fromLTRB(14, 15, 14, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.18)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TechBuddyTextInput(
                controller: _promptController,
                focusNode: _promptFocusNode,
                hintText: 'Ask Your Buddy Anything...',
                textStyle: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                ),
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                sendIconColor: AppColors.primary,
                onSubmitted: (_) => _submitPrompt(),
                onSendPressed: _submitPrompt,
                trailingAction: Tooltip(
                  message: _speechSupported
                      ? (_isListening ? 'Stop listening' : 'Tap to speak')
                      : 'Voice input unavailable on this device',
                  child: InkWell(
                    onTap: _speechSupported ? _toggleListening : null,
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: !_speechSupported
                            ? AppColors.background
                            : _isListening
                            ? Colors.redAccent
                            : AppColors.background,
                        border: Border.all(
                          color: !_speechSupported
                              ? AppColors.textMuted.withOpacity(0.2)
                              : _isListening
                              ? Colors.redAccent.withOpacity(0.25)
                              : AppColors.primary.withOpacity(0.16),
                        ),
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none_rounded,
                        color: _speechSupported
                            ? (_isListening
                                  ? Colors.redAccent
                                  : AppColors.primary)
                            : AppColors.textMuted,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    _voiceStatus,
                    key: ValueKey<String>(_voiceStatus),
                    style: TextStyle(
                      color: _isListening
                          ? AppColors.primary
                          : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
