import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../player_provider.dart';

class BufferingIndicator extends StatelessWidget {
  const BufferingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final buffering =
            ref.watch(playerStateProvider.select((s) => s.buffering));

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
      },
    );
  }
}
