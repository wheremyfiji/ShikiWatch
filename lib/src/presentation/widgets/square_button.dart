import 'package:flutter/material.dart';

import '../../utils/extensions/buildcontext.dart';

class SquareButton extends StatelessWidget {
  const SquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 48.0,
    this.iconSize,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final rarius = size / 4;

    return SizedBox.square(
      dimension: size,
      child: Card(
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rarius),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(rarius),
          child: Icon(
            icon,
            size: iconSize ?? size / 2,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
