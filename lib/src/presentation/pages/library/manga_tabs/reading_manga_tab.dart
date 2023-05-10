import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/library_manga_provider.dart';
import '../../../widgets/error_widget.dart';

import '../../../widgets/manga_card.dart';
import '../widgets/search_widget.dart';
import '../widgets/empty_list.dart';

class ReadingMangaTab extends ConsumerWidget {
  const ReadingMangaTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(readingMangaTabProvider);

    return controller.manga.when(
      data: (data) => data.isEmpty
          ? RefreshIndicator(
              onRefresh: () async => ref.refresh(readingMangaTabProvider),
              child: Stack(
                children: <Widget>[ListView(), const EmptyList()],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => ref.refresh(readingMangaTabProvider),
              child: CustomScrollView(
                key: const PageStorageKey<String>('WatchingPage'),
                scrollDirection: Axis.vertical,
                slivers: [
                  SliverToBoxAdapter(
                    child: SearchWidget(
                      controller: controller.textEditingController,
                      text: 'controller.query',
                      onChanged: controller.onSearchChanged,
                      hintText: 'Поиск (${data.length} всего)',
                    ),
                  ),
                  if (controller.searchResult.isEmpty &&
                      controller.textEditingController.text.isNotEmpty) ...[
                    const SliverPadding(
                      padding: EdgeInsets.all(16.0),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'В этом списке пусто\nПопробуй поискать в другом', // Хм, похоже здесь пусто
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          data.sort((a, b) {
                            // выбор типа сортировки через настройки
                            String adate = a.updatedAt!;
                            String bdate = b.updatedAt!;
                            return -adate.compareTo(bdate);
                          });
                          final sortedData = controller.searchResult.isEmpty &&
                                  controller.textEditingController.text.isEmpty
                              ? data
                              : controller.searchResult;

                          if (sortedData.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final model = sortedData[index];

                          return MangaCardWidget(model);
                        },
                        childCount: controller.searchResult.isEmpty
                            ? data.length
                            : controller.searchResult.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        maxCrossAxisExtent: 150, //150
                        mainAxisExtent: 220, //220
                      ),
                    ),
                  ),
                ],
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => CustomErrorWidget(
          err.toString(), () => ref.refresh(readingMangaTabProvider)),
    );
  }
}
