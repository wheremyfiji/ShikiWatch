import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/extensions/buildcontext.dart';
import '../../../domain/models/shiki_comment.dart';
import '../../providers/comments_provider.dart';
import '../../widgets/shiki_comment.dart';

class CommentsPage extends ConsumerWidget {
  final int topicId;
  final String name;

  const CommentsPage({
    super.key,
    required this.topicId,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(commentsPageProvider(topicId));

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
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Обсуждение',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: PagedSliverList<int, ShikiComment>.separated(
                  pagingController: controller.pageController,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  builderDelegate: PagedChildBuilderDelegate<ShikiComment>(
                    itemBuilder: (context, item, index) {
                      return ShikiCommentItem(
                        item,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
