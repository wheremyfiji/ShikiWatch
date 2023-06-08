import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../utils/extensions/buildcontext.dart';

class PlayerError extends StatelessWidget {
  final String error;

  const PlayerError(
    this.error, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '(┬┬﹏┬┬)',
              textAlign: TextAlign.center,
              style: context.textTheme.displayMedium!.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              error,
              softWrap: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}
