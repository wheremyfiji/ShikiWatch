import 'package:flutter/material.dart';

import '../../../utils/extensions/buildcontext.dart';

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool zeroPadding;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.zeroPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: zeroPadding ? const EdgeInsets.all(0) : null,
      //titleAlignment: ListTileTitleAlignment.titleHeight,
      leading: Icon(
        icon,
        color: context.colorScheme.secondary,
      ),
      title: Text(
        title,
        style: context.textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(
          fontSize: 14.0,
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
    );
  }
}
