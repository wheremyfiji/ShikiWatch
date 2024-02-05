import 'dart:async';

import 'package:flutter/material.dart';

import 'package:media_kit_video/media_kit_video.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../domain/models/anime_player_page_extra.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/extensions/duration.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/auto_hide.dart';
import '../../../widgets/error_widget.dart';
import '../../settings/widgets/player_long_press_seek.dart';
import '../shared/animated_play_pause.dart';
import '../shared/buffering_indicator.dart';
import '../shared/player_speed_popup.dart';
import '../shared/quality_popup_menu.dart';
import '../player_provider.dart';
import '../shared/shared.dart';

import 'components/double_tap_seek_button.dart';
import 'components/bottom_controls.dart';
import 'components/seek_indicator.dart';
import 'components/top_bar.dart';

const Duration switchDuration = Duration(milliseconds: 300);
const double _seekOffset = 80.0;

class MobilePlayerPage extends StatefulHookConsumerWidget {
  final PlayerPageExtra extra;
  const MobilePlayerPage(this.extra, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MobilePlayerPageState();
}

class _MobilePlayerPageState extends ConsumerState<MobilePlayerPage> {
  bool _seek = false;
  bool _seekShowUI = false;

  double _startDx = 0;
  double _currentDx = 0;

  String _positionText = '';
  String _diffText = '';
  Duration _seekToDuration = const Duration();
  Duration _savedPosition = const Duration();

  static const int horizontalGestureSensitivity = 4;
  static const int doubleTapSeekValue = 5;

  void _seekToPosition(
      {required Duration currentPosition, required Duration duration}) {
    final dxDiff = (_currentDx - _startDx) ~/ horizontalGestureSensitivity;
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

  Offset? _tapPosition;
  bool _mountSeekBackwardButton = false;
  bool _mountSeekForwardButton = false;
  bool _hideSeekBackwardButton = false;
  bool _hideSeekForwardButton = false;

  late double _widgetWidth;
  Timer? _timerSeekBackwardButton;
  Timer? _timerSeekForwardButton;

  void _handleDoubleTapDown(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
  }

  void _onDoubleTapSeekBackward() {
    setState(() {
      _mountSeekBackwardButton = true;
    });
  }

  void _onDoubleTapSeekForward() {
    setState(() {
      _mountSeekForwardButton = true;
    });
  }

  bool _isInSegment(double localX, int segmentIndex) {
    // Local variable with the list of ratios
    List<int> segmentRatios = [1, 1, 1];

    int totalRatios = segmentRatios.reduce((a, b) => a + b);

    double segmentWidthMultiplier = _widgetWidth / totalRatios;
    double start = 0;
    double end;

    for (int i = 0; i < segmentRatios.length; i++) {
      end = start + (segmentWidthMultiplier * segmentRatios[i]);

      // Check if the current index matches the segmentIndex and if localX falls within it
      if (i == segmentIndex && localX >= start && localX <= end) {
        return true;
      }

      // Set the start of the next segment
      start = end;
    }

    // If localX does not fall within the specified segment
    return false;
  }

  bool _isInRightSegment(double localX) {
    return _isInSegment(localX, 2);
  }

  bool _isInCenterSegment(double localX) {
    return _isInSegment(localX, 1);
  }

  bool _isInLeftSegment(double localX) {
    return _isInSegment(localX, 0);
  }

  void _handlePointerDown(PointerDownEvent event, VoidCallback onTap) {
    if (!(_isInCenterSegment(event.position.dx))) {
      return;
    }

    onTap();
  }

  void _handleTapDown(TapDownDetails details, VoidCallback onTap) {
    if ((_isInCenterSegment(details.localPosition.dx))) {
      return;
    }

    onTap();
  }

  @override
  void dispose() {
    _timerSeekBackwardButton?.cancel();
    _timerSeekForwardButton?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = PlayerProviderParameters(widget.extra);

    final notifier = ref.watch(playerProvider(p));

    final longPressSeek = ref.watch(
        settingsProvider.select((settings) => settings.playerLongPressSeek));

    final viewPadding = context.viewPadding;
    final safePaddingTop = useState(viewPadding.top);
    final safePaddingBottom = useState(viewPadding.bottom);
    if (viewPadding.top > 0) {
      safePaddingTop.value = viewPadding.top;
    }
    if (viewPadding.bottom > 0) {
      safePaddingBottom.value = viewPadding.bottom;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _widgetWidth = constraints.maxWidth;

          return notifier.videoLinksAsync.when(
            loading: () {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.only(top: safePaddingTop.value),
                        child: PlayerTopBar(
                          title: notifier.e.info.animeName,
                          subtitle:
                              'Серия ${notifier.currentEpNumber} • ${notifier.e.info.studioName}',
                          actions: const [],
                        ),
                      ),
                    ),
                  ),
                  const Align(child: CircularProgressIndicator()),
                ],
              );
            },
            error: (error, stackTrace) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.only(top: safePaddingTop.value),
                        child: PlayerTopBar(
                          title: notifier.e.info.animeName,
                          subtitle:
                              'Серия ${notifier.currentEpNumber} • ${notifier.e.info.studioName}',
                          actions: const [],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    child: CustomErrorWidget(
                      error.toString(),
                      () {},
                      showButton: false,
                      stackTrace: stackTrace.toString(),
                    ),
                  ),
                ],
              );
            },
            data: (_) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    child: RepaintBoundary(
                      child: Video(
                        key: notifier.videoStateKey,
                        controller: notifier.playerController,
                        fill: Colors.transparent,
                        fit: notifier.playerFit,
                        controls: NoVideoControls,
                      ),
                    ),
                  ),
                  AutoHide(
                    switchDuration: switchDuration,
                    controller: notifier.hideController,
                    child: Container(color: Colors.black54),
                  ),
                  Positioned.fill(
                    left: 16.0,
                    top: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                    child: Listener(
                      onPointerDown: (event) => _handlePointerDown(
                        event,
                        notifier.hideController.toggle,
                      ),
                      child: GestureDetector(
                        //behavior: HitTestBehavior.translucent,
                        onTapDown: (details) => _handleTapDown(
                          details,
                          notifier.hideController.toggle,
                        ),
                        onDoubleTapDown: _handleDoubleTapDown,
                        onDoubleTap: () {
                          if (_tapPosition == null) {
                            return;
                          }

                          if (_isInRightSegment(_tapPosition!.dx)) {
                            _onDoubleTapSeekForward();
                          } else {
                            if (_isInLeftSegment(_tapPosition!.dx)) {
                              _onDoubleTapSeekBackward();
                            }
                          }
                        },
                        onLongPressStart: !longPressSeek
                            ? null
                            : (_) {
                                if (!notifier.init) {
                                  return;
                                }
                                //HapticFeedback.lightImpact();
                                notifier.longPressSeek(true);
                              },
                        onLongPressEnd: !longPressSeek
                            ? null
                            : (_) {
                                notifier.longPressSeek(false);
                              },
                        onHorizontalDragStart: (DragStartDetails details) {
                          if (!notifier.init) {
                            return;
                          }

                          _currentDx = 0;
                          _seekToDuration = Duration.zero;
                          _savedPosition = notifier.position;
                          _startDx = details.localPosition.dx;
                          _seek = true;
                        },
                        onHorizontalDragUpdate: (DragUpdateDetails details) {
                          if (!notifier.init) {
                            _seek = false;
                            _seekShowUI = false;
                            return;
                          }

                          if ((details.localPosition.dx - _startDx).abs() <
                              _seekOffset) {
                            _seekToDuration = _savedPosition;
                            return;
                          }

                          if (_seek) {
                            _seek = false;
                            _seekShowUI = true;

                            //HapticFeedback.lightImpact();

                            notifier.hideController.cancel();

                            notifier.hideController.permShow();
                          }

                          if ((details.localPosition.dx - _startDx)
                              .isNegative) {
                            _currentDx = details.localPosition.dx + _seekOffset;
                          } else {
                            _currentDx = details.localPosition.dx - _seekOffset;
                          }

                          _seekToPosition(
                            currentPosition: notifier.position,
                            duration: notifier.duration,
                          );
                        },
                        onHorizontalDragEnd: (DragEndDetails details) {
                          _seek = false;
                          _seekShowUI = false;

                          if (!notifier.init) {
                            return;
                          }

                          notifier.hideController.hide();

                          if (_seekToDuration == _savedPosition) {
                            return;
                          }

                          notifier.player.seek(_seekToDuration.clampToRange(
                            notifier.duration,
                          ));
                        },
                        child: Container(
                          color: const Color(0x00000000),
                        ),
                      ),
                    ),
                  ),
                  //Top controls
                  AutoHide(
                    switchDuration: switchDuration,
                    controller: notifier.hideController,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.only(top: safePaddingTop.value),
                          child: PlayerTopBar(
                            title: notifier.e.info.animeName,
                            subtitle:
                                'Серия ${notifier.currentEpNumber} • ${notifier.e.info.studioName}',
                            actions: (notifier.init && !notifier.error)
                                ? [
                                    const SizedBox(
                                      width: 16.0,
                                    ),
                                    PlayerSpeedPopUp(
                                      playbackSpeed: notifier.playbackSpeed,
                                      onSelected: notifier.setPlaybackSpeed,
                                    ),
                                    QualityPopUpMenu(
                                      videoLinks: notifier.videoLinks,
                                      selectedQuality: notifier.selectedQuality,
                                      onSelected: (q) =>
                                          notifier.changeQuality(q),
                                      onOpened: () {
                                        notifier.hideController.cancel();
                                        notifier.hideController.permShow();
                                      },
                                      onCanceled: () {
                                        notifier.hideController.toggle();
                                      },
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    child: BufferingIndicator(
                      buffering: notifier.buffering,
                    ),
                  ),
                  if (_mountSeekBackwardButton || _mountSeekForwardButton)
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            child: _mountSeekBackwardButton
                                ? TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                      begin: 0.0,
                                      end: _hideSeekBackwardButton ? 0.0 : 1.0,
                                    ),
                                    duration: const Duration(milliseconds: 200),
                                    builder: (context, value, child) => Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                    onEnd: () {
                                      if (_hideSeekBackwardButton) {
                                        setState(() {
                                          _hideSeekBackwardButton = false;
                                          _mountSeekBackwardButton = false;
                                        });
                                      }
                                    },
                                    child: DoubleTapSeekButton(
                                      action: DoubleTapSeekAction.backward,
                                      value: doubleTapSeekValue,
                                      onChanged: (value) {},
                                      onSubmitted: (value) {
                                        setState(() {
                                          _hideSeekBackwardButton = true;
                                        });

                                        Duration result =
                                            notifier.position - value;
                                        result = result.clampToRange(
                                          notifier.duration,
                                        );
                                        notifier.player.seek(result);
                                      },
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                          const Expanded(child: SizedBox()),
                          Expanded(
                            child: _mountSeekForwardButton
                                ? AnimatedOpacity(
                                    opacity: _hideSeekForwardButton ? 0 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: DoubleTapSeekButton(
                                      action: DoubleTapSeekAction.forward,
                                      value: doubleTapSeekValue,
                                      onChanged: (value) {},
                                      onSubmitted: (value) {
                                        _timerSeekForwardButton?.cancel();

                                        _timerSeekForwardButton = Timer(
                                            const Duration(milliseconds: 200),
                                            () {
                                          if (_hideSeekForwardButton) {
                                            setState(() {
                                              _hideSeekForwardButton = false;
                                              _mountSeekForwardButton = false;
                                            });
                                          }
                                        });

                                        setState(() {
                                          _hideSeekForwardButton = true;
                                        });
                                        Duration result =
                                            notifier.position + value;
                                        result = result.clampToRange(
                                          notifier.duration,
                                        );
                                        notifier.player.seek(result);
                                      },
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  //Center controls
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: _seekShowUI
                        ? Align(
                            child: SeekIndicator(
                              position: _positionText,
                              diff: _diffText,
                            ),
                          )
                        : AutoHide(
                            switchDuration: switchDuration,
                            controller: notifier.hideController,
                            child: Align(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox.shrink(),
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
                                  // const SizedBox(width: 24),
                                  IgnorePointer(
                                    ignoring: notifier.buffering,
                                    child: AnimatedOpacity(
                                      curve: Curves.easeInOut,
                                      opacity: !notifier.buffering ? 1.0 : 0.0,
                                      duration:
                                          const Duration(milliseconds: 150),
                                      child: IconButton(
                                        color: Colors.white,
                                        iconSize: 48.0,
                                        icon: AnimatedPlayPause(
                                          playing: notifier.playing,
                                          color: Colors.white,
                                        ),
                                        onPressed: notifier.player.playOrPause,
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(width: 24),
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
                                  const SizedBox.shrink(),
                                ],
                              ),
                            ),
                          ),
                  ),
                  //Bottom controls
                  AutoHide(
                    switchDuration: switchDuration,
                    controller: notifier.hideController,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.only(
                            // bottom: safePadding.bottom == 0.0
                            //     ? 24.0
                            //     : safePadding.bottom,
                            bottom: safePaddingBottom.value,
                          ),
                          child: BottomControls(
                            p,
                            seekShowUI: _seekShowUI,
                            seekTo: _seekToDuration,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class MobilePlayerSettings extends StatelessWidget {
  const MobilePlayerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      child: Material(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28.0),
          topLeft: Radius.circular(28.0),
        ),
        elevation: 8,
        clipBehavior: Clip.hardEdge,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text('data'),
              ),
              PlayerLongPressSeekOption(),
            ],
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      //showDragHandle: true,
      isScrollControlled: true,
      useRootNavigator: true,
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
      ),
      builder: (_) => const SafeArea(
        bottom: false,
        child: MobilePlayerSettings(),
      ),
    );
  }
}
