import 'package:flutter/foundation.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import '../../../../../anime_lib/models/models.dart';
import '../../../../domain/models/pages_extra.dart';
import '../../../../../anime_lib/anilib_api.dart';

class AnilibNotifierParameters extends Equatable {
  const AnilibNotifierParameters(
    this.extra,
  );

  final AnimeSourcePageExtra extra;

  @override
  List<Object> get props => [extra];
}

final anilibEpisodeProvider = FutureProvider.family
    .autoDispose<AnilibEpisode, int>((ref, episodeId) async {
  final episode = await ref.read(anilibApiProvider).getEpisode(episodeId);

  return episode;
}, name: 'anilibEpisodeProvider');

final anilibSourceProvider = ChangeNotifierProvider.family
    .autoDispose<AnilibSourceNotifier, AnilibNotifierParameters>((ref, p) {
  final api = ref.read(anilibApiProvider);
  final c = AnilibSourceNotifier(extra: p.extra, api: api);

  c.init();

  return c;
}, name: 'anilibSourceProvider');

class AnilibSourceNotifier extends ChangeNotifier {
  final AnimeSourcePageExtra extra;
  final AnilibApi api;

  AnilibSourceNotifier({
    required this.extra,
    required this.api,
  }) : playlistAsync = const AsyncValue.loading();

  AsyncValue<List<AnilibPlaylist>> playlistAsync;

  void init() async {
    await fetchPlaylist();
  }

  Future<void> fetchPlaylist() async {
    playlistAsync = await AsyncValue.guard(
      () async {
        final search = await api.search(extra.searchName);

        final title = search.firstWhereOrNull(
          (e) => e.shikiId == extra.shikimoriId,
        );

        if (title == null) {
          //playlist = AsyncError('title == null', StackTrace.current);
          throw 'title == null';
        }

        return await api.getPlaylist(title.id);
      },
    );

    notifyListeners();
  }
}
