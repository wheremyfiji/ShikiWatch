import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../../../domain/models/animes.dart';
import '../../providers/explore_page_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/error_widget.dart';
import 'widgets/explore_actions.dart';

class TestPerf extends StatelessWidget {
  const TestPerf({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        key: const PageStorageKey<String>('TestPerf'),
        slivers: [
          SliverAppBar.large(
            title: const Text('ShikiWatch'),
            actions: [
              IconButton(
                onPressed: () => context.push('/explore/search'),
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: ExploreActions(),
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 140,
              childAspectRatio: 0.55,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.deepPurple[100 * (index % 9)],
                  ),
                  alignment: Alignment.center,
                  //color: Colors.teal[100 * (index % 9)],
                  child: Text('grid item $index'),
                );
              },
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              addSemanticIndexes: false,
              childCount: 400,
            ),
          )
        ],
      ),
    );
  }
}

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(explorePageProvider);

    return Scaffold(
      body: CustomScrollView(
        //cacheExtent: 0,
        clipBehavior: Clip.none,
        key: const PageStorageKey<String>('ExplorePage'),
        slivers: [
          SliverAppBar.large(
            title: const Text('ShikiWatch'),
            actions: [
              // IconButton(
              //   onPressed: () => Navigator.of(context).push(
              //     PageRouteBuilder(
              //       pageBuilder: (context, animation, secondaryAnimation) =>
              //           const TestPerf(),
              //     ),
              //   ),
              //   icon: const Icon(Icons.power_off),
              // ),
              IconButton(
                onPressed: () => context.push('/explore/search'),
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: ExploreActions(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Сейчас выходит',
                style: context.textTheme.titleLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: PagedSliverGrid<int, Animes>(
              //addRepaintBoundaries: false,
              addSemanticIndexes: false,
              addRepaintBoundaries: false,
              showNewPageErrorIndicatorAsGridChild: false,
              pagingController: controller.pageController,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 140, //150
                //mainAxisExtent: 230,
                childAspectRatio: 0.55,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
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
                    () => controller.pageController.retryLastFailedRequest(),
                  );
                },
                itemBuilder: (context, item, index) {
                  return ExcludeSemantics(child: AnimeTileExp(item));
                },
              ),
            ),
          ),
          //const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );

    // return Scaffold(
    //   body: NestedScrollView(
    //     headerSliverBuilder: (context, innerBoxIsScrolled) {
    //       return [
    //         SliverAppBar.large(
    //           forceElevated: innerBoxIsScrolled,
    //           stretch: true,
    //           title: const Text('ShikiWatch'),
    //           actions: [
    //             IconButton(
    //               onPressed: () => context.push('/explore/search'),
    //               icon: const Icon(Icons.search),
    //             ),
    //           ],
    //         ),
    //       ];
    //     },
    //     body: CustomScrollView(
    //       key: const PageStorageKey<String>('HomePage'),
    //       slivers: [
    //         const SliverPadding(
    //           padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
    //           sliver: SliverToBoxAdapter(
    //             child: ExploreActions(),
    //           ),
    //         ),
    //         SliverPadding(
    //           padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    //           sliver: SliverToBoxAdapter(
    //             child: Text(
    //               'Сейчас выходит',
    //               style: context.textTheme.titleLarge,
    //             ),
    //             // Row(
    //             //   children: [
    //             //     Text(
    //             //       'Сейчас выходит',
    //             //       style: context.textTheme.titleLarge,
    //             //     ),
    //             //     const Spacer(),
    //             //     IconButton(
    //             //       onPressed: () {},
    //             //       icon: const Icon(Icons.arrow_forward),
    //             //     ),
    //             //   ],
    //             // ),
    //           ),
    //         ),
    //         SliverPadding(
    //           padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    //           sliver: PagedSliverGrid<int, Animes>(
    //             showNewPageErrorIndicatorAsGridChild: false,
    //             addAutomaticKeepAlives: true,
    //             pagingController: controller.pageController,
    //             gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    //               maxCrossAxisExtent: 140, //150
    //               //mainAxisExtent: 230,
    //               childAspectRatio: 0.55,
    //               crossAxisSpacing: 8,
    //               mainAxisSpacing: 8,
    //             ),
    //             builderDelegate: PagedChildBuilderDelegate<Animes>(
    //               firstPageErrorIndicatorBuilder: (context) {
    //                 return CustomErrorWidget(
    //                   controller.pageController.error.toString(),
    //                   () => controller.pageController.refresh(),
    //                 );
    //               },
    //               newPageErrorIndicatorBuilder: (context) {
    //                 return CustomErrorWidget(
    //                   controller.pageController.error.toString(),
    //                   () => controller.pageController.retryLastFailedRequest(),
    //                 );
    //               },
    //               itemBuilder: (context, item, index) {
    //                 return AnimeTileExp(item);
    //               },
    //             ),
    //           ),
    //         ),
    //         const SliverToBoxAdapter(child: SizedBox(height: 60)),
    //       ],
    //     ),
    //   ),
    // );
  }
}
