import 'package:flutter/material.dart';

class RatingDialog extends StatelessWidget {
  const RatingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Подтверждение возраста'),
      content: const Text(
          'Для продолжения необходимо подтвердить,\nчто тебе уже исполнилось 18 лет'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Назад'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Подтвердить'),
        ),
      ],
    );
  }
}
