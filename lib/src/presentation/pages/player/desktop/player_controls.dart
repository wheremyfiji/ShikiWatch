import 'package:flutter/material.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/player_provider_parameters.dart';
import '../shared/skip_fragment_button.dart';
import '../shared/animated_play_pause.dart';
import '../shared/quality_popup_menu.dart';
import '../shared/player_speed_popup.dart';
import '../../../../utils/app_utils.dart';
import '../../../widgets/auto_hide.dart';
import '../player_provider.dart';

import 'components/player_info_header.dart';
import 'components/player_volume_slider.dart';

class DesktopPlayerControls extends ConsumerWidget {
  const DesktopPlayerControls(this.p, {super.key});

  final PlayerProviderParameters p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      autofocus: true,
      child: _UiGestures(
        providerParameters: p,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topLeft,
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.black54)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => ref
                        .read(playerPageProvider(p))
                        .toggleDFullscreen(p: true)
                        .then((value) => GoRouter.of(context).pop()),
                    padding: const EdgeInsets.all(0),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    iconSize: 24.0,
                    tooltip: 'Назад',
                  ),
                  const Spacer(),
                  _PlayerInfoHeader(p),
                  const SizedBox(
                    height: 24,
                  ),
                  _ProgressBar(p),
                  _PlayerBottom(p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerBottom extends ConsumerWidget {
  const _PlayerBottom(this.providerParameters);

  final PlayerProviderParameters providerParameters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _VolumeSlider(providerParameters),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: _PlaybackControls(providerParameters),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _OtherControls(providerParameters),
          ),
        ),
      ],
    );
  }
}

class _OtherControls extends ConsumerWidget {
  const _OtherControls(this.providerParameters);

  final PlayerProviderParameters providerParameters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (init, error) =
        ref.watch(playerPageProvider(providerParameters).select((value) => (
              value.init,
              value.error,
            )));

    final (playbackSpeed) =
        ref.watch(playerStateProvider.select((s) => (s.playbackSpeed)));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (init && !error) ...[
          PlayerSpeedPopUp(
            playbackSpeed: playbackSpeed,
            onSelected: ref
                .read(playerPageProvider(providerParameters))
                .setPlaybackSpeed,
          ),
          Consumer(
            builder: (context, ref, child) {
              final (playableContent, selectedQuality) = ref.watch(
                  playerPageProvider(providerParameters).select((value) => (
                        value.playableContent,
                        value.selectedQuality,
                      )));

              return QualityPopUpMenu(
                playableContent: playableContent,
                selectedQuality: selectedQuality,
                onSelected: (q) => ref
                    .read(playerPageProvider(providerParameters))
                    .changeQuality(q),
                onOpened: () {},
                onCanceled: () {},
              );
            },
          ),
          _ShadersButton(providerParameters),
        ],
        IconButton(
          tooltip: 'Полноэкранный режим',
          icon: const Icon(Icons.fullscreen),
          color: Colors.white,
          iconSize: 24.0,
          onPressed: () => ref
              .read(playerPageProvider(providerParameters))
              .toggleDFullscreen(),
        ),
      ],
    );
  }
}

class _ShadersButton extends ConsumerWidget {
  const _ShadersButton(this.providerParameters);

  final PlayerProviderParameters providerParameters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(playerPageProvider(providerParameters));

    return IconButton(
      tooltip: 'Anime4K шейдеры',
      icon: Icon(n.shaders ? Icons.four_k : Icons.four_k_outlined),
      iconSize: 24.0,
      color: Colors.white,
      onPressed: () {
        n.toggleShaders().then(
          (_) {
            if (!n.shadersExists) {
              showErrorSnackBar(
                ctx: context,
                msg: 'Шейдеры не найдены, инструкция в тг канале',
              );
            }
          },
        );
      },
    );
  }
}

class _VolumeSlider extends ConsumerWidget {
  const _VolumeSlider(this.providerParameters);

  final PlayerProviderParameters providerParameters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (player, volume) =
        ref.watch(playerStateProvider.select((s) => (s.player, s.volume)));

    return PlayerVolumeSlider(
      volume,
      onChange: (d) {
        ref.read(playerPageProvider(providerParameters)).saveVolume(d);
        player.setVolume(d);
      },
    );
  }
}

class _PlaybackControls extends ConsumerWidget {
  const _PlaybackControls(this.providerParameters);

  final PlayerProviderParameters providerParameters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (player, playing) =
        ref.watch(playerStateProvider.select((s) => (s.player, s.playing)));

    final (hasPrevEp, hasNextEp) = ref.watch(
        playerPageProvider(providerParameters)
            .select((value) => (value.hasPrevEp, value.hasNextEp)));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Предыдущая серия',
          onPressed: hasPrevEp
              ? () {
                  final currentEpNumber = ref
                      .read(playerPageProvider(providerParameters))
                      .currentEpNumber;

                  ref
                      .read(playerPageProvider(providerParameters))
                      .changeEpisode(currentEpNumber - 1);
                }
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
            playing: playing,
            color: Colors.white,
          ),
          onPressed: player.playOrPause,
        ),
        const SizedBox(
          width: 24.0,
        ),
        IconButton(
          tooltip: 'Следующая серия',
          onPressed: hasNextEp
              ? () {
                  final currentEpNumber = ref
                      .read(playerPageProvider(providerParameters))
                      .currentEpNumber;

                  ref
                      .read(playerPageProvider(providerParameters))
                      .changeEpisode(currentEpNumber + 1);
                }
              : null,
          color: Colors.white,
          iconSize: 32.0,
          icon: const Icon(Icons.skip_next),
        ),
      ],
    );
  }
}

class _PlayerInfoHeader extends ConsumerWidget {
  const _PlayerInfoHeader(this.providerParameters);

  final PlayerProviderParameters providerParameters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = providerParameters.extra;

    final currentEpNumber = ref.watch(playerPageProvider(providerParameters)
        .select((value) => value.currentEpNumber));

    final studioName = extra.studio.name
        .replaceFirst('.Subtitles', ' (Субтитры)')
        .replaceFirst('|Субтитры', ' (Субтитры)');

    return PlayerInfoHeader(
      animeName: extra.titleInfo.animeName,
      animePicture: extra.titleInfo.imageUrl,
      episodeNumber: currentEpNumber,
      studioName: studioName,
      skipButton: _SkipButton(providerParameters),
    );
  }
}

class _SkipButton extends ConsumerWidget {
  const _SkipButton(this.providerParameters);

  final PlayerProviderParameters providerParameters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opTimecode = ref.watch(playerPageProvider(providerParameters)
        .select((value) => value.opTimecode));

    final (player, position) =
        ref.watch(playerStateProvider.select((s) => (s.player, s.position)));

    final showSkip = opTimecode.length == 2 &&
        (opTimecode.first) <= position.inSeconds &&
        opTimecode.last > position.inSeconds;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: showSkip
          ? IgnorePointer(
              ignoring: !showSkip,
              child: SkipFragmentButton(
                title: 'Пропустить опенинг',
                onSkip: () => player.seek(Duration(seconds: opTimecode.last)),
                onClose: () => ref
                    .read(playerPageProvider(providerParameters))
                    .opTimecode = [],
              ),
            )
          : IconButton(
              tooltip: 'Перемотать 125 секунд',
              iconSize: 32,
              color: Colors.white,
              onPressed: () => player.seek(
                position + const Duration(seconds: 85),
              ),
              icon: const Icon(Icons.double_arrow_rounded),
            ),
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar(this.providerParameters);

  final PlayerProviderParameters providerParameters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (player, position, duration, buffer) = ref.watch(playerStateProvider
        .select((s) => (s.player, s.position, s.duration, s.buffer)));
    final hideController = ref.watch(playerPageProvider(providerParameters)
        .select((value) => value.hideController));

    return ProgressBar(
      progress: position,
      total: duration,
      buffered: buffer,
      thumbRadius: 8,
      timeLabelPadding: 4,
      timeLabelTextStyle: const TextStyle(
        color: Colors.white,
      ),
      thumbGlowRadius: 24,
      onSeek: player.seek,
      // onDragUpdate: (_) {
      //   if (notifier.hideController.isVisible) {
      //     notifier.hideController.show();
      //   }
      // },
      onDragStart: (details) {
        hideController.cancel();
        hideController.permShow();
      },
      onDragEnd: () {
        hideController.hide();
      },
    );
  }
}

class _UiGestures extends ConsumerWidget {
  const _UiGestures({
    required this.providerParameters,
    required this.child,
  });

  final PlayerProviderParameters providerParameters;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerStateProvider.select((s) => s.player));
    final hideController = ref.watch(playerPageProvider(providerParameters)
        .select((value) => value.hideController));

    return GestureDetector(
      onTap: player.playOrPause,
      child: MouseRegion(
        onHover: (_) {
          hideController.show();
        },
        onEnter: (_) {
          hideController.show();
        },
        onExit: (_) {
          hideController.hide();
        },
        child: AutoHide(
          controller: hideController,
          switchDuration: const Duration(milliseconds: 500),
          child: child,
        ),
      ),
    );
  }
}
