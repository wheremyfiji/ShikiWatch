import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shikidev/src/utils/extensions/string_ext.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:timeago/timeago.dart' as timeago;

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
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(
              title: Text('Обсуждение'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: PagedSliverList<int, ShikiComment>(
                pagingController: controller.pageController,
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
    );

    // return Scaffold(
    //   body: NestedScrollView(
    //     headerSliverBuilder: (context, innerBoxIsScrolled) {
    //       return [
    //         SliverAppBar.large(
    //           forceElevated: innerBoxIsScrolled,
    //           stretch: true,
    //           title: const Text('Обсуждение'),
    //         ),
    //       ];
    //     },
    //     body: RefreshIndicator(
    //       onRefresh: () => Future.sync(
    //         () => controller.pageController.refresh(),
    //       ),
    //       child: CustomScrollView(
    //         slivers: [
    //           SliverPadding(
    //             padding: const EdgeInsets.all(16.0),
    //             sliver: PagedSliverList<int, ShikiComment>(
    //               pagingController: controller.pageController,
    //               builderDelegate: PagedChildBuilderDelegate<ShikiComment>(
    //                 itemBuilder: (context, item, index) {
    //                   return CommentWidget(
    //                     comment: item,
    //                   );
    //                 },
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}

class CommentWidget extends StatelessWidget {
  final ShikiComment comment;

  const CommentWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final updatedAt =
        DateTime.tryParse(comment.updatedAt ?? '')?.toLocal() ?? DateTime(1970);

    //final date = DateFormat.yMMMMd().format(updatedAt);
    //final time = DateFormat.Hms().format(updatedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                context.push('/profile/${comment.user!.id!}',
                    extra: comment.user);
              },
              child: Row(
                children: [
                  CircleAvatar(
                    //radius: 24,
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
                        Text(
                          //'$date в $time',
                          timeago.format(updatedAt, locale: 'ru'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                //CoolChip(label: '${comment.id}'),
                if (comment.isOfftopic ?? false) ...[
                  const SizedBox(
                    width: 8,
                  ),
                  const CoolChip(label: 'Оффтоп'),
                ],
              ],
            ),
            // Text(
            //   '${comment.body}',
            //   //maxLines: 4,
            // ),
            Html(
              data: comment.htmlBody,
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
            // BBCodeText(
            //   data: comment.body ?? '',
            //   stylesheet: defaultBBStylesheet(
            //     textStyle: context.textTheme.bodyMedium,
            //   ),
            // ),
          ],
        ),
      ),
    );

    // return Card(
    //   child: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         CircleAvatar(
    //           radius: 24,
    //           backgroundColor: Colors.transparent,
    //           backgroundImage: ExtendedNetworkImageProvider(
    //             comment.user?.avatar ?? '',
    //             cache: true,
    //           ),
    //         ),
    //         Expanded(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(
    //                 '${comment.user?.nickname}',
    //                 maxLines: 1,
    //                 overflow: TextOverflow.ellipsis,
    //               ),
    //               Text(
    //                 '${comment.updatedAt}',
    //                 maxLines: 1,
    //                 overflow: TextOverflow.ellipsis,
    //               ),
    //               Text(
    //                 '${comment.body}',
    //                 //maxLines: 4,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
