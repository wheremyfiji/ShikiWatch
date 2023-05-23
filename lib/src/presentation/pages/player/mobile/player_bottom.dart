import 'package:flutter/material.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class PlayerBottom extends StatelessWidget {
  final Duration progress;
  final Duration total;
  final Duration? buffered;

  final VoidCallback opSkip;
  final Function(Duration) onSeek;
  final VoidCallback onDragUpdate;

  const PlayerBottom({
    super.key,
    required this.progress,
    required this.total,
    required this.buffered,
    required this.opSkip,
    required this.onSeek,
    required this.onDragUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: opSkip,
                child: const Text('+ 125'),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ProgressBar(
              progress: progress,
              total: total,
              onDragUpdate: (_) => onDragUpdate(),
              thumbRadius: 8,
              timeLabelTextStyle: const TextStyle(color: Colors.white),
              buffered: buffered,
              timeLabelPadding: 4,
              onSeek: onSeek,
            ),
          ],
        ),
      ),
    );
  }
}
