import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/pages_extra.dart';
import '../../../widgets/error_widget.dart';
import '../shared/nothing_found.dart';

import 'anilib_studio_select_page.dart';
import 'anilib_source_controller.dart';

class AnilibSourcePage extends ConsumerWidget {
  const AnilibSourcePage(this.extra, {super.key});

  final AnimeSourcePageExtra extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AnilibNotifierParameters(extra);

    final playlistAsync = ref.watch(
      anilibSourceProvider(p).select((v) => v.playlistAsync),
    ); //  controller

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(anilibSourceProvider(p)),
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
                data: (playlist) {
                  if (playlist.isEmpty) {
                    return [
                      const SourceNothingFound(),
                    ];
                  }

                  return [
                    SliverList.builder(
                      itemCount: playlist.length,
                      itemBuilder: (context, index) {
                        final item = playlist[index];

                        final isCompleted = item.number <= extra.epWatched;

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 0, 0, 0),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        AnilibStudioSelectPage(
                                  extra,
                                  episodeId: item.id,
                                  playlist: playlist,
                                  selectedEpisode: item.number,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          title: Text('Серия ${item.number}'),
                          subtitle:
                              item.name.isNotEmpty ? Text(item.name) : null,
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
                      () => ref.invalidate(anilibSourceProvider(p)),
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
