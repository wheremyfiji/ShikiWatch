import 'dart:async';
import 'dart:math';

import 'package:floating/floating.dart';
import 'package:flutter/material.dart';

import 'package:media_kit_video/media_kit_video.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../../../../utils/app_utils.dart';
import '../../settings/widgets/player_long_press_seek.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/extensions/duration.dart';
import '../../../providers/app_theme_provider.dart';
import '../../../providers/settings_provider.dart';
import '../domain/player_provider_parameters.dart';
import '../../../widgets/error_widget.dart';
import '../pip_provider.dart';
import '../shared/animated_play_pause.dart';
import '../shared/buffering_indicator.dart';
import '../shared/player_speed_popup.dart';
import '../shared/quality_popup_menu.dart';
import '../domain/player_page_extra.dart';
import '../shared/next_ep_countdown.dart';
import '../../../widgets/auto_hide.dart';
import '../shaders_provider.dart';
import '../player_provider.dart';

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

  bool _mountSeekBackwardButton = false;
  bool _mountSeekForwardButton = false;
  bool _hideSeekBackwardButton = false;
  bool _hideSeekForwardButton = false;

  Timer? _timerSeekBackwardButton;
  Timer? _timerSeekForwardButton;

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        final autoPip = ref.read(
            settingsProvider.select((settings) => settings.playerAutoPip));

        final isPipAvailable = ref.read(pipAvailabilityProvider);

        if (autoPip && isPipAvailable) {
          _enablePip(context, auto: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _timerSeekBackwardButton?.cancel();
    _timerSeekForwardButton?.cancel();
    super.dispose();
  }

  Future<void> _enablePip(
    BuildContext context, {
    bool auto = false,
  }) async {
    try {
      final player = ref.read(playerStateProvider.select((s) => (s.player)));
      final w = player.state.width ?? 16;
      final h = player.state.height ?? 9;

      Rational rational = Rational(w, h);

      if (!rational.fitsInAndroidRequirements) {
        rational = const Rational.landscape();
      }

      if (!context.mounted) return;

      final mediaQuery = MediaQuery.of(context);
      final screenSize = mediaQuery.size * mediaQuery.devicePixelRatio;
      final height = screenSize.width ~/ rational.aspectRatio;

      final arguments = auto
          ? OnLeavePiP(
              aspectRatio: rational,
              sourceRectHint: Rectangle<int>(
                0,
                (screenSize.height ~/ 2) - (height ~/ 2),
                screenSize.width.toInt(),
                height,
              ),
            )
          : ImmediatePiP(
              aspectRatio: rational,
              sourceRectHint: Rectangle<int>(
                0,
                (screenSize.height ~/ 2) - (height ~/ 2),
                screenSize.width.toInt(),
                height,
              ),
            );

      // final arguments = ImmediatePiP(
      //   aspectRatio: rational,
      //   sourceRectHint: Rectangle<int>(
      //     0,
      //     (screenSize.height ~/ 2) - (height ~/ 2),
      //     screenSize.width.toInt(),
      //     height,
      //   ),
      // );

      final floating = ref.read(floatingProvider);
      final status = await floating.enable(arguments);

      if (status == PiPStatus.disabled && context.mounted) {
        showErrorSnackBar(ctx: context, msg: 'Не удалось активировать PiP');
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(ctx: context, msg: 'Ошибка: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = PlayerProviderParameters(widget.extra);

    final videoController =
        ref.watch(playerStateProvider.select((s) => (s.videoController)));

    final playerState = ref.watch(playerStateProvider);

    final notifier = ref.watch(playerPageProvider(p));

    final appTheme = ref.watch(appThemeDataProvider).data;

    final longPressSeek = ref.watch(
        settingsProvider.select((settings) => settings.playerLongPressSeek));

    final playerNextEpisode = ref.watch(
        settingsProvider.select((settings) => settings.playerNextEpisode));

    final viewPadding = context.viewPadding;
    final safePaddingTop = useState(viewPadding.top);
    final safePaddingBottom = useState(viewPadding.bottom);
    if (viewPadding.top > 0) {
      safePaddingTop.value = viewPadding.top;
    }
    if (viewPadding.bottom > 0) {
      safePaddingBottom.value = viewPadding.bottom;
    }

    ref.watch(shaderApplicatorProvider);
    // ref.watch(pipAvailabilityProvider);

    final studioName = widget.extra.studio.name
        .replaceFirst('.Subtitles', ' (Субтитры)')
        .replaceFirst('|Субтитры', ' (Субтитры)');

    final playerWidget = Align(
      child: RepaintBoundary(
        child: Video(
          key: notifier.videoStateKey,
          controller: videoController,
          fill: Colors.transparent,
          fit: notifier.playerFit,
          controls: NoVideoControls,
        ),
      ),
    );

    return Theme(
      data: appTheme.dark,
      child: PiPSwitcher(
        childWhenEnabled: playerWidget,
        childWhenDisabled: Scaffold(
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
          body: notifier.playableContentAsync.when(
            data: (_) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  playerWidget,
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
                    child: Row(
                      children: [
                        Expanded(
                          //flex: 2,
                          child: GestureDetector(
                            onTap: notifier.completed
                                ? null
                                : notifier.hideController.toggle,
                            onDoubleTap: notifier.completed
                                ? null
                                : _onDoubleTapSeekBackward,
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: notifier.completed
                                ? null
                                : notifier.hideController.toggle,
                          ),
                        ),
                        Expanded(
                          //flex: 2,
                          child: GestureDetector(
                            onTap: notifier.completed
                                ? null
                                : notifier.hideController.toggle,
                            onDoubleTap: notifier.completed
                                ? null
                                : _onDoubleTapSeekForward,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    left: 16.0,
                    top: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                    child: GestureDetector(
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
                        if (!notifier.init || notifier.completed) {
                          return;
                        }

                        _currentDx = 0;
                        _seekToDuration = Duration.zero;
                        _savedPosition = playerState.position;
                        _startDx = details.localPosition.dx;
                        _seek = true;
                      },
                      onHorizontalDragUpdate: (DragUpdateDetails details) {
                        if (!notifier.init || notifier.completed) {
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

                        if ((details.localPosition.dx - _startDx).isNegative) {
                          _currentDx = details.localPosition.dx + _seekOffset;
                        } else {
                          _currentDx = details.localPosition.dx - _seekOffset;
                        }

                        _seekToPosition(
                          currentPosition: playerState.position,
                          duration: playerState.duration,
                        );
                      },
                      onHorizontalDragEnd: (DragEndDetails details) {
                        _seek = false;
                        _seekShowUI = false;

                        if (!notifier.init || notifier.completed) {
                          return;
                        }

                        notifier.hideController.hide();

                        if (_seekToDuration == _savedPosition) {
                          return;
                        }

                        notifier.player.seek(_seekToDuration.clampToRange(
                          playerState.duration,
                        ));
                      },
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
                            title: widget.extra.titleInfo.animeName,
                            subtitle:
                                'Серия ${notifier.currentEpNumber} • $studioName',
                            actions: (notifier.init && !notifier.error)
                                ? [
                                    const SizedBox(
                                      width: 16.0,
                                    ),
                                    PlayerSpeedPopUp(
                                      playbackSpeed: playerState.playbackSpeed,
                                      onSelected: notifier.setPlaybackSpeed,
                                    ),
                                    QualityPopUpMenu(
                                      playableContent: notifier.playableContent,
                                      selectedQuality: notifier.selectedQuality,
                                      onSelected: (q) =>
                                          notifier.changeQuality(q),
                                      onOpened: () {
                                        if (notifier.completed) {
                                          return;
                                        }

                                        notifier.hideController.cancel();
                                        notifier.hideController.permShow();
                                      },
                                      onCanceled: () {
                                        if (notifier.completed) {
                                          return;
                                        }

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
                  const Align(
                    child: BufferingIndicator(),
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
                                            playerState.position - value;
                                        result = result.clampToRange(
                                          playerState.duration,
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
                                            playerState.position + value;
                                        result = result.clampToRange(
                                          playerState.duration,
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
                  ((notifier.hasNextEp && notifier.completed) &&
                          playerNextEpisode)
                      ? Align(
                          child: NextEpisodeCountdown(
                            number: notifier.currentEpNumber,
                            onCancel: () {
                              notifier.onPlayerCompleted(false);
                              notifier.hideController.toggle();
                            },
                            onPlay: () {
                              notifier
                                  .changeEpisode(notifier.currentEpNumber + 1);
                              notifier.hideController.toggle();
                            },
                          ),
                        )
                      : AnimatedSwitcher(
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
                                          ignoring: playerState.buffering,
                                          child: AnimatedOpacity(
                                            curve: Curves.easeInOut,
                                            opacity: !playerState.buffering
                                                ? 1.0
                                                : 0.0,
                                            duration: const Duration(
                                                milliseconds: 150),
                                            child: IconButton(
                                              color: Colors.white,
                                              iconSize: 48.0,
                                              icon: AnimatedPlayPause(
                                                playing: playerState.playing,
                                                color: Colors.white,
                                              ),
                                              onPressed:
                                                  notifier.player.playOrPause,
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
                            onEnablePip: () => _enablePip(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // const Positioned(
                  //   top: 4,
                  //   right: 8,
                  //   child: ClockWidget(),
                  // ),
                ],
              );
            },
            loading: () => Stack(
              children: [
                playerWidget,
                Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: safePaddingTop.value),
                      child: PlayerTopBar(
                        title: widget.extra.titleInfo.animeName,
                        subtitle:
                            'Серия ${notifier.currentEpNumber} • $studioName',
                        actions: const [],
                      ),
                    ),
                  ),
                ),
                const Align(child: CircularProgressIndicator()),
              ],
            ),
            error: (error, stackTrace) => Stack(
              children: [
                playerWidget,
                Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: safePaddingTop.value),
                      child: PlayerTopBar(
                        title: widget.extra.titleInfo.animeName,
                        subtitle:
                            'Серия ${notifier.currentEpNumber} • $studioName',
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
                    //stackTrace: stackTrace.toString(),
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

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(minutes: 1)),
      builder: (context, snapshot) {
        return Text(
          DateFormat.Hm().format(DateTime.now()),
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.white60,
          ),
        );
      },
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

extension on Rational {
  /// Checks whether given [Rational] instance fits into Android requirements
  /// or not.
  ///
  /// Android docs specified boundaries as inclusive.
  bool get fitsInAndroidRequirements {
    final aspectRatio = numerator / denominator;
    const min = 1 / 2.39;
    const max = 2.39;
    return (min <= aspectRatio) && (aspectRatio <= max);
  }
}
