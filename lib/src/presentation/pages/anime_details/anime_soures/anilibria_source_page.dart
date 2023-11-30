import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../anilibria/anilibria_api.dart';
import '../../../../../anilibria/enums/title_status_code.dart';
import '../../../../../anilibria/models/title.dart';
import '../../../../domain/enums/anime_source.dart';
import '../../../../domain/models/anime_database.dart';
import '../../../../domain/models/anime_player_page_extra.dart' as appe;
import '../../../../services/anime_database/anime_database_provider.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/extensions/date_time_ext.dart';
import '../../../../utils/app_utils.dart';
import '../../../hooks/use_auto_scroll_controller.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../widgets/error_widget.dart';

import '../../player/continue_dialog.dart';
import 'kodik_source_page.dart';
import 'providers.dart';

class AnilibriaSourcePage extends HookConsumerWidget {
  final int shikimoriId;
  final int epWatched;
  final String animeName;
  final String searchName;
  final String imageUrl;

  const AnilibriaSourcePage({
    super.key,
    required this.shikimoriId,
    required this.epWatched,
    required this.animeName,
    required this.searchName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(anilibriaSearchProvider(searchName));
    final anime = ref.watch(isAnimeInDataBaseProvider(shikimoriId));

    void addEpisode(int episode) {
      ref
          .read(animeDatabaseProvider)
          .updateEpisode(
            shikimoriId: shikimoriId,
            animeName: animeName,
            imageUrl: imageUrl,
            timeStamp: 'Просмотрено полностью',
            studioId: 610,
            studioName: 'AniLibria.TV',
            studioType: 'voice',
            episodeNumber: episode,
            complete: true,
          )
          .then((_) {
        showSnackBar(ctx: context, msg: 'Серия $episode добавлена');
        return ref.refresh(isAnimeInDataBaseProvider(shikimoriId));
      });
    }

    void removeEpisode(int episode) {
      ref
          .read(animeDatabaseProvider)
          .deleteEpisode(
            shikimoriId: shikimoriId,
            studioId: 610,
            episodeNumber: episode,
          )
          .then((value) {
        showSnackBar(ctx: context, msg: 'Серия $episode удалена');
        return ref.refresh(isAnimeInDataBaseProvider(shikimoriId));
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

      final latestEpisode = episodesList?.last;

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

    List<appe.PlaylistItem> p(List<AnilibriaEpisode> playlist, String host) {
      List<appe.PlaylistItem> t = [];

      for (var e in playlist) {
        t.add(appe.PlaylistItem(
          episodeNumber: e.episode ?? -1,
          link: null,
          libria: appe.LibriaEpisode(
            //host: 'https://static.libria.fun',
            host: host,
            fnd: e.hls!.fhd,
            hd: e.hls!.hd,
            sd: e.hls!.sd,
          ),
          name: e.name,
        ));
      }

      return t;
    }

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
                animeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  color: context.theme.colorScheme.onBackground,
                ),
              ),
              pinned: true,
              actions: [
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
                      child: NothingFound(
                        shikimoriId: shikimoriId,
                        epWatched: epWatched,
                        animeName: animeName,
                        searchName: searchName,
                        imageUrl: imageUrl,
                      ),
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

                      final isCompleted = ep.episode! <= epWatched;

                      return AutoScrollTag(
                        controller: autoScrollController,
                        key: ValueKey(index),
                        index: index,
                        child: AnilibriaEpisodeTile(
                          ep: ep,
                          savedEpisode: savedEpisode,
                          isCompleted: isCompleted,
                          host: 'https://${title.player!.host!}',
                          shikimoriId: shikimoriId,
                          epWatched: epWatched,
                          animeName: animeName,
                          imageUrl: imageUrl,
                          removeEpisode: (e) => removeEpisode(e),
                          addEpisode: (e) => addEpisode(e),
                          onTap: () async {
                            String startPosition = '';

                            if (savedEpisode?.position != null) {
                              bool? dialogValue = await showDialog<bool>(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => const ContinueDialog(),
                              );

                              if (dialogValue ?? false) {
                                startPosition = savedEpisode?.position ?? '';
                              }
                            }

                            final e = appe.PlayerPageExtra(
                              selected: ep.episode!,
                              info: appe.TitleInfo(
                                shikimoriId: shikimoriId,
                                animeName: animeName,
                                imageUrl: imageUrl,
                                studioId: 610,
                                studioName: 'AniLibria.TV',
                                studioType: 'voice',
                                additInfo: null,
                              ),
                              animeSource: AnimeSource.libria,
                              startPosition: startPosition,
                              playlist: p(
                                title.player!.playlist!,
                                //'https://${title.player!.host!}',
                                'https://static.libria.fun',
                              ),
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
                    () => ref.refresh(anilibriaSearchProvider(searchName)),
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
      // onTap: () async {
      //   if (ep.hls == null || (ep.hls?.fhd == null && ep.hls?.hd == null)) {
      //     showErrorSnackBar(ctx: context, msg: 'Серия не найдена');

      //     return;
      //   }

      //   String startPosition = '';

      //   if (savedEpisode?.position != null) {
      //     bool? dialogValue = await showDialog<bool>(
      //       barrierDismissible: false,
      //       context: context,
      //       builder: (context) => const ContinueDialog(),
      //     );

      //     if (dialogValue ?? false) {
      //       startPosition = savedEpisode?.position ?? '';
      //     }
      //   }

      //   // AnimePlayerPageExtra extra = AnimePlayerPageExtra(
      //   //   studioId: 610,
      //   //   shikimoriId: shikimoriId,
      //   //   episodeNumber: ep.episode!,
      //   //   animeName: animeName,
      //   //   studioName: 'AniLibria.TV',
      //   //   studioType: 'voice',
      //   //   episodeLink: '',
      //   //   additInfo: '',
      //   //   position: savedEpisode?.position,
      //   //   imageUrl: imageUrl,
      //   //   startPosition: startPosition,
      //   //   isLibria: true,
      //   //   libriaEpisode: LibriaEpisode(
      //   //     //host: 'https://${title.player!.host!}',
      //   //     host: AppUtils.instance.isDesktop
      //   //         ? 'https://static.libria.fun'
      //   //         : host,
      //   //     fnd: ep.hls?.fhd,
      //   //     hd: ep.hls?.hd,
      //   //   ),
      //   // );

      //   // // ignore: use_build_context_synchronously
      //   // GoRouter.of(context).pushNamed('player', extra: extra);
      // },
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
                              0.8,
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
                      // ignore: use_build_context_synchronously
                      showErrorSnackBar(
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
  final int shikimoriId;
  final int epWatched;
  final String animeName;
  final String searchName;
  final String imageUrl;

  const NothingFound({
    super.key,
    required this.shikimoriId,
    required this.epWatched,
    required this.animeName,
    required this.searchName,
    required this.imageUrl,
  });

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
                        KodikSourcePage(
                      shikimoriId: shikimoriId,
                      animeName: animeName,
                      searchName: searchName,
                      epWatched: epWatched,
                      imageUrl: imageUrl,
                    ),
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
