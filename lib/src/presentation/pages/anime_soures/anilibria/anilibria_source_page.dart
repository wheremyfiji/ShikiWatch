import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../../../../anilibria/anilibria_api.dart';
import '../../../../../anilibria/enums/title_status_code.dart';
import '../../../../../anilibria/models/title.dart';
import '../../../../domain/enums/anime_source.dart';
import '../../../../domain/models/anime_database.dart';
import '../../../../domain/models/pages_extra.dart';
import '../../../../services/anime_database/anime_database_provider.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/extensions/date_time_ext.dart';
import '../../../../utils/app_utils.dart';
import '../../../hooks/use_auto_scroll_controller.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../widgets/error_widget.dart';
import '../../player/continue_dialog.dart';
import '../../player/domain/player_page_extra.dart' as ppe;
import '../kodik/kodik_source_page.dart';

import 'anilibria_source_controller.dart';

class AnilibriaSourcePage extends HookConsumerWidget {
  const AnilibriaSourcePage(
    this.extra, {
    super.key,
  });

  final AnimeSourcePageExtra extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchPhrase = useState(extra.searchList[0]);
    final result = ref.watch(anilibriaSearchProvider(searchPhrase.value));
    final anime = ref.watch(isAnimeInDataBaseProvider(extra.shikimoriId));

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

    final List<Episode>? episodesList = useMemoized(() {
      return anime.maybeWhen(
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
    }, [anime]);

    final autoScrollController =
        useAutoScrollController(suggestedRowHeight: 48);

    useEffect(() {
      if (result.isLoading || result.asData == null) {
        return null;
      }

      final latestEpisode = episodesList?.lastOrNull;

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
    }, [episodesList, result]);

    // List<appe.PlaylistItem> p(List<AnilibriaEpisode> playlist, String host) {
    //   List<appe.PlaylistItem> t = [];

    //   for (var e in playlist) {
    //     t.add(appe.PlaylistItem(
    //       episodeNumber: e.episode ?? -1,
    //       link: null,
    //       anilibEpisode: null,
    //       libria: appe.LibriaEpisode(
    //         //host: 'https://static.libria.fun',
    //         host: host,
    //         fnd: e.hls!.fhd,
    //         hd: e.hls!.hd,
    //         sd: e.hls!.sd,
    //         opSkip: e.skips?.opening == null
    //             ? []
    //             : [
    //                 e.skips!.opening!.start ?? 0,
    //                 e.skips!.opening!.stop!,
    //               ],
    //       ),
    //       name: e.name,
    //     ));
    //   }

    //   return t;
    // }

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          controller: autoScrollController,
          slivers: [
            SliverAppBar.medium(
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
              pinned: true,
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
                IconButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      icon: const Icon(Icons.info),
                      title: const Text('Информация'),
                      content: const Text(
                        'Поиск производится по названию через API АниЛибрии. Результат может НЕ совпадать с искомым аниме.\n'
                        '\nНайденные серии связаны с озвучкой от Анилибрии в других источниках.',
                      ),
                      actions: <Widget>[
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
            ...result.when(
              skipLoadingOnRefresh: false,
              data: (data) {
                if (data.list == null ||
                    data.list!.isEmpty ||
                    data.list?[0].player?.playlist == null ||
                    data.list![0].player!.playlist!.isEmpty) {
                  return [
                    SliverFillRemaining(
                      child: NothingFound(extra),
                    ),
                  ];
                }

                final title = data.list!.first;

                return [
                  TitleInfo(title),
                  if (title.torrent != null &&
                      title.torrent!.torrentlist != null &&
                      title.torrent!.torrentlist!.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: Divider(),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 6.0,
                          bottom: 8.0,
                        ),
                        child: Text(
                          'Torrent-раздачи',
                          style: context.textTheme.titleLarge,
                        ),
                      ),
                    ),
                    AnilibriaTorrentList(title.torrent!),
                    const SliverPadding(
                      padding: EdgeInsets.only(top: 16.0),
                      sliver: SliverToBoxAdapter(
                        child: Divider(height: 1),
                      ),
                    ),
                  ],
                  SliverList.builder(
                    itemCount: title.player!.playlist!.length,
                    itemBuilder: (context, index) {
                      final ep = title.player!.playlist![index];

                      final savedEpIndex = episodesList
                          ?.indexWhere((e) => e.nubmer == ep.episode);

                      final Episode? savedEpisode;

                      if (savedEpIndex == -1) {
                        savedEpisode = null;
                      } else {
                        savedEpisode = episodesList?[savedEpIndex!];
                      }

                      final isCompleted = ep.episode! <= extra.epWatched;

                      return AutoScrollTag(
                        controller: autoScrollController,
                        key: ValueKey(index),
                        index: index,
                        child: AnilibriaEpisodeTile(
                          ep: ep,
                          savedEpisode: savedEpisode,
                          isCompleted: isCompleted,
                          host: 'https://${title.player!.host!}',
                          shikimoriId: extra.shikimoriId,
                          epWatched: extra.epWatched,
                          animeName: extra.animeName,
                          imageUrl: extra.imageUrl,
                          removeEpisode: (e) => removeEpisode(e),
                          addEpisode: (e) => addEpisode(e),
                          onTap: () async {
                            String startPosition = '';

                            if (savedEpisode?.position != null) {
                              final dialogValue = await ContinueDialogNew.show(
                                    context,
                                    titleName: extra.animeName,
                                    selectedEp: ep.episode ?? 0,
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

                            for (AnilibriaEpisode p
                                in title.player!.playlist!) {
                              t.add(
                                ppe.LibriaPlaylistItem(
                                  number: p.episode ?? -1,
                                  name: p.name,
                                  fnd: p.hls!.fhd,
                                  hd: p.hls!.hd,
                                  sd: p.hls!.sd,
                                  opSkip: p.skips?.opening == null
                                      ? []
                                      : [
                                          p.skips!.opening!.start ?? 0,
                                          p.skips!.opening!.stop!,
                                        ],
                                ),
                              );
                            }

                            final ppe.LibriaPlaylist libriaPlaylist =
                                ppe.LibriaPlaylist(
                              //host: 'https://static.libria.fun',
                              host: 'https://${title.player!.host!}',
                              // host: 'https://cache-rfn.libria.fun',
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
                              selected: ep.episode!,
                              animeSource: AnimeSource.libria,
                              startPosition: startPosition,
                              anilib: null,
                              libria: libriaPlaylist,
                              kodik: null,
                            );

                            // ignore: use_build_context_synchronously
                            GoRouter.of(context).pushNamed('player', extra: e);
                          },
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
                    () =>
                        ref.refresh(anilibriaSearchProvider(extra.searchName)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnilibriaEpisodeTile extends StatelessWidget {
  final AnilibriaEpisode ep;
  final Episode? savedEpisode;
  final bool isCompleted;
  final String host;

  final int shikimoriId;
  final int epWatched;
  final String animeName;
  final String imageUrl;

  final void Function() onTap;

  final void Function(int episode) removeEpisode;
  final void Function(int episode) addEpisode;

  const AnilibriaEpisodeTile({
    super.key,
    required this.ep,
    required this.savedEpisode,
    required this.isCompleted,
    required this.host,
    required this.shikimoriId,
    required this.epWatched,
    required this.animeName,
    required this.imageUrl,
    required this.removeEpisode,
    required this.addEpisode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
      onTap: onTap,
      title: Text(
        'Серия ${ep.episode}',
      ),
      subtitle: savedEpisode != null && savedEpisode!.timeStamp != null
          ? Text(
              savedEpisode!.timeStamp!,
              style: TextStyle(
                fontSize: 12,
                color: context.colorScheme.onBackground.withOpacity(0.8),
              ),
            )
          : null,
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
                removeEpisode(ep.episode!);
              },
              icon: const Icon(Icons.delete),
              color: Theme.of(context).colorScheme.error,
            ),
          ] else ...[
            IconButton(
              onPressed: () {
                addEpisode(ep.episode!);
              },
              icon: const Icon(Icons.add),
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }
}

class TitleInfo extends StatelessWidget {
  final AnilibriaTitle title;

  const TitleInfo(this.title, {super.key});

  String getSheduleWeekDay(int day) {
    switch (day) {
      case 0:
        return 'каждый понедельник';
      case 1:
        return 'каждый вторник';
      case 2:
        return 'каждую среду';
      case 3:
        return 'каждый четверг';
      case 4:
        return 'каждую пятницу';
      case 5:
        return 'каждую субботу';
      case 6:
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
                  'Найдено в AniLibria',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  title.names?.ru ?? title.names?.en ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (title.season?.weekDay != null &&
                    title.status?.code == TitleStatusCode.inWork)
                  Text(
                    'Выходит ${getSheduleWeekDay(title.season!.weekDay!)}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                if (title.updated != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Обновлено ${title.updated!.convertToDaysAgo()}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            context.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ),
                if (title.announce != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      title.announce!,
                      style: context.textTheme.titleMedium,
                      // style: const TextStyle(
                      //   fontSize: 18,
                      // ),
                    ),
                  ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     const Spacer(),
                //     FilledButton(
                //       onPressed: () {},
                //       child: const Text('Подробнее'),
                //     )
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnilibriaTorrentList extends StatelessWidget {
  final AnilibriaTorrent torrent;

  const AnilibriaTorrentList(this.torrent, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: torrent.torrentlist!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12.0),
      itemBuilder: (context, index) {
        final torrentItem = torrent.torrentlist![index];

        final DateTime? uploadedTs = torrentItem.uploadedTimestamp == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                torrentItem.uploadedTimestamp! * 1000,
              );

        return ListTile(
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
          minVerticalPadding: 0,
          title: Text(
            'Серия ${torrentItem.episodes?.string ?? ''} (${torrentItem.quality?.string})',
            style: const TextStyle(
              fontSize: 14,
              //fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    torrentItem.sizeString ??
                        '${((torrentItem.totalSize ?? 0) / 1073741824).toStringAsFixed(1)} GB',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onBackground.withOpacity(
                        0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_upward_rounded,
                    size: 14,
                    color: Colors.green,
                  ),
                  Text(
                    (torrentItem.seeders ?? 0).toString(),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onBackground.withOpacity(
                        0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_downward_rounded,
                    size: 14,
                    color: Colors.red,
                  ),
                  Text(
                    (torrentItem.leechers ?? 0).toString(),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onBackground.withOpacity(
                        0.8,
                      ),
                    ),
                  ),
                ],
              ),
              if (uploadedTs != null)
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Row(
                    children: [
                      // Icon(
                      //   Icons.update_rounded,
                      //   size: 14,
                      //   color: context.colorScheme.onBackground.withOpacity(
                      //     0.8,
                      //   ),
                      // ),
                      // const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          uploadedTs.convertToDaysAgo(),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onBackground.withOpacity(
                              0.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (torrentItem.magnet != null)
                IconButton(
                  onPressed: () async {
                    try {
                      await launchUrlString(
                        torrentItem.magnet!,
                        mode: LaunchMode.externalNonBrowserApplication,
                      );
                    } on PlatformException {
                      showErrorSnackBar(
                        // ignore: use_build_context_synchronously
                        ctx: context,
                        msg:
                            'Не удалось открыть magnet-ссылку. Отсутствует подходящее приложение',
                        dur: const Duration(seconds: 5),
                      );
                    }
                  },
                  icon: const Icon(
                    FontAwesomeIcons.magnet,
                    size: 18,
                  ),
                ),
              if (torrentItem.url != null)
                IconButton(
                  onPressed: () => launchUrl(
                    Uri.parse(kAnilibriaStaticUrl + torrentItem.url!),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.download_rounded),
                ),
            ],
          ),
        );
      },
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
