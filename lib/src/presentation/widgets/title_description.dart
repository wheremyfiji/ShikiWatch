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
  }
}
