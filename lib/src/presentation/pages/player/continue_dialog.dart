import 'package:flutter/material.dart';

class ContinueDialog extends StatelessWidget {
  const ContinueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Продолжить просмотр?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Нет"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Да"),
        ),
      ],
    );
  }
}
