import 'dart:developer';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as w;

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:media_kit/media_kit.dart';
import 'package:intl/intl.dart';

import '../../../services/anime_database/anime_database_provider.dart';
import '../../../../anime_lib/enums/translation_type.dart';
import '../anime_soures/anime365/anime365_provider.dart';
import '../../../../anime_lib/enums/video_quality.dart';
import '../../providers/anime_details_provider.dart';
import '../../providers/environment_provider.dart';
import '../../../domain/enums/stream_quality.dart';
import '../../../domain/enums/anime_source.dart';
import '../../../utils/player/player_utils.dart';
import '../../providers/settings_provider.dart';
import '../../../../anime365/enums/enums.dart';
import '../../../../anime_lib/anilib_api.dart';
import '../../../../anime365/anime365.dart';
import '../../../constants/config.dart';
import '../../../utils/app_utils.dart';
import '../../widgets/auto_hide.dart';
import '../../../../kodik/kodik.dart';
import '../../../../secret.dart';

import 'domain/playable_content.dart';
import 'domain/player_page_extra.dart';
import 'domain/player_provider_parameters.dart';
import 'domain/playlist_item.dart';

final playerPageProvider = ChangeNotifierProvider.autoDispose
    .family<PlayerController, PlayerProviderParameters>((ref, p) {
  final (player, videoController) = ref
      .watch(playerStateProvider.select((s) => (s.player, s.videoController)));

  final c = PlayerController(
    ref,
    e: p.extra,
    player: player,
    videoController: videoController,
  );
  c.initState();
  ref.onDispose(c.disposeState);

  return c;
}, name: 'playerPageProvider');

class PlayerController extends SafeChangeNotifier {
  final Ref ref;
  final PlayerPageExtra e;
  final AutoHideController hideController;

  final Player player;
  final VideoController videoController;
  final PlayerLogger _playerLogger;

  PlayerController(
    this.ref, {
    required this.e,
    required this.player,
    required this.videoController,
  })  : _currentEpNumber = e.selected,
        _playerLogger = PlayerLogger(),
        playableContentAsync = const AsyncValue.loading(),
        hideController = AutoHideController(
          duration: const Duration(seconds: 3),
        );

  AsyncValue<PlayableContent> playableContentAsync;
  late PlayableContent playableContent;
  late SharedPreferences prefs;

  bool _playerOrientationLock = false;
  bool _playerObserveAudioSession = false;
  bool _playerAndroidNewAudioBackend = false;

  bool _disposed = false;
  bool _init = false;
  bool get init => _init;

  late DiscordRPC _discordRPC;
  bool _useDiscordRPC = false;
  // Directory? _appDir;
  int? _sdkVersion;
  int _videoW = 0;
  int _videoH = 0;

  bool shadersExists = false;
  bool shaders = false;

  int _currentEpNumber;
  int get currentEpNumber => _currentEpNumber;

  late AnimeSource _animeSourceType;
  StreamQuality selectedQuality = StreamQuality.idk;

  late PlaylistItem _playlistItem;

  bool _hasPrevEp = false;
  bool get hasPrevEp => _hasPrevEp;

  bool _hasNextEp = false;
  bool get hasNextEp => _hasNextEp;

  final List<StreamSubscription> _playerSubs = [];
  int _retryCount = 0;
  bool _error = false;
  bool get error => _error;

  AudioSession? _audioSession;
  final List<StreamSubscription> _audioSessionSubscriptions = [];

  List<int> opTimecode = [];

  double _savedPlaybackSpeed = 1.0;
  late final w.GlobalKey<VideoState> videoStateKey = w.GlobalKey<VideoState>();
  w.BoxFit playerFit = w.BoxFit.contain;

  bool _videoCompleted = false;
  bool get completed => _videoCompleted;

  void initState() async {
    if (!AppUtils.instance.isDesktop) {
      _sdkVersion = ref.read(environmentProvider).sdkVersion;

      _playerOrientationLock = ref.read(settingsProvider
          .select((settings) => settings.playerOrientationLock));

      _playerObserveAudioSession = ref.read(settingsProvider
          .select((settings) => settings.playerObserveAudioSession));

      _playerAndroidNewAudioBackend = ref.read(settingsProvider
          .select((settings) => settings.playerAndroidNewAudioBackend));

      if (_playerOrientationLock) {
        await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
        );
      }

      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      if (_playerObserveAudioSession) {
        _audioSession = await AudioSession.instance;
        await _configureAudioSession();
      }
    }

    if (Platform.isWindows || Platform.isLinux) {
      _useDiscordRPC = ref.read(
          settingsProvider.select((settings) => settings.playerDiscordRpc));

      _discordRPC = DiscordRPC(
        applicationId: kDiscordAppId,
      );
    }

    hideController.addListener(_hideCallback);
    hideController.permShow();

    _animeSourceType = e.animeSource;

    _selectEpFromPlaylist(_currentEpNumber);

    await _parseEpisode();

    _safeHls();

    playableContentAsync.whenData((_) async {
      if (!_parseQuality()) {
        return;
      }

      // await _safeMpvSetPropertyExtras(player.platform as NativePlayer);
      await _setAndroidSubFont();

      if (_animeSourceType == AnimeSource.anilib) {
        await (player.platform as NativePlayer).setProperty(
          'User-Agent',
          AnilibUtils.kUserAgent,
        );

        await (player.platform as NativePlayer).setProperty(
          'http-header-fields',
          'Referer: ${AnilibUtils.kReferer}',
        );
      }

      if (_animeSourceType == AnimeSource.anime365) {
        await (player.platform as NativePlayer).setProperty(
          'User-Agent',
          ref.read(anime365Provider).userAgent,
        );

        await (player.platform as NativePlayer).setProperty(
          'http-header-fields',
          'Referer: ${Anime365Endpoints.base}/',
        );
      }

      // await (player.platform as NativePlayer).setProperty(
      //   'demuxer-lavf-o',
      //   'http_persistent=0,seg_max_retry=10,insecure=yes', //  fflags=+discardcorrupt
      // );
      // await (player.platform as NativePlayer).setProperty('tls-verify', 'no');
      // //await (player.platform as NativePlayer).setProperty('insecure', 'yes');

      if (_playerAndroidNewAudioBackend && Platform.isAndroid) {
        await (player.platform as NativePlayer).setProperty('ao', 'audiotrack');
      }

      await _openMedia();

      if (e.startPosition.isNotEmpty) {
        await (player.platform as NativePlayer).setProperty(
          'start',
          e.startPosition,
        );
        await player.seek(_parseDuration(e.startPosition));
      }

      final speed =
          ref.read(settingsProvider.select((settings) => settings.playerSpeed));

      await player.setRate(speed);

      if (AppUtils.instance.isDesktop) {
        prefs = await SharedPreferences.getInstance();
        // _appDir = await getApplicationSupportDirectory();
        await player.setVolume(prefs.getDouble('player_volume') ?? 40.0);

        _updateDiscordRpc();
      }

      await player.play();

      if (_audioSession != null) {
        await _audioSession!.setActive(true);
      }

      hideController.toggle();

      if (_audioSession != null) {
        _observeAudioSession();
      }

      _playerSubs.addAll(
        [
          player.stream.completed.listen((event) {
            if (_disposed) {
              return;
            }

            onPlayerCompleted(event);
          }),
          player.stream.error.listen((event) {
            if (_disposed) {
              return;
            }

            //log(event, name: 'Player Error');

            _onPlayerError(event);
          }),
        ],
      );

      _init = true;
    });

    notifyListeners();
  }

  void onPlayerCompleted(bool v) {
    _videoCompleted = v;

    if (v) {
      hideController.cancel();
      hideController.permShow();
    }

    notifyListeners();
  }

  void disposeState() async {
    _disposed = true;

    if (e.animeSource == AnimeSource.anime365) {
      ref.invalidate(anime365UserProvider);
    }

    hideController.dispose();

    if (Platform.isWindows || Platform.isLinux) {
      _discordRPC.clearPresence();
    }

    if (_playerOrientationLock) {
      await SystemChrome.setPreferredOrientations([]);
    }

    await _unfullscreen();

    for (final s in _playerSubs) {
      await s.cancel();
    }

    if (_audioSession != null) {
      await _audioSession!.setActive(false);

      for (final s in _audioSessionSubscriptions) {
        await s.cancel();
      }
    }

    playableContentAsync.whenData((_) async {
      await _updateDb();
    });
  }

  void changePlayerFit() {
    playerFit =
        playerFit == w.BoxFit.contain ? w.BoxFit.fitWidth : w.BoxFit.contain;

    videoStateKey.currentState?.update(
      fit: playerFit,
    );

    notifyListeners();
  }

  void changeQuality(StreamQuality q) async {
    if (selectedQuality == q) {
      return;
    }

    selectedQuality = q;
    _retryCount = 0;

    final cp = player.state.position;
    final p = player.state.playing;

    await player.stop();

    // await player.open(
    //   Media(playableContent.getQ(q)!),
    //   play: false,
    // );

    await _openMedia(streamQuality: q);

    await (player.platform as NativePlayer).setProperty('start', cp.toString());

    await player.seek(cp);

    if (p) {
      await player.play();
    }

    notifyListeners();
  }

  void saveVolume(double value) async {
    if (!AppUtils.instance.isDesktop) {
      return;
    }

    await prefs.setDouble('player_volume', value.roundToDouble());
  }

  Future<void> toggleShaders() async {
    // if (shaders) {
    //   await (player.platform as NativePlayer).setProperty('glsl-shaders', '');
    //   await _resizeVideoTexture(true);
    //   shaders = false;

    //   notifyListeners();
    // } else {
    //   bool exists = await Directory(getShadersDir(_appDir!.path)).exists();
    //   shadersExists = exists;
    //   if (!exists) {
    //     notifyListeners();
    //     return;
    //   }

    //   final resize = await _resizeVideoTexture(false);
    //   if (!resize) {
    //     return;
    //   }

    //   await (player.platform as NativePlayer).setProperty(
    //     'glsl-shaders',
    //     anime4kModeAFast(_appDir!.path),
    //   ); //  anime4kModeDoubleA  || anime4kModeAFast || anime4kModeGan

    //   shaders = true;
    //   notifyListeners();
    // }
  }

  Future<bool> _resizeVideoTexture(bool revert) async {
    // if (e.animeSource == AnimeSource.libria &&
    //     selectedQuality == StreamQuality.fhd) {
    //   return true;
    // }

    if (selectedQuality == StreamQuality.fhd ||
        selectedQuality == StreamQuality.fourK ||
        Platform.isAndroid) {
      return true;
    }

    final width = player.state.width;
    final height = player.state.height;

    if (width == null || height == null) {
      return false;
    }

    if (revert && _videoW != 0) {
      await videoController.setSize(
        width: _videoW,
        height: _videoH,
      );

      return true;
    }

    _videoW = width;
    _videoH = height;

    await videoController.setSize(
      width: width * 2,
      height: height * 2,
    );

    return true;
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

  void setPlaybackSpeed(double speed) async {
    await ref.read(settingsProvider.notifier).setPlayerSpeed(speed);

    await player.setRate(speed);
  }

  void longPressSeek(bool seek) {
    if (_disposed || !init) {
      return;
    }

    if (seek) {
      _savedPlaybackSpeed = player.state.rate;
      player.setRate(2.0);
    } else {
      player.setRate(_savedPlaybackSpeed);
    }
  }

  void changeEpisode(int ep) async {
    await player.pause();

    await _updateDb();

    await player.stop();

    _currentEpNumber = ep;
    _retryCount = 0;

    _selectEpFromPlaylist(_currentEpNumber);
    await _parseEpisode();

    playableContentAsync.whenData((_) async {
      final q = selectedQuality;

      if (!_parseQuality()) {
        return;
      }

      selectedQuality = playableContent.getQ(q) != null ? q : selectedQuality;

      _updateDiscordRpc();

      await (player.platform as NativePlayer).setProperty(
        'start',
        '0',
      );

      await _openMedia(streamQuality: selectedQuality);

      await player.play();
    });

    notifyListeners();
  }

  Future<void> _openMedia(
      {bool play = false, StreamQuality? streamQuality}) async {
    await player.open(
      Media(streamQuality == null
          ? playableContent.getMaxQ()
          : playableContent.getQ(streamQuality)!),
      play: play,
    );

    if (playableContent.subs != null && playableContent.subs!.isNotEmpty) {
      await player.setSubtitleTrack(
        SubtitleTrack.data(playableContent.subs!),
      );
    }
  }

  void _selectEpFromPlaylist(int s) {
    if (_animeSourceType == AnimeSource.anilib && e.anilib != null) {
      final list = e.anilib!.playlist;

      _playlistItem = PlaylistItem(
        episodeNumber: s,
        anilibPlaylistItem: list.firstWhere((i) => i.number == s),
      );

      _hasPrevEp = list.firstWhereOrNull((i) => i.number == s - 1) != null;
      _hasNextEp = list.firstWhereOrNull((i) => i.number == s + 1) != null;
    } else if (_animeSourceType == AnimeSource.libria && e.libria != null) {
      final list = e.libria!.playlist;

      _playlistItem = PlaylistItem(
        episodeNumber: s,
        libriaPlaylistItem: list.firstWhere((i) => i.number == s),
      );

      _hasPrevEp = list.firstWhereOrNull((i) => i.number == s - 1) != null;
      _hasNextEp = list.firstWhereOrNull((i) => i.number == s + 1) != null;
    } else if (_animeSourceType == AnimeSource.kodik && e.kodik != null) {
      final list = e.kodik!;

      _playlistItem = PlaylistItem(
        episodeNumber: s,
        kodikPlaylistItem: list.firstWhere((i) => i.number == s),
      );

      _hasPrevEp = list.firstWhereOrNull((i) => i.number == s - 1) != null;
      _hasNextEp = list.firstWhereOrNull((i) => i.number == s + 1) != null;
    } else if (_animeSourceType == AnimeSource.anime365 && e.anime365 != null) {
      final ts = e.anime365!.ts;

      _playlistItem = PlaylistItem(
        episodeNumber: s,
        anime365PlaylistItem: ts,
      );

      _hasPrevEp = false;
      _hasNextEp = false;
    }
  }

  Future<void> _parseEpisode() async {
    _playerLogger.addLog(
      '[parse episode] [Shiki id: ${e.titleInfo.shikimoriId}] [source: ${_animeSourceType.name}] [ep: ${e.selected}] [studio: ${e.studio.name}]',
    );

    if (_animeSourceType == AnimeSource.anilib) {
      playableContentAsync = await AsyncValue.guard(
        () async {
          final episodeId = _playlistItem.anilibPlaylistItem!.id;

          final anilibEpisode =
              await ref.read(anilibApiProvider).getEpisode(episodeId);

          final player = anilibEpisode.players
              .firstWhereOrNull((element) => element.team.id == e.studio.id);

          if (player == null) {
            throw 'Серии от выбранной студии не найдено';
          }

          String? subs;

          if (player.translationType == TranslationType.sub &&
              player.subtitles.isNotEmpty) {
            try {
              final subsUrl =
                  player.subtitles.firstOrNull ?? player.subtitles.last;

              subs =
                  await ref.read(anilibApiProvider).getSubtitles(subsUrl.src);
            } catch (e) {
              throw 'Не удалось загрузить субтитры';
            }
          }

          final host = e.anilib!.host;

          final fourK = player.video
              .firstWhereOrNull(
                  (element) => element.quality == VideoQuality.fourK)
              ?.href;
          final fullHd = player.video
              .firstWhereOrNull(
                  (element) => element.quality == VideoQuality.fullHd)
              ?.href;
          final hd = player.video
              .firstWhereOrNull((element) => element.quality == VideoQuality.hd)
              ?.href;
          final sd = player.video
              .firstWhereOrNull((element) => element.quality == VideoQuality.sd)
              ?.href;

          return PlayableContent(
            fourK: fourK != null ? host + fourK : null,
            fhd: fullHd != null ? host + fullHd : null,
            hd: hd != null ? host + hd : null,
            low: sd != null ? host + sd : null,
            subs: subs,
          );
        },
      );
    } else if (_animeSourceType == AnimeSource.libria) {
      playableContentAsync = AsyncValue.data(
        PlayableContent(
          fhd: _playlistItem.libriaPlaylistItem!.fnd == null
              ? null
              : e.libria!.host + _playlistItem.libriaPlaylistItem!.fnd!,
          hd: _playlistItem.libriaPlaylistItem!.hd == null
              ? null
              : e.libria!.host + _playlistItem.libriaPlaylistItem!.hd!,
          sd: _playlistItem.libriaPlaylistItem!.sd == null
              ? null
              : e.libria!.host + _playlistItem.libriaPlaylistItem!.sd!,
        ),
      );

      opTimecode = _playlistItem.libriaPlaylistItem!.opSkip ?? [];
    } else if (_animeSourceType == AnimeSource.kodik) {
      playableContentAsync = await AsyncValue.guard(
        () async {
          final links = await ref
              .read(kodikApiProvider)
              .getHLSLink(episodeLink: _playlistItem.kodikPlaylistItem!.link);

          opTimecode = links.opTimecode ?? [];

          return PlayableContent(
            hd: links.video720,
            sd: links.video480,
            low: links.video360,
          );
        },
      );
    } else if (_animeSourceType == AnimeSource.anime365) {
      playableContentAsync = await AsyncValue.guard(
        () async {
          final ts = _playlistItem.anime365PlaylistItem!;

          final player = await ref.read(anime365Provider).getPlayer(ts.embedId);

          if (player == null) {
            throw 'Серии от выбранной студии не найдено';
          }

          String? subs;

          if (ts.kind == TranslationKindType.sub && player.ass.isNotEmpty) {
            try {
              subs = await ref.read(anime365Provider).getSubtitles(
                    url: player.ass,
                    ref: ts.embedUrl,
                  );
            } catch (e) {
              throw 'Не удалось загрузить субтитры';
            }
          }

          final fourK = player.videos
              .firstWhereOrNull((e) => e.quality == VideoQuality.fourK)
              ?.href;
          final fullHd = player.videos
              .firstWhereOrNull((e) => e.quality == VideoQuality.fullHd)
              ?.href;
          final hd = player.videos
              .firstWhereOrNull((e) => e.quality == VideoQuality.hd)
              ?.href;
          final sd = player.videos
              .firstWhereOrNull((e) => e.quality == VideoQuality.sd)
              ?.href;

          return PlayableContent(
            fourK: fourK,
            fhd: fullHd,
            hd: hd,
            low: sd,
            subs: subs,
          );
        },
      );
    }

    playableContentAsync.whenOrNull(error: (error, s) {
      //TODO
      debugPrint(error.toString());
      debugPrint(s.toString());

      _playerLogger.addLog(
        '[parse episode] [error] $error',
      );

      notifyListeners();
    });
  }

  bool _parseQuality() {
    final s = playableContentAsync.asData!.value;

    playableContent = s;

    if (s.fourK == null) {
      if (s.fhd == null) {
        if (s.hd == null) {
          if (s.sd == null) {
            if (s.low == null) {
              playableContentAsync =
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
    } else {
      selectedQuality = StreamQuality.fourK;
    }

    return true;
  }

  void _hideCallback() async {
    if (_disposed) return;

    notifyListeners();

    if (AppUtils.instance.isDesktop) {
      return;
    }

    hideController.isVisible == false
        ? await SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.immersiveSticky)
        : await _unfullscreen();
  }

  Future<void> _unfullscreen() async {
    if (AppUtils.instance.isDesktop) {
      return;
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

  void _onPlayerError(String event) {
    if (_error) {
      return;
    }

    if (event.contains('Failed to open') && _retryCount < 3) {
      player
          .open(
        Media(playableContent.getQ(selectedQuality)!),
        play: _currentEpNumber == e.selected ? e.startPosition.isEmpty : true,
      )
          .then(
        (_) {
          _retryCount += 1;

          if (e.startPosition.isNotEmpty && _currentEpNumber == e.selected) {
            (player.platform as NativePlayer)
                .setProperty(
                  "start",
                  e.startPosition,
                )
                .then(
                  (_) => player.seek(_parseDuration(e.startPosition)),
                )
                .then(
                  (_) => player.play(),
                );
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

    playableContentAsync = AsyncValue.error(event, StackTrace.current);

    notifyListeners();
  }

  Future<void> _updateDb() async {
    // TODO
    if (e.animeSource == AnimeSource.anilib ||
        e.animeSource == AnimeSource.anime365) {
      return;
    }

    if (error) {
      return;
    }

    if (player.state.position < const Duration(seconds: 5)) {
      return;
    }

    bool isCompl = false;
    String timeStamp =
        'Просмотрено до ${_formatDuration(player.state.position)}';

    if (player.state.duration.inSeconds / player.state.position.inSeconds <
        1.2) {
      isCompl = true;
      timeStamp = 'Просмотрено полностью';
    }

    await ref
        .read(animeDatabaseProvider)
        .updateEpisode(
          complete: isCompl,
          shikimoriId: e.titleInfo.shikimoriId,
          animeName: e.titleInfo.animeName,
          imageUrl: e.titleInfo.imageUrl,
          timeStamp: timeStamp,
          studioId: e.studio.id,
          studioName: e.studio.name,
          studioType: e.studio.type,
          episodeNumber: currentEpNumber,
          position: player.state.position.toString(),
        )
        .then((_) => ref.invalidate(isAnimeInDataBaseProvider));
  }

  void _updateDiscordRpc() {
    if (!_useDiscordRPC) {
      return;
    }

    if (!(Platform.isWindows || Platform.isLinux)) {
      return;
    }

    _discordRPC.start(autoRegister: true);
    _discordRPC.updatePresence(
      DiscordPresence(
        details: 'Смотрит "${e.titleInfo.animeName}"',
        state: 'Серия $_currentEpNumber',
        //startTimeStamp: DateTime.now().millisecondsSinceEpoch,
        largeImageKey: AppConfig.staticUrl + e.titleInfo.imageUrl,
        largeImageText: 'гайки хавать будешь?',
        button1Label: 'Открыть',
        button1Url: '${AppConfig.staticUrl}/animes/${e.titleInfo.shikimoriId}',
        button2Label: 'че за прила??',
        button2Url: 'https://github.com/wheremyfiji/ShikiWatch/',
      ),
    );
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
                //if (playing) {
                player.pause();
                //}

                break;
            }
          },
        ),
        _audioSession!.becomingNoisyEventStream.listen((_) {
          //if (playing) {
          player.pause();
          //}
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

  Future<void> _setAndroidSubFont() async {
    if (AppUtils.instance.isDesktop) {
      return;
    }

    await (player.platform as NativePlayer).setProperty(
      'sub-fonts-dir',
      PlayerUtils.instance.fontsDirPath,
    );
    await (player.platform as NativePlayer).setProperty(
      'sub-font',
      'Noto Sans',
    );
  }

  // https://github.com/emp0ry/AnimeShin/blob/main/lib/feature/player/player_page.dart#L508
  Future<void> _safeHls() async {
    unawaited(_safeMpvSetProperty('cache', 'yes'));
    unawaited(_safeMpvSetProperty('cache-secs', '120'));
    unawaited(_safeMpvSetProperty(
        'demuxer-seekable-cache', 'yes')); // allow seeks from cache
    unawaited(_safeMpvSetProperty(
        'demuxer-readahead-secs', '15')); // read ahead more data
    unawaited(_safeMpvSetProperty(
        'demuxer-max-back-bytes', '${64 * 1024 * 1024}')); // 64MB back buffer

    // --- Avoid aggressive frame dropping on micro stalls ---
    unawaited(_safeMpvSetProperty(
        'hr-seek-framedrop', 'no')); // keep frames on precise seeks
    unawaited(
        _safeMpvSetProperty('framedrop', 'no')); // prefer not dropping frames

    // --- Make A/V sync follow the display clock (VLC-like smoothness) ---
    unawaited(_safeMpvSetProperty(
        'video-sync', 'display-resample')); // reduce "chase" & teleports

    // --- Hardware decoding: safer choice across devices ---
    unawaited(
        _safeMpvSetProperty('hwdec', 'auto-safe')); // avoid brittle decoders

    // --- Stabilize timestamp probing for HLS/TS (helps missing PTS) ---
    unawaited(
        _safeMpvSetProperty('demuxer-lavf-analyzeduration', '10')); // seconds
    unawaited(
        _safeMpvSetProperty('demuxer-lavf-probesize', '${50 * 1024 * 1024}'));
    // Generate missing PTS if upstream is wobbly.
    unawaited(_safeMpvSetProperty('demuxer-lavf-o', 'fflags=+genpts'));

    // --- HTTP/HLS transport safety (you already set some; keep them consolidated) ---
    unawaited(_safeMpvSetProperty(
      'stream-lavf-o',
      // 'demuxer-lavf-o',
      [
        // Keep persistent connections to reduce mid-segment stalls
        'http_persistent=1',
        'reconnect=1',
        'reconnect_streamed=1',
        'reconnect_on_http_error=4xx,5xx',
        // Some CDNs play nicer when we avoid multi-range; mpv handles ranges anyway
        // 'multiple_requests=0', // optional; only if you see glide-skips
      ].join(':'),
    ));
  }

  Future<void> _safeMpvSetProperty(String property, String value) async {
    final platform = player.platform;
    if (platform is NativePlayer) {
      try {
        await platform.setProperty(property, value);
        _playerLogger.addLog('setProperty "$property"');
      } catch (e) {
        _playerLogger.addLog('setProperty("$property","$value") failed: $e');
      }
    }
  }

  // Future<void> _safeMpvSetPropertyExtras(NativePlayer player) async {
  //   await player.setProperty(
  //     'deband',
  //     'yes',
  //   );

  //   await player.setProperty(
  //     'deband-iterations',
  //     '2',
  //   );

  //   await player.setProperty(
  //     'deband-threshold',
  //     '35',
  //   );

  //   await player.setProperty(
  //     'deband-range',
  //     '20',
  //   );

  //   await player.setProperty(
  //     'deband-grain',
  //     '5',
  //   );

  //   await player.setProperty(
  //     'dither-depth',
  //     'auto',
  //   );

  //   await player.setProperty(
  //     'interpolation',
  //     'yes',
  //   );

  //   await player.setProperty(
  //     'tscale',
  //     'bicubic',
  //   );

  //   await player.setProperty(
  //     'video-sync',
  //     'display-resample',
  //   );
  // }
}

final playerStateProvider =
    NotifierProvider.autoDispose<VideoPlayerNotifier, VideoPlayerState>(() {
  final Player player = Player(
    configuration: const PlayerConfiguration(
      title: 'ShikiWatch',
      libass: true,
      // osc: true,
      bufferSize: 32 * 1024 * 1024,
      // logLevel: MPVLogLevel.v,
      logLevel: kDebugMode ? MPVLogLevel.v : MPVLogLevel.error,
    ),
  );

  final VideoController videoController = VideoController(
    player,
    configuration: const VideoControllerConfiguration(
      // vo: Platform.isAndroid ? 'gpu' : 'gpu-next',
      // vo: 'gpu-next',
      androidAttachSurfaceAfterVideoParameters: false,
    ),
  );

  return VideoPlayerNotifier(
    player: player,
    videoController: videoController,
  );
}, name: 'videoPlayerProvider');

class VideoPlayerNotifier extends AutoDisposeNotifier<VideoPlayerState> {
  VideoPlayerNotifier({
    required this.player,
    required this.videoController,
  });

  final Player player;
  final VideoController videoController;
  late PlayerLogger _playerLogger;

  final List<StreamSubscription> _subscriptions = [];

  @override
  VideoPlayerState build() {
    ref.onDispose(() {
      Future.microtask(() async {
        for (final s in _subscriptions) {
          await s.cancel();
        }

        await player.dispose();
      });
    });

    _playerLogger = PlayerLogger();

    _subscribe();

    return VideoPlayerState(
      player: player,
      videoController: videoController,
      playing: false,
      buffering: true,
      position: Duration.zero,
      duration: Duration.zero,
      buffer: Duration.zero,
      playbackSpeed: 1.0,
      volume: 100.0,
    );
  }

  void _subscribe() {
    _subscriptions.addAll(
      [
        player.stream.playing.listen((event) {
          state = state.copyWith(playing: event);
        }),
        player.stream.buffering.listen((event) {
          state = state.copyWith(buffering: event);
        }),
        player.stream.position
            .distinct(
                (a, b) => (a - b).abs() < const Duration(milliseconds: 500))
            .listen((event) {
          state = state.copyWith(position: event);
        }),
        player.stream.duration.listen((event) {
          state = state.copyWith(duration: event);
        }),
        player.stream.rate.listen((event) {
          state = state.copyWith(playbackSpeed: event);
        }),
        player.stream.volume.listen((event) {
          state = state.copyWith(volume: event);
        }),
        player.stream.buffer
            .distinct(
                (a, b) => (a - b).abs() < const Duration(milliseconds: 500))
            .listen((event) {
          state = state.copyWith(buffer: event);
        }),
        //if (kDebugMode)
        player.stream.log.listen(
          (event) {
            if (event.text.contains('HTTP error 403')) {
              return;
            }
            _playerLogger.addLog(
              '[${event.prefix}] [${event.level}] ${event.text}',
              level: event.level,
            );
            if (kDebugMode) {
              log(
                '${event.prefix}: ${event.level}: ${event.text}',
                name: 'mpv player',
              );
            }
          },
        ),
      ],
    );
  }
}

class VideoPlayerState {
  const VideoPlayerState({
    required this.player,
    required this.videoController,
    required this.playing,
    required this.buffering,
    required this.position,
    required this.duration,
    required this.buffer,
    required this.playbackSpeed,
    required this.volume,
  });

  final Player player;
  final VideoController videoController;
  final bool playing;
  final bool buffering;
  final Duration position;
  final Duration duration;
  final Duration buffer;
  final double playbackSpeed;
  final double volume;

  VideoPlayerState copyWith({
    Player? player,
    VideoController? videoController,
    bool? playing,
    bool? buffering,
    Duration? position,
    Duration? duration,
    Duration? buffer,
    double? playbackSpeed,
    double? volume,
  }) {
    return VideoPlayerState(
      player: player ?? this.player,
      videoController: videoController ?? this.videoController,
      playing: playing ?? this.playing,
      buffering: buffering ?? this.buffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffer: buffer ?? this.buffer,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      volume: volume ?? this.volume,
    );
  }
}

final _dateFormat = DateFormat.Hms();

class LogEntry {
  final String log;
  final String level;
  final DateTime timestamp;

  const LogEntry({
    required this.log,
    required this.level,
    required this.timestamp,
  });

  @override
  String toString() {
    return '[${_dateFormat.format(timestamp)}] $log';
  }
}

class PlayerLogger {
  static PlayerLogger? _instance;

  PlayerLogger._internal() {
    _instance = this;
  }

  factory PlayerLogger() => _instance ?? PlayerLogger._internal();

  List<LogEntry> logs = [];

  void addLog(String log, {String? level}) {
    logs = [
      ...logs,
      LogEntry(
        timestamp: DateTime.now(),
        log: log,
        level: level ?? '',
      ),
    ].take(500).toList();
  }

  void clear() {
    logs = [];
  }
}
