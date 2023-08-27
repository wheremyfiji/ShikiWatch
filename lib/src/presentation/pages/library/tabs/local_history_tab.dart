import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../services/anime_database/anime_database_provider.dart';
import '../../../providers/library_local_history_provider.dart';
import '../../../../utils/extensions/date_time_ext.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/pages_extra.dart';
import '../../../widgets/automatic_keep_alive.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/error_widget.dart';
import '../../../../constants/config.dart';
import '../../../../utils/utils.dart';

class LocalHistoryTab extends ConsumerWidget {
  const LocalHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localHistory = ref.watch(animeLocalHistoryProvider);

    return ExtendedVisibilityDetector(
      uniqueKey: const Key('LocalHistoryTab'),
      child: localHistory.when(
        data: (data) => data.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'В истории пусто',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontSize: 16),
                  ),
                ),
              )
            : AutoKeepAlive(
                child: CustomScrollView(
                  key: const PageStorageKey<String>('LocalHistoryTab'),
                  slivers: [
                    const SliverPadding(
                      padding: EdgeInsets.only(top: 16.0),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: data.length,
                        (context, index) {
                          final anime = data[index];

                          var studios = anime.studios;

                          if (studios == null || studios.isEmpty) {
                            return null;
                          }

                          studios = [
                            ...studios.where(
                                (element) => element.episodes!.isNotEmpty)
                          ];

                          studios
                              .sort((a, b) => a.updated!.compareTo(b.updated!));

                          if (studios.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final studio = studios.last;

                          int episode = 0;

                          if (studio.episodes!.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          episode = studio.episodes?.last.nubmer ?? 0;
                          final ts = studio.episodes?.last.timeStamp;

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: HistoryItem(
                              animeName: anime.animeName ?? '',
                              image: anime.imageUrl ?? '',
                              update: anime.lastUpdate ?? DateTime(2000),
                              studioName: studio.name ?? '',
                              episode: episode,
                              timeStamp: ts,
                              shikimoriId: anime.shikimoriId,
                              studioId: studio.id ?? 0,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
        error: (err, stack) => CustomErrorWidget(
          err.toString(),
          null,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class HistoryItem extends ConsumerWidget {
  final String animeName;
  final String image;
  final DateTime update;
  final String studioName;
  final int? episode;
  final String? timeStamp;
  final int shikimoriId;
  final int studioId;

  const HistoryItem({
    super.key,
    required this.animeName,
    required this.image,
    required this.update,
    required this.studioName,
    required this.episode,
    required this.timeStamp,
    required this.shikimoriId,
    required this.studioId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onLongPress: () {
          DeleteFromHistoryBottomSheet.show(
            context: context,
            titleName: animeName,
            episode: episode,
            onDelete: () => ref
                .read(animeDatabaseProvider)
                .deleteEpisode(
                  shikimoriId: shikimoriId,
                  studioId: studioId,
                  episodeNumber: episode!,
                )
                .then(
                  (_) =>
                      showSnackBar(ctx: context, msg: 'Серия $episode удалена'),
                ),
          );
        },
        onTap: () {
          final extra = AnimeDetailsPageExtra(
            id: shikimoriId,
            label: animeName,
          );

          context.pushNamed(
            'library_anime',
            pathParameters: <String, String>{
              'id': shikimoriId.toString(),
            },
            extra: extra,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 100, //120
                  child: AspectRatio(
                    aspectRatio: 0.703,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedImage(
                        AppConfig.staticUrl + image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$episode серия • $studioName',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
                  if (timeStamp != null)
                    Text(
                      timeStamp!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    //'$date в $time ($lastUpdate)',
                    update.convertToDaysAgo(),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteFromHistoryBottomSheet extends StatelessWidget {
  final String titleName;
  final int? episode;
  final Function() onDelete;

  const DeleteFromHistoryBottomSheet({
    super.key,
    required this.titleName,
    this.episode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            titleName,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          color: context.colorScheme.secondaryContainer,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.info_rounded,
                    color: context.colorScheme.onSecondaryContainer,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Серия $episode будет удалена из истории просмотра',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        //   child: Text(
        //     'Серия $episode будет удалена из истории просмотра',
        //     maxLines: 2,
        //     overflow: TextOverflow.ellipsis,
        //     style: TextStyle(
        //       fontSize: 14,
        //       color: context.colorScheme.onBackground.withOpacity(0.8),
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              style: FilledButton.styleFrom(
                backgroundColor: context.colorScheme.error,
                foregroundColor: context.colorScheme.onError,
              ),
              icon: const Icon(Icons.delete),
              label: const Text('Удалить серию'),
            ),
          ),
        ),
      ],
    );
  }

  static void show({
    required BuildContext context,
    required String titleName,
    int? episode,
    required Function() onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      useRootNavigator: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
      ),
      builder: (_) => SafeArea(
        child: DeleteFromHistoryBottomSheet(
          titleName: titleName,
          episode: episode,
          onDelete: onDelete,
        ),
      ),
    );
  }
}
