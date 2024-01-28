// ContentCardFooter

import 'package:flutter/material.dart';

import '../../../../../utils/extensions/buildcontext.dart';
import '../../../../widgets/cached_image.dart';

class ContentCardFooter extends StatelessWidget {
  const ContentCardFooter({
    super.key,
    required this.userImageUrl,
    required this.userNickname,
    required this.createdAt,
    required this.commentsCount,
  });

  final String userImageUrl;
  final String userNickname;
  final String createdAt;
  final int commentsCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CachedCircleImage(
          userImageUrl,
          radius: 10.0,
          clipBehavior: Clip.antiAlias,
        ),
        const SizedBox(
          width: 6.0,
        ),
        Expanded(
          child: Text(
            userNickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onBackground.withOpacity(
                0.8,
              ),
            ),
          ),
        ),
        const Spacer(),
        const Icon(
          Icons.schedule_rounded,
          size: 14,
        ),
        const SizedBox(
          width: 2.0,
        ),
        Text(
          createdAt,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onBackground.withOpacity(
              0.8,
            ),
          ),
        ),
        const SizedBox(
          width: 4.0,
        ),
        const Icon(
          Icons.reply_rounded,
          size: 14,
        ),
        const SizedBox(
          width: 2.0,
        ),
        Text(
          '$commentsCount',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onBackground.withOpacity(
              0.8,
            ),
          ),
        ),
      ],
    );
  }
}
