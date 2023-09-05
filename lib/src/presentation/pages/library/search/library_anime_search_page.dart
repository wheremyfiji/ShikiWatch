import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/models/pages_extra.dart';
import '../../../../services/http/http_service_provider.dart';
import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../../../utils/debouncer.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/custom_info_chip.dart';
import '../../../widgets/image_with_shimmer.dart';

class LibraryAnimeSearchPage extends ConsumerWidget {
  const LibraryAnimeSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(libraryAnimeSearchProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              pinned: true,
              title: TextField(
                autofocus: true,
                controller: provider.fieldController,
                onChanged: provider.onSearchChanged,
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  //contentPadding: EdgeInsets.zero,
                  hintText: 'Поиск аниме',
                  suffixIcon: provider.fieldController.text.isNotEmpty
                      ? GestureDetector(
                          child: const Icon(Icons.close),
                          onTap: () => provider.clearQuery(),
                        )
                      : null,
                ),
              ),
              bottom: AppBar(
                automaticallyImplyLeading: false,
                primary: false,
                titleSpacing: 0,
                title: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: [
                      const SizedBox(
                        width: 8.0,
                      ),
                      ChoiceChip(
                        label: const Text('Все'),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        selected: provider.searchType == LibrarySearchType.all,
                        onSelected: (_) => ref
                            .read(libraryAnimeSearchProvider)
                            .setSearchType(LibrarySearchType.all),
                      ),
                      ChoiceChip(
                        label: const Text('Смотрю'),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        selected:
                            provider.searchType == LibrarySearchType.watching,
                        onSelected: (_) => ref
                            .read(libraryAnimeSearchProvider)
                            .setSearchType(LibrarySearchType.watching),
                      ),
                      ChoiceChip(
                        label: const Text('В планах'),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        selected:
                            provider.searchType == LibrarySearchType.planned,
                        onSelected: (_) => ref
                            .read(libraryAnimeSearchProvider)
                            .setSearchType(LibrarySearchType.planned),
                      ),
                      ChoiceChip(
                        label: const Text('Просмотрено'),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        selected:
                            provider.searchType == LibrarySearchType.completed,
                        onSelected: (_) => ref
                            .read(libraryAnimeSearchProvider)
                            .setSearchType(LibrarySearchType.completed),
                      ),
                      ChoiceChip(
                        label: const Text('Пересматриваю'),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        selected:
                            provider.searchType == LibrarySearchType.rewatching,
                        onSelected: (_) => ref
                            .read(libraryAnimeSearchProvider)
                            .setSearchType(LibrarySearchType.rewatching),
                      ),
                      ChoiceChip(
                        label: const Text('Отложено'),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        selected:
                            provider.searchType == LibrarySearchType.onHold,
                        onSelected: (_) => ref
                            .read(libraryAnimeSearchProvider)
                            .setSearchType(LibrarySearchType.onHold),
                      ),
                      ChoiceChip(
                        label: const Text('Брошено'),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        selected:
                            provider.searchType == LibrarySearchType.dropped,
                        onSelected: (_) => ref
                            .read(libraryAnimeSearchProvider)
                            .setSearchType(LibrarySearchType.dropped),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Divider(
                height: 1,
              ),
            ),
            ...provider.result.when(
              data: (data) {
                if (data.isEmpty &&
                    provider.fieldController.value.text.isNotEmpty) {
                  return [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),
                    const SliverToBoxAdapter(
                      child: _NothingFound(),
                    ),
                  ];
                }

                return [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  SliverList.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      final lastElement = index == (data.length - 1);

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          lastElement ? 16 : 8,
                        ),
                        child: _SearchAnimeItem(item),
                      );
                    },
                  ),
                ];
              },
              error: (e, _) => [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                SliverToBoxAdapter(
                  child: _SearchError(
                    e.toString(),
                    onRetry: () {
                      provider.fetch(provider.fieldController.value.text);
                    },
                  ),
                ),
              ],
              loading: () => [
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAnimeItem extends StatelessWidget {
  final GraphqlSearch anime;

  const _SearchAnimeItem(this.anime);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();

          final extra = AnimeDetailsPageExtra(
            id: anime.id,
            label: (anime.russian == '' ? anime.name : anime.russian) ?? '',
          );

          context.pushNamed(
            'library_anime',
            pathParameters: <String, String>{
              'id': (anime.id).toString(),
            },
            extra: extra,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: AspectRatio(
                aspectRatio: 0.703,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: ImageWithShimmerWidget(
                    imageUrl: anime.poster?.mainAltUrl ?? '',
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (anime.russian == '' ? anime.name : anime.russian) ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 8,
                      children: [
                        _RateStatusChip(anime.userRate.status),
                        if (anime.userRate.status != RateStatus.planned &&
                            anime.userRate.status != RateStatus.completed)
                          CustomInfoChip(
                            title: 'Эпизоды: ${anime.userRate.episodes}',
                          ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
                  //   child: _RateStatusChip(anime.userRate.status),
                  // ),
                  // if (anime.userRate.status != RateStatus.completed)
                  //   Text(
                  //     'Эпизоды: ${anime.userRate.episodes}',
                  //     style: TextStyle(
                  //       fontSize: 12,
                  //       color: Theme.of(context).textTheme.bodySmall!.color,
                  //     ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateStatusChip extends StatelessWidget {
  final RateStatus status;

  const _RateStatusChip(this.status);

  Color getColor({required RateStatus status, required bool dark}) {
    return switch (status) {
      RateStatus.planned =>
        dark ? Colors.deepPurple.shade400 : Colors.deepPurple.shade300,
      RateStatus.watching =>
        dark ? Colors.yellow.shade400 : Colors.yellow.shade300,
      RateStatus.rewatching =>
        dark ? Colors.lime.shade400 : Colors.lime.shade300,
      RateStatus.completed =>
        dark ? Colors.green.shade400 : Colors.green.shade300,
      RateStatus.onHold =>
        dark ? Colors.lightBlue.shade400 : Colors.lightBlue.shade300,
      RateStatus.dropped => dark ? Colors.red.shade400 : Colors.red.shade300,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor(status: status, dark: context.isDarkThemed);

    return Card(
      margin: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: color.withOpacity(0.5),
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: Text(
          status.rusName,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const _SearchError(
    this.error, {
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '(´･ω･`)?',
            textAlign: TextAlign.center,
            style: context.textTheme.displaySmall,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
            child: Text(
              'Ой, ошибка..',
              style: context.textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              error,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onBackground.withOpacity(
                  0.8,
                ),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

class _NothingFound extends StatelessWidget {
  const _NothingFound();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '(˘･_･˘)',
            textAlign: TextAlign.center,
            style: context.textTheme.displaySmall,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
            child: Text(
              'Ничего не найдено',
              style: context.textTheme.titleLarge,
            ),
          ),
          Text(
            'Измени список или воспользуйся глобальным поиском',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onBackground.withOpacity(
                0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// TODO
/// че это тут забыло
/// надо убрать все отсюда
/// |
/// V

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
}

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
            'https://shikimori.me/api/graphql',
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

enum RateStatus {
  planned('planned'),
  watching('watching'),
  rewatching('rewatching'),
  completed('completed'),
  onHold('on_hold'),
  dropped('dropped');

  final String value;

  const RateStatus(this.value);

  static RateStatus fromValue(String value) =>
      RateStatus.values.singleWhere((e) => value == e.value);

  String get rusName {
    return switch (this) {
      RateStatus.planned => 'В планах',
      RateStatus.watching => 'Смотрю',
      RateStatus.rewatching => 'Пересматриваю',
      RateStatus.completed => 'Просмотрено',
      RateStatus.onHold => 'Отложено',
      RateStatus.dropped => 'Брошено',
    };
  }
}
