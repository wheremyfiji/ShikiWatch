import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:shikidev/src/utils/extensions/buildcontext.dart';
import 'package:shikidev/src/utils/extensions/string_ext.dart';

import '../../../domain/models/manga_ranobe.dart';
import '../../../domain/models/manga_short.dart';
import '../../../constants/config.dart';
import '../../../utils/shiki_utils.dart';
import '../../providers/manga_details_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/header_appbar_title.dart';
import '../../widgets/image_with_shimmer.dart';
import '../../widgets/manga_card.dart';
import '../../widgets/title_description.dart';
import '../anime_details/related_titles.dart';
import '../comments/comments_page.dart';

import 'widgets/manga_chips.dart';
import 'widgets/manga_detail_fab.dart';
import 'widgets/manga_info_header.dart';
import 'widgets/manga_rates_statuses.dart';

const double dividerHeight = 16;

class MangaDetailPage extends ConsumerWidget {
  final MangaShort manga;

  const MangaDetailPage({super.key, required this.manga});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaDetails = ref.watch(mangaDetailsPageProvider(manga.id!));

    return Scaffold(
      //extendBodyBehindAppBar: true,
      floatingActionButton: mangaDetails.title.when(
        data: (data) => MangaDetailFAB(data: data, manga: manga),
        error: (error, stackTrace) => null,
        loading: () => null,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(mangaDetailsPageProvider(manga.id!)),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverAppBar(
              stretch: true,
              pinned: true,
              floating: false,
              expandedHeight: 300,
              title: HeaderAppBarTitle(
                text: manga.russian ?? manga.name ?? '[Без навзвания]',
              ),
              actions: [
                PopupMenuButton(
                  tooltip: '',
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("Открыть в браузере"),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text("Поделиться"),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 0) {
                      launchUrlString(
                        AppConfig.staticUrl + (manga.url ?? ''),
                        mode: LaunchMode.externalApplication,
                      );
                    } else if (value == 1) {
                      Share.share(AppConfig.staticUrl + (manga.url ?? ''));
                    }
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: MangaInfoHeader(
                  data: manga,
                ),
              ),
            ),
            ...mangaDetails.title.when(
              data: (data) => [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: MangaActionsWidget(
                      manga: manga,
                      data: data,
                    ),
                  ),
                ),
                // if (data.userRate != null) ...[
                //   SliverPadding(
                //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                //     sliver: SliverToBoxAdapter(
                //       child: UserRateWidget(
                //         manga: manga,
                //         data: data,
                //       ),
                //     ),
                //   ),
                // ],
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: MangaChipsWidget(
                      genres: data.genres,
                      publishers: data.publishers,
                      score: manga.score,
                    ),
                  ),
                ),
                if (data.description != null) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: TitleDescription(data.descriptionHtml!),
                    ),
                  ),
                ],
                if (mangaDetails.statsValues != []) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: MangaRatesStatusesWidget(
                        statsValues: mangaDetails.statsValues,
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: RelatedWidget(
                    id: data.id!,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 70)),
              ],
              loading: () => [
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 130),
                          child: const CircularProgressIndicator()),
                    ),
                  ),
                )
              ],
              error: (err, stack) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(err.toString(),
                      () => ref.refresh(mangaDetailsPageProvider(manga.id!))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MangaActionsWidget extends StatelessWidget {
  final MangaShort manga;
  final MangaRanobe data;

  const MangaActionsWidget({
    super.key,
    required this.manga,
    required this.data,
  });

  String getRateStatus(String value) {
    String status;

    const map = {
      'planned': 'В планах',
      'watching': 'Читаю',
      'rewatching': 'Перечитываю',
      'completed': 'Прочитано',
      'on_hold': 'Отложено',
      'dropped': 'Брошено'
    };

    status = map[value] ?? '';

    return status;
  }

  @override
  Widget build(BuildContext context) {
    final int? topicId = data.topicId;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        SimilarMangaPage(mangaId: manga.id!),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.join_inner),
                    SizedBox(
                      height: 4,
                    ),
                    Text('Похожее'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: (topicId == null || topicId == 0)
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                CommentsPage(
                              topicId: topicId,
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                child: const Column(
                  children: [
                    Icon(Icons.topic), //chat
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Обсуждение',
                      // style: TextStyle(
                      //   color: context.textTheme.bodyMedium?.color,
                      // ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  _openFullscreenDialog(context);
                },
                child: const Column(
                  children: [
                    Icon(Icons.link),
                    SizedBox(
                      height: 4,
                    ),
                    Text('Ссылки'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreenDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      useRootNavigator: false,
      useSafeArea: false,
      builder: (context) => Dialog.fullscreen(
        child: MangaExternalLinksWidget(
          mangaId: manga.id!,
        ),
      ),
    );
  }
}

class MangaExternalLinksWidget extends ConsumerWidget {
  final int mangaId;

  const MangaExternalLinksWidget({super.key, required this.mangaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(externalLinksMangaProvider(mangaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ссылки'),
        centerTitle: false,
        // automaticallyImplyLeading: false,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.close),
        //     onPressed: () => Navigator.of(context).pop(),
        //   ),
        // ],
      ),
      body: links.when(
        data: (data) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final link = data.toList()[index];
                  final enable = link.url != null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(0),
                      child: ListTile(
                        enabled: enable,
                        title: Text(
                          link.kind?.replaceAll('_', ' ').capitalizeFirst ?? '',
                        ),
                        //subtitle: Text('${link.updatedAt}'),
                        trailing: const Icon(
                          Icons.open_in_browser,
                        ),
                        onTap: () {
                          launchUrlString(
                            link.url!,
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        error: (err, stack) => CustomErrorWidget(err.toString(),
            () => ref.refresh(externalLinksMangaProvider(mangaId))),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class SimilarMangaPage extends ConsumerWidget {
  final int mangaId;

  const SimilarMangaPage({super.key, required this.mangaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarManga = ref.watch(similarTitlesMangaProvider(mangaId));

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              forceElevated: innerBoxIsScrolled,
              stretch: true,
              title: const Text(
                'Похожее',
              ),
            ),
          ];
        },
        body: similarManga.when(
          data: (data) {
            if (data.isEmpty) {
              return Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Σ(ಠ_ಠ)',
                          textAlign: TextAlign.center,
                          style: context.textTheme.displayMedium,
                        ),
                        Text(
                          'Похоже тут пусто..',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: const Text(
                            'Назад',
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
            return CustomScrollView(
              shrinkWrap: false,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final manga = data.toList()[index];

                        return MangaCardEx(manga);
                      },
                      childCount: data.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 140,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                  ),
                ),
              ],
            );
          },
          error: (err, stack) => CustomErrorWidget(err.toString(),
              () => ref.refresh(similarTitlesMangaProvider(mangaId))),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class RelatedWidget extends ConsumerWidget {
  final int id;

  const RelatedWidget({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final related = ref.watch(relatedTitlesMangaProvider(id));

    return related.when(
      data: (data) {
        if (data.isEmpty) {
          return const SizedBox.shrink();
        }

        final dataList = data.toList();
        final hasMore = dataList.length > 3;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Связанное',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    '(${dataList.length})',
                    style: context.textTheme.bodySmall,
                  ),
                  if (hasMore) ...[
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                RelatedTitles(related: dataList),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Text(
                        'Ещё',
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              ListView.builder(
                padding: const EdgeInsets.all(0),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hasMore ? 3 : dataList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final info = dataList[index];
                  // ignore: prefer_typing_uninitialized_variables
                  var title;
                  if (info.anime != null) {
                    title = info.anime!;
                  } else {
                    title = info.manga!;
                  }
                  final relation = info.relationRussian ?? info.relation ?? '';
                  final kind = getKind(title.kind ?? '');
                  final isManga = kindIsManga(title!.kind ?? '');

                  final airedOn =
                      DateTime.tryParse(title!.airedOn ?? '') ?? DateTime(1970);
                  final year = airedOn.year;

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          if (isManga) {
                            context.pushNamed(
                              'library_manga',
                              pathParameters: <String, String>{
                                'id': (title!.id!).toString(),
                              },
                              extra: title,
                            );
                          } else {
                            context.pushNamed(
                              'library_anime',
                              pathParameters: <String, String>{
                                'id': (title!.id!).toString(),
                              },
                              extra: title,
                            );
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 60,
                              child: AspectRatio(
                                aspectRatio: 0.703,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ImageWithShimmerWidget(
                                    imageUrl: AppConfig.staticUrl +
                                        (title?.image?.original ?? ''),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    (title?.russian == ''
                                            ? title?.name
                                            : title?.russian) ??
                                        '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    '$relation • $kind • $year год',
                                    style: context.textTheme.bodySmall,
                                  ),
                                  //Text('$isManga'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        return const SizedBox.shrink();
      },
      loading: () {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Связанное',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 100.0,
                  child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.surface,
                    highlightColor:
                        Theme.of(context).colorScheme.onInverseSurface,
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
