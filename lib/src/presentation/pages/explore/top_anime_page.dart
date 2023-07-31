import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../domain/models/animes.dart';
import '../../providers/explore_top_page_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/error_widget.dart';

class TopAnimePage extends ConsumerWidget {
  const TopAnimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(exploreTopAnimePageProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(
              title: Text('Топ аниме'),
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
                    return AnimeTileExp(item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
