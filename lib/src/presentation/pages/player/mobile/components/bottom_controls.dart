import 'package:flutter/material.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/shared.dart';
import '../../player_provider.dart';

class BottomControls extends ConsumerWidget {
  final PlayerProviderParameters p;
  final bool seekShowUI;
  final Duration seekTo;
  const BottomControls(
    this.p, {
    super.key,
    required this.seekShowUI,
    required this.seekTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(playerProvider(p));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 24,
        ),
        Expanded(
          child: ProgressBar(
            //progress: notifier.position,
            progress: seekShowUI ? seekTo : notifier.position,
            buffered: notifier.buffer,
            total: notifier.duration,
            onDragUpdate: (_) {
              if (notifier.hideController.isVisible) {
                notifier.hideController.show();
              }
            },
            onSeek: (p) {
              notifier.player.seek(p);
            },
            timeLabelTextStyle: const TextStyle(color: Colors.white),
            thumbRadius: 8,
            timeLabelPadding: 4,
            timeLabelLocation: TimeLabelLocation.below,
            timeLabelType: TimeLabelType.totalTime,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        IconButton(
          color: Colors.white,
          onPressed: () {
            notifier.player.seek(
              notifier.position + const Duration(seconds: 85),
            );
          },
          icon: const Icon(
            Icons.double_arrow_rounded,
          ),
          iconSize: 21,
          tooltip: 'Перемотать 125 секунд',
        ),
        IconButton(
          color: Colors.white,
          onPressed: notifier.changePlayerFit,
          icon: Icon(
            notifier.playerFit != BoxFit.contain
                ? Icons.close_fullscreen_rounded
                : Icons.open_in_full_rounded,
          ),
          iconSize: 21,
        ),
        // IconButton(
        //   onPressed: () =>
        //       MobilePlayerSettings.show(context),
        //   icon: const Icon(
        //     Icons.settings_rounded,
        //   ),
        //   iconSize: 21,
        //   color: Colors.white,
        // ),
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }
}
