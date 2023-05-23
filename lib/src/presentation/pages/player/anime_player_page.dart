//import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/anime_player_page_extra.dart';
import '../../providers/anime_player_provider.dart';
import '../../widgets/auto_hide.dart';
import 'mobile/animated_play_pause.dart';
import 'mobile/player_bottom.dart';
import 'mobile/player_header.dart';

// static const List<double> _examplePlaybackRates = <double>[
//   0.25,
//   0.5,
//   0.75,
//   1.0,
//   1.25,
//   1.5,
//   1.75,
//   2.0,
// ];

class AnimePlayerPage extends HookConsumerWidget {
  final AnimePlayerPageExtra data;

  const AnimePlayerPage({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.watch(playerControllerProvider(PlayerProviderParameters(
      studioId: data.studioId,
      shikimoriId: data.shikimoriId,
      episodeNumber: data.episodeNumber,
      animeName: data.animeName,
      imageUrl: data.imageUrl,
      studioName: data.studioName,
      studioType: data.studioType,
      episodeLink: data.episodeLink,
      episodeAdditInfo: data.additInfo,
      position: data.startPosition,
    )));

    //final statusBarHeight = MediaQuery.of(context).padding.top;
    //ui.window.padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: controller.streamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => PlayerError(e.toString()),
        data: (video) {
          return SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                SeekVideoWidget(
                  seekBackward: () => controller.back(),
                  seekForward: () => controller.forward(),
                  seekLongBackward: () => controller.backMore(),
                  seekLongForward: () => controller.forwardMore(),
                  child: Align(
                    child: controller.playerController.value.isInitialized
                        ? AspectRatio(
                            aspectRatio:
                                controller.playerController.value.aspectRatio,
                            child: VideoPlayer(
                              controller.playerController,
                            ),
                          )
                        : Container(),
                  ),
                ),
                AutoHide(
                  switchDuration: const Duration(milliseconds: 250),
                  controller: controller.hideController,
                  child: Container(color: Colors.black54),
                ),
                if (controller.playerController.value.isBuffering)
                  const Align(child: CircularProgressIndicator()),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: controller.hideController.toggle,
                ),
                AutoHide(
                  switchDuration: const Duration(milliseconds: 250),
                  controller: controller.hideController,
                  child: Stack(
                    children: [
                      PlayerHeader(
                        animeName: data.animeName,
                        episodeNumber: data.episodeNumber,
                        studioName: data.studioName,
                        streamQuality: controller.streamQuality,
                        onQualitySelect: (int qual) {
                          controller.streamQuality = qual;
                          controller.getValuesAndPlay(qual);
                        },
                      ),
                      Align(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (controller.isError == false) ...[
                              GestureDetector(
                                onLongPress: controller.backMore,
                                child: IconButton(
                                  color: Colors.white,
                                  iconSize: 36,
                                  icon: const Icon(Icons.replay_10),
                                  onPressed: controller.back,
                                ),
                              ),
                              IconButton(
                                color: Colors.white,
                                iconSize: 48,
                                icon: AnimatedPlayPause(
                                  playing: controller
                                      .playerController.value.isPlaying,
                                  size: 48,
                                  color: Colors.white,
                                ),
                                onPressed:
                                    controller.playerController.value.isPlaying
                                        ? controller.playerController.pause
                                        : controller.playerController.play,
                              ),
                              GestureDetector(
                                onLongPress: controller.forwardMore,
                                //onDoubleTap: controller.forwardMore,
                                child: IconButton(
                                  color: Colors.white,
                                  iconSize: 36,
                                  icon: const Icon(Icons.forward_10),
                                  onPressed: controller.forward,
                                ),
                              ),
                            ],
                            if (controller.isError == true) ...[
                              ElevatedButton.icon(
                                onPressed: controller.retryPlay,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Ошибка\nвоспроизведения'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      PlayerBottom(
                        progress: controller.playerController.value.position,
                        total: controller.playerController.value.duration,
                        buffered: controller
                                .playerController.value.buffered.isNotEmpty
                            ? controller
                                .playerController.value.buffered.last.end
                            : null,
                        onDragUpdate: () {
                          if (controller.hideController.isVisible) {
                            controller.hideController.show();
                          }
                        },
                        onSeek: controller.seekTo,
                        opSkip: () {
                          controller.seekTo(
                            controller.playerController.value.position +
                                const Duration(seconds: 85),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PlayerError extends StatelessWidget {
  final String error;

  const PlayerError(
    this.error, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error,
            softWrap: true,
          ),
          const SizedBox(
            height: 8,
          ),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Назад'),
          ),
        ],
      ),
    );
  }
}

class SeekVideoWidget extends StatelessWidget {
  final Widget? child;
  final VoidCallback seekBackward;
  final VoidCallback seekForward;

  final VoidCallback? seekLongBackward;
  final VoidCallback? seekLongForward;

  const SeekVideoWidget({
    super.key,
    this.child,
    this.seekLongBackward,
    this.seekLongForward,
    required this.seekBackward,
    required this.seekForward,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkResponse(
                //GestureDetector
                //behavior: HitTestBehavior.opaque,
                onDoubleTap: seekBackward,
                onLongPress: seekLongBackward,
                // child: const IconTheme(
                //   data: IconThemeData(color: Colors.white),
                //   child: Icon(
                //     Icons.fast_rewind,

                //   ),
                // ),
              ),
            ),
            Expanded(
              child: InkResponse(
                onDoubleTap: seekForward,
                onLongPress: seekLongForward,
                //child: const SizedBox.expand(),
              ),
              // GestureDetector(
              //   behavior: HitTestBehavior.opaque,
              //   onDoubleTap: seekForward,
              //   onLongPress: seekLongForward,
              //   // child: const IconTheme(
              //   //   data: IconThemeData(color: Colors.white),
              //   //   child: Icon(Icons.fast_forward),
              //   // ),
              // ),
            ),
          ],
        ),
        //const Text('data'),
      ],
    );
  }
}
