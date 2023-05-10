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

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(explorePageProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              forceElevated: innerBoxIsScrolled,
              stretch: true,
              title: const Text('ShikiWatch'),
              actions: [
                IconButton(
                  onPressed: () => context.push('/explore/search'),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ];
        },
        body: CustomScrollView(
          key: const PageStorageKey<String>('HomePage'),
          slivers: [
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
                // Row(
                //   children: [
                //     Text(
                //       'Сейчас выходит',
                //       style: context.textTheme.titleLarge,
                //     ),
                //     const Spacer(),
                //     IconButton(
                //       onPressed: () {},
                //       icon: const Icon(Icons.arrow_forward),
                //     ),
                //   ],
                // ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
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
                      () => controller.pageController.retryLastFailedRequest(),
                    );
                  },
                  itemBuilder: (context, item, index) {
                    return Padding(
                      //padding: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
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
    );
  }
}
