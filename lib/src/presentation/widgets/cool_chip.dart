import 'package:flutter/material.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

class CoolChip extends StatelessWidget {
  final String label;
  final Widget? avatar;
  final Color? backgroundColor;

  const CoolChip({
    super.key,
    required this.label,
    this.avatar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.all(0),
      shadowColor: Colors.transparent,
      elevation: 0,
      side: const BorderSide(width: 0, color: Colors.transparent),
      labelStyle: context.theme.textTheme.bodyMedium
          ?.copyWith(color: context.theme.colorScheme.onSecondaryContainer),
      backgroundColor:
          backgroundColor ?? context.theme.colorScheme.secondaryContainer,
      avatar: avatar,
      label: Text(label),
    );
  }
}
