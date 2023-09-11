import 'package:flutter/material.dart';

import '../../utils/extensions/buildcontext.dart';

class MaterialYouChip extends StatelessWidget {
  const MaterialYouChip({
    super.key,
    required this.title,
    required this.onPressed,
    required this.isSelected,
    this.icon,
  });

  final String title;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorPrimary = isSelected
        ? context.theme.colorScheme.secondaryContainer
        : Colors.transparent;

    final colorOnPrimary = isSelected
        ? context.theme.colorScheme.onSecondaryContainer
        : context.colorScheme.onBackground;

    return Card(
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          style: isSelected ? BorderStyle.none : BorderStyle.solid,
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      color: colorPrimary,
      shadowColor: Colors.transparent,
      elevation: isSelected ? 1 : 0,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: isSelected ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    icon,
                    size: 16,
                    color: colorOnPrimary,
                  ),
                ),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colorOnPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // final borderRadius =
    //     isSelected ? BorderRadius.circular(24) : BorderRadius.circular(12);

    // final colorPrimary = isSelected
    //     ? context.theme.colorScheme.primaryContainer
    //     : context.theme.colorScheme.tertiaryContainer;

    // final colorOnPrimary = isSelected
    //     ? context.theme.colorScheme.onPrimaryContainer
    //     : context.theme.colorScheme.onTertiaryContainer;

    // return GestureDetector(
    //   onTap: onPressed,
    //   child: Card(
    //     margin: const EdgeInsets.all(0),
    //     shape: RoundedRectangleBorder(
    //       borderRadius: borderRadius,
    //     ),
    //     //clipBehavior: Clip.antiAlias,
    //     color: colorPrimary,
    //     elevation: 0.0,
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(
    //         horizontal: 12,
    //         vertical: 8,
    //       ),
    //       child: Row(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           if (icon != null) ...[
    //             Icon(
    //               icon,
    //               size: 16,
    //             ),
    //           ],
    //           if (icon != null) ...[
    //             const SizedBox(
    //               width: 6,
    //             ),
    //           ],
    //           Flexible(
    //             child: Text(
    //               title,
    //               style: TextStyle(
    //                 color: colorOnPrimary,
    //                 fontWeight: isSelected ? FontWeight.w500 : null,
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
