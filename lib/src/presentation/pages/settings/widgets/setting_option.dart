import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';

class SettingsOption extends StatelessWidget {
  const SettingsOption({
    Key? key,
    required this.title,
    this.icon,
    this.trailing,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = onTap == null
        ? context.colorScheme.onBackground.withOpacity(0.6)
        : context.colorScheme.onBackground;

    return ListTile(
      leading: icon == null
          ? null
          : Icon(
              icon,
              color: color,
            ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.colorScheme.onBackground.withOpacity(0.8),
              ),
            )
          : null,
      onTap: onTap,
      trailing: trailing,
    );
  }
}
