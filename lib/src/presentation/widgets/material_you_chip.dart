import 'package:flutter/material.dart';

class MaterialYouChip extends StatelessWidget {
  const MaterialYouChip({
    super.key,
    required this.title,
    this.icon,
    required this.onPressed,
    required this.isSelected,
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
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceVariant;
    final colorOnPrimary = isSelected
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;

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
                ),
                // style: Theme.of(context).textTheme.subtitle1?.copyWith(
                //       color: colorOnPrimary,
                //       fontWeight: FontWeight.w600,
                //     ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
