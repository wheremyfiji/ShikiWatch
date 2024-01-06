import 'package:flutter/material.dart';

class BufferingIndicator extends StatelessWidget {
  final bool buffering;

  const BufferingIndicator({
    super.key,
    required this.buffering,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0.0,
          end: buffering ? 1.0 : 0.0,
        ),
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 50),
        builder: (context, value, child) {
          if (value > 0.0) {
            return Opacity(
              opacity: value,
              child: child!,
            );
          }
          return const SizedBox.shrink();
        },
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
