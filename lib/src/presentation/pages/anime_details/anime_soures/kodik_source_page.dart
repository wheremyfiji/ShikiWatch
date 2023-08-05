import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'anilibria_source_page.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../../kodik/kodik.dart';
import '../../../../../kodik/models/kodik_anime.dart';
import '../../../../utils/utils.dart';
import '../../../widgets/error_widget.dart';
import 'kodik_series_select_page.dart';

import 'latest_studio.dart';
import 'providers.dart';

class KodikSourcePage extends ConsumerWidget {
  final int shikimoriId;
  final int epWatched;
  final String animeName;
  final String searchName;
  final String imageUrl;

  const KodikSourcePage({
    super.key,
    required this.shikimoriId,
    required this.epWatched,
    required this.animeName,
    required this.searchName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<KodikAnime> studios = ref.watch(kodikAnimeProvider(shikimoriId));
    final latestStudio = ref.watch(latestStudioProvider(shikimoriId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(kodikAnimeProvider(shikimoriId).future),
        child: SafeArea(
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
                      }
                    },
                  ),
                ],
              ),
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
                                pageBuilder:
                                    (context, animation1, animation2) =>
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
                        return const SliverToBoxAdapter(
                            child: SizedBox.shrink());
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
                              .format(
                                  DateTime.parse(dateTimeString!).toLocal());

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
      ),
    );
  }
}
