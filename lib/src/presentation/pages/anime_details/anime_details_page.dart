import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../domain/models/pages_extra.dart';
import '../../../services/shared_pref/shared_preferences_provider.dart';
import '../../providers/anime_details_provider.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../constants/config.dart';
import '../../../utils/shiki_utils.dart';
import '../../widgets/error_widget.dart';

import '../../widgets/image_with_shimmer.dart';
import '../../widgets/title_description.dart';
import 'widgets/anime_actions.dart';
import 'widgets/anime_chips_widger.dart';
import 'widgets/anime_videos_widget.dart';
import 'widgets/details_screenshots.dart';
import 'widgets/info_header.dart';
import 'widgets/rates_statuses_widget.dart';
import 'widgets/user_anime_rate.dart';
import 'studio_select_page.dart';
import 'rating_dialog.dart';
import 'related_titles.dart';

const double dividerHeight = 16;

class AnimeDetailsPage extends ConsumerWidget {
  final AnimeDetailsPageExtra extra;

  const AnimeDetailsPage({
    super.key,
    required this.extra,
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
    final titleInfo = ref.watch(titleInfoPageProvider(extra.id));

    return Scaffold(
      floatingActionButton: titleInfo.title.when(
        data: (data) => data.kind == 'music'
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
                          id: data.id ?? 0,
                          name:
                              (data.russian == '' ? data.name : data.russian) ??
                                  '',
                          ep: titleInfo.currentProgress,
                          imgUrl: data.image?.original ?? '',
                        );
                      }
                    } else {
                      pushStudioSelectPage(
                        ctx: context,
                        id: data.id ?? 0,
                        name: (data.russian == '' ? data.name : data.russian) ??
                            '',
                        ep: titleInfo.currentProgress,
                        imgUrl: data.image?.original ?? '',
                      );
                    }
                  } else {
                    pushStudioSelectPage(
                      ctx: context,
                      id: data.id ?? 0,
                      name:
                          (data.russian == '' ? data.name : data.russian) ?? '',
                      // animeData.russian ??
                      //     animeData.name ??
                      //     '[Без навзвания]',
                      ep: titleInfo.currentProgress,
                      imgUrl: data.image?.original ?? '',
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Смотреть'),
              ),
        error: (error, stackTrace) => null,
        loading: () => null,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(titleInfoPageProvider(extra.id)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: titleInfo.title.valueOrNull == null ? null : 280,
              title: Text(
                // (animeData.russian == ''
                //         ? animeData.name
                //         : animeData.russian) ??
                //     '',
                extra.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.theme.colorScheme.onBackground,
                ),
              ),
              actions: titleInfo.title.valueOrNull == null
                  ? null
                  : [
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
                              '${AppConfig.staticUrl}/animes/${extra.id}',
                              mode: LaunchMode.externalApplication,
                            );
                          } else if (value == 1) {
                            Share.share(AppConfig.staticUrl +
                                (titleInfo.title.valueOrNull!.url ?? ''));
                          }
                        },
                      ),
                    ],
              flexibleSpace: titleInfo.title.valueOrNull == null
                  ? null
                  : FlexibleSpaceBar(
                      background: AnimeInfoHeader(
                        titleInfo.title.value!,
                        duration: titleInfo.duration,
                        favoured: titleInfo.isFavor,
                        nextEp: titleInfo.nextEp ?? '',
                        rating: titleInfo.rating,
                      ).animate().fade(),
                    ),
            ),
            ...titleInfo.title.when(
              skipLoadingOnRefresh: false,
              data: (data) => [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  sliver: SliverToBoxAdapter(
                    child: AnimeActionsWidget(
                      anime: data,
                      onBtnPress: () => showModalBottomSheet<void>(
                        context: context,
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width >= 700
                              ? 700
                              : double.infinity,
                        ),
                        useRootNavigator: true,
                        isScrollControlled: true,
                        enableDrag: false,
                        useSafeArea: true,
                        builder: (context) {
                          return SafeArea(
                            child: AnimeUserRateBottomSheet(
                              data: data,
                              needUpdate: true,
                              //anime: animeData,
                            ),
                          );
                        },
                      ),
                    ).animate().fadeIn(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 6),
                  sliver: SliverToBoxAdapter(
                    child: AnimeChipsWidget(
                      genres: data.genres,
                      studios: data.studios,
                      score: data.score,
                      rating: titleInfo.rating,
                    ).animate().fade(),
                  ),
                ),
                if (data.description != null) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: TitleDescription(
                        data.descriptionHtml!,
                      ).animate().fade(),
                    ),
                  ),
                ],
                if (titleInfo.statsValues != []) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: AnimeRatesStatusesWidget(
                        statsValues: titleInfo.statsValues,
                      ).animate().fade(),
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
                    padding: const EdgeInsets.only(bottom: dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: AnimeScreenshots(data).animate().fade(),
                    ),
                  ),
                ],
                if (data.videos != null && data.videos!.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: AnimeVideosMobileWidget(data).animate().fade(),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 70)),
              ],
              error: (err, stack) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(err.toString(),
                      () => ref.invalidate(titleInfoPageProvider(extra.id))),
                ),
              ],
              loading: () => [
                const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator())),
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
  final bool padding;

  const RelatedWidget({
    super.key,
    required this.id,
    this.padding = true,
  });

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

        // return Padding(
        //   padding: const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
        //   child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         'Связанное',
        //         style: Theme.of(context)
        //             .textTheme
        //             .bodyLarge!
        //             .copyWith(fontWeight: FontWeight.bold),
        //       ),
        //       const SizedBox(
        //         height: 8,
        //       ),
        //       ClipRRect(
        //         borderRadius: BorderRadius.circular(12),
        //         child: SizedBox(
        //           height: 100.0,
        //           child: Shimmer.fromColors(
        //             baseColor: Theme.of(context).colorScheme.surface,
        //             highlightColor:
        //                 Theme.of(context).colorScheme.onInverseSurface,
        //             child: Container(
        //               color: Colors.black,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // );

        return Padding(
          padding: padding
              ? const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight)
              : const EdgeInsets.all(0),
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
                              pathParameters: <String, String>{
                                'id': (title!.id!).toString(),
                              },
                              extra: title,
                            );
                          } else {
                            final extra = AnimeDetailsPageExtra(
                              id: title.id!,
                              label: (title.russian == ''
                                      ? title.name
                                      : title.russian) ??
                                  '',
                            );
                            context.pushNamed(
                              'library_anime',
                              pathParameters: <String, String>{
                                'id': (title!.id!).toString(),
                              },
                              extra: extra,
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
                  ).animate().fade();
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
          ).animate().fade(),
        );
      },
    );
  }
}
