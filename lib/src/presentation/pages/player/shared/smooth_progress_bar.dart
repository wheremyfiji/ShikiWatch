import 'package:flutter/material.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SmoothProgressBar extends HookWidget {
  final Duration progress;
  final Duration buffered;
  final Duration total;

  final bool isPlaying;

  final void Function() onDragUpdate;
  final void Function(Duration)? onSeek;

  const SmoothProgressBar({
    super.key,
    required this.progress,
    required this.buffered,
    required this.total,
    required this.isPlaying,
    required this.onDragUpdate,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final animationController =
        useAnimationController(duration: total, keys: [total]);

    final targetRelativePosition =
        progress.inMilliseconds / total.inMilliseconds;

    final currentPosition = Duration(
        milliseconds:
            (animationController.value * total.inMilliseconds).round());

    final offset = progress - currentPosition;

    useValueChanged(
      progress,
      (_, __) {
        final correct = isPlaying &&
            offset.inMilliseconds > -500 &&
            offset.inMilliseconds < -50;
        final correction = const Duration(milliseconds: 500) - offset;
        final targetPos =
            correct ? animationController.value : targetRelativePosition;
        final duration = correct ? total + correction : total;

        animationController.duration = duration;
        isPlaying
            ? animationController.forward(from: targetPos)
            : animationController.value = targetRelativePosition;
        return true;
      },
    );

    useValueChanged(
      isPlaying,
      (_, __) => isPlaying
          ? animationController.forward(from: targetRelativePosition)
          : animationController.stop(),
    );

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final millis = animationController.value * total.inMilliseconds;

        return ProgressBar(
          progress: Duration(milliseconds: millis.round()),
          buffered: buffered,
          total: total,
          onDragUpdate: (_) {
            onDragUpdate();
          },
          onSeek: onSeek,
          timeLabelTextStyle: const TextStyle(color: Colors.white),
          thumbRadius: 8,
          timeLabelPadding: 4,
          timeLabelLocation: TimeLabelLocation.below,
          timeLabelType: TimeLabelType.totalTime,
        );
      },
    );
  }
}
