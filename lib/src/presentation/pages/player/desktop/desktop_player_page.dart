import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/anime_player_page_extra.dart';
import '../../../providers/anime_details_provider.dart';
import '../mobile/animated_play_pause.dart';
import '../../../../utils/app_utils.dart';
import '../player_error.dart';

import 'components/player_volume_slider.dart';
import 'components/player_info_header.dart';
import 'desktop_player_provider.dart';

class DesktopPlayerPage extends ConsumerWidget {
  final AnimePlayerPageExtra extra;

  const DesktopPlayerPage({super.key, required this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = DesktopPlayerParameters(extra);

    final notifier = ref.watch(desktopPlayerProvider(p));
    return Scaffold(
      backgroundColor: Colors.black,
      body: notifier.streamAsync.when(
        data: (data) {
          return Stack(
            children: [
              Align(
                child: Video(
                  controller: notifier.playerController,
                  //filterQuality: FilterQuality.high,
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
                        notifier.toggleFullScreen(),
                    const SingleActivator(LogicalKeyboardKey.escape): () =>
                        notifier.toggleFullScreen(p: true),
                  },
                  child: DesktopPlayerControls(p),
                ),
              ),
              //if (notifier.buffering)
              Align(
                child: AnimatedOpacity(
                  curve: Curves.easeInOut,
                  opacity: notifier.buffering ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: const CircularProgressIndicator(),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => PlayerError(error.toString()),
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
  final DesktopPlayerParameters p;

  const DesktopPlayerControls(this.p, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DesktopPlayerControlsState();
}

class _DesktopPlayerControlsState extends ConsumerState<DesktopPlayerControls> {
  DesktopPlayerParameters get p => widget.p;

  final controlsHoverDuration = const Duration(seconds: 3);

  Timer? _timer;

  bool mount = false;
  bool visible = false;
  bool draggingProgressBar = false;
  bool showUI = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(desktopPlayerProvider(p));

    return Focus(
      autofocus: true,
      child: GestureDetector(
        onTap: () {
          notifier.player.playOrPause();
        },
        child: MouseRegion(
          onHover: (_) {
            setState(() {
              mount = true;
              visible = true;
            });

            _timer?.cancel();
            _timer = Timer(controlsHoverDuration, () {
              if (draggingProgressBar || showUI) {
                return;
              }

              if (mounted) {
                setState(() {
                  visible = false;
                });
              }
            });
          },
          onEnter: (_) {
            setState(() {
              mount = true;
              visible = true;
            });

            _timer?.cancel();
            _timer = Timer(controlsHoverDuration, () {
              if (draggingProgressBar || showUI) {
                return;
              }

              if (mounted) {
                setState(() {
                  visible = false;
                });
              }
            });
          },
          onExit: (_) {
            if (showUI) {
              return;
            }
            setState(() {
              visible = false;
            });
            _timer?.cancel();
          },
          child: AnimatedOpacity(
            curve: Curves.easeInOut,
            opacity: visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            onEnd: () {
              if (!visible) {
                setState(() {
                  mount = false;
                });
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topLeft,
              children: [
                Container(color: Colors.black54),
                if (mount)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () async {
                            // exit fullscreen
                            await notifier.toggleFullScreen(p: true);

                            // update DB
                            await notifier.updateDataBase().then(
                              (_) {
                                ref.invalidate(isAnimeInDataBaseProvider);
                                GoRouter.of(context).pop();
                              },
                            ).catchError(
                              (e) {
                                showErrorSnackBar(
                                    ctx: context,
                                    msg: 'Ошибка обновления: ${e.toString()}');
                                GoRouter.of(context).pop();
                              },
                            );
                          },
                          padding: const EdgeInsets.all(0),
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          iconSize: 24.0,
                          tooltip: 'Назад',
                        ),
                        const Spacer(),
                        PlayerInfoHeader(
                          animeName: p.extra.animeName,
                          animePicture: p.extra.imageUrl,
                          episodeNumber: p.extra.episodeNumber,
                          studioName: p.extra.studioName,
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
                          timeLabelTextStyle:
                              const TextStyle(color: Colors.white),
                          thumbGlowRadius: 24,
                          onSeek: (value) {
                            notifier.player.seek(value);
                          },
                          onDragStart: (details) {
                            draggingProgressBar = true;
                          },
                          onDragEnd: () {
                            draggingProgressBar = false;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                      color: Colors.white,
                                      iconSize: 48.0,
                                      icon: AnimatedPlayPause(
                                        playing: notifier.playing,
                                        color: Colors.white,
                                      ),
                                      onPressed: notifier.player.playOrPause,
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
                                        notifier.toggleShaders().then(
                                          (_) {
                                            if (!notifier.shadersExists) {
                                              showErrorSnackBar(
                                                ctx: context,
                                                msg: 'Шейдеры не найдены',
                                              );
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Полноэкранный режим',
                                      icon: const Icon(Icons.fullscreen),
                                      color: Colors.white,
                                      iconSize: 24.0,
                                      onPressed: () =>
                                          notifier.toggleFullScreen(),
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
