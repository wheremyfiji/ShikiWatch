import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../domain/models/manga_short.dart';
import '../../providers/explore_top_page_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/manga_card.dart';

class TopMangaPage extends ConsumerWidget {
  const TopMangaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(exploreTopMangaPageProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(
              title: Text('Топ манги'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: PagedSliverGrid<int, MangaShort>(
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
                builderDelegate: PagedChildBuilderDelegate<MangaShort>(
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
                    return MangaCardEx(item);
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
