import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:media_kit_video/media_kit_video.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

// import '../../../../utils/app_utils.dart';
import '../../../providers/app_theme_provider.dart';
import '../../../widgets/error_widget.dart';
import '../domain/player_page_extra.dart';
import '../domain/player_provider_parameters.dart';
import '../player_provider.dart';
import '../shared/buffering_indicator.dart';
import 'player_controls.dart';

class DesktopPlayerPage extends ConsumerWidget {
  const DesktopPlayerPage(this.extra, {super.key});

  final PlayerPageExtra extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = PlayerProviderParameters(extra);

    //final playerState = ref.watch(videoPlayerProvider);

    final appTheme = ref.watch(appThemeDataProvider).data;

    final (videoController, player) = ref.watch(
        playerStateProvider.select((s) => (s.videoController, s.player)));

    final playableContentAsync = ref.watch(
        playerPageProvider(p).select((value) => value.playableContentAsync));

    // final shadersExists =
    //     ref.watch(playerPageProvider(p).select((value) => value.shadersExists));

    final playerWidget = Align(
      child: RepaintBoundary(
        child: Video(
          //key: notifier.videoStateKey,
          controller: videoController,
          fill: Colors.transparent,
          fit: BoxFit.contain,
          controls: NoVideoControls,
        ),
      ),
    );

    return Theme(
      data: appTheme.dark,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: playableContentAsync.when(
          data: (_) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                playerWidget,
                Positioned.fill(
                  child: CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.space): () =>
                          player.playOrPause(),
                      const SingleActivator(LogicalKeyboardKey.keyJ): () {
                        player.seek(ref.read(playerStateProvider).position -
                            const Duration(seconds: 10));
                      },
                      const SingleActivator(LogicalKeyboardKey.keyL): () {
                        player.seek(ref.read(playerStateProvider).position +
                            const Duration(seconds: 10));
                      },
                      const SingleActivator(LogicalKeyboardKey.keyK): () =>
                          player.playOrPause(),
                      const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
                        player.seek(ref.read(playerStateProvider).position -
                            const Duration(seconds: 2));
                      },
                      const SingleActivator(LogicalKeyboardKey.arrowRight): () {
                        player.seek(ref.read(playerStateProvider).position +
                            const Duration(seconds: 2));
                      },
                      const SingleActivator(LogicalKeyboardKey.arrowUp): () {
                        final vol = (ref.read(playerStateProvider).volume + 5.0)
                            .clamp(0.0, 100.0);

                        ref.read(playerPageProvider(p)).saveVolume(vol);

                        player.setVolume(vol);
                      },
                      const SingleActivator(LogicalKeyboardKey.arrowDown): () {
                        final vol = (ref.read(playerStateProvider).volume - 5.0)
                            .clamp(0.0, 100.0);

                        ref.read(playerPageProvider(p)).saveVolume(vol);

                        player.setVolume(vol);
                      },
                      const SingleActivator(LogicalKeyboardKey.keyF): () =>
                          ref.read(playerPageProvider(p)).toggleDFullscreen(),
                      const SingleActivator(LogicalKeyboardKey.escape): () =>
                          ref
                              .read(playerPageProvider(p))
                              .toggleDFullscreen(p: true),
                      // TODO: quit without save to db
                      const SingleActivator(LogicalKeyboardKey.keyQ,
                              control: true):
                          () => ref
                              .read(playerPageProvider(p))
                              .toggleDFullscreen(p: true)
                              .then((value) => GoRouter.of(context).pop()),
                      // const SingleActivator(LogicalKeyboardKey.keyS): () =>
                      //     ref.read(playerPageProvider(p)).toggleShaders().then(
                      //       (_) {
                      //         if (!shadersExists) {
                      //           showErrorSnackBar(
                      //             ctx: context,
                      //             msg:
                      //                 'Шейдеры не найдены, инструкция в тг канале',
                      //           );
                      //         }
                      //       },
                      //     ),
                    },
                    child: DesktopPlayerControls(p),
                  ),
                ),
                const Align(
                  child: BufferingIndicator(),
                ),
              ],
            );
          },
          error: (e, s) => Stack(
            children: [
              playerWidget,
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
              playerWidget,
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
      ),
    );
  }
}
