import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../constants/config.dart';
import '../../../domain/models/animes.dart';
import '../../../services/shared_pref/shared_preferences_provider.dart';
import '../../../utils/shiki_utils.dart';
import '../../providers/anime_details_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/header_appbar_title.dart';

import '../../widgets/image_with_shimmer.dart';
import 'rating_dialog.dart';
import 'related_titles.dart';
import 'studio_select_page.dart';
import 'widgets/anime_actions.dart';
import 'widgets/anime_chips_widger.dart';
import 'widgets/anime_videos_widget.dart';
import 'widgets/details_screenshots.dart';
import 'widgets/info_header.dart';
import 'widgets/rates_statuses_widget.dart';
import '../../widgets/title_description.dart';
import 'widgets/user_anime_rate.dart';

const double dividerHeight = 16;

class AnimeDetailsPage extends ConsumerWidget {
  final Animes animeData;

  const AnimeDetailsPage({
    super.key,
    required this.animeData,
  });

  void pushStudioSelectPage({
    required BuildContext ctx,
    required int id,
    required String name,
    required int ep,
    required String imgUrl,
  }) {
    Navigator.push(
      ctx,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => StudioSelectPage(
          //animeId: titleInfo.id,
          shikimoriId: id,
          animeName: name,
          epWatched: ep,
          imageUrl: imgUrl,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleInfo = ref.watch(titleInfoPageProvider(animeData.id!));

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton:
          // titleInfo.isAnons
          //     ? const SizedBox.shrink()
          //     :
          titleInfo.title.isLoading || animeData.kind == 'music'
              ? null
              : FloatingActionButton.extended(
                  onPressed: () async {
                    if (titleInfo.rating == '18+') {
                      final allowExp = ref
                              .read(sharedPreferencesProvider)
                              .getBool('allowExpContent') ??
                          false;

                      if (!allowExp) {
                        bool? dialogValue = await showDialog<bool>(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => const RatingDialog(),
                        );

                        if (dialogValue ?? false) {
                          await ref
                              .read(sharedPreferencesProvider)
                              .setBool('allowExpContent', true);
                          // ignore: use_build_context_synchronously
                          pushStudioSelectPage(
                            ctx: context,
                            id: animeData.id ?? 0,
                            name: animeData.russian ??
                                animeData.name ??
                                '[Без навзвания]',
                            ep: titleInfo.currentProgress,
                            imgUrl: animeData.image?.original ?? '',
                          );
                        }
                      } else {
                        pushStudioSelectPage(
                          ctx: context,
                          id: animeData.id ?? 0,
                          name: animeData.russian ??
                              animeData.name ??
                              '[Без навзвания]',
                          ep: titleInfo.currentProgress,
                          imgUrl: animeData.image?.original ?? '',
                        );
                      }
                    } else {
                      pushStudioSelectPage(
                        ctx: context,
                        id: animeData.id ?? 0,
                        name: animeData.russian ??
                            animeData.name ??
                            '[Без навзвания]',
                        ep: titleInfo.currentProgress,
                        imgUrl: animeData.image?.original ?? '',
                      );
                    }
                  },
                  label: const Text('Смотреть'),
                  icon: const Icon(Icons.play_arrow),
                ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.refresh(titleInfoPageProvider(animeData.id!)),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverAppBar(
              stretch: true,
              pinned: true,
              floating: false,
              expandedHeight: 300,
              title: HeaderAppBarTitle(
                text: animeData.russian ?? animeData.name ?? '[Без навзвания]',
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
                        '${AppConfig.staticUrl}/animes/${animeData.id}',
                        mode: LaunchMode.externalApplication,
                      );
                    } else if (value == 1) {
                      Share.share(AppConfig.staticUrl + (animeData.url ?? ''));
                    }
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: AnimeInfoHeader(
                  data: animeData,
                  duration: titleInfo.duration,
                  favoured: titleInfo.isFavor,
                  nextEp: titleInfo.nextEp ?? '',
                  rating: titleInfo.rating,
                ),
              ),
            ),
            ...titleInfo.title.when(
              data: (data) => [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                  sliver: SliverToBoxAdapter(
                    child: AnimeActionsWidget(
                      anime: data,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                  sliver: SliverToBoxAdapter(
                    child: UserAnimeRateWidget(
                      animeData,
                      data,
                      titleInfo.userImage,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                  sliver: SliverToBoxAdapter(
                    child: AnimeChipsWidget(
                      genres: data.genres,
                      studios: data.studios,
                      score: animeData.score,
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
                if (titleInfo.statsValues != []) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: AnimeRatesStatusesWidget(
                          statsValues: titleInfo.statsValues),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: RelatedWidget(
                    id: data.id!,
                  ),
                ),
                if (data.screenshots != null &&
                    data.screenshots!.isNotEmpty) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: AnimeScreenshots(data),
                    ),
                  ),
                ],
                if (data.videos != null && data.videos!.isNotEmpty) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: AnimeVideosMobileWidget(data),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 70)),
              ],
              error: (err, stack) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(err.toString(),
                      () => ref.refresh(titleInfoPageProvider(animeData.id!))),
                ),
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
            ),
          ],
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
    final related = ref.watch(relatedTitlesAnimeProvider(id));

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
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    // TextButton(
                    //   onPressed: () {},
                    //   child: const Text('Ещё'),
                    // ),
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
                              params: <String, String>{
                                'id': (title!.id!).toString(),
                              },
                              extra: title,
                            );
                          } else {
                            context.pushNamed(
                              'library_anime',
                              params: <String, String>{
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
                              //height: 100,
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
        //return const SizedBox.shrink();

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
                  //width: 200.0,
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
      //error: ((error, stackTrace) => Center(child: Text(error.toString()))),
      // loading: () => const Center(
      //   child: CircularProgressIndicator(),
      // ),
    );
  }
}
