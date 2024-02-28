import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';

import '../../../../utils/extensions/date_time_ext.dart';
import '../../../widgets/auto_sliver_animated_list.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/flexible_sliver_app_bar.dart';
import '../../../../../kodik/models/kodik_anime.dart';
import '../../../../domain/models/pages_extra.dart';
import '../anilibria/anilibria_source_page.dart';
import '../../../widgets/error_widget.dart';
import '../shared/compact_info_chip.dart';
import '../../../../utils/app_utils.dart';
import '../../../../../kodik/kodik.dart';
import '../shared/nothing_found.dart';
import '../latest_studio.dart';
import '../providers.dart';

import 'kodik_series_select_page.dart';
import 'kodik_source_controller.dart';

class KodikSourcePage extends ConsumerWidget {
  const KodikSourcePage(
    this.extra, {
    super.key,
  });

  final AnimeSourcePageExtra extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<KodikAnime> studiosAsync =
        ref.watch(kodikAnimeProvider(extra.shikimoriId));
    final latestStudio = ref.watch(latestStudioProvider(extra.shikimoriId));
    final studioFilter = ref.watch(studioFilterProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(kodikAnimeProvider(extra.shikimoriId).future),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              FlexibleSliverAppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Text(
                  extra.animeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                bottomContent: SingleChildScrollView(
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
                        selected: studioFilter == StudioFilter.all,
                        onSelected: (value) => ref
                            .read(studioFilterProvider.notifier)
                            .state = StudioFilter.all,
                      ),
                      ChoiceChip(
                        label: const Text('Озвучка'),
                        selected: studioFilter == StudioFilter.voice,
                        onSelected: (value) => ref
                            .read(studioFilterProvider.notifier)
                            .state = StudioFilter.voice,
                      ),
                      ChoiceChip(
                        label: const Text('Субтитры'),
                        selected: studioFilter == StudioFilter.sub,
                        onSelected: (value) => ref
                            .read(studioFilterProvider.notifier)
                            .state = StudioFilter.sub,
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                    ],
                  ),
                ),
                actions: [
                  PopupMenuButton(
                    tooltip: '',
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Text("Искать в AniLibria"),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == 0) {
                        //Navigator.pop(context);

                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                AnilibriaSourcePage(
                              extra,
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                ),
              ),
              ...studiosAsync.when(
                loading: () => [
                  const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator())),
                ],
                error: (err, stack) => [
                  SliverFillRemaining(
                    child: CustomErrorWidget(
                        err.toString(),
                        () =>
                            ref.refresh(kodikAnimeProvider(extra.shikimoriId))),
                  ),
                ],
                data: (studios) {
                  if (studios.total == 0 || studios.studio == null) {
                    return [const SourceNothingFound()];
                  }

                  final studioList =
                      ref.watch(filteredStudiosProvider(studios.studio!));

                  if (studioList.isEmpty) {
                    return [const SourceNothingFound()];
                  }

                  return [
                    latestStudio.maybeWhen(
                      skipError: true,
                      data: (latestStudio) {
                        if (latestStudio == null) {
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        }

                        return LatestStudio(
                          studio: latestStudio,
                          onContinue: () {
                            final element = studios.studio!.firstWhereOrNull(
                                (e) => e.studioId == latestStudio.id);
                            if (element == null) {
                              showErrorSnackBar(
                                  ctx: context, msg: 'element == null');
                              return;
                            }

                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                settings: const RouteSettings(
                                  name: 'series select page',
                                ),
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        SeriesSelectPage(
                                  seriesList: element.kodikSeries,
                                  studioId: element.studioId ?? 0,
                                  shikimoriId: extra.shikimoriId,
                                  episodeWatched: extra.epWatched,
                                  animeName: extra.animeName,
                                  studioName: element.name ?? '',
                                  studioType: element.type ?? '',
                                  imageUrl: extra.imageUrl,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        );
                      },
                      orElse: () {
                        return const SliverToBoxAdapter(
                            child: SizedBox.shrink());
                      },
                    ),

                    AutoAnimatedSliverList(
                      items: studioList,
                      itemBuilder: (context, _, index, animation) {
                        studioList.sort(
                          (a, b) {
                            final int sortByEpCount =
                                -a.episodesCount!.compareTo(b.episodesCount!);
                            if (sortByEpCount == 0) {
                              final int sortByUpdate =
                                  -a.updatedAt!.compareTo(b.updatedAt!);
                              return sortByUpdate;
                            }
                            return sortByEpCount;
                          },
                        );

                        final studio = studioList[index];

                        final updatedAtDateTime =
                            DateTime.parse(studio.updatedAt!).toLocal();

                        return SizeFadeTransition(
                          animation: animation,
                          child: StudioListTile(
                            name: studio.name ?? '',
                            type: studio.type ?? '',
                            update: updatedAtDateTime.convertToDaysAgo(),
                            episodeCount: studio.episodesCount ?? 0,
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                settings: const RouteSettings(
                                  name: 'series select page',
                                ),
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        SeriesSelectPage(
                                  seriesList: studio.kodikSeries,
                                  studioId: studio.studioId ?? 0,
                                  shikimoriId: extra.shikimoriId,
                                  episodeWatched: extra.epWatched,
                                  animeName: extra.animeName,
                                  studioName: studio.name ?? '',
                                  studioType: studio.type ?? '',
                                  imageUrl: extra.imageUrl,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // SliverList.builder(
                    //   itemBuilder: (context, index) {
                    //     studioList.sort(
                    //       (a, b) {
                    //         final int sortByEpCount =
                    //             -a.episodesCount!.compareTo(b.episodesCount!);
                    //         if (sortByEpCount == 0) {
                    //           final int sortByUpdate =
                    //               -a.updatedAt!.compareTo(b.updatedAt!);
                    //           return sortByUpdate;
                    //         }
                    //         return sortByEpCount;
                    //       },
                    //     );

                    //     final studio = studioList[index];

                    //     final updatedAtDateTime =
                    //         DateTime.parse(studio.updatedAt!).toLocal();

                    //     return StudioListTile(
                    //       name: studio.name ?? '',
                    //       type: studio.type ?? '',
                    //       update: updatedAtDateTime.convertToDaysAgo(),
                    //       episodeCount: studio.episodesCount ?? 0,
                    //       onTap: () => Navigator.push(
                    //         context,
                    //         PageRouteBuilder(
                    //           settings: const RouteSettings(
                    //             name: 'series select page',
                    //           ),
                    //           pageBuilder: (context, animation1, animation2) =>
                    //               SeriesSelectPage(
                    //             seriesList: studio.kodikSeries,
                    //             studioId: studio.studioId ?? 0,
                    //             shikimoriId: shikimoriId,
                    //             episodeWatched: epWatched,
                    //             animeName: animeName,
                    //             studioName: studio.name ?? '',
                    //             studioType: studio.type ?? '',
                    //             imageUrl: imageUrl,
                    //           ),
                    //           transitionDuration: Duration.zero,
                    //           reverseTransitionDuration: Duration.zero,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   itemCount: studioList.length,
                    // ),

                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudioListTile extends StatelessWidget {
  const StudioListTile({
    super.key,
    required this.name,
    required this.type,
    required this.update,
    required this.episodeCount,
    required this.onTap,
  });

  final String name;
  final String type;
  final String update;
  final int episodeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // leading: studio.studioId == 610
      //     ? const Icon(Icons.push_pin_rounded)
      //     : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              name.replaceFirst('.Subtitles', ''),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          if (type == 'subtitles')
            const CompactInfoChip(
              'Субтитры',
            ),
        ],
      ),
      subtitle: Text(
        'Обновлено $update',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontSize: 12,
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      trailing: Text(
        '$episodeCount эп.',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontSize: 12,
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      onTap: onTap,
    );
  }
}
