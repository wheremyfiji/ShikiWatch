import 'package:flutter/material.dart';

class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Дисклеймер'),
      content: const Text(
          'Весь контент, представленный в приложении, предназначен для бесплатного, домашнего, ознакомительного просмотра.\n\nАвтор приложения никак не связан с размещением и распространением контента.'),
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
