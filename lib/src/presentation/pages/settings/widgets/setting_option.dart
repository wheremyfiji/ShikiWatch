import 'package:flutter/material.dart';

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
    return ListTile(
      leading: icon == null
          ? null
          : Icon(
              icon,
              color: Theme.of(context).colorScheme.onBackground,
            ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )
          : null,
      onTap: onTap,
      trailing: trailing,
    );
  }
}
