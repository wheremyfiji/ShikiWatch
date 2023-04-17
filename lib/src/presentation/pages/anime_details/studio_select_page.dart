import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../kodik/kodik.dart';
import '../../../../kodik/models/kodik_anime.dart';
import '../../widgets/error_widget.dart';
import 'series_select_page.dart';

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

  // final int studioId;
  // final int shikimoriId;
  // final int episodeNumber;
  // final String animeName;
  // final String studioName;
  // final String studioType;
  // final String episodeLink;

  // const StudioSelectPage(this.studioId, this.shikimoriId, this.episodeNumber,
  //     this.animeName, this.studioName, this.studioType, this.episodeLink,
  //     {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<KodikAnime> studios = ref.watch(kodikAnimeProvider(shikimoriId));
    // const dateTimeString = '2019-12-21T14:42:45Z';
    // final formattedDate = DateFormat('dd/MM/yyyy - HH:mm')
    //     .format(DateTime.parse(dateTimeString).toLocal());

    return Scaffold(
      body: RefreshIndicator(
        //onRefresh: ref.refresh(studios),
        onRefresh: () async => ref.refresh(kodikAnimeProvider(shikimoriId)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              //pinned: true,
              //floating: false,
              title: const Text('Студия'),
              //title: Text('$animeName • Студия'),
              // expandedHeight: 100.0,
              // flexibleSpace: const FlexibleSpaceBar(
              //   collapseMode: CollapseMode.pin,
              //   background: Center(child: Text('Студия')),
              // ),
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
            studios.when(
              loading: () => const SliverFillRemaining(
                  //hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SliverFillRemaining(
                //hasScrollBody: false,
                child: CustomErrorWidget(err.toString(),
                    () => ref.refresh(kodikAnimeProvider(shikimoriId))),
              ),
              data: (data) {
                if (data.total == 0) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('Ничего не найдено')),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        // data.studio?.sort((a, b) {
                        //   int adate = a.episodesCount!;
                        //   int bdate = b.episodesCount!;
                        //   return -adate.compareTo(bdate);
                        // });

                        data.studio?.sort(
                          (a, b) {
                            final int sortByCourse =
                                -a.episodesCount!.compareTo(b.episodesCount!);
                            if (sortByCourse == 0) {
                              final int sortByName =
                                  -a.updatedAt!.compareTo(b.updatedAt!);
                              //if (sortByName == 0) {
                              //  return a.age.compareTo(b.age);
                              //}
                              return sortByName;
                            }
                            return sortByCourse;
                          },
                        );

                        final KodikStudio? element = data.studio?[index];
                        final dateTimeString = element?.updatedAt;
                        final formattedDate = DateFormat('dd/MM/yyyy - HH:mm')
                            .format(DateTime.parse(dateTimeString!).toLocal());

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              title: Text(
                                element?.name ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                  //color: Colors.white,
                                  fontSize: 16,
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Обновлено: $formattedDate',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 12,
                                  //fontWeight: FontWeight.w300,
                                ),
                              ),
                              trailing: Text(
                                '${element?.episodesCount} эп.',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
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
                                  // MaterialPageRoute(
                                  //   builder: (context) => SeriesSelectPage(
                                  //     seriesList: element?.kodikSeries,
                                  //     studioId: element?.studioId ?? 0,
                                  //     shikimoriId: shikimoriId,
                                  //     episodeWatched: epWatched,
                                  //     animeName: animeName,
                                  //     studioName: element?.name ?? '',
                                  //     studioType: element?.type ?? '',
                                  //     animePic: animePic,
                                  //   ),
                                  // ),
                                );
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => SeriesSelectPage(
                                //       seriesList: element?.kodikSeries,
                                //       epWatched: epWatched,
                                //       animeName: animeName,
                                //       stud: element?.name ?? '',
                                //     ),
                                //   ),
                                // );
                              },
                            ),
                          ),
                        );
                      },
                      childCount: data.total,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// final kodikAnimeProvider =
//     FutureProvider.autoDispose.family<KodikAnime, int>((ref, animeId) async {
//   Map<String, String> headers = {
//     'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
//     'User-Agent':
//         'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36'
//   };

//   final uri = Uri.https(
//     'kodikapi.com',
//     '/search',
//     {'token': kKodikToken, 'shikimori_id': animeId, 'with_episodes': 'true'}
//         .map((key, value) => MapEntry(key, value.toString())),
//   );
//   final response = await http.get(
//     uri,
//     headers: headers,
//   );

//   final statusCode = response.statusCode;

//   if (statusCode != 200) {
//     AppMetrica.reportEvent(
//         '[FATAL] kodikapi search error (anime id: $animeId, code: $statusCode))');
//     throw Exception(
//         'kodikapi search error (anime id: $animeId, code: $statusCode)');
//   }

//   final json = convert.jsonDecode(convert.utf8.decode(response.bodyBytes));

//   final searchResult = KodikSearch.fromJson(json);
//   List<KodikStudio>? studios = [];
//   int counter = 0;

//   try {
//     for (var element in searchResult.results!) {
//       final result = searchResult.results![counter];
//       final seasons = result.seasons;

//       if (seasons != null) {
//         final Map<String, dynamic> temp = seasons[seasons.keys.last]!; //first
//         final Map<String, dynamic> eps = temp['episodes'];

//         List<String> epList = [];

//         for (var epNum = 1; epNum <= eps.length; epNum++) {
//           epList.add('https:${eps[epNum.toString()]}');
//         }

//         studios.add(
//           KodikStudio(
//             id: element.id,
//             shikimoriId: element.shikimoriId,
//             createdAt: element.createdAt ?? '',
//             updatedAt: element.updatedAt ?? '',
//             name: element.translation?.title,
//             episodesCount: element.episodesCount,
//             episodesLinks: epList,
//           ),
//         );
//       } else {
//         List<String> epList = [];
//         epList.add('https:${element.link!}');
//         studios.add(
//           KodikStudio(
//             id: element.id,
//             shikimoriId: element.shikimoriId,
//             createdAt: element.createdAt ?? '',
//             updatedAt: element.updatedAt ?? '',
//             name: element.translation?.title,
//             episodesCount: element.episodesCount ?? 1,
//             episodesLinks: epList,
//           ),
//         );
//       }

//       counter++;
//     }
//   } catch (e) {
//     AppMetrica.reportEvent(
//         '[FATAL] kodikapi search result parse error (anime id: $animeId))');
//     throw Exception('kodikapi search result parse error (anime id: $animeId)');
//   }

//   final KodikAnime anime = KodikAnime(
//     time: searchResult.time,
//     total: searchResult.total,
//     studio: studios,
//   );

//   return anime;
// }, name: 'kodikAnimeProvider');