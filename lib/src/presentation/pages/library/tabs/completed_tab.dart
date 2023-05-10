import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/library_tab_page_provider.dart';
import '../../../widgets/anime_card.dart';
import '../../../widgets/error_widget.dart';
import '../widgets/search_widget.dart';
import '../widgets/empty_list.dart';

class CompletedTab extends ConsumerWidget {
  const CompletedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(completedTabPageProvider);

    return controller.animes.when(
      data: (data) => data.isEmpty
          ? RefreshIndicator(
              onRefresh: () async => ref.refresh(completedTabPageProvider),
              child: Stack(
                children: <Widget>[ListView(), const EmptyList()],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => ref.refresh(completedTabPageProvider),
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollState) {
                  return false;
                },
                child: CustomScrollView(
                  key: const PageStorageKey<String>('CompletedTab'),
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
                    if (controller.searchAnimes.isEmpty &&
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
                      //padding: const EdgeInsets.all(0.0),
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            data.sort((a, b) {
                              String adate = a.updatedAt!;
                              String bdate = b.updatedAt!;
                              return -adate.compareTo(bdate);
                            });
                            final sortedData =
                                controller.searchAnimes.isEmpty &&
                                        controller
                                            .textEditingController.text.isEmpty
                                    ? data
                                    : controller.searchAnimes;

                            if (sortedData.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            final model = sortedData[index];

                            return AnimeCard(model);
                          },
                          childCount: controller.searchAnimes.isEmpty
                              ? data.length
                              : controller.searchAnimes.length,
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
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          CustomErrorWidget(err.toString(), () => controller.fetch()),
    );
  }
}
