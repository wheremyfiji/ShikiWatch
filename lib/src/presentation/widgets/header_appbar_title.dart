import 'package:flutter/material.dart';

import '../../utils/extensions/buildcontext.dart';

class HeaderAppBarTitle extends StatelessWidget {
  final String text;

  const HeaderAppBarTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.theme.colorScheme.onBackground,
      ),
    );
  }
}
