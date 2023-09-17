import 'package:flutter/material.dart';

import '../../utils/extensions/buildcontext.dart';

class CustomInfoChip extends StatelessWidget {
  final String title;
  final bool elevation;

  const CustomInfoChip({
    super.key,
    required this.title,
    this.elevation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: context.theme.colorScheme.tertiaryContainer,
      elevation: elevation ? null : 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: Text(
          title,
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            color: context.theme.colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}
