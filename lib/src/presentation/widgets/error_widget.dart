import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

const errorFaces = [
  'Σ(ಠ_ಠ)',
  '(˘･_･˘)',
//'＼（〇_ｏ）／',
  '(┬┬﹏┬┬)',
  '(´･ω･`)?',
];

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget(this.errorString, this.buttonOnPressed, {Key? key})
      : super(key: key);
  final String errorString;
  final Function()? buttonOnPressed;
  @override
  Widget build(BuildContext context) {
    final errorFace = errorFaces[Random().nextInt(errorFaces.length)];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorFace,
              textAlign: TextAlign.center,
              style: context.textTheme.displayMedium,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'Ой, ошибка..',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              errorString,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              onPressed: buttonOnPressed,
              label: const Text(
                'Повторить',
              ),
              icon: const Icon(Icons.refresh_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
