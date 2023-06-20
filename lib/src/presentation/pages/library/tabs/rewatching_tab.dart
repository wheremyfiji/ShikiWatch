import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/library_tab_page_provider.dart';
import '../../../widgets/anime_card.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/loading_grid.dart';
import '../widgets/search_widget.dart';
import '../widgets/empty_list.dart';

class RewatchingTab extends ConsumerWidget {
  const RewatchingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(rewatchingTabPageProvider);

    return controller.animes.when(
      data: (data) {
        if (data.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(rewatchingTabPageProvider),
            child: Stack(
              children: <Widget>[ListView(), const EmptyList()],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(rewatchingTabPageProvider),
          child: CustomScrollView(
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
                        'В этом списке пусто\nПопробуй поискать в другом',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
              SliverList.builder(
                itemCount: controller.searchAnimes.isEmpty
                    ? data.length
                    : controller.searchAnimes.length,
                itemBuilder: (context, index) {
                  data.sort((a, b) {
                    String adate = a.updatedAt!;
                    String bdate = b.updatedAt!;
                    return -adate.compareTo(bdate);
                  });
                  final sortedData = controller.searchAnimes.isEmpty &&
                          controller.textEditingController.text.isEmpty
                      ? data
                      : controller.searchAnimes;

                  if (sortedData.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final model = sortedData[index];

                  final lastElement = index == (data.length - 1);

                  return Padding(
                    padding:
                        EdgeInsets.fromLTRB(16, 0, 16, lastElement ? 16 : 8),
                    child: AnimeListTile(model),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => CustomErrorWidget(
        err.toString(),
        () => ref.refresh(rewatchingTabPageProvider),
      ),
    );

    return controller.animes.when(
      data: (data) => data.isEmpty
          ? RefreshIndicator(
              onRefresh: () async => ref.refresh(rewatchingTabPageProvider),
              child: Stack(
                children: <Widget>[ListView(), const EmptyList()],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => ref.refresh(rewatchingTabPageProvider),
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollState) {
                  return false;
                },
                child: CustomScrollView(
                  key: const PageStorageKey<String>('RewatchingTab'),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
            ),
      loading: () => const LoadingGrid(),
      error: (err, stack) => CustomErrorWidget(
        err.toString(),
        () => ref.refresh(rewatchingTabPageProvider),
      ),
    );
  }
}
