import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../anime365/models/translations.dart';
import '../../../../../anime365/models/search.dart';
import '../../../../utils/extensions/riverpod_extensions.dart';
import '../../../../utils/player/player_utils.dart';
import '../../../../../anime365/enums/enums.dart';
import '../../../../../anime365/models/user.dart';
import '../../../../../anime365/anime365.dart';

final anime365Provider = Provider<Anime365Api>((ref) {
  return Anime365Api(appPath: PlayerUtils.instance.appDocumentsPath);
}, name: 'anime365Provider');

final anime365UserProvider =
    AsyncNotifierProvider<Anime365UserNotifier, Anime365User>(() {
  return Anime365UserNotifier();
}, name: 'anime365UserNotifier');

class Anime365UserNotifier extends AsyncNotifier<Anime365User> {
  @override
  Future<Anime365User> build() async {
    ref.onDispose(() {
      state = const AsyncValue.loading();
    });

    return await _fetchUser();
  }

  Future<Anime365User> _fetchUser() async {
    final me = await ref.read(anime365Provider).user();
    return me;
  }
}

final anime365SearchProvider =
    FutureProvider.family.autoDispose<Anime365Search?, int>((ref, id) async {
  final api = ref.read(anime365Provider);
  final cancelToken = ref.cancelToken();

  final search = await api.search(
    shikimoriId: id,
    cancelToken: cancelToken,
  );

  return search;
}, name: 'anime365SearchProvider');

final anime365TranslationsProvider = FutureProvider.family
    .autoDispose<List<Anime365Translation>, int>((ref, id) async {
  final api = ref.read(anime365Provider);
  final cancelToken = ref.cancelToken();

  final translations = await api.getTranslations(
    id: id,
    cancelToken: cancelToken,
  );

  return translations;
}, name: 'anime365TranslationsProvider');

enum Anime365StudioFilter {
  all,
  voice,
  sub,
  raw,
}

final anime365StudioFilterProvider = StateProvider<Anime365StudioFilter>(
  (ref) => Anime365StudioFilter.all,
  name: 'anime365StudioFilterProvider',
);

final anime365FilteredStudiosProvider = Provider.autoDispose
    .family<List<Anime365Translation>, List<Anime365Translation>>(
        (ref, rawList) {
  final sortType = ref.watch(anime365StudioFilterProvider);

  switch (sortType) {
    case Anime365StudioFilter.all:
      return rawList;
    case Anime365StudioFilter.voice:
      return rawList.where((e) => e.kind == TranslationKindType.voice).toList();
    case Anime365StudioFilter.sub:
      return rawList.where((e) => e.kind == TranslationKindType.sub).toList();
    case Anime365StudioFilter.raw:
      return rawList.where((e) => e.kind == TranslationKindType.raw).toList();
  }
}, name: 'anime365filteredStudiosProvider');
