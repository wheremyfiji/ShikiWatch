import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../data/data_sources/anime_data_src.dart';
import '../../data/repositories/anime_repo.dart';
import '../../domain/models/animes.dart';
import '../../services/secure_storage/secure_storage_service.dart';

final explorePageProvider = ChangeNotifierProvider((ref) {
  // final c = ExplorePageController(ref.read(animeDataSourceProvider));
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

// class AnimePageController extends ChangeNotifier {
//   final AnimeRepository animeRepository;

//   //final Ref _ref;
//   AsyncValue<List<Animes>> animes;
//   bool isLoadingMore = false;
//   bool showJump = false;

//   int currentPage = 2;
//   int limit = 45; //15  45

//   bool hasMore = true;
//   bool respEmpty = false;

//   AnimePageController(this.animeRepository)
//       : animes = const AsyncValue.loading() {
//     fetch();
//   }

//   void onLoadMore() {
//     if (!isLoadingMore) {
//       isLoadingMore = true;
//       fetchMore().catchError((err, stack) => print(stack)).whenComplete(() {
//         currentPage++;
//         isLoadingMore = false;
//       });
//     }
//   }

//   Future<Iterable<Animes>> baseRequest({int page = 1}) async {
//     final req = await animeRepository.getAnimes(
//       page: page,
//       limit: limit,
//       order: 'ranked', // ranked ?? popularity
//       status: 'ongoing',
//       //season: 'spring_2023', //  winter_2023
//       score: 1,
//       censored: 'true',
//       userToken: SecureStorageService.instance.token,
//     );
//     return req;
//   }

//   Future<void> fetch() async {
//     animes = await AsyncValue.guard(
//       () async {
//         // final updates = await animeRepository.getAnimes(
//         //   page: 1,
//         //   limit: limit,
//         //   order: 'ranked', // ranked popularity
//         //   status: 'ongoing',
//         //   season: 'winter_2023',
//         //   score: 1,
//         //   userToken: SecureStorageService.instance.token,
//         // );
//         // // final updates = await _ref.read(animeDataSourceProvider).getAnimes(
//         // //       page: 1,
//         // //       limit: limit,
//         // //       order: 'ranked',
//         // //     );
//         // return updates.toList();
//         final data = await baseRequest();
//         if (data.isEmpty) {
//           hasMore = false;
//           respEmpty = true;
//         }
//         return data.toList();
//       },
//     );
//     //if (animes.asData.hasValue)
//     currentPage = 2;
//     hasMore = !respEmpty;
//     notifyListeners();
//   }

//   Future<void> fetchMore() async {
//     // final resp = await _ref.read(shikimoriRepositoryProvider).getAnimes(
//     //       page: currentPage,
//     //       limit: limit,
//     //       order: 'ranked',
//     //     );
//     // final resp = await animeRepository.getAnimes(
//     //   page: currentPage,
//     //   limit: limit,
//     //   order: 'ranked',
//     //   status: 'ongoing',
//     //   season: 'winter_2023',
//     //   score: 1,
//     //   userToken: SecureStorageService.instance.token,
//     // );

//     if (!hasMore) return;

//     //await Future.delayed(const Duration(milliseconds: 200));

//     final resp = await baseRequest(page: currentPage);
//     // print('resp debug:: resp.length = ${resp.length}');
//     // if (resp.length > limit && currentPage > 2) {
//     //   hasMore = false;
//     //   print('resp debug:: hasMore = false');
//     // }

//     //log('resp items count: ${resp.length}', name: 'on load more');

//     if (resp.isEmpty) {
//       hasMore = false;
//     } else {
//       animes.value!.addAll(resp);
//     }

//     notifyListeners();
//   }
// }
