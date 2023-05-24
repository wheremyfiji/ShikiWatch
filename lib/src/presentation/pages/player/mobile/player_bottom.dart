import 'package:flutter/material.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class PlayerBottom extends StatelessWidget {
  final Duration progress;
  final Duration total;
  final Duration? buffered;

  final VoidCallback opSkip;
  final Function(Duration) onSeek;
  final VoidCallback onDragUpdate;
  final VoidCallback onExpand;
  final bool expandVideo;

  const PlayerBottom({
    super.key,
    required this.progress,
    required this.total,
    required this.buffered,
    required this.opSkip,
    required this.onSeek,
    required this.onDragUpdate,
    required this.onExpand,
    required this.expandVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        //padding: const EdgeInsets.all(24),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 24,
            ),
            Expanded(
              child: ProgressBar(
                progress: progress,
                total: total,
                onDragUpdate: (_) => onDragUpdate(),
                buffered: buffered,
                onSeek: onSeek,
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
              onPressed: opSkip,
              icon: const Icon(
                Icons.double_arrow_rounded, //keyboard_double_arrow_right
              ),
              iconSize: 18,
              tooltip: 'Перемотать 125 секунд',
            ),
            IconButton(
              color: Colors.white,
              onPressed: onExpand,
              icon: Icon(
                expandVideo
                    ? Icons.close_fullscreen_rounded
                    : Icons.open_in_full_rounded,
              ),
              iconSize: 18,
            ),
            const SizedBox(
              width: 8,
            ),
          ],
        ),
      ),
    );
  }
}
