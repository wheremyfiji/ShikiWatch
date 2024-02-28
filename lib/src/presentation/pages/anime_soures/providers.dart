import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/anime_details_provider.dart';
import '../../../domain/models/anime_database.dart';

enum EpisodeSortType {
  newest,
  oldest,
}

final episodeSortTypeProvider =
    StateProvider<EpisodeSortType>((ref) => EpisodeSortType.oldest);

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
