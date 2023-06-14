//import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/anime_player_page_extra.dart';
import '../../providers/anime_player_provider.dart';
import '../../widgets/auto_hide.dart';
import 'mobile/player_bottom.dart';
import 'mobile/player_center.dart';
import 'mobile/player_header.dart';
import 'mobile/video_widget.dart';
import 'player_error.dart';

const Duration switchDuration = Duration(milliseconds: 300);

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: AutoHide(
          switchDuration: switchDuration,
          controller: controller.hideController,
          child: PlayerHeader(
            animeName: data.animeName,
            episodeNumber: data.episodeNumber,
            studioName: data.studioName,
            streamQuality: controller.streamQuality,
            onQualitySelect: (int qual) {
              controller.streamQuality = qual;
              controller.getValuesAndPlay(qual);
            },
            isInit: (controller.streamAsync.valueOrNull != null) &&
                controller.playerController.value.isInitialized &&
                !controller.isError,
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        curve: Curves.easeInOutExpo,
        duration: const Duration(milliseconds: 300),
        height: controller.hasConnection ? 0 : 80.0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          child: Center(
            child: Text(
              'Отсутствует подключение к интернету',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      body: controller.streamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => PlayerError(e.toString()),
        data: (video) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: controller.isError ? null : controller.hideController.toggle,
            child: Stack(
              children: [
                Align(
                  child: controller.playerController.value.isInitialized &&
                          !controller.isError
                      ? VideoWidget(
                          controller.playerController,
                          enableSwipe: controller.enableSwipe,
                          expandVideo: controller.expandVideo,
                          aspectRatio:
                              controller.playerController.value.aspectRatio,
                          currentPosition:
                              controller.playerController.value.position,
                          onBack: controller.back,
                          onForward: controller.forward,
                        )
                      : Container(),
                ),
                AutoHide(
                  switchDuration: switchDuration,
                  controller: controller.hideController,
                  child: Container(color: Colors.black54),
                ),
                if (controller.playerController.value.isBuffering)
                  const Align(child: CircularProgressIndicator()),
                AutoHide(
                  switchDuration: switchDuration,
                  controller: controller.hideController,
                  child: Stack(
                    children: [
                      // PlayerHeader(
                      //   animeName: data.animeName,
                      //   episodeNumber: data.episodeNumber,
                      //   studioName: data.studioName,
                      //   streamQuality: controller.streamQuality,
                      //   onQualitySelect: (int qual) {
                      //     controller.streamQuality = qual;
                      //     controller.getValuesAndPlay(qual);
                      //   },
                      // ),
                      PlayerCenter(
                        isError: controller.isError,
                        isPlaying: controller.playerController.value.isPlaying,
                        onPlayPause: controller.playerController.value.isPlaying
                            ? controller.playerController.pause
                            : controller.playerController.play,
                        onRetry: controller.retryPlay,
                      ),
                      SafeArea(
                        top: false,
                        bottom: false,
                        child: PlayerBottom(
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
                          expandVideo: controller.expandVideo,
                          onExpand: controller.toggleExpand,
                        ),
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
