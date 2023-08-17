import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> options;

  const SettingsGroup({
    Key? key,
    required this.title,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      clipBehavior: Clip.hardEdge,
      elevation: 0,
      color: context.colorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context
              .colorScheme.surfaceVariant, //onInverseSurface  surfaceVariant
          width: 1,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
          ...options
        ],
      ),
    );
  }
}
