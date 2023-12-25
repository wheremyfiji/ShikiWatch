import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as w;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:media_kit/media_kit.dart';

import '../../../../kodik/kodik.dart';
import '../../../domain/enums/anime_source.dart';
import '../../../domain/enums/stream_quality.dart';
import '../../../domain/models/anime_player_page_extra.dart';
import '../../../services/anime_database/anime_database_provider.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/shaders.dart';
import '../../providers/anime_details_provider.dart';
import '../../providers/environment_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/auto_hide.dart';

import 'shared/shared.dart';

final playerProvider = ChangeNotifierProvider.autoDispose
    .family<PlayerNotifier, PlayerProviderParameters>((ref, p) {
  final n = PlayerNotifier(ref, e: p.extra);

  n.initState();

  ref.onDispose(n.disposeState);

  return n;
});

class PlayerNotifier extends w.ChangeNotifier {
  final Ref ref;
  final PlayerPageExtra e;

  PlayerNotifier(
    this.ref, {
    required this.e,
  })  : _currentEpNumber = e.selected,
        videoLinksAsync = const AsyncValue.loading(),
        hideController = AutoHideController(
          duration: const Duration(seconds: 3),
        );

  final AutoHideController hideController;

  bool _init = false;
  bool get init => _init;

  bool _error = false;
  bool get error => _error;

  bool _disposed = false;

  late PlaylistItem _playlistItem;
  PlaylistItem? _prevPlaylistItem;
  PlaylistItem? _nextPlaylistItem;

  int _currentEpNumber;

  bool get hasPrevEp => _prevPlaylistItem != null;
  bool get hasNextEp => _nextPlaylistItem != null;
  int get currentEpNumber => _currentEpNumber;

  bool _playerOrientationLock = false;

  late SharedPreferences prefs;

  late final Player player = Player(
    configuration: const PlayerConfiguration(
      title: 'ShikiWatch',
      bufferSize: 32 * 1024 * 1024,
      logLevel: kDebugMode ? MPVLogLevel.v : MPVLogLevel.error,
    ),
  );

  late final playerController = VideoController(
    player,
    configuration: const VideoControllerConfiguration(
      androidAttachSurfaceAfterVideoParameters: false,
    ),
  );

  late final w.GlobalKey<VideoState> videoStateKey = w.GlobalKey<VideoState>();
  w.BoxFit playerFit = w.BoxFit.contain;

  AsyncValue<VideoLinks> videoLinksAsync;
  late VideoLinks videoLinks;
  late AnimeSource _animeSourceType;

  StreamQuality selectedQuality = StreamQuality.idk;

  final List<StreamSubscription> subscriptions = [];

  bool playing = false;
  bool completed = false;
  bool buffering = true;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  Duration buffer = Duration.zero;
  double playbackSpeed = 1.0;
  double _savedPlaybackSpeed = 1.0;
  double volume = 100.0;

  int retryCount = 0;

  int? _sdkVersion;
  bool discordRpc = false;
  bool shaders = false;
  bool shadersExists = false;
  int _videoW = 0;
  int _videoH = 0;
  Directory? _appDir;

  AudioSession? _audioSession;
  final List<StreamSubscription> _audioSessionSubscriptions = [];

  void initState() async {
    if (!AppUtils.instance.isDesktop) {
      _sdkVersion = ref.read(environmentProvider).sdkVersion;

      _playerOrientationLock = ref.read(settingsProvider
          .select((settings) => settings.playerOrientationLock));

      if (_playerOrientationLock) {
        await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
        );
      }

      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      _audioSession = await AudioSession.instance;
      await _configureAudioSession();
    }

    hideController.addListener(hideCallback);
    hideController.permShow();

    _animeSourceType = e.animeSource;

    _selectEpFromPlaylist(_currentEpNumber);

    await _parseEpisode();

    videoLinksAsync.whenData((_) async {
      if (!_parseQuality()) {
        return;
      }

      //_pipeLogsToConsole(player);

      await (player.platform as NativePlayer).setProperty('tls-verify', 'no');
      await (player.platform as NativePlayer).setProperty('insecure', 'yes');
      await (player.platform as NativePlayer)
          .setProperty('force-seekable', 'yes');

      await (player.platform as NativePlayer).setProperty(
        'demuxer-lavf-o',
        'http_persistent=0,seg_max_retry=10',
      );

      await player.open(
        Media(videoLinks.getMaxQ()),
        play: false,
      );

      if (e.startPosition.isNotEmpty) {
        await (player.platform as NativePlayer).setProperty(
          'start',
          e.startPosition,
        );
        await player.seek(_parseDuration(e.startPosition));
      }

      //await pt();

      final speed =
          ref.read(settingsProvider.select((settings) => settings.playerSpeed));

      await player.setRate(speed);

      if (AppUtils.instance.isDesktop) {
        prefs = await SharedPreferences.getInstance();
        _appDir = await getApplicationSupportDirectory();
        await player.setVolume(prefs.getDouble('player_volume') ?? 40.0);
      }

      await player.play();

      if (_audioSession != null) {
        await _audioSession!.setActive(true);
      }

      hideController.toggle();

      playbackSpeed = player.state.rate;
      position = player.state.position;
      duration = player.state.duration;
      playing = player.state.playing;
      buffering = player.state.buffering;
      volume = player.state.volume;

      if (_audioSession != null) {
        _observeAudioSession();
      }

      subscriptions.addAll(
        [
          player.stream.volume.listen((event) {
            if (_disposed) {
              return;
            }

            volume = event;
          }),
          player.stream.rate.listen((event) {
            if (_disposed) {
              return;
            }

            playbackSpeed = event;
          }),
          player.stream.error.listen((event) {
            if (_disposed) {
              return;
            }

            //log(event, name: 'Player Error');

            _onPlayerError(event);
          }),
          player.stream.playing.listen((event) {
            if (_disposed) {
              return;
            }

            playing = event;
            notifyListeners();
          }),
          player.stream.completed.listen((event) {
            if (_disposed) {
              return;
            }

            completed = event;

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
        ],
      );

      _init = true;
    });

    notifyListeners();
  }

  void disposeState() async {
    _disposed = true;

    hideController.dispose();

    await _unfullscreen();

    await player.pause();
    await player.dispose();

    if (_audioSession != null) {
      await _audioSession!.setActive(false);

      for (final s in _audioSessionSubscriptions) {
        await s.cancel();
      }
    }

    for (final s in subscriptions) {
      await s.cancel();
    }

    videoLinksAsync.whenData((_) async {
      await _updateDb();
    });
  }

  void hideCallback() async {
    if (_disposed) return;

    notifyListeners();

    if (AppUtils.instance.isDesktop) {
      return;
    }

    // hideController.isVisible == false
    //     ? await SystemChrome.setEnabledSystemUIMode(
    //         SystemUiMode.immersiveSticky)
    //     : await _unfullscreen();
  }

  void setPlaybackSpeed(double speed) async {
    await ref.read(settingsProvider.notifier).setPlayerSpeed(speed);

    await player.setRate(speed);
  }

  void longPressSeek(bool seek) {
    if (_disposed || !init) {
      return;
    }

    if (seek) {
      _savedPlaybackSpeed = playbackSpeed;
      player.setRate(2.0);
    } else {
      player.setRate(_savedPlaybackSpeed);
    }
  }

  void saveVolume(double value) async {
    if (!AppUtils.instance.isDesktop) {
      return;
    }

    await prefs.setDouble('player_volume', value.roundToDouble());
  }

  Future<void> toggleDFullscreen({bool p = false}) async {
    if (!AppUtils.instance.isDesktop) {
      return;
    }

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

  void changePlayerFit() {
    playerFit =
        playerFit == w.BoxFit.contain ? w.BoxFit.fitWidth : w.BoxFit.contain;

    videoStateKey.currentState?.update(
      fit: playerFit,
    );

    notifyListeners();
  }

  void changeEpisode(int ep) async {
    await player.pause();

    await _updateDb();

    await player.stop();

    _currentEpNumber = ep;
    retryCount = 0;

    _selectEpFromPlaylist(_currentEpNumber);
    await _parseEpisode();

    videoLinksAsync.whenData((_) async {
      if (!_parseQuality()) {
        return;
      }

      await (player.platform as NativePlayer).setProperty(
        'start',
        '0',
      );

      await player.open(
        Media(videoLinks.getQ(selectedQuality) ?? videoLinks.getMaxQ()),
        play: true,
      );
    });

    notifyListeners();
  }

  void changeQuality(StreamQuality q) async {
    if (selectedQuality == q) {
      return;
    }

    selectedQuality = q;
    retryCount = 0;

    final cp = player.state.position;
    final p = player.state.playing;

    await player.stop();

    await player.open(
      Media(videoLinks.getQ(q)!),
      play: false,
    );

    await (player.platform as NativePlayer).setProperty('start', cp.toString());

    await player.seek(cp);

    if (p) {
      await player.play();
    }

    notifyListeners();
  }

  Future<void> toggleShaders() async {
    if (shaders) {
      await (player.platform as NativePlayer).setProperty('glsl-shaders', '');
      await _resizeVideoTexture(true);
      shaders = false;

      notifyListeners();
    } else {
      bool exists = await Directory(getShadersDir(_appDir!.path)).exists();
      shadersExists = exists;
      if (!exists) {
        notifyListeners();
        return;
      }

      final resize = await _resizeVideoTexture(false);
      if (!resize) {
        return;
      }

      await (player.platform as NativePlayer).setProperty(
        'glsl-shaders',
        anime4kModeAFast(_appDir!.path),
      ); //  anime4kModeDoubleA  || anime4kModeAFast || anime4kModeGan

      shaders = true;
      notifyListeners();
    }
  }

  Future<bool> _resizeVideoTexture(bool revert) async {
    if (e.animeSource == AnimeSource.libria &&
        selectedQuality == StreamQuality.fhd) {
      return true;
    }

    final width = player.state.width;
    final height = player.state.height;

    if (width == null || height == null) {
      return false;
    }

    if (revert && _videoW != 0) {
      await playerController.setSize(
        width: _videoW,
        height: _videoH,
      );

      return true;
    }

    _videoW = width;
    _videoH = height;

    await playerController.setSize(
      width: width * 2,
      height: height * 2,
    );

    return true;
  }

  Future<void> _updateDb() async {
    if (error) {
      return;
    }

    if (position == Duration.zero || position < const Duration(seconds: 5)) {
      return;
    }

    bool isCompl = false;
    String timeStamp = 'Просмотрено до ${_formatDuration(position)}';

    if (duration.inSeconds / position.inSeconds < 1.2) {
      isCompl = true;
      timeStamp = 'Просмотрено полностью';
    }

    await ref
        .read(animeDatabaseProvider)
        .updateEpisode(
          complete: isCompl,
          shikimoriId: e.info.shikimoriId,
          animeName: e.info.animeName,
          imageUrl: e.info.imageUrl,
          timeStamp: timeStamp,
          studioId: e.info.studioId,
          studioName: e.info.studioName,
          studioType: e.info.studioType,
          episodeNumber: currentEpNumber,
          position: position.toString(),
        )
        .then((_) => ref.invalidate(isAnimeInDataBaseProvider));
  }

  void _onPlayerError(String event) {
    if (_error) {
      return;
    }

    if (event.contains('Failed to open') && retryCount < 3) {
      player
          .open(
        Media(videoLinks.getQ(selectedQuality)!),
        play: _currentEpNumber == e.selected ? e.startPosition.isEmpty : true,
      )
          .then(
        (_) {
          retryCount += 1;
          if (e.startPosition.isNotEmpty && _currentEpNumber == e.selected) {
            (player.platform as NativePlayer)
                .setProperty(
                  "start",
                  e.startPosition,
                )
                .then((_) => player.seek(_parseDuration(e.startPosition)))
                .then((_) => player.play());
          }
        },
      );

      return;
    }

    //tcp: ffurl_read returned
    //return

    // TODO
    return;

    _error = true;

    hideController.cancel();
    hideController.permShow();

    videoLinksAsync = AsyncValue.error(event, StackTrace.current);

    notifyListeners();
  }

  void _selectEpFromPlaylist(int s) {
    _playlistItem = e.playlist.firstWhere((i) => i.episodeNumber == s);

    _prevPlaylistItem =
        e.playlist.firstWhereOrNull((i) => i.episodeNumber == s - 1);

    _nextPlaylistItem =
        e.playlist.firstWhereOrNull((i) => i.episodeNumber == s + 1);
  }

  Future<void> _parseEpisode() async {
    if (_animeSourceType == AnimeSource.libria &&
        _playlistItem.libria != null) {
      videoLinksAsync = AsyncValue.data(
        VideoLinks(
          fhd: _playlistItem.libria!.fnd == null
              ? null
              : _playlistItem.libria!.host + _playlistItem.libria!.fnd!,
          hd: _playlistItem.libria!.hd == null
              ? null
              : _playlistItem.libria!.host + _playlistItem.libria!.hd!,
          sd: _playlistItem.libria!.sd == null
              ? null
              : _playlistItem.libria!.host + _playlistItem.libria!.sd!,
        ),
      );
    } else if (_animeSourceType == AnimeSource.kodik &&
        _playlistItem.link != null) {
      videoLinksAsync = await AsyncValue.guard(
        () async {
          final links = await ref.read(kodikApiProvider).getHLSLink(
                episodeLink: _playlistItem.link!,
              );

          return VideoLinks(
            hd: links.video720,
            sd: links.video480,
            low: links.video360,
          );
        },
      );
    }

    videoLinksAsync.whenOrNull(error: (e, s) {
      //TODO
      print(e);
      print(s);

      notifyListeners();
    });
  }

  bool _parseQuality() {
    final s = videoLinksAsync.asData!.value;

    videoLinks = s;

    if (s.fhd == null) {
      if (s.hd == null) {
        if (s.sd == null) {
          if (s.low == null) {
            videoLinksAsync =
                AsyncValue.error('нету качества', StackTrace.current);
            notifyListeners();

            return false;
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

    return true;
  }

  Future<void> _unfullscreen() async {
    if (AppUtils.instance.isDesktop) {
      return;
    }

    if (_playerOrientationLock) {
      await SystemChrome.setPreferredOrientations([]);
    }

    if ((_sdkVersion ?? 0) < 29) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _configureAudioSession() async {
    if (AppUtils.instance.isDesktop) {
      return;
    }

    if (_audioSession == null) {
      return;
    }

    await _audioSession!.configure(const AudioSessionConfiguration(
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.movie,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  void _observeAudioSession() {
    _audioSessionSubscriptions.addAll(
      [
        _audioSession!.interruptionEventStream.listen(
          (event) {
            if (!event.begin) {
              return;
            }

            switch (event.type) {
              case AudioInterruptionType.duck:
                break;
              case AudioInterruptionType.pause:
              case AudioInterruptionType.unknown:
                if (playing) {
                  player.pause();
                }

                break;
            }
          },
        ),
        _audioSession!.becomingNoisyEventStream.listen((_) {
          if (playing) {
            player.pause();
          }
        }),
      ],
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

  String _formatDuration(Duration d) {
    String tmp = d.toString().split('.').first.padLeft(8, "0");
    return tmp.replaceFirst('00:', '');
  }

  // Future<void> _test() async {
  //   await (player.platform as NativePlayer).setProperty(
  //     'brightness',
  //     '-7',
  //   );

  //   await (player.platform as NativePlayer).setProperty(
  //     'contrast',
  //     '10',
  //   );

  //   await (player.platform as NativePlayer).setProperty(
  //     'gamma',
  //     '5',
  //   );

  //   await (player.platform as NativePlayer).setProperty(
  //     'saturation',
  //     '-20',
  //   );
  // }

  // void _pipeLogsToConsole(Player player) {
  //   if (!kDebugMode) {
  //     return;
  //   }

  //   player.stream.log.listen(
  //     (event) {
  //       if (kDebugMode) {
  //         log('${event.prefix}: ${event.level}: ${event.text}',
  //             name: 'mpv player');
  //       }
  //     },
  //   );
  // }
}
