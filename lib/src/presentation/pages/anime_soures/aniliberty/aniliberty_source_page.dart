import 'package:flutter/material.dart';

import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../../../services/anime_database/anime_database_provider.dart';
import '../../../../../aniliberty/models/aniliberty_anime.dart';
import '../../../../utils/extensions/date_time_ext.dart';
import '../../../hooks/use_auto_scroll_controller.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/anime_database.dart';
import '../../../../domain/enums/anime_source.dart';
import '../../../../domain/models/pages_extra.dart';
import '../../player/domain/player_page_extra.dart' as ppe;
import '../../../widgets/error_widget.dart';
import '../../player/continue_dialog.dart';
import '../../../../utils/app_utils.dart';
import '../kodik/kodik_source_page.dart';

import 'aniliberty_source_controller.dart';

class AnilibertySourcePage extends HookConsumerWidget {
  const AnilibertySourcePage(this.extra, {super.key});

  final AnimeSourcePageExtra extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchPhrase = useState(extra.searchList[0]);

    final p = AnilibertySourceParameters(
      query: searchPhrase.value,
      year: extra.year,
      isOngoing: extra.isOngoing,
    );

    void addEpisode(int episode) {
      ref
          .read(animeDatabaseProvider)
          .updateEpisode(
            shikimoriId: extra.shikimoriId,
            animeName: extra.animeName,
            imageUrl: extra.imageUrl,
            timeStamp: 'Просмотрено полностью',
            studioId: 610,
            studioName: 'AniLibria.TV',
            studioType: 'voice',
            episodeNumber: episode,
            complete: true,
          )
          .then((_) {
        showSnackBar(ctx: context, msg: 'Серия $episode добавлена');
        return ref.refresh(isAnimeInDataBaseProvider(extra.shikimoriId));
      });
    }

    void removeEpisode(int episode) {
      ref
          .read(animeDatabaseProvider)
          .deleteEpisode(
            shikimoriId: extra.shikimoriId,
            studioId: 610,
            episodeNumber: episode,
          )
          .then((value) {
        showSnackBar(ctx: context, msg: 'Серия $episode удалена');
        return ref.refresh(isAnimeInDataBaseProvider(extra.shikimoriId));
      });
    }

    final result = ref.watch(anilibertySourceProvider(p));
    final localAnime = ref.watch(isAnimeInDataBaseProvider(extra.shikimoriId));

    final autoScrollController =
        useAutoScrollController(suggestedRowHeight: 48);

    final List<Episode>? localEpisodesList = useMemoized(() {
      return localAnime.maybeWhen(
        data: (anime) {
          final studioIndex = anime?.studios
              ?.indexWhere((e) => (e.id == 610 && e.name == 'AniLibria.TV'));

          if (studioIndex == -1) {
            return null;
          }

          final studio = anime?.studios?[studioIndex!];

          return studio?.episodes;
        },
        orElse: () => null,
      );
    }, [localAnime]);

    useEffect(() {
      if (result.isLoading || result.asData == null) {
        return null;
      }

      final latestEpisode = localEpisodesList?.lastOrNull;

      if (latestEpisode == null) {
        return null;
      }

      if (latestEpisode.nubmer == null) {
        return null;
      }

      final index = latestEpisode.nubmer! - 1;

      if (index < 0) {
        return null;
      }

      autoScrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
      );

      return null;
    }, [localEpisodesList, result]);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          controller: autoScrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
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
                  color: context.theme.colorScheme.onBackground,
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  tooltip: 'Поиск по другому названию',
                  itemBuilder: (context) {
                    return List.generate(
                      extra.searchList.length,
                      (index) => PopupMenuItem(
                        value: extra.searchList[index],
                        child: Text(extra.searchList[index]),
                      ),
                    );
                  },
                  onSelected: (value) {
                    searchPhrase.value = value;
                  },
                  elevation: 8,
                  icon: const Icon(Icons.manage_search_rounded),
                ),
              ],
            ),
            ...result.when(
              skipLoadingOnRefresh: false,
              data: (title) {
                if (title == null || title.episodes.isEmpty) {
                  return [
                    SliverFillRemaining(
                      child: NothingFound(extra),
                    ),
                  ];
                }

                return [
                  InfoCard(title),
                  SliverList.builder(
                    itemCount: title.episodes.length,
                    itemBuilder: (context, index) {
                      final episode = title.episodes[index];

                      final savedEpIndex = localEpisodesList
                          ?.indexWhere((e) => e.nubmer == episode.ordinal);

                      final Episode? savedEpisode;

                      if (savedEpIndex == -1) {
                        savedEpisode = null;
                      } else {
                        savedEpisode = localEpisodesList?[savedEpIndex!];
                      }

                      final isCompleted = episode.ordinal <= extra.epWatched;

                      return AutoScrollTag(
                        controller: autoScrollController,
                        key: ValueKey(index),
                        index: index,
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 0, 0, 0),
                          onTap: () async {
                            String startPosition = '';

                            if (savedEpisode?.position != null) {
                              final dialogValue = await ContinueDialogNew.show(
                                    context,
                                    titleName: extra.animeName,
                                    selectedEp: episode.ordinal,
                                    savedPosition: savedEpisode!.position!,
                                    imageUrl: extra.imageUrl,
                                    studioName: 'AniLibria.TV',
                                  ) ??
                                  ContinueDialogResult.cancel;

                              if (dialogValue == ContinueDialogResult.cancel) {
                                return;
                              }

                              if (dialogValue == ContinueDialogResult.saved) {
                                startPosition = savedEpisode.position ?? '';
                              }
                            }

                            List<ppe.LibriaPlaylistItem> t = [];

                            for (final p in title.episodes) {
                              t.add(
                                ppe.LibriaPlaylistItem(
                                  number: p.ordinal,
                                  name: p.name,
                                  fnd: p.videoFhd,
                                  hd: p.videoHd,
                                  sd: p.videoSd,
                                  opSkip: p.opening,
                                ),
                              );
                            }

                            final ppe.LibriaPlaylist libriaPlaylist =
                                ppe.LibriaPlaylist(
                              //host: 'https://static.libria.fun',
                              // host: 'https://${title.player!.host!}',
                              // host: 'https://cache-rfn.libria.fun',
                              host: '',
                              playlist: t,
                            );

                            final e = ppe.PlayerPageExtra(
                              titleInfo: ppe.TitleInfo(
                                shikimoriId: extra.shikimoriId,
                                animeName: extra.animeName,
                                imageUrl: extra.imageUrl,
                              ),
                              studio: const ppe.Studio(
                                id: 610,
                                name: 'AniLibria.TV',
                                type: 'voice',
                              ),
                              selected: episode.ordinal,
                              animeSource: AnimeSource.liberty,
                              startPosition: startPosition,
                              anilib: null,
                              libria: libriaPlaylist,
                              kodik: null,
                            );

                            // ignore: use_build_context_synchronously
                            GoRouter.of(context).pushNamed('player', extra: e);
                          },
                          title: Text(episode.name != null
                              ? '#${episode.ordinal}'
                              : 'Серия ${episode.ordinal}'),
                          subtitle: _buildSubtitle(
                            context,
                            name: episode.name,
                            ts: savedEpisode?.timeStamp,
                          ),
                          // subtitle: episode.name != null &&
                          //         episode.name!.isNotEmpty
                          //     ? RichText(
                          //         text: TextSpan(
                          //           text: episode.name,
                          //           style:
                          //               context.textTheme.bodyMedium?.copyWith(
                          //             color:
                          //                 context.colorScheme.onSurfaceVariant,
                          //           ),
                          //           children: savedEpisode?.timeStamp != null
                          //               ? [
                          //                   TextSpan(
                          //                     text:
                          //                         '\n${savedEpisode?.timeStamp}',
                          //                     style: TextStyle(
                          //                       fontSize: 12,
                          //                       color: context.colorScheme
                          //                           .onSurfaceVariant
                          //                           .withOpacity(0.8),
                          //                     ),
                          //                   ),
                          //                 ]
                          //               : null,
                          //         ),
                          //       )
                          //     : savedEpisode?.timeStamp != null
                          //         ? Text(
                          //             savedEpisode!.timeStamp!,
                          //             style: TextStyle(
                          //               fontSize: 12,
                          //               color: context
                          //                   .colorScheme.onSurfaceVariant,
                          //             ),
                          //           )
                          //         : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (savedEpisode != null && !isCompleted) ...[
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.done),
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              ],
                              if (isCompleted) ...[
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.check_circle_rounded),
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              ],
                              if (savedEpisode != null) ...[
                                IconButton(
                                  onPressed: () {
                                    removeEpisode(episode.ordinal);
                                  },
                                  icon: const Icon(Icons.delete),
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ] else ...[
                                IconButton(
                                  onPressed: () {
                                    addEpisode(episode.ordinal);
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
                ];
              },
              loading: () => [
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (err, stack) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(
                    err.toString(),
                    () => ref.refresh(anilibertySourceProvider(p)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildSubtitle(
    BuildContext context, {
    String? name,
    String? ts,
  }) {
    final hasName = name != null && name.isNotEmpty;
    final hasTime = ts != null;
    if (!hasName && !hasTime) return null;

    return Text.rich(
      TextSpan(
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        children: [
          if (hasName) TextSpan(text: name),
          if (hasName && hasTime) const TextSpan(text: '\n'),
          if (hasTime)
            TextSpan(
              text: ts,
              style: TextStyle(
                fontSize: 12,
                color: context.colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
            ),
        ],
      ),
      // overflow: TextOverflow.ellipsis,
      // maxLines: 2,
    );
  }
}

class InfoCard extends StatelessWidget {
  final AnilibertyAnime title;

  const InfoCard(this.title, {super.key});

  String getSheduleWeekDay(int day) {
    switch (day) {
      case 1:
        return 'каждый понедельник';
      case 2:
        return 'каждый вторник';
      case 3:
        return 'каждую среду';
      case 4:
        return 'каждый четверг';
      case 5:
        return 'каждую пятницу';
      case 6:
        return 'каждую субботу';
      case 7:
        return 'каждое воскресенье';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
      sliver: SliverToBoxAdapter(
        child: Card(
          margin: const EdgeInsets.all(0.0),
          elevation: 4,
          shadowColor: Colors.transparent,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Найдено в AniLiberty',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  title.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (title.publishDay != 0 && title.isInProduction)
                  Text(
                    'Выходит ${getSheduleWeekDay(title.publishDay)}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                if (title.updatedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Обновлено ${title.updatedAt!.toLocal().convertToDaysAgo()}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            context.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ),
                if (title.notification.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      title.notification,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NothingFound extends StatelessWidget {
  const NothingFound(
    this.extra, {
    super.key,
  });

  final AnimeSourcePageExtra extra;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Σ(ಠ_ಠ)',
              textAlign: TextAlign.center,
              style: context.textTheme.displayMedium,
            ),
            const SizedBox(
              height: 4,
            ),
            const Text(
              'Ничего не найдено',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        KodikSourcePage(extra),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: const Text(
                'Искать в Kodik',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
