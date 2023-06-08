import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmptyList extends StatelessWidget {
  const EmptyList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'В этом списке ничего не найдено',
          style:
              Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 16),
        ),
      ),
    ).animate().fade();
  }
}
