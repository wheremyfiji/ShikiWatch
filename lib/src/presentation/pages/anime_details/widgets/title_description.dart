//import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart';

// CustomRenderMatcher birdMatcher() =>
//     (context) => context.tree.element?.localName == 'character';

class TitleDescription extends StatelessWidget {
  final String description;
  const TitleDescription(this.description, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final document = parse(description);
    final String parsedString =
        parse(document.body?.text).documentElement!.text;

    return ExpandableText(
      parsedString,
      expandText: 'Развернуть',
      collapseText: 'Свернуть',
      maxLines: 6,
      animation: true,
      animationDuration: const Duration(milliseconds: 500),
      linkStyle: const TextStyle(fontWeight: FontWeight.bold),
      urlStyle: const TextStyle(
        decoration: TextDecoration.underline,
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
      expandOnTextTap: true,
      collapseOnTextTap: true,
      // onUrlTap: (value) {
      //   print(value);
      // },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                //fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
        ),
        // Html(
        //     onLinkTap: (url, context, attributes, element) {
        //       log(url ?? '');
        //     },
        //     data: description,
        //     style: {
        //       'div': Style(
        //         padding: const EdgeInsets.all(0),
        //       ),
        //       'a': Style(
        //         textDecorationThickness: 0,
        //         color: Theme.of(context).colorScheme.primary,
        //       ),
        //     }),

        ExpandableText(
          //description,
          parsedString,
          expandText: 'Развернуть',
          collapseText: 'Свернуть',
          maxLines: 6,
          animation: true,
          animationDuration: const Duration(milliseconds: 500),
          linkStyle: const TextStyle(fontWeight: FontWeight.bold),
          urlStyle: const TextStyle(
            decoration: TextDecoration.underline,
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
          expandOnTextTap: true,
          collapseOnTextTap: true,
          // onUrlTap: (value) {
          //   print(value);
          // },
        ),
      ],
    );
  }
}
