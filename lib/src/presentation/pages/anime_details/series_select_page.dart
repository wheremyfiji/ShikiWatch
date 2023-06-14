import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../../../../kodik/models/kodik_anime.dart';
import '../../../domain/models/anime_database.dart';
import '../../../domain/models/anime_player_page_extra.dart';
import '../../../services/anime_database/anime_database_provider.dart';
import '../../../utils/target_platform.dart';
import '../../../utils/utils.dart';
import '../player/continue_dialog.dart';

enum EpisodeSortType { newest, oldest }

final isAnimeInDataBaseProvider =
    FutureProvider.family.autoDispose<AnimeDatabase?, int>((ref, id) {
  final anime = ref.read(animeDatabaseProvider).getAnime(shikimoriId: id);
  return anime;
}, name: 'isAnimeInDataBaseProvider');

final episodeSortTypeProvider =
    StateProvider<EpisodeSortType>((ref) => EpisodeSortType.oldest);

final seriesSortProvider = StateProvider.family
    .autoDispose<List<KodikSeries>, List<KodikSeries>>((ref, series) {
  final sortType = ref.watch(episodeSortTypeProvider);
  switch (sortType) {
    case EpisodeSortType.oldest:
      return series;
    case EpisodeSortType.newest:
      return series.reversed.toList();
    default:
      return series;
  }
}, name: 'episodeSortProvider');

class SeriesSelectPage extends ConsumerWidget {
  final List<KodikSeries>? seriesList;

  final int studioId;
  final int shikimoriId;
  final int episodeWatched;
  final String animeName;
  final String imageUrl;
  final String studioName;
  final String studioType;

  const SeriesSelectPage({
    super.key,
    this.seriesList,
    required this.studioId,
    required this.shikimoriId,
    required this.episodeWatched,
    required this.animeName,
    required this.imageUrl,
    required this.studioName,
    required this.studioType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anime = ref.watch(isAnimeInDataBaseProvider(shikimoriId));

    void addEpisode(int? episode) async {
      if (episode != null) {
        ref
            .read(animeDatabaseProvider)
            .updateEpisode(
                shikimoriId: shikimoriId,
                animeName: animeName,
                imageUrl: imageUrl,
                timeStamp: 'Просмотрено полностью',
                studioId: studioId,
                studioName: studioName,
                studioType: studioType,
                episodeNumber: episode,
                complete: true)
            .then((value) {
          showSnackBar(ctx: context, msg: 'Серия $episode добавлена');
          return ref.refresh(isAnimeInDataBaseProvider(shikimoriId));
        });
      }
    }

    void removeEpisode(int? episode) async {
      if (episode != null) {
        ref
            .read(animeDatabaseProvider)
            .deleteEpisode(
                shikimoriId: shikimoriId,
                studioId: studioId,
                episodeNumber: episode)
            .then((value) {
          showSnackBar(ctx: context, msg: 'Серия $episode удалена');
          return ref.refresh(isAnimeInDataBaseProvider(shikimoriId));
        });
      }
    }

    List<Episode>? episodesList(int studioId) => anime.maybeWhen(
          data: (anime) {
            // возврящает -1 если элемент не найден
            final studioIndex =
                anime?.studios?.indexWhere((e) => e.id == studioId);

            // если такой студии нету
            if (studioIndex == -1) {
              return null;
            }

            final studio = anime?.studios?[studioIndex!];

            return studio?.episodes;
          },
          orElse: () => null,
        );

    void setSortType(EpisodeSortType type) async {
      ref.read(episodeSortTypeProvider.notifier).update((state) => type);
      context.pop();
    }

    watchRouteChange() async {
      if (!GoRouter.of(context).location.contains('/player')) {
        await Future.delayed(const Duration(milliseconds: 500));

        ref.invalidate(isAnimeInDataBaseProvider);
        debugPrint('invalidate isAnimeInDataBaseProvider');
        if (context.mounted) {
          debugPrint('removeListener watchRouteChange');
          GoRouter.maybeOf(context)?.removeListener(watchRouteChange);
        }
      }
    }

    final sortedSeriesList = ref.watch(seriesSortProvider(seriesList!));
    final currentSort = ref.watch(episodeSortTypeProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(isAnimeInDataBaseProvider(shikimoriId).future),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              actions: [
                Tooltip(
                  message: 'Сортировка серий',
                  child: IconButton(
                    onPressed: () {
                      _sortBottomSheet(context, setSortType, currentSort);
                    },
                    //onPressed: null,
                    icon: const Icon(Icons.filter_list),
                  ),
                ),
              ],
              title: Text(
                '$animeName • $studioName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // SliverPinnedHeader(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Card(
            //       //color: Colors.transparent,
            //       shadowColor: Colors.transparent,
            //       child: Padding(
            //         padding: const EdgeInsets.all(16.0),
            //         child: Column(
            //           mainAxisSize: MainAxisSize.min,
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text('$animeName • $studioName'),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final seria = sortedSeriesList[index];
                  final epList = episodesList(studioId);

                  final epIndex = epList?.indexWhere(
                      (e) => e.nubmer == int.parse(seria.number ?? ''));

                  final Episode? episode;

                  if (epIndex == -1) {
                    episode = null;
                  } else {
                    episode = epList?[epIndex!];
                  }

                  final int seriaNum = int.parse(seria.number ?? '0');

                  final isComp = seriaNum <= episodeWatched;
                  return ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                    onTap: () async {
                      String startPosition = '';
                      if (!TargetP.instance.isDesktop &&
                          episode?.position != null &&
                          seria.type == null) {
                        bool? dialogValue = await showDialog<bool>(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => const ContinueDialog(),
                        );

                        if (dialogValue ?? false) {
                          startPosition = episode?.position ?? '';
                        }
                      }
                      AnimePlayerPageExtra data = AnimePlayerPageExtra(
                        studioId: studioId,
                        shikimoriId: shikimoriId,
                        episodeNumber: int.parse(seria.number ?? ''),
                        animeName: animeName,
                        studioName: studioName,
                        studioType: studioType,
                        episodeLink: seria.link ?? '',
                        additInfo: seria.type ?? '',
                        position: episode?.position,
                        imageUrl: imageUrl,
                        startPosition: startPosition,
                      );

                      // ignore: use_build_context_synchronously
                      GoRouter.of(context).pushNamed('player', extra: data);
                      // ignore: use_build_context_synchronously
                      GoRouter.of(context).addListener(watchRouteChange);
                      debugPrint('addListener watchRouteChange');
                    },
                    // title: seria.type != null
                    //     ? Text("Серия ${seria.number} (${seria.type})")
                    //     : Text("Серия ${seria.number}"),
                    title: Text("Серия ${seria.number}"),
                    subtitle: seria.type == null
                        ? (episode != null
                            ? Text(
                                episode.timeStamp ?? '',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.8),
                                ),
                              )
                            : null)
                        : Text(
                            seria.type!,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.8),
                            ),
                          ),
                    trailing: seria.type != null
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (episode != null && !isComp) ...[
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.done),
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              ],
                              if (isComp) ...[
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.check_circle_rounded),
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              ],
                              if (episode != null) ...[
                                IconButton(
                                  onPressed: () {
                                    removeEpisode(
                                        int.parse(seria.number ?? ''));
                                  },
                                  icon: const Icon(Icons.delete),
                                  color: Theme.of(context).colorScheme.error,
                                  // MediaQuery.of(context).platformBrightness ==
                                  //         Brightness.dark
                                  //     ? Colors.red.shade200
                                  //     : Colors.red.shade600,
                                ),
                              ] else ...[
                                IconButton(
                                  onPressed: () {
                                    addEpisode(int.parse(seria.number ?? ''));
                                  },
                                  icon: const Icon(Icons.add),
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                  );
                },
                childCount: sortedSeriesList.length,
              ),
            ),
            //const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  _sortBottomSheet(BuildContext context,
      Function(EpisodeSortType type) setSortType, EpisodeSortType currentSort) {
    return showModalBottomSheet(
      useRootNavigator: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
      ),
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Сортировка списка серий',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              RadioListTile<EpisodeSortType>(
                title: const Text(
                  'По старым',
                ),
                value: EpisodeSortType.oldest,
                groupValue: currentSort,
                onChanged: (value) {
                  setSortType(EpisodeSortType.oldest);
                },
              ),
              RadioListTile<EpisodeSortType>(
                title: const Text(
                  'По новым',
                ),
                value: EpisodeSortType.newest,
                groupValue: currentSort,
                onChanged: (value) {
                  setSortType(EpisodeSortType.newest);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
