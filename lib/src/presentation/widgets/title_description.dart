//import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:flutter_html/flutter_html.dart';
//import 'package:html/parser.dart' as html_parser;

import '../../utils/extensions/buildcontext.dart';
import '../../utils/shiki_utils.dart';

import 'expanded_section.dart';

// CustomRenderMatcher birdMatcher() =>
//     (context) => context.tree.element?.localName == 'character';

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
  final String descriptionHtml;

  const TitleDescriptionFromHtml(this.descriptionHtml, {super.key});

  @override
  Widget build(BuildContext context) {
    final expand = useState(false);

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

// class TitleDescriptionFromHtml extends StatelessWidget {
//   final String descriptionHtml;

//   const TitleDescriptionFromHtml(this.descriptionHtml, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     final document = html_parser.parse(descriptionHtml);
//     final String parsedString =
//         html_parser.parse(document.body?.text).documentElement!.text;

//     return ExpandableText(
//       parsedString,
//       expandText: 'Развернуть',
//       collapseText: 'Свернуть',
//       maxLines: 6,
//       animation: true,
//       animationDuration: const Duration(milliseconds: 500),
//       linkStyle: const TextStyle(fontWeight: FontWeight.bold),
//       urlStyle: const TextStyle(
//         color: Colors.red,
//         decoration: TextDecoration.underline,
//       ),
//       style: context.textTheme.bodyMedium?.copyWith(fontSize: 14),
//       expandOnTextTap: true,
//       collapseOnTextTap: true,
//       onUrlTap: (value) {
//         print(value);
//       },
//     );
//   }
// }

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

    // return InkWell(
    //   onTap: onTap,
    //   borderRadius: BorderRadius.circular(12.0),
    //   child: Padding(
    //     padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
    //     child: Row(
    //       //mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         Icon(
    //           expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
    //           color: context.colorScheme.secondary,
    //           size: 16.0,
    //         ),
    //         const SizedBox(
    //           width: 6.0,
    //         ),
    //         Text(
    //           expanded ? 'Свернуть' : 'Развернуть',
    //           style: context.textTheme.labelLarge?.copyWith(
    //             color: context.colorScheme.secondary,
    //             fontSize: 14.0,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
