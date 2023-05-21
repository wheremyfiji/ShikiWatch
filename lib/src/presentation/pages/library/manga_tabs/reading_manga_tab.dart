import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/library_manga_provider.dart';
import '../../../widgets/error_widget.dart';

import '../../../widgets/loading_grid.dart';
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          data.sort((a, b) {
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

                          return MangaCard(model);
                        },
                        childCount: controller.searchResult.isEmpty
                            ? data.length
                            : controller.searchResult.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 140,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      loading: () => const LoadingGrid(),
      error: (err, stack) => CustomErrorWidget(
          err.toString(), () => ref.refresh(readingMangaTabProvider)),
    );
  }
}
