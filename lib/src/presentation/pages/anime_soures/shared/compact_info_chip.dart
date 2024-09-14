import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';

class CompactInfoChip extends StatelessWidget {
  const CompactInfoChip(
    this.title, {
    super.key,
    this.margin,
    this.padding,
    this.primary = false,
  });

  final String title;
  final bool primary;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;

    return Card(
      //margin: const EdgeInsets.all(0.0),
      margin: margin ?? const EdgeInsets.only(left: 4, right: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: primary ? cs.primaryContainer : cs.tertiaryContainer,
      //elevation: 0.0,
      child: Padding(
        //padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: primary ? cs.onPrimaryContainer : cs.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}
