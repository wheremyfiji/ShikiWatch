import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shikidev/src/utils/extensions/riverpod_extensions.dart';

import '../../services/secure_storage/secure_storage_service.dart';
import '../../data/data_sources/anime_data_src.dart';
import '../../data/repositories/anime_repo.dart';
import '../../domain/models/anime.dart';
import '../../domain/models/related_title.dart';

final relatedTitlesAnimeProvider = FutureProvider.autoDispose
    .family<Iterable<RelatedTitle>, int>((ref, id) async {
  // final cancelToken = CancelToken();
  // ref.onDispose(() {
  //   cancelToken.cancel();
  // });

  if (ref.state.isRefreshing) {
    await ref.debounce();
  }

  ref.cacheFor();

  final token = ref.cancelToken();

  await Future.delayed(const Duration(milliseconds: 250));

  return ref
      .read(animeDataSourceProvider)
      .getRelatedTitlesAnime(id: id, cancelToken: token);
}, name: 'relatedTitlesAnimeProvider');

// final similarAnimesProvider =
//     FutureProvider.autoDispose.family<Iterable<Animes>, int>((ref, id) async {
//   await Future.delayed(const Duration(milliseconds: 250));

//   return ref.watch(shikimoriRepositoryProvider).getSimilarAnimes(id: id);
// }, name: 'similarAnimesProvider');

// final franchiseProvider =
//     FutureProvider.autoDispose.family<Franchise, int>((ref, id) async {
//   await Future.delayed(const Duration(milliseconds: 500));

//   return ref.watch(shikimoriRepositoryProvider).getAnimeFranchise(id: id);
// }, name: 'franchiseProvider');

final titleInfoPageProvider = ChangeNotifierProvider.autoDispose
    .family<TitleInfoPageController, int>((ref, id) {
  // final cancelToken = CancelToken();
  // ////ref.onDispose(() => cancelToken.cancel());
  // ref.onDispose(() {
  //   cancelToken.cancel();
  // });
  ref.cacheFor();

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

  int duration = 0;
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

  // int? currentProgress;
  // int? currentRewatches = 0;
  // int? currentScore = 0;
  // String? currentStatus = '';

  String userImage = '';

  // void addEpisodeButton() {
  //   if (currentProgress < title.asData!.value.episodes!) {
  //     currentProgress = currentProgress + 1;
  //   }
  //   notifyListeners();
  // }

  // void removeEpisodeButton() {
  //   if (currentProgress > 0) {
  //     currentProgress = currentProgress - 1;
  //   }
  //   notifyListeners();
  // }

  // void addRewatchButton() {
  //   currentRewatches = currentRewatches + 1;
  //   notifyListeners();
  // }

  // void removeRewatchButton() {
  //   if (currentRewatches > 0) {
  //     currentRewatches = currentRewatches - 1;
  //   }
  //   notifyListeners();
  // }

  // void incScoreButton() {
  //   if (currentScore < 10) {
  //     currentScore = currentScore + 1;
  //   }
  //   notifyListeners();
  // }

  // void decScoreButton() {
  //   if (currentScore > 0) {
  //     currentScore = currentScore - 1;
  //   }
  //   notifyListeners();
  // }

  // void onStatusSelected(bool selected, String newStatus) {
  //   if (selected) {
  //     currentStatus = newStatus;
  //   }
  //   notifyListeners();
  // }

  // void fillVariables( Anime data) {
  //   try {
  //     currentProgress = title.asData!.value.userRate!.episodes!;
  //     currentRewatches = title.asData!.value.userRate!.rewatches!;
  //     currentScore = title.asData!.value.userRate!.score!;
  //     currentStatus = title.asData!.value.userRate!.status!;

  //     isAnons = title.asData?.value.anons ?? true;
  //     duration = title.asData?.value.duration ?? 0;
  //   } on Exception catch (e) {
  //     throw Exception(e);
  //   }

  //   try {
  //     for (var i = 0; i < title.asData!.value.ratesScoresStats!.length; i++) {
  //       allScores += title.asData!.value.ratesScoresStats![i].value!.toInt();
  //     }
  //   } on Exception catch (e) {
  //     throw Exception(e);
  //   }

  //   try {
  //     for (var i = 0; i < title.asData!.value.ratesStatusesStats!.length; i++) {
  //       allStatuses +=
  //           title.asData!.value.ratesStatusesStats![i].value!.toInt();
  //     }
  //   } on Exception catch (e) {
  //     throw Exception(e);
  //   }
  // }

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

  void calcAllRates() {
    try {
      for (var i = 0; i < title.asData!.value.ratesScoresStats!.length; i++) {
        allScores += title.asData!.value.ratesScoresStats![i].value!.toInt();
      }
    } on Exception catch (e) {
      throw Exception(e);
    }

    try {
      for (var i = 0; i < title.asData!.value.ratesStatusesStats!.length; i++) {
        allStatuses +=
            title.asData!.value.ratesStatusesStats![i].value!.toInt();
      }
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  String getRating(String r) {
    const map = {
      'g': '0+',
      'pg': '6+',
      'pg_13': '16+',
      'r': '18+',
      'r_plus': '18+',
      'rx': 'Hentai'
    };
    return map[r] ?? r;
    //return '';
  }

  void fillVariables(Anime data) {
    isAnons = data.anons ?? true;
    duration = data.duration ?? 0;
    isFavor = data.favoured ?? false;
    rating = getRating(data.rating ?? '');

    if (data.ratesStatusesStats != null) {
      for (var e in data.ratesStatusesStats!) {
        statsValues.add(e.value ?? 0);
        //statuses.add({'domain': element.name, 'measure': element.value});
      }
    }

    //print(statuses);

    if (data.nextEpisodeAt != null) {
      //final splitted = data.nextEpisodeAt!.split('-');
      //nextEp = '${splitted[1]}-${splitted[2]}';
      final dateTime = DateTime.parse(data.nextEpisodeAt!);
      nextEp = DateFormat.MMMEd().format(dateTime);
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
    userImage = SecureStorageService.instance.userProfileImage;
    //if (title.asData!.value != null) calcAllRates();
    notifyListeners();
  }
}
