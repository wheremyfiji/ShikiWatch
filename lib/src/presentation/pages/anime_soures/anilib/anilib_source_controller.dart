import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import '../../../../utils/extensions/riverpod_extensions.dart';
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
  final anilibApi = ref.read(anilibApiProvider);
  final cancelToken = ref.cancelToken();

  final episode =
      await anilibApi.getEpisode(episodeId, cancelToken: cancelToken);

  return episode;
}, name: 'anilibEpisodeProvider');

final anilibSourceProvider = FutureProvider.family
    .autoDispose<List<AnilibPlaylist>, AnilibNotifierParameters>(
        (ref, p) async {
  final anilibApi = ref.read(anilibApiProvider);
  final cancelToken = ref.cancelToken();
  final extra = p.extra;

  final search = await anilibApi.search(
    extra.searchName,
    cancelToken: cancelToken,
  );

  final title = search.firstWhereOrNull(
    (e) => e.shikiId == extra.shikimoriId,
  );

  if (title == null) {
    return [];
  }

  return await anilibApi.getPlaylist(
    title.id,
    cancelToken: cancelToken,
  );
}, name: 'anilibSourceProvider');
