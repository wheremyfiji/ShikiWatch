import 'package:flutter/material.dart';

import '../../utils/extensions/buildcontext.dart';

class DescWithTextElement extends StatelessWidget {
  final String text;
  final Color color;
  const DescWithTextElement(
      {super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(
              Radius.circular(4.0),
            ),
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: context.textTheme.bodySmall,
          // style: TextStyle(
          //   fontSize: 12.0,
          //   color: context.colorScheme.onBackground.withOpacity(0.8),
          // ),
        ),
        const SizedBox(
          width: 8.0,
        ),
      ],
    );
  }
}
