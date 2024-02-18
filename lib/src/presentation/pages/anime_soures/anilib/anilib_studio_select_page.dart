import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/pages_extra.dart';
import '../../../../../anime_lib/models/models.dart';
import '../../../../../anime_lib/enums/enums.dart';
import '../../../../../anime_lib/anilib_api.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/error_widget.dart';
import '../shared/compact_info_chip.dart';

import '../shared/nothing_found.dart';
import 'anilib_source_controller.dart';

class AnilibStudioSelectPage extends ConsumerWidget {
  const AnilibStudioSelectPage(
    this.extra, {
    super.key,
    required this.episodeId,
  });

  final AnimeSourcePageExtra extra;
  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studiosAsync = ref.watch(anilibEpisodeProvider(episodeId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(anilibEpisodeProvider(episodeId).future),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
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
                      'Серия 1',
                      //studioName.replaceFirst('.Subtitles', ' (Субтитры)'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ...studiosAsync.when(
                data: (studios) {
                  if (studios.players.isEmpty) {
                    return [const SourceNothingFound()];
                  }

                  return [
                    SliverList.builder(
                      itemCount: studios.players.length,
                      itemBuilder: (context, index) {
                        final item = studios.players[index];

                        return StudioListItem(item);
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
                      () => ref.invalidate(
                        anilibEpisodeProvider(episodeId),
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
  const StudioListItem(this.item, {super.key});

  final AnilibPlayer item;

  @override
  Widget build(BuildContext context) {
    // final subtitle =
    //     '${item.translationType.name} / ${item.video[0].quality.toShort}';

    return ListTile(
      onTap: () {
        final videoLink = AnilibUtils.kVideoHosts[0] + item.video[0].href;

        print('LINK: $videoLink');

        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => PlayerPage(videoLink: videoLink),
        //   ),
        // );
      },
      leading: CachedCircleImage(
        item.team.teamCover,
        httpHeaders: const {
          'Referer': 'https://test-front.anilib.me/',
          'User-Agent': AnilibUtils.kUserAgent,
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              item.team.name.replaceFirst('.Subtitles', ''),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          if (item.translationType == TranslationType.sub)
            const CompactInfoChip(
              'Субтитры',
            ),
        ],
      ),
      //subtitle: Text(subtitle),
      trailing: CompactInfoChip(item.video[0].quality.toShort),
    );
  }
}
