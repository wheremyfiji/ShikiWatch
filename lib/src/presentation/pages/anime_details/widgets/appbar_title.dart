import 'package:flutter/material.dart';

class AppbarTitle extends StatelessWidget {
  final String text;
  const AppbarTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
    );
  }
}
