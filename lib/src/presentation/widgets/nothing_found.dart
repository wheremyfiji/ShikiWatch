import 'package:flutter/material.dart';

import '../../utils/extensions/buildcontext.dart';

class NothingFound extends StatelessWidget {
  const NothingFound({
    super.key,
    this.title = 'Ничего не найдено',
    this.subtitle = 'Измени список или воспользуйся глобальным поиском',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '(˘･_･˘)',
            textAlign: TextAlign.center,
            style: context.textTheme.displaySmall,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
            child: Text(
              title,
              style: context.textTheme.titleLarge,
            ),
          ),
          Text(
            subtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onBackground.withOpacity(
                0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
