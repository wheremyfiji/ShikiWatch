import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/extensions/date_time_ext.dart';
import '../../../utils/extensions/string_ext.dart';
import '../../../domain/models/shiki_comment.dart';
import '../../providers/comments_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/cool_chip.dart';

class CommentsPage extends ConsumerWidget {
  final int topicId;
  const CommentsPage({super.key, required this.topicId});

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
              SliverAppBar.large(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: const Text('Обсуждение'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: PagedSliverList<int, ShikiComment>.separated(
                  pagingController: controller.pageController,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  builderDelegate: PagedChildBuilderDelegate<ShikiComment>(
                    itemBuilder: (context, item, index) {
                      return CommentWidget(
                        comment: item,
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

class CommentWidget extends StatelessWidget {
  final ShikiComment comment;

  const CommentWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    // final updatedAt =
    //     DateTime.tryParse(comment.updatedAt ?? '')?.toLocal() ?? DateTime(1970);

    final updatedAt = DateTime.tryParse(comment.updatedAt ?? '');

    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push(
              '/profile/${comment.user!.id!}',
              extra: comment.user,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: CachedNetworkImageProvider(
                      comment.user?.avatar ?? '',
                      cacheManager: cacheManager,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${comment.user?.nickname}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (updatedAt != null)
                          Text(
                            //timeago.format(updatedAt, locale: 'ru'),
                            updatedAt.toLocal().convertToDaysAgo(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (comment.isOfftopic ?? false)
                    const CoolChip(label: 'Оффтоп'),
                  // IconButton(
                  //   onPressed: () {
                  //     launchUrlString(
                  //       'https://shikimori.me/comments/${comment.id}',
                  //       mode: LaunchMode.externalApplication,
                  //     );
                  //   },
                  //   icon: const Icon(Icons.more_vert),
                  //   tooltip: 'Открыть в браузере',
                  // ),
                ],
              ),
            ),
          ),
          // Text(
          //   '${comment.body}',
          //   //maxLines: 4,
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Html(
              data: comment.htmlBody,
              style: {
                "body": Style(
                  margin: Margins.all(0),
                ),
              },
              onLinkTap: (url, attributes, element) {
                //print(url);
                if (url.isNull) {
                  return;
                }

                launchUrlString(
                  url!,
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ),
          // BBCodeText(
          //   data: comment.body ?? '',
          //   stylesheet: defaultBBStylesheet(
          //     textStyle: context.textTheme.bodyMedium,
          //   ),
          // ),
        ],
      ),
    );
  }
}
