import 'package:flutter/material.dart';

class NothingFound extends StatelessWidget {
  const NothingFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Ничено не найдено',
          style:
              Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}
