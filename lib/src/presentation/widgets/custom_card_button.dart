import 'package:flutter/material.dart';

import '../../utils/extensions/buildcontext.dart';

class CustomCardButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const CustomCardButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.all(0.0),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              const SizedBox(
                width: 8,
              ),
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: context.theme.colorScheme.secondary,
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
