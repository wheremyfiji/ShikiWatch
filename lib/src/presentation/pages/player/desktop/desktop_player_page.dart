import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/anime_player_page_extra.dart';
import '../../../widgets/auto_hide.dart';
import '../../../widgets/error_widget.dart';
import '../player_provider.dart';
import '../shared/animated_play_pause.dart';
import '../shared/buffering_indicator.dart';
import '../shared/shared.dart';

import 'components/player_info_header.dart';
import 'components/player_volume_slider.dart';

class DesktopPlayerPage extends ConsumerStatefulWidget {
  final PlayerPageExtra extra;

  const DesktopPlayerPage(this.extra, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      DesktopPlayerPageState();
}

class DesktopPlayerPageState extends ConsumerState<DesktopPlayerPage> {
  @override
  Widget build(BuildContext context) {
    final p = PlayerProviderParameters(widget.extra);

    final notifier = ref.watch(playerProvider(p));

    return Scaffold(
      backgroundColor: Colors.black,
      body: notifier.videoLinksAsync.when(
        data: (_) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                child: Video(
                  controller: notifier.playerController,
                  fill: Colors.transparent,
                  fit: BoxFit.contain,
                  controls: NoVideoControls,
                ),
              ),
              Positioned.fill(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.space): () =>
                        notifier.player.playOrPause(),
                    const SingleActivator(LogicalKeyboardKey.keyJ): () {
                      notifier.player.seek(
                          notifier.position - const Duration(seconds: 10));
                    },
                    const SingleActivator(LogicalKeyboardKey.keyL): () {
                      notifier.player.seek(
                          notifier.position + const Duration(seconds: 10));
                    },
                    const SingleActivator(LogicalKeyboardKey.keyK): () =>
                        notifier.player.playOrPause(),
                    const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
                      notifier.player
                          .seek(notifier.position - const Duration(seconds: 2));
                    },
                    const SingleActivator(LogicalKeyboardKey.arrowRight): () {
                      notifier.player
                          .seek(notifier.position + const Duration(seconds: 2));
                    },
                    const SingleActivator(LogicalKeyboardKey.arrowUp): () {
                      notifier.player
                          .setVolume((notifier.volume + 5.0).clamp(0.0, 100.0));
                    },
                    const SingleActivator(LogicalKeyboardKey.arrowDown): () {
                      notifier.player
                          .setVolume((notifier.volume - 5.0).clamp(0.0, 100.0));
                    },
                    const SingleActivator(LogicalKeyboardKey.keyF): () =>
                        notifier.toggleDFullscreen(),
                    const SingleActivator(LogicalKeyboardKey.escape): () =>
                        notifier.toggleDFullscreen(p: true),
                  },
                  child: DesktopPlayerControls(p),
                ),
              ),
              Align(
                child: BufferingIndicator(
                  buffering: notifier.buffering,
                ),
              ),
            ],
          );
        },
        error: (e, s) => Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: IconButton(
                onPressed: () => GoRouter.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                iconSize: 24.0,
                tooltip: 'Назад',
              ),
            ),
            CustomErrorWidget(
              e.toString(),
              () {},
              showButton: false,
            ),
          ],
        ),
        loading: () => Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: IconButton(
                onPressed: () => GoRouter.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                iconSize: 24.0,
                tooltip: 'Назад',
              ),
            ),
            const Align(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopPlayerControls extends ConsumerStatefulWidget {
  final PlayerProviderParameters p;
  const DesktopPlayerControls(this.p, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DesktopPlayerControlsState();
}

class _DesktopPlayerControlsState extends ConsumerState<DesktopPlayerControls> {
  PlayerProviderParameters get p => widget.p;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(playerProvider(p));

    return Focus(
      autofocus: true,
      child: GestureDetector(
        onTap: notifier.player.playOrPause,
        child: MouseRegion(
          onHover: (_) {
            notifier.hideController.show();
          },
          onEnter: (_) {
            notifier.hideController.show();
          },
          onExit: (_) {
            notifier.hideController.hide();
          },
          child: AutoHide(
            controller: notifier.hideController,
            switchDuration: const Duration(milliseconds: 500),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topLeft,
              children: [
                Container(color: Colors.black54),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          notifier
                              .toggleDFullscreen(p: true)
                              .then((value) => GoRouter.of(context).pop());
                        },
                        padding: const EdgeInsets.all(0),
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        iconSize: 24.0,
                        tooltip: 'Назад',
                      ),
                      const Spacer(),
                      PlayerInfoHeader(
                        animeName: p.extra.info.animeName,
                        animePicture: p.extra.info.imageUrl,
                        episodeNumber: notifier.currentEpNumber,
                        studioName: p.extra.info.studioName,
                        onPressed: () => notifier.player.seek(
                          notifier.position + const Duration(seconds: 85),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      ProgressBar(
                        progress: notifier.position,
                        total: notifier.duration,
                        buffered: notifier.buffer,
                        thumbRadius: 8,
                        timeLabelPadding: 4,
                        timeLabelTextStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        thumbGlowRadius: 24,
                        onSeek: notifier.player.seek,
                        // onDragUpdate: (_) {
                        //   if (notifier.hideController.isVisible) {
                        //     notifier.hideController.show();
                        //   }
                        // },
                        onDragStart: (details) {
                          notifier.hideController.cancel();
                          notifier.hideController.permShow();
                        },
                        onDragEnd: () {
                          notifier.hideController.hide();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PlayerVolumeSlider(
                            notifier.volume,
                            onChange: (d) {
                              notifier.saveVolume(d);
                              notifier.player.setVolume(d);
                            },
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Предыдущая серия',
                                    onPressed: notifier.hasPrevEp
                                        ? () => notifier.changeEpisode(
                                            notifier.currentEpNumber - 1)
                                        : null,
                                    color: Colors.white,
                                    iconSize: 32.0,
                                    icon: const Icon(Icons.skip_previous),
                                  ),
                                  const SizedBox(
                                    width: 24.0,
                                  ),
                                  IconButton(
                                    color: Colors.white,
                                    iconSize: 48.0,
                                    icon: AnimatedPlayPause(
                                      playing: notifier.playing,
                                      color: Colors.white,
                                    ),
                                    onPressed: notifier.player.playOrPause,
                                  ),
                                  const SizedBox(
                                    width: 24.0,
                                  ),
                                  IconButton(
                                    tooltip: 'Следующая серия',
                                    onPressed: notifier.hasNextEp
                                        ? () => notifier.changeEpisode(
                                            notifier.currentEpNumber + 1)
                                        : null,
                                    color: Colors.white,
                                    iconSize: 32.0,
                                    icon: const Icon(Icons.skip_next),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Anime4K шейдеры',
                                    icon: Icon(notifier.shaders
                                        ? Icons.four_k
                                        : Icons.four_k_outlined),
                                    iconSize: 24.0,
                                    color: Colors.white,
                                    onPressed: () {
                                      // notifier.toggleShaders().then(
                                      //   (_) {
                                      //     if (!notifier.shadersExists) {
                                      //       showErrorSnackBar(
                                      //         ctx: context,
                                      //         msg: 'Шейдеры не найдены',
                                      //       );
                                      //     }
                                      //   },
                                      // );
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Полноэкранный режим',
                                    icon: const Icon(Icons.fullscreen),
                                    color: Colors.white,
                                    iconSize: 24.0,
                                    onPressed: () =>
                                        notifier.toggleDFullscreen(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
