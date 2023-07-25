import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart' as flutter;
import 'package:flutter/services.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:equatable/equatable.dart';
import 'package:wakelock/wakelock.dart';

import '../../services/anime_database/anime_database_provider.dart';
import '../../domain/models/anime_player_page_extra.dart';
import '../../../kodik/models/kodik_parsed_video.dart';
import '../../domain/enums/stream_quality.dart';
import '../../../kodik/kodik.dart';
import '../widgets/auto_hide.dart';

import 'anime_details_provider.dart';

class PlayerProviderParameters extends Equatable {
  final AnimePlayerPageExtra extra;

  const PlayerProviderParameters(this.extra);

  @override
  List<Object> get props => [extra];
}

final playerControllerProvider = ChangeNotifierProvider.family
    .autoDispose<PlayerController, PlayerProviderParameters>(
  (ref, parameter) {
    final c = PlayerController(
      ref: ref,
      extra: parameter.extra,
    );

    c.initState();
    ref.onDispose(c.disposeState);
    return c;
  },
);

class PlayerController extends flutter.ChangeNotifier {
  final AnimePlayerPageExtra extra;
  final AutoHideController hideController;
  final Ref ref;

  PlayerController({required this.ref, required this.extra})
      : streamAsync = const AsyncValue.loading(),
        hideController = AutoHideController(
          duration: const Duration(seconds: 3),
        );

  bool _disposed = false;
  int playBackTime = 0;
  bool isError = false;

  late VideoPlayerController playerController;

  AsyncValue<KodikParsedVideo?> streamAsync;

  late Duration savedPosition;

  String? streamFhd;
  String? streamHd;
  String? streamSd;
  String? streamLow;

  StreamQuality selectedQuality = StreamQuality.fhd;
  bool latestPlayingState = false;
  bool expandVideo = false;

  double playbackSpeed = 1.0;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool hasConnection = true;

  Future<void> initState() async {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

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
                'episodeAdditInfo': extra.additInfo,
                'episodeLink': extra.episodeLink,
              },
            );
            //scope.setTag('my-tag', 'my value');
            scope.level = SentryLevel.error;
          },
        );
        notifyListeners();
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

      // if (streamFhd == null) {
      //   selectedQuality = StreamQuality.hd;
      // } else if (streamHd == null) {
      //   selectedQuality = StreamQuality.sd;
      // }

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

      playerController = VideoPlayerController.networkUrl(
        Uri.parse(streamFhd ?? streamHd ?? streamSd ?? streamLow!),
      );

      playerController.addListener(playerCallback);
      hideController.addListener(hideCallback);

      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );

      playerController.initialize().then((_) async {
        if (extra.startPosition.isNotEmpty) {
          await playerController.seekTo(_parseDuration(extra.startPosition));
        }

        await playerController.play();
      });
      await Wakelock.enable();
    });
  }

  Future<void> disposeState() async {
    _disposed = true;

    _connectivitySubscription.cancel();

    streamAsync.whenData(
      (value) async {
        final currentPosDuration = playerController.value.position;
        final duration = playerController.value.duration.inSeconds;

        bool isCompl = false;
        String timeStamp =
            'Просмотрено до ${_formatDuration(currentPosDuration)}';

        if (duration / currentPosDuration.inSeconds < 1.2) {
          //1.3
          //1.03
          isCompl = true;
          timeStamp = 'Просмотрено полностью';
        }

        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          //overlays: [SystemUiOverlay.top],
        );

        await Wakelock.disable();

        playerController.pause().then(
          (value) {
            playerController.dispose();
            log('PlayerController disposed!', name: 'PlayerController');
          },
        );

        if (isError) {
          return;
        }

        await ref
            .read(animeDatabaseProvider)
            .updateEpisode(
              complete: isCompl,
              shikimoriId: extra.shikimoriId,
              animeName: extra.animeName,
              imageUrl: extra.imageUrl,
              timeStamp: timeStamp,
              studioId: extra.studioId,
              studioName: extra.studioName,
              studioType: extra.studioType,
              episodeNumber: extra.episodeNumber,
              position: playerController.value.position.toString(),
            )
            .then((value) => ref.invalidate(isAnimeInDataBaseProvider));
      },
    );
  }

  Future<void> hideCallback() async {
    if (_disposed) return;

    notifyListeners();

    if (hideController.isVisible) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top],
      );
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    //-----------------

    // if (hideController.isVisible) {
    //   // await SystemChrome.setEnabledSystemUIMode(
    //   //   SystemUiMode.manual,
    //   //   overlays: SystemUiOverlay.values,
    //   // );
    //   // await SystemChrome.setEnabledSystemUIMode(
    //   //   SystemUiMode.manual,
    //   //   overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    //   // );
    //   await SystemChrome.setEnabledSystemUIMode(
    //     SystemUiMode.edgeToEdge,
    //     overlays: [SystemUiOverlay.top],
    //   );
    // } else {
    //   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // }
  }

  Future<void> playerCallback() async {
    if (_disposed) return;

    playBackTime = playerController.value.position.inSeconds;

    playbackSpeed = playerController.value.playbackSpeed;

    if (playerController.value.hasError) {
      isError = true;
      hideController.permShow();

      log(playerController.value.errorDescription ?? '',
          name: 'PlayerController');

      Sentry.captureException(
        playerController.value.errorDescription,
        //stackTrace: stackTrace,
        withScope: (scope) {
          scope.setContexts(
            'context',
            {
              'shikimoriId': extra.shikimoriId,
              'shikimoriName': extra.animeName,
              'studioId': extra.studioId,
              'studioName': extra.studioName,
              'episodeNumber': extra.episodeNumber,
              'episodeAdditInfo': extra.additInfo,
              'episodeLink': extra.episodeLink,
            },
          );

          scope.level = SentryLevel.error;
        },
      );
    }

    notifyListeners();
  }

  String? get getStreamLink {
    switch (selectedQuality) {
      case StreamQuality.fhd:
        return streamFhd;
      case StreamQuality.hd:
        return streamHd;
      case StreamQuality.sd:
        return streamSd;
      case StreamQuality.low:
        return streamLow;
    }
  }

  void seekTo(Duration position) {
    playerController.seekTo(position);
  }

  void toggleExpand() {
    expandVideo = !expandVideo;
    notifyListeners();
  }

  Future<void> back() async {
    playerController.seekTo(
      (await playerController.position ?? Duration.zero) -
          const Duration(seconds: 10),
    );
  }

  Future<void> forward() async {
    playerController.seekTo(
      (await playerController.position ?? Duration.zero) +
          const Duration(seconds: 10),
    );
  }

  void changeStreamQuality(StreamQuality q) async {
    final s = getStreamLink;

    if (s == null) {
      return;
    }

    savedPosition = playerController.value.position;
    latestPlayingState = playerController.value.isPlaying;

    await _startPlay(
      videoUrl: s,
      position: savedPosition,
    );

    log(savedPosition.toString(), name: 'PlayerController');
  }

  Future<void> retryPlay() async {
    if (!hasConnection) {
      return;
    }

    hideController.hide();

    savedPosition = playerController.value.position;

    await Future.delayed(
      const Duration(milliseconds: 200),
      () {
        playerController.pause().then(
          (_) {
            playerController = VideoPlayerController.networkUrl(
              Uri.parse(streamFhd ?? streamHd ?? streamSd ?? streamLow!),
            );
            playerController.addListener(playerCallback);
            playerController.initialize().then(
              (_) async {
                await playerController.seekTo(savedPosition);
                await playerController.play();
                isError = false;
              },
            );
          },
        );
      },
    );
  }

  Future<void> _initializePlay(String videoPath, Duration? pos) async {
    playerController = VideoPlayerController.networkUrl(
      Uri.parse(videoPath),
    );

    playerController.addListener(playerCallback);

    playerController.initialize().then((_) {
      if (pos != null) playerController.seekTo(pos);
      if (latestPlayingState) playerController.play();
    });
  }

  Future<void> _startPlay(
      {required String videoUrl, Duration? position}) async {
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        playerController.pause().then((_) {
          _initializePlay(videoUrl, position);
        });
      },
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (_disposed) {
      return;
    }

    if (result.name == 'none') {
      hasConnection = false;
    } else {
      hasConnection = true;
    }

    notifyListeners();
  }

  String _formatDuration(Duration d) {
    String tmp = d.toString().split('.').first.padLeft(8, "0");
    return tmp.replaceFirst('00:', '');
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
}
