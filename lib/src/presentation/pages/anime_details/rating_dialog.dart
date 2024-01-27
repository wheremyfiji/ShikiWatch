import 'package:flutter/material.dart';

import '../../../utils/extensions/buildcontext.dart';

class RatingDialog extends StatelessWidget {
  const RatingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_rounded),
      title: const Text('Подтверждение возраста'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              text: 'Данный тайтл имеет возрастное ограничение ',
              style: context.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '18+',
                  style: TextStyle(
                    color: context.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              text:
                  '\nДля продолжения необходимо подтвердить, что тебе уже исполнилось ',
              style: context.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '18 лет',
                  style: TextStyle(
                    color: context.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // const Text(
          //   'Для продолжения необходимо подтвердить, что тебе уже исполнилось 18 лет',
          // ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Назад'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Мне есть 18 лет'),
        ),
      ],
    );
  }
}
