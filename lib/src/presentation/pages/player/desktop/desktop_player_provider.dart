import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:flutter/foundation.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../../kodik/kodik.dart';
import '../../../../../kodik/models/kodik_parsed_video.dart';
import '../../../../../secret.dart';
import '../../../../constants/config.dart';
import '../../../../domain/enums/stream_quality.dart';
import '../../../../domain/models/anime_player_page_extra.dart';
import '../../../../services/anime_database/anime_database_provider.dart';
import '../../../../utils/shaders.dart';
import '../../../providers/settings_provider.dart';

class DesktopPlayerParameters extends Equatable {
  final AnimePlayerPageExtra extra;

  const DesktopPlayerParameters(this.extra);

  @override
  List<Object> get props => [extra];
}

final desktopPlayerProvider = ChangeNotifierProvider.family
    .autoDispose<DesktopPlayerNotifier, DesktopPlayerParameters>((ref, extra) {
  final c = DesktopPlayerNotifier(
    ref: ref,
    extra: extra.extra,
  );

  c.initState();

  ref.onDispose(c.disposeState);

  return c;
}, name: 'desktopPlayerProvider');

class DesktopPlayerNotifier extends ChangeNotifier {
  final Ref ref;
  final AnimePlayerPageExtra extra;

  DesktopPlayerNotifier({required this.ref, required this.extra})
      : streamAsync = const AsyncValue.loading();

  late final Player player = Player(
    configuration: const PlayerConfiguration(
      title: 'ShikiWatch',
      logLevel: MPVLogLevel.warn,
    ),
  );
  late final playerController = VideoController(player);
  late SharedPreferences prefs;

  AsyncValue<KodikParsedVideo?> streamAsync;

  final rpc = DiscordRPC(
    applicationId: kDiscordAppId,
  );

  bool discordRpc = false;
  bool shaders = false;
  bool shadersExists = false;

  String? oldTitle;
  Directory? appDir;

  String? streamFhd;
  String? streamHd;
  String? streamSd;
  String? streamLow;

  bool _disposed = false;

  final List<StreamSubscription> subscriptions = [];
  bool playing = false;
  bool buffering = true;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  Duration buffer = Duration.zero;
  double volume = 0.0;

  StreamQuality selectedQuality = StreamQuality.fhd;

  Future<void> initState() async {
    oldTitle = await windowManager.getTitle();

    if (extra.isLibria) {
      streamAsync = const AsyncValue.data(null);
    } else {
      streamAsync = await AsyncValue.guard(
        () async {
          final links = await ref
              .read(kodikVideoProvider)
              .getHLSLink(episodeLink: extra.episodeLink);
          return links;
        },
      );
    }

    streamAsync.whenOrNull(
      error: (error, stackTrace) {
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setContexts(
              'context',
              {
                'shikimoriId': extra.shikimoriId,
                'shikimoriName': extra.animeName,
                'studioId': extra.studioId,
                'studioName': extra.studioName,
                'episodeNumber': extra.episodeNumber,
                'episodeLink': extra.episodeLink,
              },
            );

            scope.level = SentryLevel.error;
          },
        );
        //notifyListeners();
      },
    );

    streamAsync.whenData((value) async {
      streamLow = extra.isLibria ? null : value!.video360;
      streamSd = extra.isLibria ? null : value!.video480;
      streamHd = extra.isLibria ? extra.libriaEpisode!.hd : value!.video720;

      if (extra.isLibria) {
        extra.libriaEpisode!.fnd != null
            ? streamFhd = extra.libriaEpisode!.host + extra.libriaEpisode!.fnd!
            : streamFhd = null;

        extra.libriaEpisode!.hd != null
            ? streamHd = extra.libriaEpisode!.host + extra.libriaEpisode!.hd!
            : streamHd = null;

        streamSd = null;
        streamLow = null;
      } else {
        streamFhd = null;
        streamHd = value!.video720;
        streamSd = value.video480;
        streamLow = value.video360;
      }

      if (streamFhd == null) {
        if (streamHd == null) {
          if (streamSd == null) {
            if (streamLow == null) {
              // все, хана, нету качества че делать
            } else {
              selectedQuality = StreamQuality.low;
            }
          } else {
            selectedQuality = StreamQuality.sd;
          }
        } else {
          selectedQuality = StreamQuality.hd;
        }
      } else {
        selectedQuality = StreamQuality.fhd;
      }

      _pipeLogsToConsole(player);

      appDir = await getApplicationSupportDirectory();

      await windowManager
          .setTitle('${extra.animeName} - Серия ${extra.episodeNumber}');

      final dr = ref.read(
          settingsProvider.select((settings) => settings.playerDiscordRpc));

      if (dr) {
        _setRpc();
      }

      // if (player.platform is NativePlayer) {
      //   await (player.platform as NativePlayer)
      //       .setProperty("profile", 'gpu-hq');
      //   await (player.platform as NativePlayer)
      //       .setProperty("scale", 'ewa_lanczossharp');
      //   await (player.platform as NativePlayer)
      //       .setProperty("cscale", 'ewa_lanczossharp');
      // }

      await player.open(
        Media(streamFhd ?? streamHd ?? streamSd ?? streamLow!),
        play: false,
      );

      if (extra.startPosition.isNotEmpty) {
        await (player.platform as NativePlayer).setProperty(
          "start",
          extra.startPosition,
        );
        await player.seek(_parseDuration(extra.startPosition));
      }

      prefs = await SharedPreferences.getInstance();

      await player.setVolume(prefs.getDouble('player_volume') ?? 40.0);

      await player.play();

      playing = player.state.playing;
      buffering = player.state.buffering;
      position = player.state.position;
      duration = player.state.duration;
      buffer = player.state.buffer;
      volume = player.state.volume;

      subscriptions.addAll(
        [
          player.stream.playing.listen((event) {
            if (_disposed) {
              return;
            }

            playing = event;
            notifyListeners();
          }),
          player.stream.buffering.listen((event) {
            if (_disposed) {
              return;
            }
            buffering = event;
            notifyListeners();
          }),
          player.stream.position
              .distinct(
                  (a, b) => (a - b).abs() < const Duration(milliseconds: 200))
              .listen((event) {
            if (_disposed) {
              return;
            }
            position = event;
            notifyListeners();
          }),
          player.stream.duration.listen((event) {
            if (_disposed) {
              return;
            }
            duration = event;
            notifyListeners();
          }),
          player.stream.buffer
              .distinct(
                  (a, b) => (a - b).abs() < const Duration(milliseconds: 200))
              .listen((event) {
            if (_disposed) {
              return;
            }
            buffer = event;
            notifyListeners();
          }),
          player.stream.volume.listen((event) {
            if (_disposed) {
              return;
            }
            volume = event;
            notifyListeners();
          }),
        ],
      );
    });

    notifyListeners();
  }

  Future<void> disposeState() async {
    _disposed = true;

    if (discordRpc) {
      rpc.clearPresence();
    }

    if (oldTitle != null) await windowManager.setTitle(oldTitle!);

    await player.pause();
    await player.dispose();

    for (final s in subscriptions) {
      await s.cancel();
    }
  }

  Future<void> toggleShaders() async {
    if (shaders) {
      await (player.platform as NativePlayer).setProperty('glsl-shaders', '');
      shaders = false;

      notifyListeners();
    } else {
      bool exists = await Directory(getShadersDir(appDir!.path)).exists();
      shadersExists = exists;
      if (!exists) {
        notifyListeners();
        return;
      }
      await (player.platform as NativePlayer).setProperty(
        'glsl-shaders',
        anime4kModeDoubleA(appDir!.path),
      ); //  anime4kModeDoubleA  || anime4kModeAFast || anime4kModeGan

      shaders = true;
      notifyListeners();
    }
  }

  Future<void> updateDataBase() async {
    if (position == Duration.zero) {
      return;
    }

    bool isCompl = false;
    String timeStamp = 'Просмотрено до ${_formatDuration(position)}';

    if (duration.inSeconds / position.inSeconds < 1.2) {
      isCompl = true;
      timeStamp = 'Просмотрено полностью';
    }

    await ref.read(animeDatabaseProvider).updateEpisode(
          complete: isCompl,
          shikimoriId: extra.shikimoriId,
          animeName: extra.animeName,
          imageUrl: extra.imageUrl,
          timeStamp: timeStamp,
          studioId: extra.studioId,
          studioName: extra.studioName,
          studioType: extra.studioType,
          episodeNumber: extra.episodeNumber,
          position: position.toString(),
        );
  }

  void saveVolume(double value) async {
    await prefs.setDouble('player_volume', value.roundToDouble());
  }

  Future<void> toggleFullScreen({bool p = false}) async {
    bool full = await windowManager.isFullScreen();

    if (full || p) {
      if (!full) {
        return;
      }

      await windowManager.setFullScreen(false);
    } else {
      await windowManager.setFullScreen(true);
    }
  }

  void _setRpc() {
    rpc.start(autoRegister: true);
    rpc.updatePresence(
      DiscordPresence(
        details: 'Смотрит ${extra.animeName}',
        state: 'Серия ${extra.episodeNumber}',
        //startTimeStamp: DateTime.now().millisecondsSinceEpoch,
        //largeImageKey: 'large_image',
        largeImageKey: AppConfig.staticUrl + extra.imageUrl,
        largeImageText: 'гайки хавать будешь?',
        button1Label: 'Открыть',
        button1Url: '${AppConfig.staticUrl}/animes/${extra.shikimoriId}',
        //smallImageKey: 'small_image',
        //smallImageText: 'This text describes the small image.',
      ),
    );
    discordRpc = true;
  }

  void _pipeLogsToConsole(Player player) {
    player.stream.log.listen(
      (event) {
        if (kDebugMode) {
          log('${event.prefix}: ${event.level}: ${event.text}',
              name: 'mpv player');
        }
      },
    );
  }

  Duration _parseDuration(String s) {
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

  _formatDuration(Duration d) {
    String tmp = d.toString().split('.').first.padLeft(8, "0");
    return tmp.replaceFirst('00:', '');
  }
}
