import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/pages_extra.dart';

import '../../../widgets/error_widget.dart';
import '../shared/nothing_found.dart';
import 'anime365_provider.dart';
import 'anime365_studio_select_page.dart';

class Anime365SourcePage extends ConsumerWidget {
  const Anime365SourcePage(this.extra, {super.key});

  final AnimeSourcePageExtra extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(anime365SearchProvider(extra.shikimoriId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(anime365SearchProvider(extra.shikimoriId).future),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
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
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
              ),
              ...playlistAsync.when(
                data: (relult) {
                  if (relult == null) {
                    return [
                      const SourceNothingFound(),
                    ];
                  }

                  final playlist = relult.episodes;

                  return [
                    SliverList.builder(
                      itemCount: playlist.length,
                      itemBuilder: (context, index) {
                        final item = playlist[index];

                        final isCompleted = item.episodeInt <= extra.epWatched;

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 0, 0, 0),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        Anime365StudioSelectPage(
                                  extra,
                                  episodeId: item.id,
                                  //playlist: playlist,
                                  selectedEpisode: item.episodeInt,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          title: Text('Серия ${item.episodeInt}'),
                          subtitle: item.episodeTitle.isNotEmpty
                              ? Text(item.episodeTitle)
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCompleted)
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.check_circle_rounded),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
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
                          anime365SearchProvider(extra.shikimoriId)),
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
