import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/shiki_franchise.dart';
import '../../domain/models/shiki_role.dart';
import '../../utils/extensions/riverpod_extensions.dart';
import '../../domain/models/anime_database.dart';
import '../../domain/models/animes.dart';
import '../../domain/models/external_link.dart';
import '../../domain/models/user_rate.dart';
import '../../services/anime_database/anime_database_provider.dart';
import '../../services/secure_storage/secure_storage_service.dart';
import '../../data/data_sources/anime_data_src.dart';
import '../../data/repositories/anime_repo.dart';
import '../../domain/models/anime.dart';
import '../../domain/models/related_title.dart';

final rolesAnimeProvider =
    FutureProvider.autoDispose.family<List<ShikiRole>, int>((ref, id) async {
  if (ref.state.isRefreshing) {
    await ref.debounce();
  }

  final token = ref.cancelToken();

  final roles = await ref
      .read(animeDataSourceProvider)
      .getAnimeRoles(id: id, cancelToken: token);

  return roles;

  //return roles.where((e) => e.character != null && e.person == null).toList();
}, name: 'rolesAnimeProvider');

final animeFranchiseProvider =
    FutureProvider.autoDispose.family<ShikiFranchise, int>((ref, id) async {
  final token = ref.cancelToken();

  return ref
      .watch(animeDataSourceProvider)
      .getAnimeFranchise(id: id, cancelToken: token);
}, name: 'animeFranchiseProvider');

final isAnimeInDataBaseProvider =
    FutureProvider.family.autoDispose<AnimeDatabase?, int>((ref, id) {
  final anime = ref.read(animeDatabaseProvider).getAnime(shikimoriId: id);
  return anime;
}, name: 'isAnimeInDataBaseProvider');

final similarTitlesAnimeProvider =
    FutureProvider.autoDispose.family<Iterable<Animes>, int>((ref, id) async {
  if (ref.state.isRefreshing) {
    await ref.debounce();
  }

  //ref.cacheFor();

  final token = ref.cancelToken();

  return ref.read(animeDataSourceProvider).getSimilarAnimes(
        id: id,
        cancelToken: token,
      );
}, name: 'similarTitlesAnimeProvider');

final relatedTitlesAnimeProvider = FutureProvider.autoDispose
    .family<Iterable<RelatedTitle>, int>((ref, id) async {
  // final cancelToken = CancelToken();
  // ref.onDispose(() {
  //   cancelToken.cancel();
  // });

  if (ref.state.isRefreshing) {
    await ref.debounce();
  }

  //ref.cacheFor();

  final token = ref.cancelToken();

  //await Future.delayed(const Duration(milliseconds: 250));

  return ref
      .read(animeDataSourceProvider)
      .getRelatedTitlesAnime(id: id, cancelToken: token);
}, name: 'relatedTitlesAnimeProvider');

final externalLinksAnimeProvider = FutureProvider.autoDispose
    .family<Iterable<ExternalLink>, int>((ref, id) async {
  if (ref.state.isRefreshing) {
    await ref.debounce();
  }

  //ref.cacheFor();

  final token = ref.cancelToken();

  return ref.read(animeDataSourceProvider).getExternalLinks(
        id: id,
        cancelToken: token,
      );
}, name: 'externalLinksAnimeProvider');

final titleInfoPageProvider = ChangeNotifierProvider.autoDispose
    .family<TitleInfoPageController, int>((ref, id) {
  final cancelToken = ref.cancelToken();

  final c = TitleInfoPageController(
      id, ref.read(animeDataSourceProvider), cancelToken);

  return c;
}, name: 'titleInfoPageProvider');

class TitleInfoPageController extends ChangeNotifier {
  final int id;
  final AnimeRepository animeRepository;
  final CancelToken cancelToken;
  AsyncValue<Anime> title;

  String duration = '?';
  bool isAnons = true;
  bool isFavor = false;
  String? nextEp;
  String rating = '';
  String nameEng = '';

  //List<Map<String, dynamic>> statuses = [];

  List<int> statsValues = [];

  TitleInfoPageController(this.id, this.animeRepository, this.cancelToken)
      : title = const AsyncValue.loading() {
    fetch();
  }

  int allScores = 0;
  int allStatuses = 0;

  int currentProgress = 0;
  int currentRewatches = 0;
  int currentScore = 0;
  String currentStatus = '';

  void addRate({
    required int rateId,
    required String updatedAt,
    required String status,
    int? score,
    int? episodes,
    int? rewatches,
    String? text,
    String? textHtml,
    String? createdAt,
  }) {
    if (title.asData == null) {
      return;
    }

    final UserRate rate = UserRate();

    rate.id = rateId;
    rate.createdAt = createdAt;
    rate.updatedAt = updatedAt;
    rate.score = score;
    rate.episodes = episodes;
    rate.rewatches = rewatches;
    rate.status = status;
    rate.text = text;
    rate.textHtml = textHtml;

    title.asData!.value.userRate = rate;

    notifyListeners();
  }

  void updateRate({
    required int rateId,
    required String updatedAt,
    required String status,
    int? score,
    int? episodes,
    int? rewatches,
    String? text,
    String? textHtml,
    String? createdAt,
  }) {
    if (title.asData == null) {
      return;
    }

    final rate = title.asData!.value.userRate;

    if (rate == null) {
      return;
    }

    rate.id = rateId;
    rate.createdAt = createdAt;
    rate.updatedAt = updatedAt;
    rate.score = score;
    rate.episodes = episodes;
    rate.rewatches = rewatches;
    rate.status = status;
    rate.text = text;
    rate.textHtml = textHtml;

    notifyListeners();
  }

  void deleteRate() {
    if (title.asData == null) {
      return;
    }

    title.asData!.value.userRate = null;

    notifyListeners();
  }

  // void calcAllRates() {
  //   try {
  //     for (var i = 0; i < title.asData!.value.ratesScoresStats!.length; i++) {
  //       allScores += title.asData!.value.ratesScoresStats![i].value!.toInt();
  //     }
  //   }  catch (e) {
  //     throw Exception(e);
  //   }

  //   try {
  //     for (var i = 0; i < title.asData!.value.ratesStatusesStats!.length; i++) {
  //       allStatuses +=
  //           title.asData!.value.ratesStatusesStats![i].value!.toInt();
  //     }
  //   }  catch (e) {
  //     throw Exception(e);
  //   }
  // }

  String getRating(String r) {
    const map = {
      'g': '0+',
      'pg': '6+',
      'pg_13': '16+',
      'r': '18+',
      'r_plus': '18+',
      'rx': 'Hentai',
      'none': '?'
    };
    return map[r] ?? r;
    //return '';
  }

  void fillVariables(Anime data) {
    isAnons = data.anons ?? true;
    duration = (data.duration ?? 0) == 0 ? '?' : '${data.duration}';
    isFavor = data.favoured ?? false;
    rating = getRating(data.rating ?? '');

    if (data.ratesStatusesStats != null &&
        data.ratesStatusesStats!.isNotEmpty) {
      for (var e in data.ratesStatusesStats!) {
        statsValues.add(e.value ?? 0);
      }
    }

    //print(statuses);

    if (data.nextEpisodeAt != null) {
      //final splitted = data.nextEpisodeAt!.split('-');
      //nextEp = '${splitted[1]}-${splitted[2]}';
      final dateTime = DateTime.parse(data.nextEpisodeAt!);
      nextEp = DateFormat.MMMMEEEEd().format(dateTime); //MMMEd
    }

    for (var i = 0; i < data.ratesScoresStats!.length; i++) {
      allScores += data.ratesScoresStats![i].value!.toInt();
    }

    for (var i = 0; i < data.ratesStatusesStats!.length; i++) {
      allStatuses += data.ratesStatusesStats![i].value!.toInt();
    }

    currentProgress = data.userRate!.episodes!;
    currentRewatches = data.userRate!.rewatches!;
    currentScore = data.userRate!.score!;
    currentStatus = data.userRate!.status!;

    if (data.english != null) {
      nameEng = data.english?[0] ?? '';
    }
  }

  Future<void> fetch() async {
    title = await AsyncValue.guard(
      () async {
        final updates = await animeRepository.getAnime(
          id: id,
          token: SecureStorageService.instance.token,
          cancelToken: cancelToken,
          needToCache: true,
        );
        return updates;
      },
    );
    title.whenData((value) {
      fillVariables(value);
      //calcAllRates();
    });
    //if (title.asData!.value != null) calcAllRates();
    notifyListeners();
  }
}
