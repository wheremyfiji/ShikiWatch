//import 'dart:async';
import 'package:flutter/widgets.dart' as flutter;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../data/data_sources/anime_data_src.dart';
import '../../data/repositories/anime_repo.dart';
import '../../domain/models/anime_filter.dart';
import '../../domain/models/animes.dart';
import '../../services/secure_storage/secure_storage_service.dart';
import '../../services/shared_pref/shared_preferences_provider.dart';
import '../../utils/debouncer.dart';

const String animeSearchHistoryKey = 'anime_search_history';

final animeSearchProvider = ChangeNotifierProvider.autoDispose((ref) {
  final c = AnimeSearchController(ref, ref.read(animeDataSourceProvider));
  c.initState();
  ref.onDispose(() {
    c.textEditingController.dispose();
    c.pageController.dispose();
    c.focusNode.dispose();
    c.debouncer.dispose();
  });
  return c;
}, name: 'animeSearchProvider');

List<AnimeFilter> animeSortList = [
  AnimeFilter('ranked', 'Оценке'),
  AnimeFilter('popularity', 'Популярности'),
  AnimeFilter('aired_on', 'Дате выхода'),
  //AnimeFilter('status', 'Статусу'),
  //AnimeFilter('kind', 'Типу'),
  //AnimeFilter('name', 'Имени'),
  AnimeFilter('episodes', 'Кол-ву эпизодов'),
  AnimeFilter('created_at', 'Дате создания'),
  AnimeFilter('created_at_desc', 'Дате создания (по убыванию)'),
];

List<AnimeFilter> animeEpisodeDurationList = [
  AnimeFilter('S', 'Менее 10 минут'),
  AnimeFilter('D', 'Менее 30 минут'),
  AnimeFilter('F', 'Более 30 минут'),
];

List<AnimeFilter> animeMyList = [
  AnimeFilter('planned', 'В планах'),
  AnimeFilter('watching', 'Смотрю'),
  AnimeFilter('rewatching', 'Пересматриваю'),
  AnimeFilter('completed', 'Просмотрено'),
  AnimeFilter('on_hold', 'Отложено'),
  AnimeFilter('dropped', 'Брошено'),
];

List<AnimeFilter> animeStatusList = [
  AnimeFilter('anons', 'Анонс'),
  AnimeFilter('ongoing', 'Онгоинг'),
  AnimeFilter('released', 'Вышло'),
];

List<AnimeFilter> animeKindList = [
  AnimeFilter('tv', 'Сериал'),
  AnimeFilter('movie', 'Фильм'),
  AnimeFilter('ova', 'OVA'),
  AnimeFilter('ona', 'ONA'),
  AnimeFilter('special', 'Спешл'),
  AnimeFilter('music', 'Клип'),
];

class AnimeSearchController extends flutter.ChangeNotifier {
  AnimeSearchController(this._ref, this.animeRepository)
      : textEditingController = flutter.TextEditingController(),
        debouncer = Debouncer(delay: const Duration(milliseconds: 800));

  final Ref _ref;
  final Debouncer debouncer;
  final AnimeRepository animeRepository;

  final flutter.TextEditingController textEditingController;

  final PagingController<int, Animes> _pagingController =
      PagingController(firstPageKey: 1);

  late flutter.FocusNode _focusNode;

  List<String> searchHistory = [];
  static const _limit = 25;

  // что это
  bool f = false;
  bool showHistory = true;
  bool isFilterApplied = false;

  String? selectedStatus;
  String? selectedKind;
  String? selectedMyList;
  String? selectedEpDuration;
  String? selectedSortType;

  Set<String> filterCount = {};

  PagingController<int, Animes> get pageController => _pagingController;

  flutter.FocusNode get focusNode => _focusNode;

  void initState() {
    _focusNode = flutter.FocusNode();
    _focusNode.requestFocus();
    _pagingController.addPageRequestListener((pageKey) {
      _fetch(pageKey);
    });
    searchHistory = _ref
            .read(sharedPreferencesProvider)
            .getStringList(animeSearchHistoryKey) ??
        [];
  }

  toggleStatus({required AnimeFilter s, required bool t}) {
    if (t) {
      filterCount.add('status');
      selectedStatus = s.shiki;
    } else {
      filterCount.remove('status');
      selectedStatus = null;
    }
    //print('selectedStatus: $selectedStatus');
    notifyListeners();
  }

  bool isStatusSelected(AnimeFilter s) {
    if (selectedStatus == null) {
      return false;
    }

    if (selectedStatus != null && selectedStatus == s.shiki) {
      return true;
    }

    return false;
  }

  toggleKind({required AnimeFilter k, required bool t}) {
    if (t) {
      filterCount.add('kind');
      selectedKind = k.shiki;
    } else {
      filterCount.remove('kind');
      selectedKind = null;
    }
    //print('selectedKind: $selectedKind');
    notifyListeners();
  }

  bool isKindSelected(AnimeFilter k) {
    if (selectedKind == null) {
      return false;
    }

    if (selectedKind != null && selectedKind == k.shiki) {
      return true;
    }

    return false;
  }

  toggleMyList({required AnimeFilter l, required bool t}) {
    if (t) {
      filterCount.add('list');
      selectedMyList = l.shiki;
    } else {
      filterCount.remove('list');
      selectedMyList = null;
    }
    //print('selectedMyList: $selectedMyList');
    notifyListeners();
  }

  bool isMyListSelected(AnimeFilter l) {
    if (selectedMyList == null) {
      return false;
    }

    if (selectedMyList != null && selectedMyList == l.shiki) {
      return true;
    }

    return false;
  }

  toggleEpDuration({required AnimeFilter e, required bool t}) {
    if (t) {
      filterCount.add('ep_dur');
      selectedEpDuration = e.shiki;
    } else {
      filterCount.remove('ep_dur');
      selectedEpDuration = null;
    }
    //print('selectedEpDuration: $selectedEpDuration');
    notifyListeners();
  }

  bool isEpDurationSelected(AnimeFilter e) {
    if (selectedEpDuration == null) {
      return false;
    }

    if (selectedEpDuration != null && selectedEpDuration == e.shiki) {
      return true;
    }

    return false;
  }

  toggleSortType({required AnimeFilter sort, required bool t}) {
    if (t) {
      filterCount.add('sort');
      selectedSortType = sort.shiki;
    } else {
      filterCount.remove('sort');
      selectedSortType = null;
    }
    //print('selectedSortType: $selectedSortType');
    notifyListeners();
  }

  bool isSortTypeSelected(AnimeFilter sort) {
    if (selectedSortType == null) {
      return false;
    }

    if (selectedSortType != null && selectedSortType == sort.shiki) {
      return true;
    }

    return false;
  }

  applyFilter() {
    f = true;
    isFilterApplied = true;
    showHistory = false;
    notifyListeners();
    _pagingController.refresh();
  }

  clearFilter() {
    selectedStatus = null;
    selectedKind = null;
    selectedMyList = null;
    selectedEpDuration = null;
    selectedSortType = null;
    isFilterApplied = false;
    showHistory = true;
    filterCount.clear();
    notifyListeners();
    //_pagingController.refresh();
  }

  void onSearchChanged(String query) {
    if (query.isNotEmpty && query.length < 3) {
      return;
    }

    notifyListeners();

    if (isFilterApplied) {
      debouncer.run(() {
        _pagingController.refresh();
      });
      return;
    }

    if (query.isEmpty &&
        _pagingController.itemList != null &&
        !isFilterApplied) {
      _pagingController.itemList!.clear();
      notifyListeners();
      return;
    }

    if (isFilterApplied) {
      debouncer.run(() {
        _pagingController.refresh();
      });
      return;
    }

    if (f) {
      debouncer.run(() {
        _pagingController.refresh();
      });
    }

    if (!f) {
      f = true;
    }
  }

  void clearQuery() {
    textEditingController.clear();

    if (_pagingController.itemList != null && !isFilterApplied) {
      _pagingController.itemList!.clear();
    }

    if (isFilterApplied) {
      _pagingController.refresh();
    }

    notifyListeners();
  }

  Future<void> _fetch(int pageKey) async {
    try {
      final data = await animeRepository.getAnimes(
        page: pageKey,
        limit: _limit,
        order: selectedSortType,
        kind: selectedKind,
        status: selectedStatus,
        duration: selectedEpDuration,
        //rating: ,
        mylist: selectedMyList,
        censored: 'true',
        //score: 1,
        search: textEditingController.text != ''
            ? textEditingController.text
            : null,
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

  Future<void> onSearchSubmitted(String query) async {
    if (query.isEmpty) {
      return;
    }

    final prefs = _ref.read(sharedPreferencesProvider);

    //Use `Set` to avoid duplication of recentSearches
    Set<String> allSearches =
        prefs.getStringList(animeSearchHistoryKey)?.toSet() ?? {};

    //Place it at first in the set
    allSearches = {query, ...allSearches};
    prefs.setStringList(animeSearchHistoryKey, allSearches.toList());

    searchHistory = {query, ...allSearches}.toList();

    notifyListeners();
  }

  void onHistoryTap(String query) {
    if (query.isEmpty) {
      return;
    }

    textEditingController.text = query;
    notifyListeners();
    _pagingController.refresh();
  }

  void clearHistory() {
    final prefs = _ref.read(sharedPreferencesProvider);

    prefs.remove(animeSearchHistoryKey);
    searchHistory = [];
    notifyListeners();
  }
}

// class AnimeSearchController extends flutter.ChangeNotifier {
//   final Ref _ref;
//   final Debouncer debouncer;
//   final AnimeRepository animeRepository;
//   AsyncValue<List<Animes>> titles;

//   final flutter.TextEditingController textEditingController;

//   // _pagingController.addPageRequestListener((pageKey) {
//   //     _fetchApi(pageKey);
//   //   });

//   AnimeSearchController(this._ref, this.animeRepository)
//       : titles = const AsyncValue.data([]),
//         textEditingController = flutter.TextEditingController(),
//         debouncer = Debouncer(delay: const Duration(milliseconds: 800));

//   List<String> searchHistory = [];
//   static const _limit = 30;
//   final PagingController<int, Animes> _pagingController =
//       PagingController(firstPageKey: 1);

//   PagingController<int, Animes> get pageController => _pagingController;

//   void initState() {
//     _pagingController.addPageRequestListener((pageKey) {
//       _fetchTest(pageKey);
//     });
//     searchHistory = _ref
//             .read(sharedPreferencesProvider)
//             .getStringList(animeSearchHistoryKey) ??
//         [];
//     //searchHistory = t.reversed.toList();
//     //notifyListeners();
//   }

//   void onSearchChanged(String query) {
//     if (query.isNotEmpty && query.length < 3) {
//       return;
//     }

//     if (query.isEmpty && titles.asData?.value != null) {
//       titles.asData!.value.clear();
//       notifyListeners();
//       return;
//     }
//     debouncer.run(() {
//       _pagingController.refresh();
//       //fetch(query);
//     });
//   }

//   void clearQuery() {
//     textEditingController.clear();

//     if (titles.asData?.value != null) {
//       titles.asData!.value.clear();
//     }

//     notifyListeners();
//   }

//   Future<void> onSearchSubmitted(String query) async {
//     if (query.isEmpty) {
//       return;
//     }

//     final prefs = _ref.read(sharedPreferencesProvider);

//     //Use `Set` to avoid duplication of recentSearches
//     Set<String> allSearches =
//         prefs.getStringList(animeSearchHistoryKey)?.toSet() ?? {};

//     //Place it at first in the set
//     allSearches = {query, ...allSearches};
//     prefs.setStringList(animeSearchHistoryKey, allSearches.toList());

//     searchHistory = {query, ...allSearches}.toList();

//     notifyListeners();
//   }

//   void onHistoryTap(String query) {
//     if (query.isEmpty) {
//       return;
//     }

//     textEditingController.text = query;
//     notifyListeners();
//     fetch(query);
//   }

//   void clearHistory() {
//     final prefs = _ref.read(sharedPreferencesProvider);

//     prefs.remove(animeSearchHistoryKey);
//     searchHistory = [];
//     notifyListeners();
//   }

//   Future<void> fetch(String query) async {
//     titles = const AsyncValue.loading();
//     notifyListeners();
//     titles = await AsyncValue.guard(
//       () async {
//         return (await animeRepository.getAnimes(
//           limit: _limit, //15
//           //order: 'popularity',
//           //order: 'ranked',
//           search: query,
//           censored: 'true',
//           mylist: 'planned',
//           userToken: SecureStorageService.instance.token,
//         ))
//             .toList();
//       },
//     );
//     notifyListeners();
//   }

//   Future<void> _fetchTest(int pageKey) async {
//     try {
//       final data = await animeRepository.getAnimes(
//         page: pageKey,
//         limit: _limit,
//         order: 'ranked', // ranked ?? popularity
//         status: 'ongoing',
//         //season: 'spring_2023', //  winter_2023
//         score: 1,
//         censored: 'true',
//         userToken: SecureStorageService.instance.token,
//       );
//       final animes = data.toList();
//       final isLastPage = animes.length < _limit;
//       if (isLastPage) {
//         _pagingController.appendLastPage(animes);
//       } else {
//         _pagingController.appendPage(animes, pageKey + 1);
//       }
//     } catch (error) {
//       _pagingController.error = error;
//     }
//   }

//   // Future<void> fetch(String query) async {
//   //   titles = const AsyncValue.loading();
//   //   notifyListeners();
//   //   titles = await AsyncValue.guard(
//   //     () async {
//   //       return (await animeRepository.getAnimes(
//   //         limit: _limit, //15
//   //         //order: 'popularity',
//   //         //order: 'ranked',
//   //         search: query,
//   //         censored: 'true',
//   //         mylist: 'planned',
//   //         userToken: SecureStorageService.instance.token,
//   //       ))
//   //           .toList();
//   //     },
//   //   );
//   //   notifyListeners();
//   // }
// }


// class AnimeSearchController extends flutter.ChangeNotifier {
//   final Ref _ref;
//   final Debouncer debouncer;
//   final AnimeRepository animeRepository;
//   AsyncValue<List<Animes>> titles;

//   final flutter.TextEditingController textEditingController;

//   AnimeSearchController(this._ref, this.animeRepository)
//       : titles = const AsyncValue.data([]),
//         textEditingController = flutter.TextEditingController(),
//         debouncer = Debouncer(delay: const Duration(milliseconds: 800));

//   List<String> searchHistory = [];

//   void initState() {
//     searchHistory = _ref
//             .read(sharedPreferencesProvider)
//             .getStringList(animeSearchHistoryKey) ??
//         [];
//     //searchHistory = t.reversed.toList();
//     //notifyListeners();
//   }

//   void onSearchChanged(String query) {
//     if (query.isNotEmpty && query.length < 3) {
//       return;
//     }

//     if (query.isEmpty && titles.asData?.value != null) {
//       titles.asData!.value.clear();
//       notifyListeners();
//       return;
//     }
//     debouncer.run(() {
//       fetch(query);
//     });
//   }

//   void clearQuery() {
//     textEditingController.clear();

//     if (titles.asData?.value != null) {
//       titles.asData!.value.clear();
//     }

//     notifyListeners();
//   }

//   Future<void> onSearchSubmitted(String query) async {
//     if (query.isEmpty) {
//       return;
//     }

//     final prefs = _ref.read(sharedPreferencesProvider);

//     //Use `Set` to avoid duplication of recentSearches
//     Set<String> allSearches =
//         prefs.getStringList(animeSearchHistoryKey)?.toSet() ?? {};

//     //Place it at first in the set
//     allSearches = {query, ...allSearches};
//     prefs.setStringList(animeSearchHistoryKey, allSearches.toList());

//     searchHistory = {query, ...allSearches}.toList();

//     notifyListeners();
//   }

//   void onHistoryTap(String query) {
//     if (query.isEmpty) {
//       return;
//     }

//     textEditingController.text = query;
//     notifyListeners();
//     fetch(query);
//   }

//   void clearHistory() {
//     final prefs = _ref.read(sharedPreferencesProvider);

//     prefs.remove(animeSearchHistoryKey);
//     searchHistory = [];
//     notifyListeners();
//   }

//   Future<void> fetch(String query) async {
//     titles = const AsyncValue.loading();
//     notifyListeners();
//     titles = await AsyncValue.guard(
//       () async {
//         return (await animeRepository.getAnimes(
//           limit: 30, //15
//           //order: 'popularity',
//           //order: 'ranked',
//           search: query,
//           censored: 'true',
//           userToken: SecureStorageService.instance.token,
//         ))
//             .toList();
//       },
//     );
//     notifyListeners();
//   }
// }
