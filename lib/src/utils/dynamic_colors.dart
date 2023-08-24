import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DynamicColors {
  final ColorScheme light;
  final ColorScheme dark;

  const DynamicColors({
    required this.light,
    required this.dark,
  });
}

final dynamicColorsProvider = Provider<DynamicColors?>((ref) {
  throw Exception('dynamicColorsProvider not initialized');
}, name: 'dynamicColorsProvider');

Future<DynamicColors?> getDynamicColors() async {
  try {
    final corePalette = await DynamicColorPlugin.getCorePalette();
    if (corePalette != null) {
      debugPrint('dynamic_color: Core palette detected.');
      return DynamicColors(
        light: corePalette.toColorScheme(),
        dark: corePalette.toColorScheme(brightness: Brightness.dark),
      );
    }
  } on PlatformException {
    debugPrint('dynamic_color: Failed to obtain core palette.');
  }

  try {
    final accentColor = await DynamicColorPlugin.getAccentColor();
    if (accentColor != null) {
      debugPrint('dynamic_color: Accent color detected.');
      return DynamicColors(
        light: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.light,
        ),
        dark: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        ),
      );
    }
  } on PlatformException {
    debugPrint('dynamic_color: Failed to obtain accent color.');
  }

  debugPrint('dynamic_color: Dynamic color not detected on this device.');

  return null;
}
