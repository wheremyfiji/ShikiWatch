import 'package:flutter/material.dart';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../utils/extensions/buildcontext.dart';

import 'expanded_section.dart';
import 'html/shiki_html.dart';

class TitleDescription extends StatelessWidget {
  final String description;

  const TitleDescription(this.description, {super.key});

  @override
  Widget build(BuildContext context) {
    final text = _removeTags(description);

    return ExpandableText(
      text,
      expandText: 'Развернуть',
      collapseText: 'Свернуть',
      maxLines: 6,
      animation: true,
      animationDuration: const Duration(milliseconds: 500),
      linkStyle: const TextStyle(fontWeight: FontWeight.bold),
      urlStyle: const TextStyle(
        decoration: TextDecoration.underline,
      ),
      style: context.textTheme.bodyMedium?.copyWith(fontSize: 14),
      expandOnTextTap: true,
      collapseOnTextTap: true,
      // onUrlTap: (value) {
      //   print(value);
      // },
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

class TitleDescriptionFromHtml extends HookWidget {
  const TitleDescriptionFromHtml(
    this.descriptionHtml, {
    super.key,
    this.shouldExpand = true,
  });

  final String descriptionHtml;
  final bool shouldExpand;

  @override
  Widget build(BuildContext context) {
    final expand = useState(false);

    final child = ShikiHtml(
      data: descriptionHtml,
      enableLinkTap: !shouldExpand || expand.value,
    );

    if (!shouldExpand) {
      return child;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            expand.value = !expand.value;
          },
          child: ExpandedSection(
            expand: expand.value,
            child: child,
          ),
        ),
        _ExpandButton(
          expanded: expand.value,
          onTap: () {
            expand.value = !expand.value;
          },
        ),
      ],
    );
  }
}

class _ExpandButton extends StatelessWidget {
  const _ExpandButton({
    required this.expanded,
    required this.onTap,
  });

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        expanded ? 'Свернуть' : 'Развернуть',
        style: context.textTheme.titleLarge?.copyWith(
          color: context.colorScheme.secondary,
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
