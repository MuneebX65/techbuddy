import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../service_helper.dart';
import 'detail_tag.dart';

Future<void> showLessonCompletionDialog({
  required BuildContext context,
  required String lessonTitle,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            'Great job!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You completed the "$lessonTitle" lesson!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Back to Lessons',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class LessonProgressHeader extends StatelessWidget {
  const LessonProgressHeader({
    super.key,
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
  });

  final double progress;
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${currentStep + 1} of $totalSteps steps',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class LessonStepContentCard extends StatelessWidget {
  const LessonStepContentCard({
    super.key,
    required this.lessonColor,
    required this.lessonIcon,
    required this.currentStep,
    required this.totalSteps,
    required this.stepText,
  });

  final Color lessonColor;
  final String lessonIcon;
  final int currentStep;
  final int totalSteps;
  final String stepText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: lessonColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(lessonIcon, style: const TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Step ${currentStep + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successText,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                DetailTag(
                  icon: Icons.timer_outlined,
                  label: LessonDetailServiceHelper.stepDuration(currentStep),
                ),
                DetailTag(
                  icon: Icons.category_outlined,
                  label: LessonDetailServiceHelper.stepCategory(stepText),
                ),
                DetailTag(
                  icon: Icons.flag_outlined,
                  label: '${currentStep + 1}/$totalSteps',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              stepText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            LessonTipBox(tipText: LessonDetailServiceHelper.stepTip(stepText)),
          ],
        ),
      ),
    );
  }
}

class LessonTipBox extends StatelessWidget {
  const LessonTipBox({super.key, required this.tipText});

  final String tipText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.lightbulb_outline,
              size: 18,
              color: Color(0xFF0369A1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tipText,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF0C4A6E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
