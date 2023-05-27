import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shikidev/src/presentation/widgets/image_with_shimmer.dart';
import 'package:shikidev/src/utils/extensions/riverpod_extensions.dart';

import '../../../constants/config.dart';
import '../../../data/data_sources/anime_data_src.dart';
import '../../../domain/models/shiki_calendar.dart';
import '../../widgets/error_widget.dart';

final calendarProvider =
    FutureProvider.autoDispose<List<ShikiCalendar>>((ref) async {
  final token = ref.cancelToken();
  final ds = ref.read(animeDataSourceProvider);
  final r = await ds.getCalendar(cancelToken: token);
  return r.toList();
}, name: 'calendarProvider');

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendar = ref.watch(calendarProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text(
              'Календарь',
            ),
          ),
          ...calendar.when(
            data: (data) => [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = data[index];
                      return CalendarItem(item);
                    },
                    childCount: data.length,
                  ),
                ),
              ),
            ],
            error: (err, stack) => [
              SliverFillRemaining(
                child: CustomErrorWidget(
                  err.toString(),
                  () => ref.refresh(calendarProvider),
                ),
              ),
            ],
            loading: () => [
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CalendarItem extends StatelessWidget {
  final ShikiCalendar item;

  const CalendarItem(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final nextEpisodeAt =
        DateTime.tryParse(item.nextEpisodeAt ?? '')?.toLocal() ??
            DateTime(1970);
    final nextEpisodeDate = DateFormat.MMMd().format(nextEpisodeAt);
    final nextEpisodeTime = DateFormat.Hm().format(nextEpisodeAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.pushNamed(
          'explore_id',
          pathParameters: <String, String>{
            'id': (item.anime?.id!).toString(),
          },
          extra: item.anime,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageWithShimmerWidget(
                imageUrl: AppConfig.staticUrl +
                    (item.anime?.image?.original ??
                        item.anime?.image?.preview ??
                        ''),
                height: 120,
                width: 84,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item.anime?.russian == ''
                            ? item.anime?.name
                            : item.anime?.russian) ??
                        '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text('Серия ${item.nextEpisode}'),
                  const SizedBox(
                    height: 2,
                  ),
                  // Text('Выйдет: ${item.nextEpisodeAt}'),
                  Text('Выйдет $nextEpisodeDate в $nextEpisodeTime'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text((item.anime?.russian == ''
                ? item.anime?.name
                : item.anime?.russian) ??
            ''),
        const SizedBox(
          height: 4,
        ),
        Text('Серия: ${item.nextEpisode}'),
        const SizedBox(
          height: 4,
        ),
        Text('Выйдет: ${item.nextEpisodeAt}'),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
