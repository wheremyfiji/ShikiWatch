import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../anilibria/enums/title_status_code.dart';
import '../../../../../anilibria/models/title.dart';
import '../../../../domain/models/anime_database.dart';
import '../../../../domain/models/anime_player_page_extra.dart';
import '../../../../services/anime_database/anime_database_provider.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/extensions/date_time_ext.dart';
import '../../../../utils/utils.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../widgets/error_widget.dart';

import '../../player/continue_dialog.dart';
import 'kodik_source_page.dart';
import 'providers.dart';

class AnilibriaSourcePage extends ConsumerWidget {
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

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
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
                      //icon: const Icon(Icons.info),
                      title: const Text('Информация'),
                      content: const Text(
                        'Поиск производится по названию через API АниЛибрии. Результат может НЕ совпадать с искомым аниме.\n\nНайденные серии связаны с озвучкой от Анилибрии в других источниках.',
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
                  TitlePlaylist(
                    title: title,
                    shikimoriId: shikimoriId,
                    epWatched: epWatched,
                    animeName: animeName,
                    imageUrl: imageUrl,
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

class TitlePlaylist extends ConsumerWidget {
  final AnilibriaTitle title;
  final int shikimoriId;
  final int epWatched;
  final String animeName;
  final String imageUrl;

  const TitlePlaylist({
    super.key,
    required this.title,
    required this.shikimoriId,
    required this.epWatched,
    required this.animeName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anime = ref.watch(isAnimeInDataBaseProvider(shikimoriId));

    List<Episode>? episodesList() => anime.maybeWhen(
          data: (anime) {
            // возврящает -1 если элемент не найден
            final studioIndex = anime?.studios
                ?.indexWhere((e) => (e.id == 610 && e.name == 'AniLibria.TV'));

            // если такой студии нету
            if (studioIndex == -1) {
              return null;
            }

            final studio = anime?.studios?[studioIndex!];

            return studio?.episodes;
          },
          orElse: () => null,
        );

    void addEpisode(int episode) async {
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

    void removeEpisode(int episode) async {
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

    return SliverList.builder(
      itemCount: title.player!.playlist!.length,
      itemBuilder: (context, index) {
        final ep = title.player!.playlist![index];

        final savedEpList = episodesList();

        final savedEpIndex =
            savedEpList?.indexWhere((e) => e.nubmer == ep.episode);

        final Episode? savedEpisode;

        if (savedEpIndex == -1) {
          savedEpisode = null;
        } else {
          savedEpisode = savedEpList?[savedEpIndex!];
        }

        final isCompleted = ep.episode! <= epWatched;

        return ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
          onTap: () async {
            if (ep.hls == null || (ep.hls?.fhd == null && ep.hls?.hd == null)) {
              showErrorSnackBar(ctx: context, msg: 'Серия не найдена');

              return;
            }

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

            AnimePlayerPageExtra extra = AnimePlayerPageExtra(
              studioId: 610,
              shikimoriId: shikimoriId,
              episodeNumber: ep.episode!,
              animeName: animeName,
              studioName: 'AniLibria.TV',
              studioType: 'voice',
              episodeLink: '',
              additInfo: '',
              position: savedEpisode?.position,
              imageUrl: imageUrl,
              startPosition: startPosition,
              isLibria: true,
              libriaEpisode: LibriaEpisode(
                host: 'https://${title.player!.host!}',
                fnd: ep.hls?.fhd,
                hd: ep.hls?.hd,
              ),
            );

            // ignore: use_build_context_synchronously
            GoRouter.of(context).pushNamed('player', extra: extra);
          },
          title: Text(
            'Серия ${ep.episode}',
          ),
          subtitle: savedEpisode != null && savedEpisode.timeStamp != null
              ? Text(
                  savedEpisode.timeStamp!,
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
      },
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
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      sliver: SliverToBoxAdapter(
        child: Card(
          shadowColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
