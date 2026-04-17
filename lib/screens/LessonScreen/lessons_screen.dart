// ignore_for_file: unused_element

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/main_tex_field.dart';
import '../Lesson_Detail_Screen/lesson_detail_screen.dart';
import 'mappers/lesson_topic_mapper.dart';
import 'models/lesson_model.dart';
import 'services/lesson_generation_service.dart';
import 'widgets/topic_tag.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key, this.onBackRequested});

  final VoidCallback? onBackRequested;

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final LessonGenerationService _lessonGenerationService =
      LessonGenerationService();
  bool _isLoadingDailyChips = true;
  bool _isGeneratingLesson = false;
  int _promptResetNonce = 0;
  List<String> _dailyTopics = const <String>[];

  @override
  void initState() {
    super.initState();
    _loadInitialTopics();
  }

  Future<void> _loadInitialTopics() async {
    final resolvedTopics = await _lessonGenerationService.loadDailyTopics();
    if (!mounted) return;
    setState(() {
      _dailyTopics = resolvedTopics;
      _isLoadingDailyChips = false;
    });
  }

  Future<void> _handleCreateLessonFromTopic(String topic, int lessonId) async {
    if (_isGeneratingLesson) {
      return;
    }

    setState(() {
      _isGeneratingLesson = true;
    });

    final lesson = await LessonModel.createLessonFromTopic(
      topic: topic,
      generateLessonWithAi: _lessonGenerationService.generateLessonWithAi,
      fallbackLesson: _lessonGenerationService.fallbackLesson,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isGeneratingLesson = false;
    });

    if (!mounted || lesson == null) {
      return;
    }

    await _showLessonPreview(lesson, lessonId);
  }

  Future<void> _handleCreateCustomLessonFromPrompt(String topic) {
    setState(() {
      _promptResetNonce++;
    });
    final stableId = LessonModel.createCustomLessonFromPrompt(topic);
    return _handleCreateLessonFromTopic(topic, stableId);
  }

  Widget _buildTopicCard(String topic, int idx) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 280 + (idx * 60)),
      tween: Tween(begin: 0, end: 1),
      builder: (ctx, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 14),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _isGeneratingLesson
            ? null
            : () => _handleCreateLessonFromTopic(topic, idx),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD1FAE5), width: 1.6),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    LessonTopicMapper.topicEmoji(topic),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      topic,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                LessonTopicMapper.topicSummary(topic),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TopicTag(
                    label: LessonTopicMapper.topicLevel(topic),
                    icon: Icons.school_outlined,
                  ),
                  TopicTag(
                    label: LessonTopicMapper.topicDuration(idx),
                    icon: Icons.schedule_outlined,
                  ),
                  const TopicTag(
                    label: '7-8 steps',
                    icon: Icons.list_alt_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLessonPreview(Map<String, dynamic> lesson, int lessonId) {
    final steps = _lessonGenerationService.extractStringList(lesson['steps']);
    final title = (lesson['title'] as String?) ?? 'Lesson';
    final icon = (lesson['icon'] as String?) ?? '📘';
    final stepCount = steps.length;
    final firstStep = steps.isNotEmpty ? steps.first : 'Start the lesson';
    final color = (lesson['color'] as Color?) ?? AppColors.primary;

    if (!mounted) return Future<void>.value();

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        backgroundColor: Colors.white,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$stepCount Steps',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'First Step:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      firstStep,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textDark,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LessonDetailScreen(
                                lesson: lesson,
                                lessonId: lessonId,
                              ),
                            ),
                          ).then((_) {
                            if (!mounted) {
                              return;
                            }
                            setState(() {
                              _promptResetNonce++;
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start Lesson',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBackPressed() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
      return;
    }
    widget.onBackRequested?.call();
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
        centerTitle: true,

        title: const Text(
          'AI Learning Topics',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today'
                          's Fresh Topics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Refreshed on every visit • Or create your own lesson',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('🎯 ', style: TextStyle(fontSize: 22)),
                Expanded(
                  child: Text(
                    'Random Topics',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_isLoadingDailyChips)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(strokeWidth: 2.5),
                      const SizedBox(height: 12),
                      Text(
                        'Loading new topics...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: _dailyTopics.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final topic = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildTopicCard(topic, idx),
                  );
                }).toList(),
              ),
            const SizedBox(height: 28),
            Row(
              children: [
                const Text('✏️ ', style: TextStyle(fontSize: 22)),
                Expanded(
                  child: Text(
                    'Custom Lesson',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AbsorbPointer(
              absorbing: _isGeneratingLesson,
              child: Opacity(
                opacity: _isGeneratingLesson ? 0.7 : 1,
                child: Center(
                  child: MainTexField(
                    onPromptSubmitted: _handleCreateCustomLessonFromPrompt,
                    resetNonce: _promptResetNonce,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
