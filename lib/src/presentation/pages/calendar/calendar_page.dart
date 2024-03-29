import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../utils/extensions/buildcontext.dart';
import '../../../utils/extensions/date_time_ext.dart';
import '../../../utils/extensions/riverpod_extensions.dart';
import '../../../utils/extensions/string_ext.dart';
import '../../../data/data_sources/anime_data_src.dart';
import '../../../domain/models/shiki_calendar.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/error_widget.dart';

final calendarProvider =
    FutureProvider.autoDispose<Map<DateTime, List<ShikiCalendar>>>((ref) async {
  final token = ref.cancelToken();
  final ds = ref.read(animeDataSourceProvider);
  final r = await ds.getCalendar(cancelToken: token);

  Map<DateTime, List<ShikiCalendar>> groupedData = _groupDataByDay(r.toList());

  return groupedData;
}, name: 'calendarProvider');

Map<DateTime, List<ShikiCalendar>> _groupDataByDay(
    List<ShikiCalendar> dataModels) {
  Map<DateTime, List<ShikiCalendar>> groupedData = {};

  for (var model in dataModels) {
    DateTime date = DateTime(model.nextEpisodeDateTime!.year,
        model.nextEpisodeDateTime!.month, model.nextEpisodeDateTime!.day);

    if (groupedData.containsKey(date)) {
      groupedData[date]!.add(model);
    } else {
      groupedData[date] = [model];
    }
  }

  return groupedData;
}

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendar = ref.watch(calendarProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(calendarProvider),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: const Text(
                  'Календарь релизов',
                ),
              ),
              ...calendar.when(
                data: (data) => [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final date = data.keys.toList()[index];
                        final dateString =
                            '${DateFormat.EEEE().format(date)}, ${DateFormat.MMMd().format(date)}';
                        final items = data[date]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Text(
                                date.isToday()
                                    ? 'Сегодня'
                                    : dateString.capitalizeFirst!,
                                style: context.textTheme.bodyLarge,
                              ),
                            ), // Выходит или вышло сегодня
                            SizedBox(
                              height: 210,
                              child: ListView.builder(
                                addRepaintBoundaries: false,
                                addSemanticIndexes: false,
                                shrinkWrap: true,
                                itemCount: items.length,
                                scrollDirection: Axis.horizontal,
                                // separatorBuilder: (context, index) {
                                //   return const SizedBox(
                                //     width: 8,
                                //   );
                                // },
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final isFirstItem = index == 0;
                                  final isLast = index == items.length - 1;

                                  return Container(
                                    margin: EdgeInsets.only(
                                      left: isFirstItem ? 16 : 0,
                                      right: isLast ? 16 : 8,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 0.55,
                                      child: AnimeTileExp(item.anime!),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        );
                      },
                      childCount: data.length,
                      addRepaintBoundaries: false,
                      addSemanticIndexes: false,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: context.padding.bottom),
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
        ),
      ),
    );
  }
}
