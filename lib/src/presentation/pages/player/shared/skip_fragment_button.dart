import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';

class SkipFragmentButton extends StatelessWidget {
  const SkipFragmentButton({
    super.key,
    required this.title,
    required this.onSkip,
    required this.onClose,
  });

  final String title;
  final VoidCallback onSkip;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final size = _measureText(
      context: context,
      text: title,
      textStyle: context.textTheme.bodyMedium!,
    );

    return SizedBox(
      child: Row(
        children: [
          Container(
            height: 48,
            width: size.width + 18,
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title, // Пропустить фрагмент
                  style: TextStyle(
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onSkip,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 4.0,
          ),
          Container(
            height: 48,
            width: 48,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: context.colorScheme.errorContainer,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.close_rounded,
                  color: context.colorScheme.onErrorContainer,
                ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onClose,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Size _measureText({
  required BuildContext context,
  required String text,
  required TextStyle textStyle,
}) {
  assert(textStyle.fontSize != null);
  return (TextPainter(
    text: TextSpan(
      text: text,
      style: textStyle.copyWith(
          fontSize:
              MediaQuery.textScalerOf(context).scale(textStyle.fontSize!)),
    ),
    maxLines: 1,
    textDirection: Directionality.of(context),
  )..layout())
      .size;
}
