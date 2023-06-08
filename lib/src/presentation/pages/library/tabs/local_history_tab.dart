import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../constants/config.dart';
import '../../../../domain/models/pages_extra.dart';
import '../../../../services/anime_database/anime_database_provider.dart';
import '../../../../utils/utils.dart';
import '../../../providers/library_local_history_provider.dart';
import '../../../widgets/error_widget.dart';

class LocalHistoryTab extends ConsumerWidget {
  const LocalHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localHistory = ref.watch(animeLocalHistoryProvider);

    return localHistory.when(
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
          : CustomScrollView(
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
                        ...studios
                            .where((element) => element.episodes!.isNotEmpty)
                      ];

                      studios.sort((a, b) => a.updated!.compareTo(b.updated!));

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

                      return HistoryItem(
                        animeName: anime.animeName ?? '',
                        image: anime.imageUrl ?? '',
                        update: anime.lastUpdate ?? DateTime(2000),
                        studioName: studio.name ?? '',
                        episode: episode,
                        timeStamp: ts,
                        shikimoriId: anime.shikimoriId,
                        studioId: studio.id ?? 0,
                      );
                    },
                  ),
                ),
              ],
            ),
      error: (err, stack) => CustomErrorWidget(
        err.toString(),
        null,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
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
    final time = DateFormat('HH:mm').format(update); //kk
    final date = DateFormat.MMMd().format(update); //MMMEd  MMMMd

    final lastUpdate =
        timeago.format(update, locale: 'ru', allowFromNow: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
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
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100, //120
                    child: AspectRatio(
                      aspectRatio: 0.703,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8), //12
                        child: CachedNetworkImage(
                          imageUrl: AppConfig.staticUrl + image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
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
                        const SizedBox(
                          height: 4,
                        ),
                        Text('$episode серия • $studioName'),
                        if (timeStamp != null) Text(timeStamp!),
                        Text('$date в $time ($lastUpdate)'),
                      ],
                    ),
                  ),
                ],
                // ),
              ),
              Positioned(
                child: InkWell(
                  onTap: () => showSnackBar(
                      ctx: context, msg: 'Удерживайте для удаления'),
                  onLongPress: () => ref
                      .read(animeDatabaseProvider)
                      .deleteEpisode(
                          shikimoriId: shikimoriId,
                          studioId: studioId,
                          episodeNumber: episode!)
                      .then(
                        (value) => showSnackBar(
                            ctx: context, msg: 'Серия $episode удалена'),
                      ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
