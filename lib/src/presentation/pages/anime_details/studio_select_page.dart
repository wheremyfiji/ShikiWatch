import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';
import 'package:shikidev/src/utils/utils.dart';

import '../../../../kodik/kodik.dart';
import '../../../../kodik/models/kodik_anime.dart';
import '../../../domain/models/anime_database.dart';
import '../../providers/anime_details_provider.dart';
import '../../widgets/error_widget.dart';
import 'series_select_page.dart';

final latestStudioProvider =
    FutureProvider.family.autoDispose<Studio?, int>((ref, shikimoriId) async {
  final anime = await ref.watch(isAnimeInDataBaseProvider(shikimoriId).future);

  if (anime == null) {
    return null;
  }

  if (anime.studios == null || anime.studios!.isEmpty) {
    return null;
  }

  final studios = anime.studios!;

  studios.sort((a, b) => b.updated!.compareTo(a.updated!));

  if (studios.first.episodes == null || studios.first.episodes!.isEmpty) {
    return null;
  }

  return studios.first;
}, name: 'latestStudioProvider');

class StudioSelectPage extends ConsumerWidget {
  final int shikimoriId;
  final int epWatched;
  final String animeName;
  final String imageUrl;

  const StudioSelectPage({
    super.key,
    required this.shikimoriId,
    required this.epWatched,
    required this.animeName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<KodikAnime> studios = ref.watch(kodikAnimeProvider(shikimoriId));
    final latestStudio = ref.watch(latestStudioProvider(shikimoriId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(kodikAnimeProvider(shikimoriId).future),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: Text(
                animeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // SliverPinnedHeader(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Card(
            //       shadowColor: Colors.transparent,
            //       child: Padding(
            //         padding: const EdgeInsets.all(16.0),
            //         child: Column(
            //           children: [
            //             Text(animeName),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            ...studios.when(
              loading: () => [
                const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator())),
              ],
              error: (err, stack) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(err.toString(),
                      () => ref.refresh(kodikAnimeProvider(shikimoriId))),
                ),
              ],
              data: (data) {
                if (data.total == 0) {
                  return [
                    const SliverFillRemaining(
                      child: Center(child: Text('Ничего не найдено')),
                    )
                  ];
                }
                return [
                  latestStudio.maybeWhen(
                    skipError: true,
                    data: (latestStudio) {
                      if (latestStudio == null) {
                        return const SliverToBoxAdapter(
                            child: SizedBox.shrink());
                      }
                      return LatestStudio(
                        studio: latestStudio,
                        onContinue: () {
                          final element = data.studio!.firstWhereOrNull(
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
                              pageBuilder: (context, animation1, animation2) =>
                                  SeriesSelectPage(
                                seriesList: element.kodikSeries,
                                studioId: element.studioId ?? 0,
                                shikimoriId: shikimoriId,
                                episodeWatched: epWatched,
                                animeName: animeName,
                                studioName: element.name ?? '',
                                studioType: element.type ?? '',
                                imageUrl: imageUrl,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                      );
                    },
                    orElse: () {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        data.studio?.sort(
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

                        final KodikStudio? element = data.studio?[index];
                        final dateTimeString = element?.updatedAt;
                        final formattedDate = DateFormat('dd/MM/yyyy - HH:mm')
                            .format(DateTime.parse(dateTimeString!).toLocal());

                        return ListTile(
                          title: Text(
                            element?.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          subtitle: Text(
                            'Обновлено: $formattedDate',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            '${element?.episodesCount} эп.',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: context.textTheme.bodyMedium
                                ?.copyWith(fontSize: 12),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                settings: const RouteSettings(
                                  name: 'series select page',
                                ),
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        SeriesSelectPage(
                                  seriesList: element?.kodikSeries,
                                  studioId: element?.studioId ?? 0,
                                  shikimoriId: shikimoriId,
                                  episodeWatched: epWatched,
                                  animeName: animeName,
                                  studioName: element?.name ?? '',
                                  studioType: element?.type ?? '',
                                  imageUrl: imageUrl,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        );
                      },
                      childCount: data.total,
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LatestStudio extends ConsumerWidget {
  final Studio studio;
  final VoidCallback onContinue;

  const LatestStudio({
    super.key,
    required this.studio,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episode = studio.episodes!.last;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      sliver: SliverToBoxAdapter(
        child: Card(
          shadowColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Последнее просмотренное',
                  // style: TextStyle(
                  //   fontWeight: FontWeight.w500,
                  //   fontSize: 18,
                  // ),
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text('${studio.name} • Серия ${episode.nubmer.toString()}'),
                if (episode.timeStamp != null) Text(episode.timeStamp!),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spacer(),
                    FilledButton(
                      onPressed: onContinue,
                      child: const Text('Продолжить'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
