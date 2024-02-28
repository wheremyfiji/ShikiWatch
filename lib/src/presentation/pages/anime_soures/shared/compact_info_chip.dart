import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';

class CompactInfoChip extends StatelessWidget {
  const CompactInfoChip(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      //margin: const EdgeInsets.all(0.0),
      margin: const EdgeInsets.only(left: 4, right: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: context.theme.colorScheme.tertiaryContainer,
      //elevation: 0.0,
      child: Padding(
        //padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: context.theme.colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}
