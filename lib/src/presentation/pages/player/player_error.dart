import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class PlayerError extends StatelessWidget {
  final String error;

  const PlayerError(
    this.error, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error,
            softWrap: true,
          ),
          const SizedBox(
            height: 8,
          ),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Назад'),
          ),
        ],
      ),
    );
  }
}
