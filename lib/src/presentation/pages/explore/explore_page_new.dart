import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../services/http/http_service_provider.dart';
import '../../../domain/enums/explore_ongoing_now.dart';
import '../../../domain/models/graphql_user_rate.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../domain/models/pages_extra.dart';
import '../../../domain/enums/shiki_gql.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';

import 'widgets/explore_actions.dart';

enum UserRateStatusIndicatorType { text, dot }

class ExplorePageNew extends ConsumerStatefulWidget {
  const ExplorePageNew({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExplorePageNewState();
}

class _ExplorePageNewState extends ConsumerState<ExplorePageNew> {
  late double _screenWidth;
  static const _pageSize = 15;
  static const _widthBreakpoint = 600.0;

  final PagingController<int, AnimeExpGql> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _screenWidth = MediaQuery.sizeOf(context).width;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsProvider.select((settings) => settings.explorePageSort),
        (previous, next) {
      _pagingController.refresh();
    });

    final layout = ref.watch(settingsProvider.select(
      (settings) => settings.explorePageLayout,
    ));

    final grid = SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: PagedSliverGrid<int, AnimeExpGql>(
        key: const PageStorageKey<String>('ExplorePageNewPagedSliverCard'),
        addSemanticIndexes: false,
        addRepaintBoundaries: false,
        showNewPageErrorIndicatorAsGridChild: false,
        pagingController: _pagingController,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140, //150
          childAspectRatio: 0.55,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        builderDelegate: PagedChildBuilderDelegate<AnimeExpGql>(
          firstPageErrorIndicatorBuilder: (context) {
            return CustomErrorWidget(
              _pagingController.error.toString(),
              () => _pagingController.refresh(),
            );
          },
          newPageErrorIndicatorBuilder: (context) {
            return CustomErrorWidget(
              _pagingController.error.toString(),
              () => _pagingController.retryLastFailedRequest(),
            );
          },
          itemBuilder: (context, item, index) {
            return AnimeExpCardItem(item);
          },
        ),
      ),
    );

    final list = SliverPadding(
      padding: const EdgeInsets.only(bottom: 16.0),
      sliver: PagedSliverList.separated(
        key: const PageStorageKey<String>('ExplorePageNewPagedSliverList'),
        addSemanticIndexes: false,
        addRepaintBoundaries: false,
        pagingController: _pagingController,
        separatorBuilder: (context, index) => const SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                SizedBox(width: 100),
                Expanded(child: Divider()),
              ],
            ),
          ),
        ),
        builderDelegate: PagedChildBuilderDelegate<AnimeExpGql>(
          firstPageErrorIndicatorBuilder: (context) {
            return CustomErrorWidget(
              _pagingController.error.toString(),
              () => _pagingController.refresh(),
            );
          },
          newPageErrorIndicatorBuilder: (context) {
            return CustomErrorWidget(
              _pagingController.error.toString(),
              () => _pagingController.retryLastFailedRequest(),
            );
          },
          itemBuilder: (context, item, _) {
            return SafeArea(
              top: false,
              bottom: false,
              child: AnimeExpListItem(item),
            );
          },
        ),
      ),
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            clipBehavior: Clip.none,
            key: const PageStorageKey<String>('ExplorePageNew'),
            slivers: [
              SliverAppBar.large(
                automaticallyImplyLeading: false,
                pinned: true,
                title: const Text('ShikiWatch'),
                actions: [
                  IconButton(
                    onPressed: () => context.push('/explore/search'),
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: ExploreActions(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: () =>
                        EditOngoingNowBottomSheet.show(context: context),
                    child: Text(
                      'Сейчас выходит',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              switch (layout) {
                ExplorePageLayout.grid => grid,
                ExplorePageLayout.list => list,
                _ => _screenWidth >= _widthBreakpoint ? grid : list,
              },
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: context.padding.bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final Map<String, dynamic> resp =
          await ref.read(httpServiceProvider).post(
                'https://shikimori.one/api/graphql',
                data: json.encode(
                  {
                    'query': _query,
                    'variables': {
                      'page': pageKey,
                      'order': ref.read(settingsProvider).explorePageSort.value,
                    },
                  },
                ),
                options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization':
                        'Bearer ${SecureStorageService.instance.token}',
                  },
                ),
              );

      if (resp.containsKey('errors')) {
        final error = (resp['errors'] as List<dynamic>).first['message'];

        throw error;
      }

      if (resp['data']?['animes'] is! List<dynamic>) {
        throw 'broken response';
      }

      final list = resp['data']['animes'] as List<dynamic>;

      final newItems = [for (final e in list) AnimeExpGql.fromJson(e)].toList();

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }
}

class EditOngoingNowBottomSheet extends StatelessWidget {
  const EditOngoingNowBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Размещение и сортировка',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Consumer(builder: (context, ref, _) {
            final layout = ref.watch(settingsProvider
                .select((settings) => settings.explorePageLayout));

            return SegmentedButton<ExplorePageLayout>(
              segments: ExplorePageLayout.values
                  .map((e) => ButtonSegment<ExplorePageLayout>(
                        value: e,
                        label: Text(e.label),
                        icon: Icon(e.icon),
                      ))
                  .toList(),
              selected: {layout},
              onSelectionChanged: (v) => ref
                  .read(settingsProvider.notifier)
                  .setExplorePageLayout(v.first),
            );
          }),
          Consumer(
            builder: (context, ref, _) {
              final sort = ref.watch(settingsProvider
                  .select((settings) => settings.explorePageSort));

              return Card(
                clipBehavior: Clip.hardEdge,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    ...ExplorePageSort.values.map(
                      (e) => RadioListTile(
                        value: e,
                        groupValue: sort,
                        title: Text(
                          e.label,
                          style: TextStyle(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        onChanged: (v) => ref
                            .read(settingsProvider.notifier)
                            .setExplorePageSort(v ?? sort)
                            .then((_) => context.pop()),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static void show({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      useRootNavigator: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
      ),
      builder: (_) => const SafeArea(child: EditOngoingNowBottomSheet()),
    );
  }
}

class AnimeExpCardItem extends StatelessWidget {
  const AnimeExpCardItem(this.anime, {super.key});

  final AnimeExpGql anime;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          onTap: () {
            final extra = TitleDetailsPageExtra(
              id: anime.id,
              label: anime.russian ?? anime.name,
            );

            context.push('/explore/${anime.id}', extra: extra);
          },
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight / 1.4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CachedImage(
                        anime.poster,
                      ),
                    ),
                  ),
                  if (anime.userRate != null)
                    UserRateStatusIndicator(anime.userRate!.status),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.russian ?? anime.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Row(
                      children: [
                        Text(
                          '${anime.kind.rusName} • ${anime.score}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class AnimeExpListItem extends StatelessWidget {
  const AnimeExpListItem(this.anime, {super.key});

  final AnimeExpGql anime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final extra = TitleDetailsPageExtra(
              id: anime.id,
              label: anime.russian ?? anime.name,
            );

            context.push('/explore/${anime.id}', extra: extra);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Stack(
                  alignment: AlignmentDirectional.topStart,
                  // alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    AspectRatio(
                      aspectRatio: 0.703,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: CachedImage(
                          anime.poster,
                        ),
                      ),
                    ),
                    if (anime.userRate != null)
                      UserRateStatusIndicator(anime.userRate!.status),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime.russian ?? anime.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (anime.studios.isNotEmpty) ...[
                        Text(
                          anime.studios.join(' • '),
                          style: context.textTheme.labelSmall?.copyWith(
                            // fontSize: 10,
                            color: context.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${anime.kind.rusName} • ${anime.episodesAired} / ${anime.episodes == 0 ? '?' : anime.episodes} эп.',
                              style: context.textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            ' • ${anime.score}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Icon(
                              Icons.star_rounded,
                              size: 10,
                            ),
                          ),
                        ],
                      ),
                      if (anime.genres.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: List.generate(
                            anime.genres.length,
                            (index) => SmallChip(anime.genres[index]),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (anime.nextEpisodeAt != null) ...[
                        Row(
                          children: [
                            Text(
                              'след. эп.: ',
                              style: context.textTheme.bodySmall,
                            ),
                            Flexible(
                              child: Text(
                                DateFormat.MMMMEEEEd()
                                    .format(anime.nextEpisodeAt!),
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserRateStatusIndicator extends StatelessWidget {
  const UserRateStatusIndicator(
    this.status, {
    super.key,
    this.type = UserRateStatusIndicatorType.text,
  });

  final RateStatus status;
  final UserRateStatusIndicatorType type;

  @override
  Widget build(BuildContext context) {
    final text = Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            spreadRadius: 4,
            blurRadius: 8,
            // blurStyle: BlurStyle.solid,
            offset: Offset(4, 4),
          ),
        ],
        color: status.color(context.colorScheme),
        borderRadius: BorderRadius.circular(52),
      ),
      child: Text(
        status.rusName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );

    final dot = Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            spreadRadius: 6,
            blurRadius: 12,
            blurStyle: BlurStyle.normal,
            // offset: Offset(2, 4),
          ),
        ],
        shape: BoxShape.circle,
        color: status.color(context.colorScheme),
      ),
    );

    return switch (type) {
      UserRateStatusIndicatorType.text => text,
      UserRateStatusIndicatorType.dot => dot,
    };
  }
}

class SmallChip extends StatelessWidget {
  const SmallChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSecondaryContainer,
          fontSize: 12.0,
        ),
      ),
    );
  }
}

class AnimeExpGql {
  final int id;
  final String name;
  final String? russian;
  final double score;

  final String poster;

  final TitleKind kind;

  final int episodes;
  final int episodesAired;
  final DateTime? nextEpisodeAt;

  final List<String> studios;
  final List<String> genres;

  final GraphqlUserRate? userRate;

  const AnimeExpGql({
    required this.id,
    required this.name,
    required this.russian,
    required this.score,
    required this.poster,
    required this.kind,
    required this.episodes,
    required this.episodesAired,
    required this.nextEpisodeAt,
    required this.studios,
    required this.genres,
    required this.userRate,
  });

  factory AnimeExpGql.fromJson(Map<String, dynamic> json) => AnimeExpGql(
        id: int.parse(json["id"]),
        name: json["name"],
        russian: json['russian'],
        score: json["score"] ?? 0.0,
        poster: json["poster"]['mainUrl'],
        kind: TitleKind.fromValue(json["kind"] ?? 'unknown'),
        episodes: json["episodes"] ?? 0,
        episodesAired: json["episodesAired"] ?? 0,
        nextEpisodeAt: json["nextEpisodeAt"] == null
            ? null
            : DateTime.tryParse(json["nextEpisodeAt"]),
        studios: json["studios"] == null
            ? []
            : List<String>.from(json["studios"].map((x) => x['name'])),
        genres: json["genres"] == null
            ? []
            : List<String>.from(json["genres"].map((x) => x['russian'])),
        userRate: json["userRate"] == null
            ? null
            : GraphqlUserRate.fromJson(json["userRate"]),
      );
}

// ranked popularity aired_on
const _query = r'''
query($page: PositiveInt, $order: OrderEnum) {
  animes(limit: 30, page: $page, status: "ongoing", order: $order, score: 1) {
    id
    name
    russian
    kind
    episodes
    episodesAired
    nextEpisodeAt
    score
    studios {
      name
    }
    genres {
      russian
    }
    poster {
      mainUrl
    }
    userRate {
      id
      status
      episodes
      score
    }
  }
}
''';
