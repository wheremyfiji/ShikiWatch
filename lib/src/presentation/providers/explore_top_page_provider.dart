import 'package:flutter/widgets.dart';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shikidev/src/utils/extensions/riverpod_extensions.dart';

import '../../data/data_sources/anime_data_src.dart';
import '../../data/data_sources/manga_data_src.dart';
import '../../data/repositories/anime_repo.dart';
import '../../data/repositories/manga_repo.dart';
import '../../domain/models/animes.dart';
import '../../domain/models/manga_short.dart';
import '../../services/secure_storage/secure_storage_service.dart';

final exploreTopAnimePageProvider = ChangeNotifierProvider.autoDispose((ref) {
  final token = ref.cancelToken();

  final c = ExploreTopAnimePageController(
    animeRepository: ref.read(animeDataSourceProvider),
    cancelToken: token,
  );

  ref.onDispose(() {
    c.pageController.dispose();
  });

  return c;
}, name: 'exploreTopAnimePageProvider');

class ExploreTopAnimePageController extends ChangeNotifier {
  ExploreTopAnimePageController({
    required this.animeRepository,
    required this.cancelToken,
  }) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchApi(pageKey);
    });
  }

  final AnimeRepository animeRepository;
  final CancelToken cancelToken;

  final PagingController<int, Animes> _pagingController =
      PagingController(firstPageKey: 1);

  static const _limit = 30;

  PagingController<int, Animes> get pageController => _pagingController;

  Future<void> _fetchApi(int pageKey) async {
    try {
      final data = await animeRepository.getAnimes(
        page: pageKey,
        limit: _limit,
        order: 'ranked',
        score: 1,
        censored: 'true',
        userToken: SecureStorageService.instance.token,
        cancelToken: cancelToken,
      );

      final animes = data.toList();

      final isLastPage = animes.length < _limit;

      if (isLastPage) {
        _pagingController.appendLastPage(animes);
      } else {
        _pagingController.appendPage(animes, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }
}

final exploreTopMangaPageProvider = ChangeNotifierProvider.autoDispose((ref) {
  final token = ref.cancelToken();

  final c = ExploreTopMangaPageController(
    mangaRepository: ref.read(mangaDataSourceProvider),
    cancelToken: token,
  );

  ref.onDispose(() {
    c.pageController.dispose();
  });

  return c;
}, name: 'exploreTopMangaPageProvider');

class ExploreTopMangaPageController extends ChangeNotifier {
  ExploreTopMangaPageController({
    required this.mangaRepository,
    required this.cancelToken,
  }) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchApi(pageKey);
    });
  }

  final MangaRepository mangaRepository;
  final CancelToken cancelToken;

  final PagingController<int, MangaShort> _pagingController =
      PagingController(firstPageKey: 1);

  static const _limit = 30;

  PagingController<int, MangaShort> get pageController => _pagingController;

  Future<void> _fetchApi(int pageKey) async {
    try {
      final data = await mangaRepository.getMangas(
        page: pageKey,
        limit: _limit,
        order: 'ranked',
        score: 1,
        censored: 'true',
        userToken: SecureStorageService.instance.token,
        cancelToken: cancelToken,
      );

      final mangas = data.toList();

      final isLastPage = mangas.length < _limit;

      if (isLastPage) {
        _pagingController.appendLastPage(mangas);
      } else {
        _pagingController.appendPage(mangas, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }
}
