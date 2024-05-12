import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../domain/models/shiki_comment.dart';

import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/date_time_ext.dart';
import 'cached_image.dart';
import 'html/shiki_html.dart';

class ShikiCommentItem extends StatelessWidget {
  const ShikiCommentItem(this.item, {super.key});

  final ShikiComment item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push(
            '/profile/${item.user.id!}',
            extra: item.user,
          ),
          child: CachedCircleImage(
            item.user.avatar ?? '',
            clipBehavior: Clip.antiAlias,
          ),
        ),
        const SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                username: item.user.nickname ?? '',
                updatedAt: item.updatedAt,
                isOfftopic: item.isOfftopic,
              ),
              // const SizedBox(
              //   height: 4.0,
              // ),
              ShikiHtml(
                data: item.htmlBody ?? '',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.username,
    required this.updatedAt,
    required this.isOfftopic,
  });

  final String username;
  final DateTime updatedAt;
  final bool isOfftopic;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.colorScheme.onSurface,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 1, 0, 0),
          child: Text(
            //'${item.createdAt}',
            updatedAt.toLocal().convertToDaysAgo(),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (isOfftopic)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 1, 0, 0),
            child: Text(
              '| оффтоп',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
