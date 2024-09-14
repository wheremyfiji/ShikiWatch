import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../anime365/models/translations.dart';
import '../../../widgets/auto_sliver_animated_list.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/flexible_sliver_app_bar.dart';
import '../../../../domain/enums/anime_source.dart';
import '../../../../domain/models/pages_extra.dart';
import '../../player/domain/player_page_extra.dart' as ppe;
import '../../../widgets/error_widget.dart';
import '../shared/nothing_found.dart';

import 'anime365_provider.dart';

class Anime365StudioSelectPage extends ConsumerWidget {
  const Anime365StudioSelectPage(
    this.extra, {
    super.key,
    required this.episodeId,
    required this.selectedEpisode,
  });

  final AnimeSourcePageExtra extra;
  final int episodeId;
  final int selectedEpisode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studiosAsync = ref.watch(anime365TranslationsProvider(episodeId));

    final studioFilter = ref.watch(anime365StudioFilterProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(anime365TranslationsProvider(episodeId).future),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              FlexibleSliverAppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      extra.animeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Серия $selectedEpisode',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                bottomContent: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: [
                      const SizedBox(
                        width: 8.0,
                      ),
                      ChoiceChip(
                        label: const Text('Все'),
                        selected: studioFilter == Anime365StudioFilter.all,
                        onSelected: (value) => ref
                            .read(anime365StudioFilterProvider.notifier)
                            .state = Anime365StudioFilter.all,
                      ),
                      ChoiceChip(
                        label: const Text('Озвучка'),
                        selected: studioFilter == Anime365StudioFilter.voice,
                        onSelected: (value) => ref
                            .read(anime365StudioFilterProvider.notifier)
                            .state = Anime365StudioFilter.voice,
                      ),
                      ChoiceChip(
                        label: const Text('Субтитры'),
                        selected: studioFilter == Anime365StudioFilter.sub,
                        onSelected: (value) => ref
                            .read(anime365StudioFilterProvider.notifier)
                            .state = Anime365StudioFilter.sub,
                      ),
                      ChoiceChip(
                        label: const Text('RAW'),
                        selected: studioFilter == Anime365StudioFilter.raw,
                        onSelected: (value) => ref
                            .read(anime365StudioFilterProvider.notifier)
                            .state = Anime365StudioFilter.raw,
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                    ],
                  ),
                ),
              ),
              ...studiosAsync.when(
                data: (studiosRaw) {
                  if (studiosRaw.isEmpty) {
                    return [const SourceNothingFound()];
                  }

                  final studiosF =
                      ref.watch(anime365FilteredStudiosProvider(studiosRaw));

                  return [
                    AutoAnimatedSliverList(
                      items: studiosF,
                      itemBuilder: (context, _, index, animation) {
                        final item = studiosF[index];

                        return SizeFadeTransition(
                          animation: animation,
                          child: StudioListItem(
                            item,
                            //onTap: () {},
                            onTap: () {
                              final anime365 = ppe.Anime365Playlist(item);

                              final e = ppe.PlayerPageExtra(
                                titleInfo: ppe.TitleInfo(
                                  shikimoriId: extra.shikimoriId,
                                  animeName: extra.animeName,
                                  imageUrl: extra.imageUrl,
                                ),
                                studio: ppe.Studio(
                                  id: -1,
                                  name: item.authorsSummary,
                                  type: item.kind.name,
                                ),
                                selected: selectedEpisode,
                                animeSource: AnimeSource.anime365,
                                startPosition: '',
                                anilib: null,
                                libria: null,
                                kodik: null,
                                anime365: anime365,
                              );

                              GoRouter.of(context)
                                  .pushNamed('player', extra: e);
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
                      child: Center(child: CircularProgressIndicator())),
                ],
                error: (err, stack) => [
                  SliverFillRemaining(
                    child: CustomErrorWidget(
                      err.toString(),
                      () => ref.invalidate(
                        anime365TranslationsProvider(episodeId),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudioListItem extends StatelessWidget {
  const StudioListItem(
    this.studio, {
    super.key,
    required this.onTap,
  });

  final Anime365Translation studio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        studio.authorsSummary,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Text(
        '${studio.lang.label} • ${studio.kind.label} • ${studio.height}p',
      ),
    );
  }
}
