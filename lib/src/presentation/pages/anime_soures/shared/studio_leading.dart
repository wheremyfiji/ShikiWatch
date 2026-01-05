import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';

class StudioLeading extends StatelessWidget {
  const StudioLeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    // String text = title.replaceAll(RegExp(r'[ .a-zа-я]'), '');
    // text = text.length >= 2 ? text.substring(0, 2) : title.substring(0, 2);

    String text = title.replaceAll(RegExp(r'[^A-ZА-ЯЁ]'), '');

    text = text.length >= 2
        ? text.substring(0, 2)
        : (title.length >= 2 ? title.substring(0, 2) : title);

    return CircleAvatar(
      backgroundColor: context.colorScheme.primaryContainer,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: context.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
