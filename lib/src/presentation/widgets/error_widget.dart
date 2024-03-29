import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../utils/extensions/buildcontext.dart';

const errorFaces = [
  'Σ(ಠ_ಠ)',
  '(˘･_･˘)',
  '(┬┬﹏┬┬)',
  '(´･ω･`)?',
  'X﹏X',
  '＞︿＜',
];

class CustomErrorWidget extends HookWidget {
  final String errorString;
  final Function()? buttonOnPressed;
  final bool showButton;
  final String? stackTrace;

  const CustomErrorWidget(
    this.errorString,
    this.buttonOnPressed, {
    super.key,
    this.showButton = true,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    final errorFace = useMemoized(
      () => errorFaces[Random().nextInt(errorFaces.length)],
    );

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
            if (showButton) ...[
              const SizedBox(
                height: 16,
              ),
              FilledButton.icon(
                onPressed: buttonOnPressed,
                label: const Text(
                  'Повторить',
                ),
                icon: const Icon(Icons.refresh_outlined),
              ),
            ],
            if (stackTrace != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton.tonal(
                  onPressed: () => Clipboard.setData(ClipboardData(
                    text: 'Error:\n$errorString\n\nStacktrace:\n$stackTrace',
                  )),
                  child: const Text('copy stack trace'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
