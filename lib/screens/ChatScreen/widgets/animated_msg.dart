import 'package:flutter/material.dart';

class AnimatedMessageEntry extends StatelessWidget {
	const AnimatedMessageEntry({super.key, required this.child});

	final Widget child;

	@override
	Widget build(BuildContext context) {
		return TweenAnimationBuilder<double>(
			duration: const Duration(milliseconds: 260),
			tween: Tween(begin: 0, end: 1),
			curve: Curves.easeOut,
			builder: (context, value, animatedChild) {
				final eased = Curves.easeOut.transform(value);
				return Opacity(
					opacity: eased,
					child: Transform.translate(
						offset: Offset(0, (1 - eased) * 10),
						child: animatedChild,
					),
				);
			},
			child: child,
		);
	}
}
