import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../constants/config.dart';
import '../../../domain/models/animes.dart';
import '../../../utils/shiki_utils.dart';
import '../../providers/explore_page_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/image_with_shimmer.dart';

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
        // body: controller.animes.when(
        //   data: (data) => RefreshIndicator(
        //     onRefresh: controller.fetch,
        //     child: NotificationListener<ScrollNotification>(
        //       onNotification: (scrollState) {
        //         if (scrollState is ScrollEndNotification &&
        //             scrollState.metrics.extentAfter < 100) {
        //           controller.onLoadMore();
        //         }
        //         return false;
        //       },
        //       child: CustomScrollView(
        //         key: const PageStorageKey<String>('ExplorePage'),
        //         slivers: [
        //           SliverPadding(
        //             padding: const EdgeInsets.all(8.0),
        //             sliver: SliverGrid(
        //               delegate: SliverChildBuilderDelegate(
        //                 (context, index) {
        //                   // if (index >= data.length) {
        //                   //   return const Padding(
        //                   //     padding: EdgeInsets.all(16.0),
        //                   //     child: Center(child: CircularProgressIndicator()),
        //                   //   );
        //                   // }

        //                   final model = data[index];

        //                   return Padding(
        //                     padding: const EdgeInsets.all(4.0),
        //                     child: AnimeTileExp(model),
        //                   );
        //                 },
        //                 //childCount: data.length + 1,
        //                 childCount: data.length,
        //               ),
        //               gridDelegate:
        //                   const SliverGridDelegateWithMaxCrossAxisExtent(
        //                 maxCrossAxisExtent: 150,
        //                 mainAxisExtent: 220,
        //               ),
        //             ),
        //           ),
        //           if (controller.hasMore) ...[
        //             SliverToBoxAdapter(
        //               child: Center(
        //                 child: Padding(
        //                   padding: const EdgeInsets.all(16.0),
        //                   child: ConstrainedBox(
        //                       constraints: const BoxConstraints(maxHeight: 130),
        //                       child: const CircularProgressIndicator()),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ],
        //       ),
        //     ),
        //   ),
        //   loading: () => const Center(child: CircularProgressIndicator()),
        //   error: (err, stack) => CustomErrorWidget(
        //     err.toString(),
        //     () => controller.fetch(),
        //   ),
        // ),
      ),
      //),
    );
  }
}

class AnimeTileExp extends StatelessWidget {
  final Animes data;

  const AnimeTileExp(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.transparent,
      //margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: InkWell(
        onTap: () => context.push('/explore/${data.id!}', extra: data),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Hero(
            //  tag: data.id!,
            //  child:
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: ImageWithShimmerWidget(
                imageUrl: AppConfig.staticUrl + (data.image?.original ?? ''),
                width: 120,
                height: 150,
              ),
            ),
            //),
            const SizedBox(
              height: 4,
            ),
            Padding(
              // padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
              padding: const EdgeInsets.all(0),
              child: Text(
                //data.russian ?? '',
                data.russian ?? data.name ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  //data.score ?? '',
                  '${getKind(data.kind ?? '')} • ${data.score}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
                const Icon(
                  Icons.star,
                  size: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
