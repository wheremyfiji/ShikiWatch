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
        if (context.mounted) {
          GoRouter.of(context).removeListener(watchRouteChange);
        }
      }
    }

    final sortedSeriesList = ref.watch(seriesSortProvider(seriesList!));
    final currentSort = ref.watch(episodeSortTypeProvider);

    return Scaffold(
      // floatingActionButton: FloatingActionButton.large(onPressed: () {
      //   scrollToIndex;
      // }),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.refresh(isAnimeInDataBaseProvider(shikimoriId)),
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
              //title: const Text('Серия'),
              //title: Text(widget.stud ?? 'Серия'),
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              sliver: SliverList(
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
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          onTap: () async {
                            String sp = '';
                            if (!TargetP.instance.isDesktop &&
                                episode?.position != null) {
                              bool? dialogValue = await showDialog<bool>(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => const ContinueDialog(),
                              );

                              if (dialogValue ?? false) {
                                sp = episode?.position ?? '';
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
                              startPosition: sp,
                            );

                            // ignore: use_build_context_synchronously
                            GoRouter.of(context)
                                .pushNamed('player', extra: data);
                            // ignore: use_build_context_synchronously
                            GoRouter.of(context).addListener(watchRouteChange);
                          }, //запись в бд
                          //title: Text("Серия ${reversedIndex + 1}"),
                          //title: Text("Серия ${seria!.name}"),
                          title: seria.type != null
                              ? Text("Серия ${seria.number} (${seria.type})")
                              : Text("Серия ${seria.number}"),
                          //subtitle: const Text('Просморено до 27:54'),
                          subtitle: episode != null
                              ? Text(episode.timeStamp ?? '')
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // if (episode != null) ...[
                              //   episode.isComplete!
                              //       ? IconButton(
                              //           onPressed: () {},
                              //           icon: const Icon(Icons.check_circle_rounded),
                              //           color: Theme.of(context).colorScheme.primary,
                              //         )
                              //       :
                              //       // Icon(
                              //       //     Icons.done,
                              //       //     color: Theme.of(context).colorScheme.primary,
                              //       //   ),
                              //       IconButton(
                              //           onPressed: () {
                              //             addEpisode(int.parse(seria.number ?? ''));
                              //           },
                              //           icon: const Icon(Icons.done),
                              //           color: context.colorScheme.onSurfaceVariant,
                              //         ),
                              // ],
                              if (episode != null && !isComp) ...[
                                // Icon(
                                //   Icons.done,
                                //   color: Theme.of(context).colorScheme.primary,
                                // ),
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
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? Colors.red.shade200
                                      : Colors.red.shade600,
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
                              // IconButton(
                              //   onPressed: () {},
                              //   icon: const Icon(Icons.more_vert),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: sortedSeriesList.length, // 1000 list items
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  _sortBottomSheet(BuildContext context,
      Function(EpisodeSortType type) setSortType, EpisodeSortType currentSort) {
    return showModalBottomSheet(
      useRootNavigator: true,
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                // ListTile(
                //   title: const Text(
                //     'По старым',
                //     style: TextStyle(
                //       fontWeight: FontWeight.normal,
                //     ),
                //   ),
                //   onTap: () => setSortType(EpisodeSortType.oldest),
                // ),
                // ListTile(
                //   title: const Text('По новым'),
                //   onTap: () => setSortType(EpisodeSortType.newest),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// class SeriesSelectPage extends StatefulWidget {
//   final List<KodikSeries>? seriesList;

//   // final int? epWatched;
//   // final String? animeName;
//   // final String? stud;

//   final int studioId;
//   final int shikimoriId;
//   final int episodeNumber;
//   final String animeName;
//   final String studioName;
//   final String studioType;
//   final String episodeLink;

//   const SeriesSelectPage(
//       {super.key,
//       this.seriesList,
//       required this.studioId,
//       required this.shikimoriId,
//       required this.episodeNumber,
//       required this.animeName,
//       required this.studioName,
//       required this.studioType,
//       required this.episodeLink});

//   // studioId: studioId,
//   // shikimoriId: shikimoriId,
//   // episodeNumber: episodeNumber,
//   // animeName: animeName,
//   // studioName: studioName,
//   // studioType: studioType,
//   // episodeLink: episodeLink

//   // const SeriesSelectPage(
//   //     {super.key,
//   //     required this.seriesList,
//   //     required this.epWatched,
//   //     required this.animeName,
//   //     required this.stud});

//   @override
//   State<SeriesSelectPage> createState() => _SeriesSelectPageState();
// }

// class _SeriesSelectPageState extends State<SeriesSelectPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar.large(
//             actions: [
//               IconButton(
//                 onPressed: () {
//                   _sortBottomSheet(context);
//                 },
//                 icon: const Icon(Icons.filter_list),
//               ),
//             ],
//             title: const Text('Серия'),
//             //title: Text(widget.stud ?? 'Серия'),
//             //title: Text('${widget.animeName} • ${widget.stud}'),
//           ),
//           // SliverPinnedHeader(
//           //   child: Padding(
//           //     padding: const EdgeInsets.all(8.0),
//           //     child: Card(
//           //       shadowColor: Colors.transparent,
//           //       child: Padding(
//           //         padding: const EdgeInsets.all(16.0),
//           //         child: Column(
//           //           children: [Text('${widget.animeName} • ${widget.stud}')],
//           //         ),
//           //       ),
//           //     ),
//           //   ),
//           // ),
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (BuildContext context, int index) {
//                 //int itemCount = seriesList?.length ?? 0;
//                 //int reversedIndex = itemCount - 1 - index;
//                 int reversedIndex = index;
//                 final seria = widget.seriesList?[reversedIndex];
//                 final isComp = reversedIndex < widget.epWatched!;
//                 return ListTile(
//                   onTap: () {
//                     // context.pushNamed(
//                     //   'player',
//                     //   params: {
//                     //     'link': seria.link ?? '',
//                     //     'name': widget.animeName ?? '',
//                     //     //'ep': widget.epWatched!.toString(),
//                     //     'ep': '${reversedIndex + 1}'
//                     //   },
//                     AnimePlayerPageExtra data = AnimePlayerPageExtra(
//                         studioId: studioId,
//                         shikimoriId: shikimoriId,
//                         episodeNumber: episodeNumber,
//                         animeName: animeName,
//                         studioName: studioName,
//                         studioType: studioType,
//                         episodeLink: episodeLink);
//                     context.pushNamed("player", extra: data);
//                   }, //запись в бд
//                   //title: Text("Серия ${reversedIndex + 1}"),
//                   //title: Text("Серия ${seria!.name}"),
//                   title: seria!.type != null
//                       ? Text("Серия ${seria.number} (${seria.type})")
//                       : Text("Серия ${seria.number}"),
//                   //subtitle: const Text('Просморено до 27:54'),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (isComp) ...[
//                         Icon(
//                           Icons.done,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                       ],
//                       IconButton(
//                         onPressed: () {},
//                         icon: const Icon(Icons.more_vert),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               childCount: widget.seriesList?.length, // 1000 list items
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   _sortBottomSheet(BuildContext context
//       //, Function(EpisodeSortType type) setSortType
//       ) {
//     return showModalBottomSheet(
//       useRootNavigator: true,
//       //isDismissible: false,
//       context: context,
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Container(
//             margin: const EdgeInsets.all(16),
//             child: Column(
//               //crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 //const Text('Выбор сортировки списка'),
//                 ListTile(
//                   title: Text(
//                     'Сортировка списка серий',
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onTap: () {
//                     context.pop();
//                   },
//                   //onTap: () => setSortType(EpisodeSortType.newest),
//                 ),
//                 ListTile(
//                   title: const Text(
//                     'От новых к старым',
//                     style: TextStyle(
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                   onTap: () {
//                     context.pop();
//                   },
//                   trailing: const Icon(Icons.check),
//                   //onTap: () => setSortType(EpisodeSortType.newest),
//                 ),
//                 ListTile(
//                   selected: true,
//                   title: const Text('От старых к новым'),
//                   onTap: () {
//                     context.pop();
//                   },
//                   // onTap: () => setSortType(EpisodeSortType.oldest),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
