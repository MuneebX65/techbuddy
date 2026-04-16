import 'package:flutter/material.dart';

import '../../core/constants.dart';
import 'service_helper.dart';
import 'widgets/cards_ui.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.lessonId,
  });

  final Map<String, dynamic> lesson;
  final int lessonId;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _currentStep = 0;
  late final List<String> _steps = LessonDetailServiceHelper.parseSteps(
    widget.lesson,
  );

  Future<void> _nextStep() async {
    final isCompleted =
        await LessonDetailServiceHelper.handleNextStepCompletion(
          currentStep: _currentStep,
          totalSteps: _steps.length,
          lessonId: widget.lessonId,
        );

    if (isCompleted) {
      showLessonCompletionDialog(
        context: context,
        lessonTitle: (widget.lesson['title'] as String?) ?? 'Lesson',
      );
      return;
    }

    setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final totalSteps = _steps.length;
    final progress = (_currentStep + 1) / totalSteps;
    final stepText = _steps[_currentStep];
    final lessonColor = (lesson['color'] as Color?) ?? AppColors.primary;
    final lessonIcon = (lesson['icon'] as String?) ?? '📘';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        surfaceTintColor: AppColors.cardBg,
        shadowColor: AppColors.textDark.withOpacity(0.14),
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          (lesson['title'] as String?) ?? 'Lesson',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            LessonProgressHeader(
              progress: progress,
              currentStep: _currentStep,
              totalSteps: totalSteps,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LessonStepContentCard(
                lessonColor: lessonColor,
                lessonIcon: lessonIcon,
                currentStep: _currentStep,
                totalSteps: totalSteps,
                stepText: stepText,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radius,
                            ),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_ios, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Previous',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _nextStep();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == totalSteps - 1
                                ? 'Finish! 🎉'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_currentStep < totalSteps - 1) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
