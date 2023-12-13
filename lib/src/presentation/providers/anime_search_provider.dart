//import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart' as flutter;

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

import '../../data/data_sources/ranobe_data_src.dart';
import '../../data/repositories/ranobe_repo.dart';
import '../../domain/models/manga_short.dart';
import '../../data/data_sources/manga_data_src.dart';
import '../../data/repositories/manga_repo.dart';
import '../../domain/models/animes.dart';
import '../../domain/enums/search_state.dart';
import '../../domain/models/shiki_title.dart';
import '../../services/secure_storage/secure_storage_service.dart';
import '../../services/preferences/preferences_service.dart';
import '../../utils/extensions/riverpod_extensions.dart';
import '../../data/data_sources/anime_data_src.dart';
import '../../data/repositories/anime_repo.dart';
import '../../domain/models/anime_filter.dart';
import '../pages/search/anime_genres.dart';
//import '../../domain/models/animes.dart';
import '../../domain/models/genre.dart';
import '../../utils/debouncer.dart';

const String animeSearchHistoryKey = 'anime_search_history';

class SearchPageParameters extends Equatable {
  const SearchPageParameters({
    required this.studioId,
    required this.genreId,
  });

  final int studioId;
  final int genreId;

  @override
  List<Object> get props => [
        studioId,
        genreId,
      ];
}

// final searchTypeProvider = StateProvider<SearchState>((ref) {
//   return SearchState.anime;
// }, name: 'searchTypeProvider');

final animeSearchProvider = ChangeNotifierProvider.autoDispose
    .family<AnimeSearchController, SearchPageParameters>((ref, i) {
  final cancelToken = ref.cancelToken();

  final c = AnimeSearchController(
    ref,
    animeRepository: ref.read(animeDataSourceProvider),
    mangaRepository: ref.read(mangaDataSourceProvider),
    ranobeRepository: ref.read(ranobeDataSourceProvider),
    cancelToken: cancelToken,
    initGenre: i.genreId,
    initStudio: i.studioId,
  );

  c.initState();

  ref.onDispose(() {
    c.textEditingController.dispose();
    c.pageController.dispose();
    c.focusNode.dispose();
    c.debouncer.dispose();
  });

  return c;
}, name: 'animeSearchProvider');

class AnimeSearchController extends flutter.ChangeNotifier {
  AnimeSearchController(this._ref,
      {required this.animeRepository,
      required this.mangaRepository,
      required this.ranobeRepository,
      required this.cancelToken,
      required this.initGenre,
      required this.initStudio})
      : textEditingController = flutter.TextEditingController(),
        debouncer = Debouncer(delay: const Duration(milliseconds: 800));

  final Ref _ref;
  final CancelToken cancelToken;
  final Debouncer debouncer;

  final AnimeRepository animeRepository;
  final MangaRepository mangaRepository;
  final RanobeRepository ranobeRepository;

  final int initGenre;
  int initStudio = 0;

  final flutter.TextEditingController textEditingController;

  final PagingController<int, ShikiTitle> _pagingController =
      PagingController(firstPageKey: 1);

  late flutter.FocusNode _focusNode;

  List<String> searchHistory = [];
  static const _limit = 25;

  SearchType _searchType = SearchType.anime;

  // что это
  bool f = false;
  bool showHistory = true;
  bool isFilterApplied = false;

  String? selectedStatus;
  String? selectedKind;
  String? selectedMyList;
  String? selectedEpDuration;
  String? selectedSortType;

  int minimalScore = 0;

  Set<String> filterCount = {};

  Set<Genre>? selectedGenres;

  //bool disableSearch = false;

  PagingController<int, ShikiTitle> get pageController => _pagingController;
  SearchType get searchType => _searchType;

  flutter.FocusNode get focusNode => _focusNode;

  void initState() {
    _focusNode = flutter.FocusNode();

    _pagingController.addPageRequestListener((pageKey) {
      _fetch(pageKey);
    });
    // searchHistory = _ref
    //         .read(sharedPreferencesProvider)
    //         .getStringList(animeSearchHistoryKey) ??
    //     [];

    searchHistory = _ref
            .read(preferencesProvider)
            .sharedPreferences
            .getStringList(animeSearchHistoryKey) ??
        [];

    if (initGenre != 0 || initStudio != 0) {
      //disableSearch = true;

      if (initGenre != 0) {
        final g = animeGenres.firstWhere((element) => element.id == initGenre);
        addGenre(g);
      }

      if (initStudio != 0) {
        filterCount.add('stdo');
      }

      applyFilter();
      return;
    }
    _focusNode.requestFocus();
  }

  changeSearchType(SearchType s) {
    _searchType = s;

    if (textEditingController.text.isNotEmpty ||
        _pagingController.itemList != null) {
      _pagingController.refresh();
    }

    notifyListeners();
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

  cleanKind() {
    selectedKind = null;
    filterCount.remove('kind');
    notifyListeners();
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

  addGenre(Genre g) {
    if (selectedGenres == null) {
      selectedGenres = {g};
    } else {
      selectedGenres!.add(g);
    }
    filterCount.add('genre');
    //log('count: ${selectedGenres?.length}', name: 'genre');
    notifyListeners();
  }

  removeGenre(Genre g) {
    selectedGenres?.remove(g);

    if (selectedGenres?.isEmpty ?? false) {
      filterCount.remove('genre');
    }
    //log('count: ${selectedGenres?.length}', name: 'genre');
    notifyListeners();
  }

  clearSelectedGenres() {
    filterCount.remove('genre');
    selectedGenres = null;
    notifyListeners();
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
    selectedGenres = null;
    isFilterApplied = false;
    showHistory = true;
    initStudio = 0;
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
    List<String>? g;

    if (selectedGenres != null) {
      List<String> t = List<String>.generate(
        selectedGenres!.length,
        (index) {
          final list = selectedGenres!.toList();
          final id = list[index].id;
          return id.toString();
        },
      );
      g = t;
    }

    // TODO что это
    int? score;
    minimalScore = 0;
    if (minimalScore > 0) {
      score = minimalScore;
    }

    //final searchType = _ref.read(searchTypeProvider);

    log(searchType.name, name: 'searchType');

    try {
      // боже чел, что это
      List<ShikiTitle> titles = [];

      switch (_searchType) {
        case SearchType.anime:
          final data = await animeRepository.getAnimes(
            page: pageKey,
            limit: _limit,
            order: selectedSortType,
            kind: selectedKind,
            status: selectedStatus,
            score: score,
            duration: selectedEpDuration,
            //rating: ,
            genre: g?.join(','),
            studio: initStudio != 0 ? '$initStudio' : null,
            mylist: selectedMyList,
            censored: 'true',
            search: textEditingController.text != ''
                ? textEditingController.text
                : null,
            userToken: SecureStorageService.instance.token,
            cancelToken: cancelToken,
          );
          for (var e in data) {
            final t = e.toShikiTitle;
            titles.add(t);
          }
          break;
        case SearchType.manga:
          final data = await mangaRepository.getMangas(
            page: pageKey,
            limit: _limit,
            order: selectedSortType,
            //kind: selectedKind,
            status: selectedStatus,
            mylist: selectedMyList,
            censored: 'true',
            search: textEditingController.text != ''
                ? textEditingController.text
                : null,
            userToken: SecureStorageService.instance.token,
            cancelToken: cancelToken,
          );
          for (var e in data) {
            final t = e.toShikiTitle;
            titles.add(t);
          }
          break;
        case SearchType.ranobe:
          final data = await ranobeRepository.getRanobe(
            page: pageKey,
            limit: _limit,
            order: selectedSortType,
            //kind: selectedKind,
            status: selectedStatus,
            mylist: selectedMyList,
            censored: 'true',
            search: textEditingController.text != ''
                ? textEditingController.text
                : null,
            userToken: SecureStorageService.instance.token,
            cancelToken: cancelToken,
          );
          for (var e in data) {
            final t = e.toShikiTitle;
            titles.add(t);
          }
          break;
        default:
      }

      // final data = await animeRepository.getAnimes(
      //   page: pageKey,
      //   limit: _limit,
      //   order: selectedSortType,
      //   kind: selectedKind,
      //   status: selectedStatus,
      //   score: score,
      //   duration: selectedEpDuration,
      //   //rating: ,
      //   genre: g?.join(','),
      //   studio: initStudio != 0 ? '$initStudio' : null,
      //   mylist: selectedMyList,
      //   censored: 'true',
      //   search: textEditingController.text != ''
      //       ? textEditingController.text
      //       : null,
      //   userToken: SecureStorageService.instance.token,
      //   cancelToken: cancelToken,
      // );

      //final titles = data.toList();

      final isLastPage = titles.length < _limit;
      if (isLastPage) {
        _pagingController.appendLastPage(titles);
      } else {
        _pagingController.appendPage(titles, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> onSearchSubmitted(String query) async {
    if (query.isEmpty) {
      return;
    }

    //final prefs = _ref.read(sharedPreferencesProvider);

    final prefs = _ref.read(preferencesProvider).sharedPreferences;

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

  void clearHistory() async {
    final prefs = _ref.read(preferencesProvider).sharedPreferences;

    await prefs.remove(animeSearchHistoryKey);
    searchHistory = [];
    notifyListeners();
  }
}

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
  AnimeFilter('latest', 'Недавно вышедшее'),
];

List<AnimeFilter> animeKindList = [
  AnimeFilter('tv', 'Сериал'),
  AnimeFilter('movie', 'Фильм'),
  AnimeFilter('ova', 'OVA'),
  AnimeFilter('ona', 'ONA'),
  AnimeFilter('special', 'Спешл'),
  AnimeFilter('music', 'Клип'),
];

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
