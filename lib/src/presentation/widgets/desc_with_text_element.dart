import 'package:flutter/material.dart';

class DescWithTextElement extends StatelessWidget {
  final String text;
  final Color color;
  const DescWithTextElement(
      {super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(
              Radius.circular(4.0),
            ),
          ),
          //color: Colors.amber,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(text),
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }
}
