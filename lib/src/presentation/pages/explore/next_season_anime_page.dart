import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shikidev/src/utils/extensions/riverpod_extensions.dart';

import '../../../data/data_sources/anime_data_src.dart';
import '../../../data/repositories/anime_repo.dart';
import '../../../domain/models/animes.dart';
import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../utils/shiki_utils.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/error_widget.dart';

class NextSeasonAnimePage extends ConsumerWidget {
  const NextSeasonAnimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(nextSeasonAnimePageProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Выйдет в след. сезоне'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: PagedSliverGrid<int, Animes>(
              //addRepaintBoundaries: false,
              addSemanticIndexes: false,
              addRepaintBoundaries: false,
              showNewPageErrorIndicatorAsGridChild: false,
              pagingController: controller.pageController,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 140, //150
                //mainAxisExtent: 230,
                childAspectRatio: 0.55,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              builderDelegate: PagedChildBuilderDelegate<Animes>(
                firstPageErrorIndicatorBuilder: (context) {
                  return CustomErrorWidget(
                    controller.pageController.error.toString(),
                    () => controller.pageController.refresh(),
                  );
                },
                newPageErrorIndicatorBuilder: (context) {
                  return CustomErrorWidget(
                    controller.pageController.error.toString(),
                    () => controller.pageController.retryLastFailedRequest(),
                  );
                },
                itemBuilder: (context, item, index) {
                  return AnimeTileExp(item, showScore: false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final nextSeasonAnimePageProvider = ChangeNotifierProvider.autoDispose((ref) {
  final token = ref.cancelToken();

  final c = NextSeasonAnimePageController(
    animeRepository: ref.read(animeDataSourceProvider),
    cancelToken: token,
  );

  ref.onDispose(() {
    c.pageController.dispose();
  });

  return c;
}, name: 'exploreTopAnimePageProvider');

class NextSeasonAnimePageController extends ChangeNotifier {
  NextSeasonAnimePageController({
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
        order: 'popularity',
        censored: 'true',
        season: getNextSeason(),
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
