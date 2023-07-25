import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../anilibria/anilibria_api.dart';
import '../../../../../anilibria/models/search.dart';
import '../../../../domain/models/anime_database.dart';
import '../../../providers/anime_details_provider.dart';

final anilibriaSearchProvider = FutureProvider.autoDispose
    .family<AnilibriaSearch, String>((ref, name) async {
  final res = await ref
      .read(anilibriaApiProvider(kAnilibriaApiUrl))
      .searchTitle(name: name);

  return res;
}, name: 'anilibriaSearchProvider');

final latestStudioProvider =
    FutureProvider.family.autoDispose<Studio?, int>((ref, shikimoriId) async {
  final anime = await ref.watch(isAnimeInDataBaseProvider(shikimoriId).future);

  if (anime == null) {
    return null;
  }

  if (anime.studios == null || anime.studios!.isEmpty) {
    return null;
  }

  final studios = anime.studios!;

  studios.sort((a, b) => b.updated!.compareTo(a.updated!));

  if (studios.first.episodes == null || studios.first.episodes!.isEmpty) {
    return null;
  }

  return studios.first;
}, name: 'latestStudioProvider');
