import 'dart:developer';
//import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/anime_player_page_extra.dart';
import '../../providers/anime_player_provider.dart';
import '../../widgets/auto_hide.dart';

class AnimePlayerPage extends HookConsumerWidget {
  // final String? link;
  // final String? name;
  // final String? ep;

  // const AnimePlayerPage(
  //     {super.key, required this.link, required this.name, required this.ep});

  final AnimePlayerPageExtra? data;

  const AnimePlayerPage({super.key, required this.data});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = ref.watch(playerControllerProvider(link!));
    final controller =
        ref.watch(playerControllerProvider(PlayerProviderParameters(
      studioId: data!.studioId,
      shikimoriId: data!.shikimoriId,
      episodeNumber: data!.episodeNumber,
      animeName: data!.animeName,
      imageUrl: data!.imageUrl,
      studioName: data!.studioName,
      studioType: data!.studioType,
      episodeLink: data!.episodeLink,
      episodeAdditInfo: data!.additInfo,
      position: data!.startPosition,
    )));
    //final statusBarHeight = MediaQuery.of(context).padding.top;
    //ui.window.padding.top;

    // useEffect(() {
    //   log('called', name: 'useEffect');
    //   return () async {
    //     log('dispose?', name: 'useEffect');
    //     await ref.read(animeDatabaseProvider).updateEpisode(
    //         shikimoriId: 11,
    //         animeName: 'animeName',
    //         timeStamp: 'timeStamp',
    //         studioId: 1,
    //         studioName: 'studioName',
    //         studioType: 'studioType',
    //         episodeNumber: 1);
    //   };
    // }, const []);

    return Scaffold(
      backgroundColor: Colors.black,
      body: controller.streamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text('Error: $err'),
            Text('$err'),
            ElevatedButton(
                onPressed: () => context.pop(), child: const Text('Назад')),
          ],
        )),
        data: (config) {
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
                            //aspectRatio: 16 / 9,
                            aspectRatio:
                                controller.playerController.value.aspectRatio,
                            child: VideoPlayer(controller.playerController),
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: ListTile(
                            leading: const BackButton(
                              color: Colors.white,
                            ),
                            title: Text(
                              data!.animeName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              'Серия ${data!.episodeNumber} • ${data!.studioName}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            trailing: PopupMenuButton<int>(
                              initialValue: controller.streamQuality,
                              onSelected: (int qual) {
                                controller.streamQuality = qual;
                                controller.getValuesAndPlay(qual);
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<int>>[
                                const PopupMenuItem<int>(
                                  value: 0,
                                  child: Text('720p'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 1,
                                  child: Text('480p'),
                                ),
                                const PopupMenuItem<int>(
                                  value: 2,
                                  child: Text('360p'),
                                ),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: QualityTextWidget(
                                    quality: controller.streamQuality),
                              ),
                            ),
                          ),
                        ),
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
                                icon: Icon(
                                  controller.playerController.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
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
                                  label: const Text('Ошибка\nвоспроизведения')),
                            ],
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // if (showSkip) ...[
                              //   Align(
                              //     alignment: Alignment.bottomRight,
                              //     child: ElevatedButton(
                              //       child: const Text('Пропустить опенинг'),
                              //       onPressed: () {
                              //         controller.seekTo(
                              //           Duration(
                              //             seconds: info.skips!.opening!.stop,
                              //           ),
                              //         );
                              //       },
                              //     ),
                              //   ),
                              //   BlankSpace.bottom(8),
                              // ],
                              ProgressBar(
                                progress:
                                    controller.playerController.value.position,
                                total:
                                    controller.playerController.value.duration,
                                onDragUpdate: (_) {
                                  if (controller.hideController.isVisible) {
                                    controller.hideController.show();
                                  }
                                },
                                thumbRadius: 8,
                                timeLabelTextStyle:
                                    const TextStyle(color: Colors.white),
                                buffered: controller.playerController.value
                                        .buffered.isNotEmpty
                                    ? controller.playerController.value.buffered
                                        .last.end
                                    : null,
                                timeLabelPadding: 4,
                                onSeek: controller.seekTo,
                              ),
                            ],
                          ),
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

class QualityTextWidget extends StatelessWidget {
  final int quality;
  const QualityTextWidget({super.key, required this.quality});

  String getString(int value) {
    String str;

    const map = {0: '720p', 1: '480p', 2: '360p'};

    str = map[value] ?? 'N/A';

    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          getString(quality),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(
          width: 4,
        ),
        const Icon(Icons.expand_more)
      ],
    );
  }
}

class AnimePlayerPage2 extends StatefulWidget {
  const AnimePlayerPage2({super.key});

  @override
  State<AnimePlayerPage2> createState() => _AnimePlayerPageState2();
}

class _AnimePlayerPageState2 extends State<AnimePlayerPage2> {
  late VideoPlayerController _controller;
  late Future<void>? _initializeVideoPlayerFuture;
  int playBackTime = 0;
  bool isError = false;

  //The values that are passed when changing quality
  late Duration newCurrentPosition;

  String defaultStream =
      'https://cloud.kodik-storage.com/useruploads/59f49139-cd53-4e4d-a441-e9482827d700/e7f70734702aa4dc0644d245cbad6e03:2023031923/720.mp4:hls:manifest.m3u8';
  String stream2 =
      'https://cloud.kodik-storage.com/useruploads/59f49139-cd53-4e4d-a441-e9482827d700/e7f70734702aa4dc0644d245cbad6e03:2023031923/480.mp4:hls:manifest.m3u8';
  String stream3 =
      'https://cloud.kodik-storage.com/useruploads/59f49139-cd53-4e4d-a441-e9482827d700/e7f70734702aa4dc0644d245cbad6e03:2023031923/360.mp4:hls:manifest.m3u8';

  @override
  void initState() {
    _controller = VideoPlayerController.network(defaultStream);
    _controller.addListener(() {
      if (_controller.value.hasError) {
        setState(() {
          isError = true;
        });
        log(_controller.value.errorDescription ?? '', name: 'AnimePlayerPage');
      }
      if (_controller.value.isInitialized) {}
      if (_controller.value.isBuffering) {}
      setState(() {
        playBackTime = _controller.value.position.inSeconds;
      });
    });
    _initializeVideoPlayerFuture = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _initializeVideoPlayerFuture = null;
    _controller.pause().then((value) => _controller.dispose());
    //_controller.dispose();
    super.dispose();
  }

  Future<bool> _clearPrevious() async {
    await _controller.pause();
    return true;
  }

  Future<void> _initializePlay(String videoPath) async {
    _controller = VideoPlayerController.network(videoPath);
    _controller.addListener(() {
      setState(() {
        playBackTime = _controller.value.position.inSeconds;
      });
    });
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.seekTo(newCurrentPosition);
      _controller.play();
    });
  }

  void _getValuesAndPlay(String videoPath) {
    newCurrentPosition = _controller.value.position;
    _startPlay(videoPath);
    log(newCurrentPosition.toString(), name: 'AnimePlayerPage');
  }

  Future<void> _startPlay(String videoPath) async {
    setState(() {
      _initializeVideoPlayerFuture = null;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _clearPrevious().then((_) {
        _initializePlay(videoPath);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return const Scaffold(
        body: Center(
          child: Text('error'),
        ),
      );
    }
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: <Widget>[
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(_controller),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.black54,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FloatingActionButton(
                        onPressed: () {
                          // Wrap the play or pause in a call to `setState`. This ensures the
                          // correct icon is shown.
                          setState(() {
                            // If the video is playing, pause it.
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              // If the video is paused, play it.
                              _controller.play();
                            }
                          });
                        },
                        // Display the correct icon depending on the state of the player.
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                      Text(
                        _controller.value.position
                            .toString()
                            .split('.')
                            .first
                            .padLeft(8, "0"),
                      ),
                      ElevatedButton(
                        //color: Colors.yellow,
                        onPressed: () {
                          _getValuesAndPlay(defaultStream);
                        },
                        child: const Text('Default Stream'),
                      ),
                      ElevatedButton(
                        //color: Colors.red,
                        onPressed: () {
                          _getValuesAndPlay(stream2);
                        },
                        child: const Text('Video Stream 2'),
                      ),
                      ElevatedButton(
                        //color: Colors.green,
                        onPressed: () {
                          _getValuesAndPlay(stream3);

                          //print('Green Button');
                        },
                        child: const Text('Video Stream 3'),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
