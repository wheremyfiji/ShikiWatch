import 'package:flutter/material.dart';

import '../../../../../domain/models/shiki_topic.dart';
import '../../../../../utils/extensions/buildcontext.dart';
import '../../../../../utils/extensions/date_time_ext.dart';

import 'content_card_footer.dart';

class TopicContentCard extends StatelessWidget {
  const TopicContentCard(this.content, {super.key});

  final ShikiTopic content;

  @override
  Widget build(BuildContext context) {
    final body = _removeTags(content.body);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        clipBehavior: Clip.hardEdge,
        type: MaterialType.card,
        color: context.colorScheme.surface,
        surfaceTintColor: context.colorScheme.surfaceTint,
        shadowColor: Colors.transparent,
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {},
          child: Padding(
            // padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    content.topicTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4.0,
                ),

                // single child with wrap
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 0,
                    children: [
                      const SizedBox(
                        width: 6.0,
                      ),
                      _CustomInfoChip(content.forum.name),
                      _CustomInfoChip(content.linkedType.rusName),
                      const SizedBox(
                        width: 6.0,
                      ),
                    ],
                  ),
                ),
                if (body.isNotEmpty) ...[
                  //const Divider(),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      body, // content.body
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                ],

                const SizedBox(
                  height: 8.0,
                ),
                //const Divider(),

                // footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ContentCardFooter(
                    userImageUrl: content.user.image!.x64!,
                    userNickname: content.user.nickname ?? '',
                    createdAt: content.createdAt.convertToDaysAgo(),
                    commentsCount: content.commentsCount,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _removeTags(String input) {
    final spoilerExp = RegExp(r'\[spoiler=[^\]]*\].*?\[/spoiler\]');
    final tagExp = RegExp(r'\[.*?\]');

    String cleanText = input.replaceAll(spoilerExp, '');
    cleanText = cleanText.replaceAll(tagExp, '');

    return cleanText;
  }
}

class _CustomInfoChip extends StatelessWidget {
  final String title;

  const _CustomInfoChip(
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: context.theme.colorScheme.tertiaryContainer,
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: context.theme.colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}
