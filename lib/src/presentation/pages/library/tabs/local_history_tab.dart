import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../constants/config.dart';
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
                  'В истории пусто', //'В истории пусто. Надо чето посмотреть..',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 16),
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  //sliver: SliverFixedExtentList(
                  sliver: SliverList(
                    //itemExtent: 180.0,
                    delegate: SliverChildBuilderDelegate(
                      childCount: data.length,
                      (BuildContext context, int index) {
                        final anime = data[index];

                        var studios = anime.studios;

                        if (studios == null || studios.isEmpty) {
                          return null;
                        }

                        studios = [
                          ...studios
                              .where((element) => element.episodes!.isNotEmpty)
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

                        //if (studio.episodes!.isNotEmpty) {
                        episode = studio.episodes?.last.nubmer ?? 0;
                        final ts = studio.episodes?.last.timeStamp;
                        //}
                        //final episode = studio.episodes?.last.nubmer;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                          child: HistoryItem(
                            animeName: anime.animeName ?? '',
                            image: anime.imageUrl ?? '',
                            update: anime.lastUpdate ?? DateTime(2000),
                            studioName: studio.name ?? '',
                            episode: episode,
                            timeStamp: ts,
                          ),
                        );
                      },
                    ),
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

// List months = [
//   'янв.',
//   'февр.',
//   'мар.',
//   'апр.',
//   'мая',
//   'июн.',
//   'июл.',
//   'авг.',
//   'сент.',
//   'окт.',
//   'нояб.',
//   'дек.'
// ];

class HistoryItem extends StatelessWidget {
  final String animeName;
  final String image;
  final DateTime update;
  final String studioName;
  final int? episode;
  final String? timeStamp;

  const HistoryItem({
    super.key,
    required this.animeName,
    required this.image,
    required this.update,
    required this.studioName,
    required this.episode,
    required this.timeStamp,
  });

  @override
  Widget build(BuildContext context) {
    //String formattedDate = DateFormat('yyyy-MM-dd в kk:mm').format(update);
    //final current_mon = update.month;
    //final day = update.day;
    //final monthName = months[update.month - 1];
    final time =
        //update.hour;
        DateFormat('HH:mm').format(update); //kk
    final date = DateFormat.MMMd().format(update); //MMMEd  MMMMd
    return
        //InkWell(
        //  onTap: () {},
        //  child:
        Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: AspectRatio(
            aspectRatio: 0.703,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ExtendedImage.network(
                AppConfig.staticUrl + image,
                fit: BoxFit.cover,
                cache: true,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text('$episode серия • $studioName'),

              if (timeStamp != null) ...[
                const SizedBox(
                  height: 2,
                ),
                Text(timeStamp!)
              ],
              const SizedBox(
                height: 2,
              ),
              Text('$date в $time'),
              //Text('$day $monthName в $time'),
              // Text('Студия: $studioName'),
              // Text('Последний эпизод: $episode'),
              // Text('Обновлено $formattedDate'),
            ],
          ),
        ),
      ],
      // ),
    );
  }
}
