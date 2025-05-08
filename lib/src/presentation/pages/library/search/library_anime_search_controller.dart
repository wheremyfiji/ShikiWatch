import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';

import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../../services/http/http_service_provider.dart';
import '../../../../domain/enums/shiki_gql.dart';
import '../../../../utils/debouncer.dart';

final libraryAnimeSearchProvider = ChangeNotifierProvider.autoDispose((ref) {
  final c = LibraryAnimeSearchNotifier(ref);
  //c.initState();
  ref.onDispose(c.disposeState);
  return c;
}, name: 'libraryAnimeSearchProvider');

class LibraryAnimeSearchNotifier extends ChangeNotifier {
  final Ref ref;
  final Debouncer debouncer;
  final CancelToken cancelToken;
  AsyncValue<List<GraphqlSearch>> result;

  late TextEditingController fieldController;

  LibraryAnimeSearchNotifier(this.ref)
      : fieldController = TextEditingController(),
        cancelToken = CancelToken(),
        result = const AsyncValue.data([]),
        debouncer = Debouncer(delay: const Duration(milliseconds: 800));

  bool _disposed = false;
  LibrarySearchType _searchType = LibrarySearchType.all;

  LibrarySearchType get searchType => _searchType;

  void disposeState() {
    _disposed = true;
    cancelToken.cancel();
    debouncer.dispose();
    fieldController.dispose();
  }

  void setSearchType(LibrarySearchType s) {
    if (result.isLoading) {
      return;
    }

    _searchType = s;

    if (fieldController.value.text.isNotEmpty) {
      fetch(fieldController.value.text);
      return;
    }

    notifyListeners();
  }

  void onSearchChanged(String query) {
    if (query.isNotEmpty && query.length < 2) {
      return;
    }

    if (query.isEmpty) {
      result = const AsyncValue.data([]);
      notifyListeners();
      return;
    }

    if (_disposed) {
      return;
    }

    debouncer.run(() {
      fetch(query);
    });
  }

  void clearQuery() {
    fieldController.clear();

    result = const AsyncValue.data([]);

    notifyListeners();
  }

  Future<void> fetch(String query) async {
    result = const AsyncValue.loading();

    if (!_disposed) {
      notifyListeners();
    }

    result = await AsyncValue.guard(() async {
      final resp = await ref.read(httpServiceProvider).post(
            'https://shikimori.one/api/graphql',
            data: json.encode({
              'query': _searchQuery,
              'variables': {
                'search': query,
                'list': _searchType.value,
              },
            }),
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization':
                    'Bearer ${SecureStorageService.instance.token}',
              },
            ),
            cancelToken: cancelToken,
          );

      final list = resp['data']['animes'];

      return [for (final e in list) GraphqlSearch.fromJson(e)].toList();
    });

    if (!_disposed) {
      notifyListeners();
    }
  }
}

const _searchQuery = r'''
query($search: String, $list: MylistString) {
  animes(search: $search, limit: 25, page: 1, mylist: $list) {
    id
    name
    russian
    
    poster {
      mainAltUrl
    }

    userRate {
      status
      episodes
    }
  }
}
''';

enum LibrarySearchType {
  all('planned,watching,rewatching,completed,on_hold,dropped'),
  planned('planned'),
  watching('watching'),
  rewatching('rewatching'),
  completed('completed'),
  onHold('on_hold'),
  dropped('dropped');

  final String value;

  const LibrarySearchType(this.value);

  static LibrarySearchType fromValue(String value) =>
      LibrarySearchType.values.singleWhere((e) => value == e.value);

  String get rusName {
    return switch (this) {
      LibrarySearchType.all => 'Все',
      LibrarySearchType.planned => 'В планах',
      LibrarySearchType.watching => 'Смотрю',
      LibrarySearchType.rewatching => 'Пересматриваю',
      LibrarySearchType.completed => 'Просмотрено',
      LibrarySearchType.onHold => 'Отложено',
      LibrarySearchType.dropped => 'Брошено',
    };
  }
}

class GraphqlSearch {
  final int id;
  final String? name;
  final String? russian;
  final int? episodes;
  final int? episodesAired;
  final Poster? poster;
  final GraphqlUserRate userRate;

  GraphqlSearch({
    required this.id,
    this.name,
    this.russian,
    this.episodes,
    this.episodesAired,
    this.poster,
    required this.userRate,
  });

  factory GraphqlSearch.fromJson(Map<String, dynamic> json) => GraphqlSearch(
        id: int.parse(json["id"]),
        name: json["name"],
        russian: json["russian"],
        episodes: json["episodes"],
        episodesAired: json["episodesAired"],
        poster: json["poster"] == null ? null : Poster.fromJson(json["poster"]),
        userRate: GraphqlUserRate.fromJson(json['userRate']),
      );
}

class Poster {
  final String? mainAltUrl;

  Poster({
    this.mainAltUrl,
  });

  factory Poster.fromJson(Map<String, dynamic> json) => Poster(
        mainAltUrl: json["mainAltUrl"],
      );
}

class GraphqlUserRate {
  final RateStatus status;
  final int? score;
  final int? episodes;

  GraphqlUserRate({
    required this.status,
    this.score,
    this.episodes,
  });

  factory GraphqlUserRate.fromJson(Map<String, dynamic> json) =>
      GraphqlUserRate(
        status: RateStatus.fromValue(json["status"]),
        score: json["score"],
        episodes: json["episodes"],
      );
}
