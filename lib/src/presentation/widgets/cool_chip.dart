import 'package:flutter/material.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

class CoolChip extends StatelessWidget {
  final String label;
  final Widget? avatar;
  final Color? backgroundColor;
  final bool useTertiaryColors;

  const CoolChip({
    super.key,
    required this.label,
    this.avatar,
    this.backgroundColor,
    this.useTertiaryColors = false,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.all(0),
      shadowColor: Colors.transparent,
      elevation: 0,
      side: const BorderSide(width: 0, color: Colors.transparent),
      labelStyle: context.theme.textTheme.bodyMedium?.copyWith(
          color: useTertiaryColors
              ? context.theme.colorScheme.onTertiaryContainer
              : context.theme.colorScheme.onSecondaryContainer),
      backgroundColor: useTertiaryColors
          ? context.theme.colorScheme.tertiaryContainer
          : backgroundColor ?? context.theme.colorScheme.secondaryContainer,
      avatar: avatar,
      label: Text(label),
    );
  }
}
