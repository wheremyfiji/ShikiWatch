import 'package:flutter/material.dart';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../utils/extensions/buildcontext.dart';
import '../../utils/shiki_utils.dart';

import 'expanded_section.dart';

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
    // final shouldExpand = useMemoized(() => descriptionHtml.length > 800);

    if (!shouldExpand) {
      return Html(
        data: descriptionHtml,
        style: {
          'body': Style(
            margin: Margins.all(0),
          ),
          'a': Style(
            textDecoration: TextDecoration.none,
            color: context.colorScheme.primary,
          ),
        },
        onLinkTap: (url, attributes, element) {
          if (url == null || url.isEmpty) {
            return;
          }
          ShikiUtils.instance.handleShikiHtmlLinkTap(
            context,
            url: url,
            attributes: attributes,
          );
        },
      );
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
            child: Html(
              data: descriptionHtml,
              style: {
                'body': Style(
                  margin: Margins.all(0),
                ),
                'a': Style(
                  textDecoration: TextDecoration.none,
                  // color: expand.value
                  //     ? context.colorScheme.primary
                  //     : context.colorScheme.onBackground,
                  color: context.colorScheme.primary,
                ),
              },
              // doNotRenderTheseTags: const {
              //   'a',
              // },
              onLinkTap: (url, attributes, element) {
                if (!expand.value) {
                  return;
                }

                if (url == null || url.isEmpty) {
                  return;
                }

                ShikiUtils.instance.handleShikiHtmlLinkTap(
                  context,
                  url: url,
                  attributes: attributes,
                );
              },
            ),
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
