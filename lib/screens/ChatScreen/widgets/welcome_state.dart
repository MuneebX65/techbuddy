import 'package:flutter/material.dart';

class WelcomeState extends StatelessWidget {
  const WelcomeState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0.95, end: 1),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'Ask your question. I will reply with short and clear guidance.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF263046),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
