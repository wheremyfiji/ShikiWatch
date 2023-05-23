import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:shikidev/src/utils/extensions/riverpod_extensions.dart';

import '../../data/data_sources/manga_data_src.dart';
import '../../data/repositories/manga_repo.dart';
import '../../domain/models/external_link.dart';
import '../../domain/models/manga_ranobe.dart';
import '../../domain/models/manga_short.dart';
import '../../domain/models/related_title.dart';
import '../../domain/models/user_rate.dart';
import '../../services/secure_storage/secure_storage_service.dart';

final relatedTitlesMangaProvider = FutureProvider.autoDispose
    .family<Iterable<RelatedTitle>, int>((ref, id) async {
  //ref.cacheFor();

  final token = ref.cancelToken();

  await Future.delayed(const Duration(milliseconds: 250));

  return ref
      .read(mangaDataSourceProvider)
      .getRelatedTitles(id: id, cancelToken: token);
}, name: 'relatedTitlesMangaProvider');

final externalLinksMangaProvider = FutureProvider.autoDispose
    .family<Iterable<ExternalLink>, int>((ref, id) async {
  if (ref.state.isRefreshing) {
    await ref.debounce();
  }

  //ref.cacheFor();

  final token = ref.cancelToken();

  return ref.read(mangaDataSourceProvider).getExternalLinks(
        id: id,
        cancelToken: token,
      );
}, name: 'externalLinksMangaProvider');

final similarTitlesMangaProvider = FutureProvider.autoDispose
    .family<Iterable<MangaShort>, int>((ref, id) async {
  if (ref.state.isRefreshing) {
    await ref.debounce();
  }

  //ref.cacheFor();

  final token = ref.cancelToken();

  return ref.read(mangaDataSourceProvider).getSimilar(
        id: id,
        cancelToken: token,
      );
}, name: 'similarTitlesMangaProvider');

final mangaDetailsPageProvider = ChangeNotifierProvider.autoDispose
    .family<MangaDetailsPageController, int>((ref, id) {
  //ref.cacheFor();

  final cancelToken = ref.cancelToken();

  final c = MangaDetailsPageController(
    id,
    ref.read(mangaDataSourceProvider),
    cancelToken,
  );

  return c;
}, name: 'mangaDetailsPageProvider');

class MangaDetailsPageController extends ChangeNotifier {
  final int id;
  final MangaRepository mangaRepository;
  final CancelToken cancelToken;
  AsyncValue<MangaRanobe> title;

  MangaDetailsPageController(this.id, this.mangaRepository, this.cancelToken)
      : title = const AsyncValue.loading() {
    fetch();
  }

  List<int> statsValues = [];

  void addRate({
    required int rateId,
    required String updatedAt,
    required String status,
    int? score,
    int? chapters,
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
    rate.chapters = chapters;
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
    int? chapters,
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
    rate.chapters = chapters;
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

  void fillVariables(MangaRanobe data) {
    if (data.ratesStatusesStats != null) {
      for (var e in data.ratesStatusesStats!) {
        statsValues.add(e.value ?? 0);
      }
    }
  }

  Future<void> fetch() async {
    title = await AsyncValue.guard(
      () async {
        final manga = await mangaRepository.getManga(
          id: id,
          token: SecureStorageService.instance.token,
          cancelToken: cancelToken,
          //needToCache: true,
        );
        return manga;
      },
    );

    title.whenData((value) {
      fillVariables(value);
    });

    notifyListeners();
  }
}
