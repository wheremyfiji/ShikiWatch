import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/extensions/buildcontext.dart';
import '../../widgets/flexible_sliver_app_bar.dart';
import '../../../domain/models/shiki_topic.dart';
import '../../widgets/nothing_found.dart';
import '../../widgets/error_widget.dart';

import 'components/content_card/content_card.dart';
import 'topics_page_provider.dart';

class TopicsRootPage extends ConsumerWidget {
  const TopicsRootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(topicsPageProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => controller.pageController.refresh(),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              FlexibleSliverAppBar(
                title: const Text('Топики'),
                bottomContent: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: [
                      const SizedBox(
                        width: 8.0,
                      ),
                      ChoiceChip(
                        label: const Text('Новости'),
                        selected: true,
                        onSelected: (value) {},
                      ),
                      // ChoiceChip(
                      //   label: const Text('Статьи'),
                      //   selected: false,
                      //   onSelected: (value) {},
                      // ),
                      const SizedBox(
                        width: 8.0,
                      ),
                    ],
                  ),
                ),
              ),
              PagedSliverList<int, ShikiTopic>.separated(
                key: const PageStorageKey<String>('TopicsPageList'),
                addSemanticIndexes: false,
                pagingController: controller.pageController,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                builderDelegate: PagedChildBuilderDelegate<ShikiTopic>(
                  firstPageProgressIndicatorBuilder: (context) {
                    return const Align(
                      alignment: Alignment.topCenter,
                      child: LinearProgressIndicator(),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return const NothingFound(
                      subtitle: 'Попробуй изменить запрос',
                    );
                  },
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
                    return TopicContentCard(item);
                  },
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: 16 + context.padding.bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
