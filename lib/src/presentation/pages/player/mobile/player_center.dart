import 'package:flutter/material.dart';

import 'animated_play_pause.dart';

class PlayerCenter extends StatelessWidget {
  final bool isError;
  final bool isPlaying;

  final VoidCallback onPlayPause;
  final VoidCallback onRetry;

  const PlayerCenter({
    super.key,
    required this.isError,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!isError) ...[
            // GestureDetector(
            //   onLongPress: controller.backMore,
            //   child: IconButton(
            //     color: Colors.white,
            //     iconSize: 36,
            //     icon: const Icon(Icons.replay_10),
            //     onPressed: controller.back,
            //   ),
            // ),
            IconButton(
              color: Colors.white,
              iconSize: 48,
              icon: AnimatedPlayPause(
                playing: isPlaying,
                size: 48,
                color: Colors.white,
              ),
              onPressed: onPlayPause,
            ),
            // GestureDetector(
            //   onLongPress: controller.forwardMore,
            //   //onDoubleTap: controller.forwardMore,
            //   child: IconButton(
            //     color: Colors.white,
            //     iconSize: 36,
            //     icon: const Icon(Icons.forward_10),
            //     onPressed: controller.forward,
            //   ),
            // ),
          ],
          if (isError) ...[
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Text('Ошибка\nвоспроизведения'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
