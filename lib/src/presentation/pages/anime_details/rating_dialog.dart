import 'package:flutter/material.dart';

import '../../../utils/extensions/buildcontext.dart';

class RatingDialog extends StatelessWidget {
  const RatingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.eighteen_up_rating_outlined),
      title: const Text('Подтверждение возраста'),
      content: RichText(
        text: TextSpan(
          text: 'Нажимая продолжить, ты подтверждаешь, что тебе исполнилось',
          style: context.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: ' 18 ',
              style: TextStyle(
                color: context.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'лет',
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Продолжить'),
        ),
      ],
    );
  }
}
