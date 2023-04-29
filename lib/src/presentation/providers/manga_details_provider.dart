import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:shikidev/src/utils/extensions/riverpod_extensions.dart';

import '../../data/data_sources/manga_data_src.dart';
import '../../data/repositories/manga_repo.dart';
import '../../domain/models/manga_ranobe.dart';
import '../../services/secure_storage/secure_storage_service.dart';

final mangaDetailsPageProvider = ChangeNotifierProvider.autoDispose
    .family<MangaDetailsPageController, int>((ref, id) {
  ref.cacheFor();

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
