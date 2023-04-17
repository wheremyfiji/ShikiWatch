import 'package:flutter/material.dart';

AppBarTheme appBarTheme(ColorScheme colors) {
  return AppBarTheme(
    elevation: 0,
    backgroundColor: colors.surface,
    foregroundColor: colors.onSurface,
  );
}

TabBarTheme tabBarTheme(ColorScheme colors) {
  return TabBarTheme(
    labelColor: colors.secondary,
    unselectedLabelColor: colors.onSurfaceVariant,
    // indicator: BoxDecoration(
    //   border: Border(
    //     bottom: BorderSide(
    //       color: colors.secondary,
    //       width: 2,
    //     ),
    //   ),
    // ),
  );
}
