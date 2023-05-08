import 'package:flutter/material.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

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
    final borderRadius =
        isSelected ? BorderRadius.circular(28) : BorderRadius.circular(12);
    final colorPrimary = isSelected
        ? context.theme.colorScheme.primaryContainer
        : context.theme.colorScheme.surfaceVariant;
    final colorOnPrimary = isSelected
        ? context.theme.colorScheme.onPrimaryContainer
        : context.theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onPressed,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        clipBehavior: Clip.antiAlias,
        color: colorPrimary,
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                ),
              ],
              if (icon != null) ...[
                const SizedBox(
                  width: 6,
                ),
              ],
              Text(
                title,
                style: TextStyle(
                  color: colorOnPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
