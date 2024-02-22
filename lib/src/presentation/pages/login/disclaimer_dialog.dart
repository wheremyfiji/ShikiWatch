import 'package:flutter/material.dart';

class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Дисклеймер',
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'Весь контент, представленный в приложении, предназначен только для ознакомления.\n\nАвтор приложения никак не связан с размещением и распространением контента.',
        textAlign: TextAlign.left,
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
