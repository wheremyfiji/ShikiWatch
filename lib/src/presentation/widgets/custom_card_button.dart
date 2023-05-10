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
                  color: context.theme.colorScheme.primary,
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
