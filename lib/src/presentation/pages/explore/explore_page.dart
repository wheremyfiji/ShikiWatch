import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../domain/models/animes.dart';
import '../../providers/explore_page_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/error_widget.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Explore page'),
    //     actions: [
    //       IconButton(
    //         onPressed: () => context.push('/explore/search'),
    //         icon: const Icon(Icons.search),
    //       ),
    //     ],
    //   ),
    //   body: Center(
    //     child: ElevatedButton(
    //       onPressed: () => context.push('/explore/search'),
    //       child: const Text('Zaglushka ://'),
    //     ),
    //   ),
    // );

    final controller = ref.watch(explorePageProvider);

    return Scaffold(
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => context.push('/explore/search'),
      //   icon: const Icon(Icons.search),
      //   label: const Text('Поиск'),
      // ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              forceElevated: innerBoxIsScrolled,
              stretch: true,
              title: const Text('Сейчас выходит'),
              actions: [
                IconButton(
                  onPressed: () => context.push('/explore/search'),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () => Future.sync(
            () => controller.pageController.refresh(),
          ),
          child: CustomScrollView(
            key: const PageStorageKey<String>('ExplorePage'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: PagedSliverGrid<int, Animes>(
                  //showNoMoreItemsIndicatorAsGridChild: false,
                  showNewPageErrorIndicatorAsGridChild: false,
                  addAutomaticKeepAlives: true,
                  pagingController: controller.pageController,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisExtent: 220,
                  ),
                  builderDelegate: PagedChildBuilderDelegate<Animes>(
                    firstPageErrorIndicatorBuilder: (context) {
                      return CustomErrorWidget(
                        controller.pageController.error.toString(),
                        () => controller.pageController.refresh(),
                      );
                    },
                    newPageErrorIndicatorBuilder: (context) {
                      return CustomErrorWidget(
                        controller.pageController.error.toString(),
                        () =>
                            controller.pageController.retryLastFailedRequest(),
                      );
                    },
                    // noMoreItemsIndicatorBuilder: (context) {
                    //   return const Center(
                    //     child: Padding(
                    //       padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                    //       child: Text('Конец списка'),
                    //     ),
                    //   );
                    // },
                    itemBuilder: (context, item, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: AnimeTileExp(item),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        ),
      ),
    );
  }
}
