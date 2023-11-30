import 'package:flutter/material.dart';

import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/enums/anime_source.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../../kodik/models/kodik_anime.dart';
import '../../../../domain/models/anime_database.dart';
import '../../../../domain/models/anime_player_page_extra.dart';
import '../../../../services/anime_database/anime_database_provider.dart';
import '../../../hooks/use_auto_scroll_controller.dart';
import '../../../providers/anime_details_provider.dart';
import '../../player/continue_dialog.dart';

enum EpisodeSortType { newest, oldest }

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

class SeriesSelectPage extends HookConsumerWidget {
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

    final sortedSeriesList = ref.watch(seriesSortProvider(seriesList!));
    final currentSort = ref.watch(episodeSortTypeProvider);

    void setSortType(EpisodeSortType type) async {
      ref.read(episodeSortTypeProvider.notifier).update((state) => type);
      context.pop();
    }

    List<PlaylistItem> p() {
      List<PlaylistItem> t = [];

      for (var e in sortedSeriesList) {
        t.add(PlaylistItem(
          episodeNumber: int.parse(e.number ?? ''),
          link: e.link,
          libria: null,
          name: null,
        ));
      }

      return t;
    }

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

    final List<Episode>? episodesList = useMemoized(() {
      return anime.maybeWhen(
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
    }, [anime]);

    final autoScrollController =
        useAutoScrollController(suggestedRowHeight: 48);

    useEffect(() {
      final latestEpisode = episodesList?.last;

      if (latestEpisode == null) {
        return null;
      }

      if (latestEpisode.nubmer == null) {
        return null;
      }

      final index = currentSort == EpisodeSortType.oldest
          ? latestEpisode.nubmer! - 1
          : sortedSeriesList.length - latestEpisode.nubmer!;

      if (index < 0) {
        return null;
      }

      autoScrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
      );

      return null;
    }, [episodesList]);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(isAnimeInDataBaseProvider(shikimoriId).future),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            controller: autoScrollController,
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                actions: [
                  Tooltip(
                    message: 'Сортировка серий',
                    child: IconButton(
                      onPressed: () {
                        _sortBottomSheet(context, setSortType, currentSort);
                      },
                      icon: const Icon(Icons.filter_list),
                    ),
                  ),
                ],
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.theme.colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      studioName.replaceFirst('.Subtitles', ' (Субтитры)'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.onBackground
                            .withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SliverList.builder(
                itemCount: sortedSeriesList.length,
                addSemanticIndexes: false,
                itemBuilder: (context, index) {
                  final seria = sortedSeriesList[index];
                  final epList = episodesList;

                  final epIndex = epList?.indexWhere(
                      (e) => e.nubmer == int.parse(seria.number ?? ''));

                  final Episode? episode;

                  if (epIndex == -1) {
                    episode = null;
                  } else {
                    episode = epList?[epIndex!];
                  }

                  //final latestEp = epList?.last;
                  //final isLatestWatched = episode?.nubmer == latestEp?.nubmer;

                  final int seriaNum = int.parse(seria.number ?? '0');

                  final isComp = seriaNum <= episodeWatched;

                  return AutoScrollTag(
                    controller: autoScrollController,
                    key: ValueKey(index),
                    index: index,
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                      onTap: () async {
                        String startPosition = '';

                        if (episode?.position != null && seria.type == null) {
                          bool? dialogValue = await showDialog<bool>(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => const ContinueDialog(),
                          );

                          if (dialogValue ?? false) {
                            startPosition = episode?.position ?? '';
                          }
                        }

                        final e = PlayerPageExtra(
                          selected: seriaNum,
                          info: TitleInfo(
                            shikimoriId: shikimoriId,
                            animeName: animeName,
                            imageUrl: imageUrl,
                            studioId: studioId,
                            studioName: studioName,
                            studioType: studioType,
                            additInfo: null,
                          ),
                          animeSource: AnimeSource.kodik,
                          startPosition: startPosition,
                          playlist: p(),
                        );

                        print('object');

                        //return;

                        // AnimePlayerPageExtra data = AnimePlayerPageExtra(
                        //   studioId: studioId,
                        //   shikimoriId: shikimoriId,
                        //   episodeNumber: int.parse(seria.number ?? ''),
                        //   animeName: animeName,
                        //   studioName: studioName,
                        //   studioType: studioType,
                        //   episodeLink: seria.link ?? '',
                        //   additInfo: seria.type ?? '',
                        //   position: episode?.position,
                        //   imageUrl: imageUrl,
                        //   startPosition: startPosition,
                        //   isLibria: false,
                        // );

                        // ignore: use_build_context_synchronously
                        GoRouter.of(context).pushNamed('player', extra: e);
                      },
                      title: Text("Серия ${seria.number}"),
                      subtitle: seria.type == null
                          ? (episode != null
                              ? Text(
                                  episode.timeStamp ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colorScheme.onBackground
                                        .withOpacity(0.8),
                                  ),
                                )
                              : null)
                          : Text(
                              seria.type!,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colorScheme.onBackground
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                ],
                                if (isComp) ...[
                                  IconButton(
                                    onPressed: () {},
                                    icon:
                                        const Icon(Icons.check_circle_rounded),
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                    ),
                  );
                },
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _sortBottomSheet(BuildContext context,
      Function(EpisodeSortType type) setSortType, EpisodeSortType currentSort) {
    return showModalBottomSheet(
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
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
