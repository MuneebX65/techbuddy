import 'package:flutter/material.dart';
import 'package:techbuddy/core/constants.dart';

class TechBuddyTextInput extends StatelessWidget {
  const TechBuddyTextInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    required this.onSendPressed,
    this.textInputAction = TextInputAction.send,
    this.minLines = 1,
    this.maxLines = 2,
    this.enabled = true,
    this.focusNode,
    this.textStyle = const TextStyle(color: AppColors.textDark, fontSize: 16),
    this.hintStyle = const TextStyle(
      color: AppColors.textMuted,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    this.sendIconColor = AppColors.primary,
    this.trailingAction,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSendPressed;
  final TextInputAction textInputAction;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final Color sendIconColor;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      style: textStyle,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        border: InputBorder.none,
        isCollapsed: true,
        suffixIcon: trailingAction == null
            ? IconButton(
                onPressed: enabled ? onSendPressed : null,
                icon: Icon(Icons.send_rounded, color: sendIconColor, size: 20),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  trailingAction!,
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: enabled ? onSendPressed : null,
                    icon: Icon(
                      Icons.send_rounded,
                      color: sendIconColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
        suffixIconConstraints: const BoxConstraints(minHeight: 40),
      ),
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
    );
  }
}
