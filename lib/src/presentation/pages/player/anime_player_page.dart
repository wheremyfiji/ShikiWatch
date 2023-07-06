//import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/anime_player_page_extra.dart';
import '../../providers/anime_player_provider.dart';
import '../../../utils/extensions/duration.dart';
import '../../widgets/auto_hide.dart';
import 'mobile/player_bottom.dart';
import 'mobile/player_center.dart';
import 'mobile/player_header.dart';
import 'mobile/video_widget.dart';
import 'player_error.dart';

const Duration switchDuration = Duration(milliseconds: 300);
const double _seekOffset = 80.0;

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

class AnimePlayerPage extends ConsumerStatefulWidget {
  final AnimePlayerPageExtra data;
  const AnimePlayerPage({super.key, required this.data});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimePlayerPageState();
}

class _AnimePlayerPageState extends ConsumerState<AnimePlayerPage> {
  AnimePlayerPageExtra get data => widget.data;

  bool _seek = false;
  bool _seekShowUI = false;
  bool _controllerWasPlaying = false;

  double _startDx = 0;
  double _currentDx = 0;

  String _positionText = '';
  String _diffText = '';
  Duration _seekToDuration = const Duration();

  void seekToPosition(
      {required Duration currentPosition, required Duration duration}) {
    final dxDiff = (_currentDx - _startDx) ~/ 5;
    final diffDuration = Duration(seconds: dxDiff);
    final prefix = diffDuration.isNegative ? '-' : '+';

    final aimedDuration =
        (currentPosition + diffDuration).clampToRange(duration);
    _seekToDuration = aimedDuration;

    setState(() {
      _positionText = '$prefix${diffDuration.printDuration()}';
      _diffText = aimedDuration.printDuration();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            playbackSpeed: controller.playbackSpeed,
            onSelectedSpeed: (double speed) {
              controller.playerController.setPlaybackSpeed(speed);
            },
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
          return LayoutBuilder(builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap:
                  controller.isError ? null : controller.hideController.toggle,
              // onDoubleTapDown: (TapDownDetails details) {
              //   // print(
              //   //     'onDoubleTapDown globalPosition: ${details.globalPosition}');
              //   // print('onDoubleTapDown localPosition: ${details.localPosition}');

              //   final centerX = constraints.maxWidth / 2;
              //   final left = details.localPosition.dx < centerX;

              //   print('onDoubleTapDown: $left');
              // },
              onHorizontalDragStart: (DragStartDetails details) {
                if (controller.isError ||
                    !controller.playerController.value.isInitialized) {
                  return;
                }

                _currentDx = 0;
                _seekToDuration = Duration.zero;

                // if (details.localPosition.dx < 100) {
                //   return;
                // }

                _controllerWasPlaying =
                    controller.playerController.value.isPlaying;

                _startDx = details.localPosition.dx;

                _seek = true;
                //_seekShowUI = true;

                // controller.hideController.permShow();

                // if (_controllerWasPlaying) {
                //   controller.playerController.pause();
                // }
              },
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                if (controller.isError ||
                    !controller.playerController.value.isInitialized) {
                  _seek = false;
                  _seekShowUI = false;
                  return;
                }

                // print(
                //   'currentDx: ${(details.localPosition.dx - _startDx).abs()}',
                // );

                if ((details.localPosition.dx - _startDx).abs() < _seekOffset) {
                  return;
                }

                if (_seek) {
                  _seek = false;
                  _seekShowUI = true;
                  controller.hideController.permShow();
                  if (_controllerWasPlaying) {
                    controller.playerController.pause();
                  }
                }

                if ((details.localPosition.dx - _startDx).isNegative) {
                  _currentDx = details.localPosition.dx + _seekOffset;
                } else {
                  _currentDx = details.localPosition.dx - _seekOffset;
                }

                // controller.hideController.permShow();

                seekToPosition(
                  currentPosition: controller.playerController.value.position,
                  duration: controller.playerController.value.duration,
                );
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                if (controller.isError ||
                    !controller.playerController.value.isInitialized) {
                  _seek = false;
                  _seekShowUI = false;
                  return;
                }

                _seek = false;
                _seekShowUI = false;
                controller.hideController.hide();

                if (_seekToDuration ==
                        controller.playerController.value.position ||
                    _seekToDuration == Duration.zero) {
                  if (_controllerWasPlaying) {
                    controller.playerController.play();
                  }

                  return;
                }

                controller.playerController
                    .seekTo(_seekToDuration)
                    .then((value) {
                  if (_controllerWasPlaying &&
                      controller.playerController.value.position !=
                          controller.playerController.value.duration) {
                    controller.playerController.play();
                  }
                });
              },
              child: Stack(
                children: [
                  Align(
                    child: controller.playerController.value.isInitialized &&
                            !controller.isError
                        ? VideoWidget(
                            controller.playerController,
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 50),
                    child: _seekShowUI
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _positionText,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _diffText,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  AutoHide(
                    switchDuration: switchDuration,
                    controller: controller.hideController,
                    child: Stack(
                      children: [
                        PlayerCenter(
                          isError: controller.isError,
                          isPlaying:
                              controller.playerController.value.isPlaying,
                          onPlayPause:
                              controller.playerController.value.isPlaying
                                  ? controller.playerController.pause
                                  : controller.playerController.play,
                          onRetry: controller.retryPlay,
                          showPlayPauseButton: !_seekShowUI,
                        ),
                        SafeArea(
                          top: false,
                          bottom: false,
                          child: PlayerBottom(
                            progress: _seekShowUI
                                ? _seekToDuration
                                : controller.playerController.value.position,
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
          });
        },
      ),
    );
  }
}

// class AnimePlayerPage extends HookConsumerWidget {
//   final AnimePlayerPageExtra data;

//   const AnimePlayerPage({super.key, required this.data});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final controller =
//         ref.watch(playerControllerProvider(PlayerProviderParameters(
//       studioId: data.studioId,
//       shikimoriId: data.shikimoriId,
//       episodeNumber: data.episodeNumber,
//       animeName: data.animeName,
//       imageUrl: data.imageUrl,
//       studioName: data.studioName,
//       studioType: data.studioType,
//       episodeLink: data.episodeLink,
//       episodeAdditInfo: data.additInfo,
//       position: data.startPosition,
//     )));

//     //final statusBarHeight = MediaQuery.of(context).padding.top;
//     //ui.window.padding.top;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.white,
//         title: AutoHide(
//           switchDuration: switchDuration,
//           controller: controller.hideController,
//           child: PlayerHeader(
//             animeName: data.animeName,
//             episodeNumber: data.episodeNumber,
//             studioName: data.studioName,
//             streamQuality: controller.streamQuality,
//             onQualitySelect: (int qual) {
//               controller.streamQuality = qual;
//               controller.getValuesAndPlay(qual);
//             },
//             isInit: (controller.streamAsync.valueOrNull != null) &&
//                 controller.playerController.value.isInitialized &&
//                 !controller.isError,
//           ),
//         ),
//       ),
//       bottomNavigationBar: AnimatedContainer(
//         curve: Curves.easeInOutExpo,
//         duration: const Duration(milliseconds: 300),
//         height: controller.hasConnection ? 0 : 80.0,
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.errorContainer,
//           borderRadius: const BorderRadius.all(
//             Radius.circular(12),
//           ),
//         ),
//         child: BottomAppBar(
//           color: Colors.transparent,
//           surfaceTintColor: Colors.transparent,
//           clipBehavior: Clip.hardEdge,
//           child: Center(
//             child: Text(
//               'Отсутствует подключение к интернету',
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onErrorContainer,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: controller.streamAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, s) => PlayerError(e.toString()),
//         data: (video) {
//           return GestureDetector(
//             behavior: HitTestBehavior.translucent,
//             onTap: controller.isError ? null : controller.hideController.toggle,
//             onHorizontalDragStart: (DragStartDetails details) {
//               if (controller.isError ||
//                   !controller.playerController.value.isInitialized) {
//                 return;
//               }

//               seek.value = true;

//               if (controller.playerController.value.isPlaying) {
//                 controller.playerController.pause();
//               }
//             },
//             onHorizontalDragUpdate: (DragUpdateDetails details) {
//               if (controller.isError ||
//                   !controller.playerController.value.isInitialized) {
//                 return;
//               }

//               //seekToRelativePosition(details.globalPosition);
//             },
//             onHorizontalDragEnd: (DragEndDetails details) {
//               if (controller.isError) {
//                 return;
//               }

//               if (controller.playerController.value.position !=
//                   controller.playerController.value.duration) {
//                 seek.value = false;
//                 controller.playerController.play();
//               }
//             },
//             child: Stack(
//               children: [
//                 Align(
//                   child: controller.playerController.value.isInitialized &&
//                           !controller.isError
//                       ? VideoWidget(
//                           controller.playerController,
//                           enableSwipe: controller.enableSwipe,
//                           expandVideo: controller.expandVideo,
//                           aspectRatio:
//                               controller.playerController.value.aspectRatio,
//                           currentPosition:
//                               controller.playerController.value.position,
//                           onBack: controller.back,
//                           onForward: controller.forward,
//                         )
//                       : Container(),
//                 ),
//                 AutoHide(
//                   switchDuration: switchDuration,
//                   controller: controller.hideController,
//                   child: Container(color: Colors.black54),
//                 ),
//                 if (controller.playerController.value.isBuffering)
//                   const Align(child: CircularProgressIndicator()),
//                 AutoHide(
//                   switchDuration: switchDuration,
//                   controller: controller.hideController,
//                   child: Stack(
//                     children: [
//                       PlayerCenter(
//                         isError: controller.isError,
//                         isPlaying: controller.playerController.value.isPlaying,
//                         onPlayPause: controller.playerController.value.isPlaying
//                             ? controller.playerController.pause
//                             : controller.playerController.play,
//                         onRetry: controller.retryPlay,
//                       ),
//                       SafeArea(
//                         top: false,
//                         bottom: false,
//                         child: PlayerBottom(
//                           progress: controller.playerController.value.position,
//                           total: controller.playerController.value.duration,
//                           buffered: controller
//                                   .playerController.value.buffered.isNotEmpty
//                               ? controller
//                                   .playerController.value.buffered.last.end
//                               : null,
//                           onDragUpdate: () {
//                             if (controller.hideController.isVisible) {
//                               controller.hideController.show();
//                             }
//                           },
//                           onSeek: controller.seekTo,
//                           opSkip: () {
//                             controller.seekTo(
//                               controller.playerController.value.position +
//                                   const Duration(seconds: 85),
//                             );
//                           },
//                           expandVideo: controller.expandVideo,
//                           onExpand: controller.toggleExpand,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
