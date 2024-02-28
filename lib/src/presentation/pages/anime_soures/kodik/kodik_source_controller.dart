import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../kodik/models/kodik_anime.dart';
import '../providers.dart';

enum StudioFilter {
  all,
  voice,
  sub,
}

final seriesSortProvider = StateProvider.family
    .autoDispose<List<KodikSeries>, List<KodikSeries>>((ref, series) {
  final sortType = ref.watch(episodeSortTypeProvider);
  switch (sortType) {
    case EpisodeSortType.oldest:
      return series;
    case EpisodeSortType.newest:
      return series.reversed.toList();
    default:
      return series;
  }
}, name: 'episodeSortProvider');

final studioFilterProvider = StateProvider<StudioFilter>(
  (ref) => StudioFilter.all,
  name: 'studioFilterProvider',
);

final filteredStudiosProvider = Provider.autoDispose
    .family<List<KodikStudio>, List<KodikStudio>>((ref, rawList) {
  final sortType = ref.watch(studioFilterProvider);

  switch (sortType) {
    case StudioFilter.all:
      return rawList;
    case StudioFilter.voice:
      return rawList.where((e) => e.type == 'voice').toList();
    case StudioFilter.sub:
      return rawList.where((e) => e.type == 'subtitles').toList();
  }
}, name: 'filteredStudiosProvider');
