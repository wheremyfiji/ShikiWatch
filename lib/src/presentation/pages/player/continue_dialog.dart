import 'package:flutter/material.dart';

class ContinueDialog extends StatelessWidget {
  const ContinueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Продолжить просмотр?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ContinueDialogResult.start),
          child: const Text("Нет"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, ContinueDialogResult.saved),
          child: const Text("Да"),
        ),
      ],
    );
  }
}

enum ContinueDialogResult {
  cancel,
  start,
  saved,
}
