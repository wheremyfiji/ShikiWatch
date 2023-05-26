import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../data/data_sources/anime_data_src.dart';
import '../../data/repositories/anime_repo.dart';
import '../../domain/models/animes.dart';
import '../../services/secure_storage/secure_storage_service.dart';

final explorePageProvider = ChangeNotifierProvider((ref) {
  final c = ExplorePageController(
    animeRepository: ref.read(animeDataSourceProvider),
  );

  ref.onDispose(() {
    c.pageController.dispose();
  });

  return c;
}, name: 'explorePageProvider');

class ExplorePageController extends ChangeNotifier {
  ExplorePageController({required this.animeRepository}) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchApi(pageKey);
    });
  }

  final AnimeRepository animeRepository;

  final PagingController<int, Animes> _pagingController =
      PagingController(firstPageKey: 1);

  static const _limit = 30;

  PagingController<int, Animes> get pageController => _pagingController;

  Future<void> _fetchApi(int pageKey) async {
    try {
      final data = await animeRepository.getAnimes(
        page: pageKey,
        limit: _limit,
        order: 'ranked', // ranked ?? popularity
        status: 'ongoing',
        //season: 'spring_2023', //  winter_2023
        score: 1,
        censored: 'true',
        userToken: SecureStorageService.instance.token,
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
