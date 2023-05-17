import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikidev/src/constants/config.dart';
//import 'package:super_clipboard/super_clipboard.dart';
import 'package:wakelock/wakelock.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../kodik/kodik.dart';
import '../../../../secret.dart';
import '../../../constants/box_types.dart';
import '../../../constants/hive_keys.dart';
import '../../../domain/models/anime_player_page_extra.dart';
import '../../../services/anime_database/anime_database_provider.dart';
import '../../../utils/shaders.dart';
import '../../../utils/utils.dart';
import '../../widgets/auto_hide.dart';
import '../../widgets/scrollable_slider.dart';

import 'continue_dialog.dart';

DiscordRPC rpc = DiscordRPC(
  applicationId: kDiscordAppId,
);

//desktop
class AnimePlayerDesktopPage extends StatefulHookConsumerWidget {
  final AnimePlayerPageExtra? data;

  const AnimePlayerDesktopPage({super.key, required this.data});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimePlayerDesktopPageState();
}

class _AnimePlayerDesktopPageState
    extends ConsumerState<AnimePlayerDesktopPage> {
  //AutoHideController? hideController;

  bool _disposed = false;
  bool shaders = false;

  final Player player = Player(
    configuration: const PlayerConfiguration(
      title: 'ShikiWatch',
      logLevel: MPVLogLevel.warn,
    ),
  );

  VideoController? controller;

  Directory? appDir;
  SharedPreferences? prefs;
  double? savedVolume;

  String? streamHd;
  String? streamSd;
  String? streamLow;

  String? oldTitle;
  Size? oldSize;
  // Size? oldMinSize;
  // Size? oldMaxSize;
  Offset? oldPos;

  final double pipSize = 550.0;
  final double pipMixSize = 300.0;
  final double pipMaxSize = 900.0;

  bool isLoading = true;
  bool isError = false;

  bool visibility = false;

  bool playing = false;
  bool buffering = true;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  List<StreamSubscription> subscriptions = [];

  bool isSetRpc = false;

  void setRpc(String animeName) {
    rpc.start(autoRegister: true);
    rpc.updatePresence(
      DiscordPresence(
        details: 'Смотрит $animeName',
        state: 'Серия ${widget.data!.episodeNumber}',
        //startTimeStamp: DateTime.now().millisecondsSinceEpoch,
        //largeImageKey: 'large_image',
        largeImageKey: AppConfig.staticUrl + widget.data!.imageUrl,
        largeImageText: 'гайки хавать будешь?',
        button1Label: 'Открыть',
        button1Url: '${AppConfig.staticUrl}/animes/${widget.data!.shikimoriId}',
        //smallImageKey: 'small_image',
        //smallImageText: 'This text describes the small image.',
      ),
    );
    isSetRpc = true;
  }

  // void toggleShaders(BuildContext ctx) async {
  void toggleShaders() async {
    if (shaders) {
      await (player.platform as libmpvPlayer).setProperty('glsl-shaders', '');
      setState(() {
        shaders = false;
      });
    } else {
      bool exists = await Directory(getShadersDir(appDir!.path)).exists();
      if (!exists && context.mounted) {
        //showSnackBar(context, 'Шейдеры не найдены');
        showSnackBar(
            ctx: context,
            msg: 'Шейдеры не найдены',
            dur: const Duration(seconds: 2));
        return;
      }
      await (player.platform as libmpvPlayer).setProperty(
          'glsl-shaders',
          anime4kModeAFast(appDir!
              .path)); //  anime4kModeDoubleA  || anime4kModeAFast || anime4kModeGan
      setState(() {
        shaders = true;
      });
    }
  }

  Future<void> hideCallback() async {
    if (_disposed) return;

    setState(() {});
  }

  void seekBack() {
    player.seek(position - const Duration(seconds: 5));
    // if (position - const Duration(seconds: 5) > duration) {
    //   player.seek(position - const Duration(seconds: 5));
    // } else {
    //   player.seek(Duration.zero);
    // }
  }

  void seekForward() {
    player.seek(position + const Duration(seconds: 5));
    // if (position + const Duration(seconds: 5) > duration) {
    //   player.seek(position + const Duration(seconds: 5));
    // } else {
    //   player.seek(duration);
    // }
  }

  bool _onKey(KeyEvent event) {
    final key = event.logicalKey.keyLabel;

    if (event is KeyDownEvent) {
      //print("Key down: $key");
    } else if (event is KeyUpEvent) {
      if (key == ' ') {
        player.playOrPause();
        //print("Key up: $key");
      }
      if (key == 'K') {
        player.playOrPause();
        //print("Key up: $key");
      }
      if (key == 'J') {
        seekBack();
        //print("Key up: $key");
      }
      if (key == 'L') {
        seekForward();
        //player.seek(position + const Duration(seconds: 5));
        //print("Key up: $key");
      }
      if (key == 'S' && !isLoading) {
        toggleShaders();
      }
      if (key == 'Escape' && !isLoading) {
        windowManager.isFullScreen().then(
          (value) {
            if (value) {
              toggleFullScreen(p: true);
            }
          },
        );
      }
      if (key == 'F11' && !isLoading) {
        toggleFullScreen();
      }
      //print("Key up: $key");
    } else if (event is KeyRepeatEvent) {
      //print("Key repeat: $key");
    }

    return false;
  }

  formatDuration(Duration d) {
    String tmp = d.toString().split('.').first.padLeft(8, "0");
    return tmp.replaceFirst('00:', '');
  }

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  @override
  void initState() {
    super.initState();

    ServicesBinding.instance.keyboard.addHandler(_onKey);

    pipeLogsToConsole(player);

    //setRpc(widget.data!.animeName);

    var box = Hive.box(BoxType.settings.name);
    bool dr = box.get(
      playerDiscordRpc,
      defaultValue: false,
    );

    if (dr) {
      setRpc(widget.data!.animeName);
    }

    //hideController = AutoHideController(
    //  duration: const Duration(seconds: 3),
    //);

    //hideController!.addListener(hideCallback);

    Future.microtask(() async {
      appDir = await getApplicationSupportDirectory();
      prefs = await SharedPreferences.getInstance();
      savedVolume = prefs!.getDouble('player_volume');

      oldTitle = await windowManager.getTitle();
      //oldSize = await windowManager.getSize();
      //oldPos = await windowManager.getPosition();
      //print('debug:: $oldTitle');
      //await windowManager.setSize(Size(pipSize, pipSize / (16 / 9)));
      //await windowManager
      //    .setMinimumSize(Size(pipMixSize, pipMixSize / (16 / 9)));

      //await windowManager
      //    .setMaximumSize(Size(pipMaxSize, pipMaxSize / (16 / 9))); //vpizdu

      //await windowManager.setAspectRatio(16 / 9);
      // await windowManager.setTitle('anime name - seria 1');
      // await windowManager.setTitle(
      //     '${widget.data!.animeName} - Серия ${widget.data!.episodeNumber}');
      //await windowManager.setAlwaysOnTop(true);
      //await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      //await windowManager.setAlignment(Alignment.bottomRight);

      //await getHLSLink(widget.data!.episodeLink);
      final list = await ref
          .read(kodikVideoProvider)
          .getHLSLink(episodeLink: widget.data!.episodeLink);

      streamHd = list.video720!;
      streamSd = list.video480!;
      streamLow = list.video720!;

      controller = await VideoController.create(player,
          enableHardwareAcceleration: true);

      await windowManager.setTitle(
          '${widget.data!.animeName} - Серия ${widget.data!.episodeNumber}');

      if (player.platform is libmpvPlayer) {
        await (player.platform as libmpvPlayer)
            .setProperty("profile", 'gpu-hq');
        await (player.platform as libmpvPlayer)
            .setProperty("scale", 'ewa_lanczossharp');
        await (player.platform as libmpvPlayer)
            .setProperty("cscale", 'ewa_lanczossharp');
      }

      await player.open(
        Playlist(
          [
            Media(streamHd!),
          ],
        ),
        play: false,
      );

      if (widget.data!.position != null) {
        // ignore: use_build_context_synchronously
        bool? dialogValue = await showDialog<bool>(
          context: context,
          builder: (context) => const ContinueDialog(),
        );
        //print('Dialog returned value ---> $dialogValue');
        if (dialogValue ?? false) {
          await (player.platform as libmpvPlayer).setProperty(
            "start",
            widget.data!.position!,
          );
          await player.seek(parseDuration(widget.data!.position!));
        }
      }

      await player.play();

      await player.setVolume(savedVolume ?? 30.0);

      await Wakelock.enable();

      isLoading = false;

      if (isError) {
        isLoading = true;
      }

      setState(() {});
    });

    playing = player.state.playing;
    buffering = player.state.buffering;
    position = player.state.position;
    duration = player.state.duration;
    subscriptions.addAll(
      [
        player.streams.playing.listen((event) {
          setState(() {
            if (mounted) {
              playing = event;
            }
          });
        }),
        player.streams.buffering.listen((event) {
          setState(() {
            buffering = event;
          });
        }),
        player.streams.position.listen((event) {
          setState(() {
            position = event;
          });
        }),
        player.streams.duration.listen((event) {
          setState(() {
            duration = event;
          });
        }),
      ],
    );
  }

  @override
  //void dispose() {
  Future<void> dispose() async {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    _disposed = true;

    if (isSetRpc) {
      rpc.clearPresence();
    }

    // Future.delayed(Duration.zero, () async {
    //   await doingSomething()
    //       .then((value) => print('niggers ${widget.data!.shikimoriId}'));
    // });

    //Future.microtask(() async {
    Future.delayed(Duration.zero, () async {
      await windowManager.setTitle(oldTitle ?? '');
      await player.pause();

      await Wakelock.disable();

      //await windowManager.setAspectRatio(0);
      //await windowManager.setSize(oldSize!);
      //await windowManager.setMinimumSize(const Size(900, 500));
      //await windowManager.setAlwaysOnTop(false);
      //await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      //await windowManager.setAlignment(Alignment.center);
      //await windowManager.setPosition(oldPos!);
      debugPrint('Disposing [Player] and [VideoController]...');
      await controller?.dispose();
      await player.dispose();
    });
    for (final s in subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  Future<void> updateDb() async {
    final currentPosDuration = position;
    final durationSec = duration.inSeconds;

    bool isCompl = false;
    String timeStamp = 'Просмотрено до ${formatDuration(currentPosDuration)}';

    // log('time stamp: ${formatDuration(currentPosDuration)}',
    //     name: 'PlayerController');

    if (durationSec / currentPosDuration.inSeconds < 1.2) {
      //1.3
      //1.03
      log('completed', name: 'PlayerController');
      isCompl = true;
      timeStamp = 'Просмотрено полностью';
    }

    //if (mounted) {
    ref.read(animeDatabaseProvider).updateEpisode(
          complete: isCompl,
          shikimoriId: widget.data!.shikimoriId,
          animeName: widget.data!.animeName,
          imageUrl: widget.data!.imageUrl,
          timeStamp: timeStamp,
          studioId: widget.data!.studioId,
          studioName: widget.data!.studioName,
          studioType: widget.data!.studioType,
          episodeNumber: widget.data!.episodeNumber,
          position: position.toString(),
        );
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Align(
            child: Video(
              controller: controller,
              filterQuality: FilterQuality.high,
              fill: Colors.transparent,
              fit: BoxFit.contain, //cover
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              player.playOrPause();
            },
            onDoubleTap: () async {
              await toggleFullScreen();
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              //child: Container(color: Colors.black54),
              child: !playing || visibility
                  ? Container(color: Colors.black54)
                  : const SizedBox.shrink(),
            ),
            // Visibility(
            //   visible: !playing || visibility,
            //   child: Container(color: Colors.black54),
            // ),
          ),
          // AutoHide(
          //   switchDuration: const Duration(milliseconds: 250),
          //   controller: hideController!,
          //   child: GestureDetector(
          //     onTap: () {
          //       player.playOrPause();
          //       //print('GestureDetector onTap');
          //     },
          //     onDoubleTap: () async {
          //       //await changeFullScreen();
          //       //print('GestureDetector onDoubleTap');
          //     },
          //     child: Container(color: Colors.black54),
          //   ),
          // ),
          if (isLoading && !isError)
            const Align(child: CircularProgressIndicator()),
          if (buffering) const Align(child: CircularProgressIndicator()),
          if (isError)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('Ошибка воспроизведения'),
                ],
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: !playing || visibility
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: IconButton(
                        padding: const EdgeInsets.all(0),
                        //onPressed: () => Navigator.pop(context),
                        onPressed: () async {
                          await toggleFullScreen(p: true);
                          await updateDb()
                              .then(
                            (value) => Navigator.pop(context),
                          )
                              .catchError(
                            (e) {
                              showSnackBar(
                                  ctx: context,
                                  msg: 'Ошибка добавления ${e.toString()}',
                                  dur: const Duration(seconds: 3));
                              Navigator.pop(context);
                            },
                          );
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        iconSize: 24.0,
                        tooltip: 'Назад',
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: !playing || visibility
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: PlayerControls(
                      player: player,
                      hide: null,
                      prefs: prefs,
                      animeName: widget.data!.animeName,
                      studioName: widget.data!.studioName,
                      episodeNumber: widget.data!.episodeNumber,
                      stream720: streamHd,
                      stream480: streamSd,
                      stream360: streamLow,
                      isLoading: isLoading,
                      shaders: shaders,
                      onBack: () {},
                      animePic: widget.data!.imageUrl,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          MouseRegion(
            // onHover: (_) => hideController!.show(),
            // onExit: (_) => hideController!.hide(),
            //cursor: visibility ? SystemMouseCursors.basic : SystemMouseCursors.none,
            onHover: (event) {
              setState(() {
                visibility = true;
              });
            },
            onExit: (event) {
              if (_disposed) {
                return;
              }
              if (!context.mounted) {
                return;
              }
              if (_disposed) {
                return;
              }
              Future.delayed(const Duration(seconds: 0), () {
                setState(() {
                  visibility = false;
                });
              });
              // setState(() {
              //   visibility = false;
              // });
            },
            opaque: false,
          ),
        ],
      ),
    );
  }
}

const List<String> list = <String>['720p', '480p', '360p'];

class PlayerControls extends StatefulWidget {
  final Player player;
  final AutoHideController? hide;
  final SharedPreferences? prefs;
  final String animeName;
  final String studioName;
  final String animePic;
  final int episodeNumber;
  final String? stream720;
  final String? stream480;
  final String? stream360;
  final bool isLoading;
  final bool shaders;

  final VoidCallback onBack;

  const PlayerControls({
    super.key,
    required this.player,
    required this.hide,
    required this.prefs,
    required this.animeName,
    required this.studioName,
    required this.episodeNumber,
    required this.stream720,
    required this.stream480,
    required this.stream360,
    required this.isLoading,
    required this.onBack,
    required this.shaders,
    required this.animePic,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  final List<StreamSubscription> subscriptions = [];
  bool playing = false;
  //bool shaders = false;

  Duration currPos = Duration.zero;
  Duration savedPos = Duration.zero;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  Duration buffer = Duration.zero;

  double volume = 0.0;
  bool isMute = false;
  double lastVolume = 0;

  String dropdownValue = list.first;

  //Directory? appDir;

  @override
  void initState() {
    super.initState();

    playing = widget.player.state.playing;
    //buffering = widget.player.state.buffering;
    position = widget.player.state.position;
    duration = widget.player.state.duration;
    buffer = widget.player.state.buffer;
    volume = widget.player.state.volume;
    subscriptions.addAll(
      [
        widget.player.streams.playing.listen((event) {
          setState(() {
            playing = event;
          });
        }),
        widget.player.streams.position.listen((event) {
          setState(() {
            position = event;
          });
        }),
        widget.player.streams.duration.listen((event) {
          setState(() {
            duration = event;
          });
        }),
        widget.player.streams.volume.listen((event) {
          //print('player volume: $volume');
          setState(() {
            volume = event;
          });
        }),
        widget.player.streams.buffer.listen((event) {
          //print('player volume: $volume');
          setState(() {
            buffer = event;
          });
        }),
        // widget.player.streams.buffering.listen((event) {
        //   setState(() {
        //     buffering = event;
        //   });
        // }),
      ],
    );
  }

  @override
  void dispose() {
    for (final s in subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  void mute() {
    if (!isMute) {
      lastVolume = volume;
      widget.player.setVolume(0);
    } else {
      widget.player.setVolume(lastVolume);
    }
    setState(() {
      isMute = !isMute;
    });
  }

  void seekTo(Duration position) {
    widget.player.seek(position);
  }

  void saveVolume(double value) async {
    if (widget.prefs == null) {
      return;
    }
    await widget.prefs!.setDouble('player_volume', value.roundToDouble());
  }

  // Future<void> takescrshot() {
  //   return Future.delayed(const Duration(milliseconds: 20), () async {
  //     RenderRepaintBoundary? boundary = playerKey.currentContext!
  //         .findRenderObject() as RenderRepaintBoundary?;
  //     ui.Image image = await boundary!.toImage();
  //     ByteData? byteData =
  //         await image.toByteData(format: ui.ImageByteFormat.png);
  //     Uint8List pngBytes = byteData!.buffer.asUint8List();
  //     final item = DataWriterItem();
  //     item.add(Formats.png(pngBytes));
  //     await ClipboardWriter.instance.write([item]);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start, //spaceBetween
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: CachedNetworkImage(
                  imageUrl: AppConfig.staticUrl + widget.animePic,
                  height: 60,
                ),
                // ExtendedImage.network(
                //   AppConfig.staticUrl + widget.animePic,
                //   height: 60,
                // ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.animeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Серия ${widget.episodeNumber} • ${widget.studioName}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              const Spacer(),

              // if (shaders)
              //   ElevatedButton(
              //       onPressed:
              //           widget.isLoading ? null : () => toggleShaders(context),
              //       child: const Text('Disable anime4K')),
              // if (!shaders)
              //   ElevatedButton(
              //     onPressed:
              //         widget.isLoading ? null : () => toggleShaders(context),
              //     child: const Text('Enable anime4K'),
              //   ),
              // ElevatedButton(
              //   onPressed:
              //       widget.isLoading ? null : () => toggleShaders(context),
              //   child: shaders
              //       ? const Text('Disable anime4K')
              //       : const Text('Enable anime4K'),
              // ),
              // ElevatedButton(
              //   onPressed: widget.isLoading
              //       ? null
              //       : () async {
              //           bool exists =
              //               await Directory(getShadersDir(appDir!.path))
              //                   .exists();
              //           if (!exists && context.mounted) {
              //             showSnackBar(context, 'Шейдеры не найдены');
              //             return;
              //           }
              //           await (widget.player.platform as libmpvPlayer)
              //               .setProperty(
              //             'glsl-shaders',
              //             anime4kModeDoubleAFast(appDir!.path),
              //           );
              //         },
              //   child: const Text(
              //     'Set',
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              // ElevatedButton(
              //   onPressed: widget.isLoading
              //       ? null
              //       : () async {
              //           await (widget.player.platform as libmpvPlayer)
              //               .setProperty('glsl-shaders', '');
              //         },
              //   child: const Text(
              //     'Clear',
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              // ElevatedButton(
              //   onPressed: widget.isLoading
              //       ? null
              //       : () {
              //           widget.player.seek(
              //             position + const Duration(seconds: 70),
              //           );
              //         },
              //   child: const Text(
              //     //'Пропустить опенинг',
              //     '+110 сек.',
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              IconButton(
                tooltip: 'Перемотать 125 секунд',
                iconSize: 32,
                color: Colors.white,
                onPressed: widget.isLoading
                    ? null
                    : () {
                        widget.player.seek(
                          position + const Duration(seconds: 85),
                        );
                      },
                icon: const Icon(Icons.forward_30),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          ProgressBar(
            progress: position,
            total: duration,
            buffered: buffer,
            thumbRadius: 8,
            timeLabelPadding: 4,
            timeLabelTextStyle: const TextStyle(color: Colors.white),
            thumbGlowRadius: 24,
            onSeek: seekTo,
            // onDragUpdate: (_) {
            //   if (widget.hide.isVisible) {
            //     widget.hide.show();
            //   }
            // },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // IconButton(
                      //   splashRadius: 12,
                      //   padding: const EdgeInsets.all(0),
                      //   onPressed: () {
                      //     mute();
                      //   },
                      //   //icon: const Icon(Icons.volume_up),
                      //   icon: isMute
                      //       ? const Icon(Icons.volume_off)
                      //       : const Icon(Icons.volume_up),
                      //   color: Colors.white,
                      //   iconSize: 24.0,
                      //   tooltip: isMute ? 'Включить звук' : 'Выключить звук',
                      // ),
                      // const SizedBox(
                      //   width: 4.0,
                      // ),
                      SizedBox(
                        width: 100,
                        //height: 10,
                        child: ScrollableSlider(
                          min: 0,
                          max: 100,
                          value: volume,
                          onScrolledUp: () {
                            final vol = (volume.clamp(0.0, 100.0) + 5.0)
                                .clamp(0.0, 100.0);
                            saveVolume(vol);
                            widget.player.setVolume(vol);
                          },
                          onScrolledDown: () {
                            final vol = (volume.clamp(0.0, 100.0) - 5.0)
                                .clamp(0.0, 100.0);
                            saveVolume(vol);
                            widget.player.setVolume(vol);
                          },
                          onChanged: (double value) {
                            saveVolume(value);
                            widget.player.setVolume(value);
                            //setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),

                      Text(
                        '${volume.round()}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed:
                            widget.isLoading ? null : widget.player.playOrPause,
                        icon: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                        ),
                        color: Colors.white,
                        iconSize: 48.0,
                        //tooltip: '',
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
                      Tooltip(
                        message: 'Anime4K (S)',
                        child: Icon(
                          widget.shaders ? Icons.four_k : Icons.four_k_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),

                      // IconButton(
                      //   padding: const EdgeInsets.all(0),
                      //   onPressed: widget.isLoading
                      //       ? null
                      //       : () async {
                      //           await takescrshot();
                      //           if (mounted) {
                      //             showSnackBar(
                      //                 ctx: context,
                      //                 msg: 'Скриншот скопирован в буфер обмена',
                      //                 dur: const Duration(seconds: 2));
                      //           }
                      //         },
                      //   icon: const Icon(Icons.screenshot_monitor),
                      //   color: Colors.white,
                      //   iconSize: 24.0,
                      //   tooltip: 'Сделать скриншот',
                      // ),
                      IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: widget.isLoading
                            ? null
                            : () async {
                                await toggleFullScreen();
                              },
                        icon: const Icon(Icons.fullscreen),
                        color: Colors.white,
                        iconSize: 24.0,
                        tooltip: 'Полноэкранный режим',
                      ),
                      IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: widget.isLoading ? null : null,
                        icon: const Icon(Icons.picture_in_picture_alt),
                        color: Colors.white,
                        iconSize: 24.0,
                        tooltip: 'Режим картинка в картинке',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QualityTextWidget extends StatelessWidget {
  final String quality;
  final AutoHideController hide;
  const QualityTextWidget(
      {super.key, required this.quality, required this.hide});

  @override
  Widget build(BuildContext context) {
    // return Stack(
    //   children: [

    //   ],
    // );

    // return const Icon(Icons.hd, color: Colors.white,);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          quality,
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
        const Icon(
          Icons.expand_more,
          color: Colors.white,
        )
      ],
    );
  }
}

void pipeLogsToConsole(Player player) {
  player.streams.log.listen((event) {
    if (kDebugMode) {
      log('${event.prefix}: ${event.level}: ${event.text}', name: 'mpv player');
      //print("mpv: ${event.prefix}: ${event.level}: ${event.text}");
    }
  });
}

Future<void> toggleFullScreen({bool p = false}) async {
  bool full = await windowManager.isFullScreen();

  // if (p) {
  //   await windowManager.setFullScreen(false);
  //   await Future.delayed(const Duration(milliseconds: 200));
  //   await windowManager.setBounds((await windowManager.getBounds()).inflate(1));
  //   await windowManager
  //       .setBounds((await windowManager.getBounds()).inflate(-1));

  //   return;
  // }

  if (full || p) {
    if (!full) {
      return;
    }

    await windowManager.setFullScreen(false);
    await Future.delayed(const Duration(milliseconds: 200));
    await windowManager.setBounds((await windowManager.getBounds()).inflate(1));
    await windowManager
        .setBounds((await windowManager.getBounds()).inflate(-1));
  } else {
    await windowManager.setFullScreen(true);
  }
}
