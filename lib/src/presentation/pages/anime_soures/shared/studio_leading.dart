import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';

class StudioLeading extends StatelessWidget {
  const StudioLeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    String text = title.replaceAll(RegExp(r'[ .a-zа-я]'), '');

    // final pre = text;

    // text = text.length >= 2 ? text.substring(0, 2) : text;
    // text = text.length == 1 ? text + title.substring(title.length - 1) : text;

    // if (text.isEmpty) {
    //   text = title.substring(0, 2);
    // }

    text = text.length >= 2 ? text.substring(0, 2) : title.substring(0, 2);

    // print('$title -> $pre -> $text');

    return CircleAvatar(
      backgroundColor: context.colorScheme.primaryContainer,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: context.colorScheme.onPrimaryContainer,
          // fontSize: 14.0,
        ),
      ),
    );
  }
}
