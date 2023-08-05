import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

class VideoWidget extends StatelessWidget {
  final bool expandVideo;
  final double aspectRatio;
  final Duration currentPosition;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VideoPlayerController playerController;

  const VideoWidget(
    this.playerController, {
    super.key,
    required this.expandVideo,
    required this.aspectRatio,
    required this.currentPosition,
    required this.onBack,
    required this.onForward,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: expandVideo ? BoxFit.fitWidth : BoxFit.contain,
        child: SizedBox(
          width: playerController.value.size.width,
          height: playerController.value.size.height,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(
              playerController,
            ),
          ),
        ),
      ),
    );
  }
}
