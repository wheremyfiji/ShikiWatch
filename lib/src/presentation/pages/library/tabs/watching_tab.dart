import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/library_tab_page_provider.dart';
import '../../../widgets/anime_card.dart';
import '../../../widgets/error_widget.dart';

import '../widgets/search_widget.dart';
import '../widgets/empty_list.dart';

class WatchingTab extends ConsumerWidget {
  const WatchingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(watchingTabPageProvider);

    return controller.animes.when(
      data: (data) => data.isEmpty
          ? RefreshIndicator(
              onRefresh: () async => ref.refresh(watchingTabPageProvider),
              child: Stack(
                children: <Widget>[ListView(), const EmptyList()],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => ref.refresh(watchingTabPageProvider),
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollState) {
                  // if (scrollState is ScrollEndNotification &&
                  //     scrollState.metrics.extentAfter < 200) {
                  //   feedController.onLoadMore();
                  // }
                  return false;
                },
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
                      padding: const EdgeInsets.all(0.0),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            data.sort((a, b) {
                              // выбор типа сортировки через настройки
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

                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: AnimeCard(model),
                            );
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

                          ///не ебу че за число
                          mainAxisExtent: 220, //220
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      //error: (err, stack) => Center(child: Text(err.toString())),
      error: (err, stack) =>
          //CustomErrorWidget(err.toString(), () => controller.fetch()),
          CustomErrorWidget(
              err.toString(), () => ref.refresh(watchingTabPageProvider)),
    );
  }
}

// class WatchingTabP extends StatelessWidget {
//   const WatchingTabP({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       key: const PageStorageKey<String>('WatchingPage'),
//       scrollDirection: Axis.vertical,
//       slivers: [
//         const SliverToBoxAdapter(
//           child: SearchWidget(
//             //controller: controller.textEditingController,
//             text: 'controller.query',
//             //onChanged: controller.onSearchChanged,
//             //hintText: 'Поиск (${data.length} всего)',
//             hintText: 'Поиск (54 всего)',
//           ),
//         ),
//         SliverGrid(
//           delegate: SliverChildBuilderDelegate(
//             (context, index) {
//               return const Padding(
//                 padding: EdgeInsets.all(4.0),
//                 child: AnimeCard(),
//               );
//             },
//             childCount: 15,
//           ),
//           gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//             crossAxisSpacing: 0,
//             mainAxisSpacing: 0,
//             maxCrossAxisExtent: 150, //150

//             ///не ебу че за число
//             mainAxisExtent: 220, //220
//           ),
//         ),
//       ],
//     );

//     return CustomScrollView(
//       key: const PageStorageKey<String>('WatchingPage'),
//       scrollDirection: Axis.vertical,
//       slivers: [
//         SliverGrid(
//           delegate: SliverChildBuilderDelegate(
//             (context, index) {
//               return const Padding(
//                 //padding: EdgeInsets.all(4.0),
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: AnimeCard(),
//               );
//             },
//             childCount: 15,
//           ),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               mainAxisSpacing: 0,
//               //crossAxisSpacing: 8,
//               mainAxisExtent: 230, //360
//               crossAxisCount: 3),
//         ),
//       ],
//     );
//   }
// }
