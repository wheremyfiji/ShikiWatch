import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart' as flutter;
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../../../kodik/kodik.dart';
import '../../../kodik/models/kodik_parsed_video.dart';
import '../../services/anime_database/anime_database_provider.dart';
import '../widgets/auto_hide.dart';

class PlayerProviderParameters extends Equatable {
  const PlayerProviderParameters(
      {required this.studioId,
      required this.shikimoriId,
      required this.episodeNumber,
      required this.animeName,
      required this.imageUrl,
      required this.studioName,
      required this.studioType,
      required this.episodeLink,
      required this.episodeAdditInfo,
      required this.position});

  final int studioId;
  final int shikimoriId;
  final int episodeNumber;
  final String animeName;
  final String imageUrl;
  final String studioName;
  final String studioType;
  final String episodeLink;
  final String episodeAdditInfo;
  final String position;

  @override
  List<Object> get props => [
        studioId,
        shikimoriId,
        animeName,
        imageUrl,
        studioName,
        studioType,
        episodeNumber,
        episodeLink,
        episodeAdditInfo,
        position
      ];
}

final playerControllerProvider = ChangeNotifierProvider.family
    .autoDispose<PlayerController, PlayerProviderParameters>(
  (ref, parameter) {
    final c = PlayerController(
        ref,
        parameter.studioId,
        parameter.shikimoriId,
        parameter.episodeNumber,
        parameter.animeName,
        parameter.imageUrl,
        parameter.studioName,
        parameter.studioType,
        parameter.episodeLink,
        parameter.episodeAdditInfo,
        parameter.position);
    c.initState();
    ref.onDispose(c.disposeState);
    return c;
  },
);

class PlayerController extends flutter.ChangeNotifier {
  PlayerController(
      this._ref,
      int stdId,
      int shikiId,
      int epNumber,
      String anmName,
      String imgUrl,
      String stdName,
      String stdType,
      String epLink,
      String addInfo,
      String pos)
      : studioId = stdId,
        shikimoriId = shikiId,
        episodeNumber = epNumber,
        animeName = anmName,
        imageUrl = imgUrl,
        studioName = stdName,
        studioType = stdType,
        episodeLink = epLink,
        episodeAdditInfo = addInfo,
        playPos = pos,
        streamAsync = const AsyncValue.loading(),
        hideController = AutoHideController(
          duration: const Duration(seconds: 3),
        );

  final Ref _ref;
  bool _disposed = false;
  int playBackTime = 0;
  bool isError = false;

  //String parseUrl = '';
  final int studioId;
  final int shikimoriId;
  final int episodeNumber;
  final String animeName;
  final String imageUrl;
  final String studioName;
  final String studioType;
  final String episodeLink;
  final String episodeAdditInfo;
  final String playPos;

  late VideoPlayerController playerController;
  final AutoHideController hideController;

  AsyncValue<KodikParsedVideo> streamAsync;

  late Duration newCurrentPosition;

  String? streamHd;
  String? streamSd;
  String? streamLow;

  int streamQuality = 0;
  bool enableSwipe = false;
  bool expandVideo = false;

  //ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool hasConnection = true;

  Future<void> initState() async {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    streamAsync = await AsyncValue.guard(
      () async {
        final links = await _ref
            .read(kodikVideoProvider)
            .getHLSLink(episodeLink: episodeLink);
        return links;
      },
    );
    streamAsync.whenOrNull(
      error: (error, stackTrace) {
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setContexts(
              'context',
              {
                'shikimoriId': shikimoriId,
                'shikimoriName': animeName,
                'studioId': studioId,
                'studioName': studioName,
                'episodeNumber': episodeNumber,
                'episodeAdditInfo': episodeAdditInfo,
                'episodeLink': episodeLink,
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
      streamLow = value.video360;
      streamSd = value.video480;
      streamHd = value.video720;

      //enableSwipe = true;

      playerController = VideoPlayerController.network(
        streamHd ?? streamSd ?? streamLow!,
      );

      playerController.addListener(playerCallback);
      hideController.addListener(hideCallback);

      // playerController.addListener(() {
      //   if (playerController.value.hasError) {
      //     isError = true;

      //     log(playerController.value.errorDescription ?? '',
      //         name: 'AnimePlayerPage');

      //     notifyListeners();
      //   }
      //   if (playerController.value.isInitialized) {}
      //   if (playerController.value.isBuffering) {}
      // });

      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );

      playerController.initialize().then((_) async {
        if (playPos.isNotEmpty) {
          await playerController.seekTo(parseDuration(playPos));
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
            'Просмотрено до ${formatDuration(currentPosDuration)}';

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

        await _ref.read(animeDatabaseProvider).updateEpisode(
              complete: isCompl,
              shikimoriId: shikimoriId,
              animeName: animeName,
              imageUrl: imageUrl,
              timeStamp: timeStamp,
              studioId: studioId,
              studioName: studioName,
              studioType: studioType,
              episodeNumber: episodeNumber,
              position: playerController.value.position.toString(),
            );
      },
    );
  }

  Future<void> hideCallback() async {
    if (_disposed) return;

    notifyListeners();
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

    if (playerController.value.hasError) {
      isError = true;
      hideController.permShow();
      //newCurrentPosition = playerController.value.position;

      log(playerController.value.errorDescription ?? '',
          name: 'PlayerController');

      Sentry.captureException(
        playerController.value.errorDescription,
        //stackTrace: stackTrace,
        withScope: (scope) {
          scope.setContexts(
            'context',
            {
              'shikimoriId': shikimoriId,
              'shikimoriName': animeName,
              'studioId': studioId,
              'studioName': studioName,
              'episodeNumber': episodeNumber,
              'episodeAdditInfo': episodeAdditInfo,
              'episodeLink': episodeLink,
            },
          );
          //scope.setTag('my-tag', 'my value');
          scope.level = SentryLevel.error;
        },
      );

      //notifyListeners();
    }

    notifyListeners();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (_disposed) {
      return;
    }

    //_connectionStatus = result;
    //log(_connectionStatus.toString(), name: 'connectionStatus');

    if (result.name == 'none') {
      hasConnection = false;
    } else {
      hasConnection = true;
    }

    notifyListeners();
  }

  String? get getStreamLink {
    switch (streamQuality) {
      case 0:
        return streamHd;
      case 1:
        return streamSd;
      case 2:
        return streamLow;
      default:
        return streamHd;
    }
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

  Future<bool> _clearPrevious() async {
    await playerController.pause();
    return true;
  }

  Future<void> _initializePlay(String videoPath) async {
    playerController = VideoPlayerController.network(videoPath);
    playerController.addListener(playerCallback);
    // playerController.addListener(() {
    //   setState(() {
    //     playBackTime = playerController.value.position.inSeconds;
    //   });
    // });
    playerController.initialize().then((_) {
      playerController.seekTo(newCurrentPosition);
      playerController.play();
    });
  }

  Future<void> retryPlay() async {
    if (!hasConnection) {
      return;
    }

    hideController.hide();

    newCurrentPosition = playerController.value.position;
    Future.delayed(const Duration(milliseconds: 200), () {
      _clearPrevious().then((_) {
        playerController =
            VideoPlayerController.network(streamHd ?? streamSd ?? streamLow!);
        playerController.addListener(playerCallback);
        playerController.initialize().then((_) {
          playerController.seekTo(newCurrentPosition);
          playerController.play();
          isError = false;
        });
      });
    });
  }

  void getValuesAndPlay(int qual) {
    //String? videoPath;

    // switch (qual) {
    //   case 0:
    //     videoPath = streamHd;
    //     break;
    //   case 1:
    //     videoPath = streamSd;
    //     break;
    //   case 2:
    //     videoPath = streamLow;
    //     break;
    //   default:
    //     videoPath = streamHd;
    // }

    if (getStreamLink == null) {
      return;
    }

    log(getStreamLink!, name: 'PlayerController');

    newCurrentPosition = playerController.value.position;
    _startPlay(getStreamLink!);
    log(newCurrentPosition.toString(), name: 'PlayerController');
  }

  Future<void> _startPlay(String videoPath) async {
    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        _clearPrevious().then((_) {
          _initializePlay(videoPath);
        });
      },
    );
  }
}
