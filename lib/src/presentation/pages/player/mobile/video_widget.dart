import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:double_tap_player_view/double_tap_player_view.dart';

import '../anime_player_page.dart';
import 'custom_swipe_overlay.dart';

class VideoWidget extends StatelessWidget {
  final bool enableSwipe;
  final bool expandVideo;
  final double aspectRatio;
  final Duration currentPosition;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VideoPlayerController playerController;

  const VideoWidget(
    this.playerController, {
    super.key,
    required this.enableSwipe,
    required this.expandVideo,
    required this.aspectRatio,
    required this.currentPosition,
    required this.onBack,
    required this.onForward,
  });

  @override
  Widget build(BuildContext context) {
    return DoubleTapPlayerView(
      doubleTapConfig: DoubleTapConfig.create(
        backDrop: Colors.black54,
        ovalColor: Colors.transparent,
        rippleColor: Colors.transparent,
        fadeTime: switchDuration,
        backDropAnimDuration: Duration.zero,
        expansionHoldingTime: Duration.zero,
        labelBuilder: (lr, tapCount) {
          String text = '';

          switch (lr) {
            case Lr.LEFT:
              text = '-10 сек.';
              break;
            case Lr.RIGHT:
              text = '+10 сек.';
              break;
            default:
          }

          return text;
        },
        onDoubleTap: (lr) {
          switch (lr) {
            case Lr.LEFT:
              onBack();
              break;
            case Lr.RIGHT:
              onForward();
              break;
            default:
          }
        },
      ),
      swipeConfig: enableSwipe
          ? SwipeConfig.create(
              backDrop: Colors.black54,
              overlayBuilder: (data) => CustomSwipeOverlay(
                data: data,
                currentPos: currentPosition,
              ),
              onSwipeStart: (dx) {
                //debugPrint('swipe onSwipeStart: $dx');
                playerController.pause();
              },
              onSwipeCancel: () {
                //debugPrint('swipe onSwipeCancel');
                playerController.play();
              },
              onSwipeEnd: (data) async {
                if (data == null) {
                  return;
                }
                //debugPrint(
                //    'swipe onSwipeEnd: ${data.startDx} | ${data.currentDx}');

                await playerController.seekTo(
                  playerController.value.position +
                      Duration(
                        seconds: (data.currentDx - data.startDx).toInt(),
                      ),
                );
                await playerController.play();
              },
            )
          : null,
      child: SizedBox.expand(
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
      ),
    );
  }
}
