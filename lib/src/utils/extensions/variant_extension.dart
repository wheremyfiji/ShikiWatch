import 'package:flutter/material.dart';

import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:dynamic_color/dynamic_color.dart';

import '../../domain/enums/color_scheme_variant.dart';
import 'dynamic_scheme_extension.dart';

extension ColorSchemeVariantExt on ColorSchemeVariant {
  ColorScheme toColorScheme(
    Color color,
    Brightness brightness, {
    double contrastLevel = 0,
  }) =>
      toDynamicScheme(
        color,
        brightness,
        contrastLevel: contrastLevel,
      ).toColorPalette().toColorScheme(brightness: brightness);

  DynamicScheme toDynamicScheme(
    Color color,
    Brightness brightness, {
    double contrastLevel = 0,
  }) {
    final sourceColorHct = Hct.fromInt(color.value);
    final isDark = brightness == Brightness.dark;
    return switch (this) {
      ColorSchemeVariant.system => SchemeTonalSpot(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: contrastLevel,
        ),
      ColorSchemeVariant.monochrome => SchemeMonochrome(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: contrastLevel,
        ),
      ColorSchemeVariant.neutral => SchemeNeutral(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: contrastLevel,
        ),
      ColorSchemeVariant.vibrant => SchemeVibrant(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: contrastLevel,
        ),
      ColorSchemeVariant.expressive => SchemeExpressive(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: contrastLevel,
        ),
      ColorSchemeVariant.rainbow => SchemeRainbow(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: contrastLevel,
        ),
      ColorSchemeVariant.fruitSalad => SchemeFruitSalad(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: contrastLevel,
        ),
    };
  }
}

// extension VariantExtension on Variant {
//   ColorScheme toColorScheme(
//     Color color,
//     Brightness brightness, {
//     double contrastLevel = 0,
//   }) =>
//       toDynamicScheme(
//         color,
//         brightness,
//         contrastLevel: contrastLevel,
//       ).toColorPalette().toColorScheme(brightness: brightness);

//   DynamicScheme toDynamicScheme(
//     Color color,
//     Brightness brightness, {
//     double contrastLevel = 0,
//   }) {
//     final sourceColorHct = Hct.fromInt(color.value);
//     final isDark = brightness == Brightness.dark;
//     return switch (this) {
//       Variant.monochrome => SchemeMonochrome(
//           sourceColorHct: sourceColorHct,
//           isDark: isDark,
//           contrastLevel: contrastLevel,
//         ),
//       Variant.neutral => SchemeNeutral(
//           sourceColorHct: sourceColorHct,
//           isDark: isDark,
//           contrastLevel: contrastLevel,
//         ),
//       Variant.tonalSpot => SchemeTonalSpot(
//           sourceColorHct: sourceColorHct,
//           isDark: isDark,
//           contrastLevel: contrastLevel,
//         ),
//       Variant.vibrant => SchemeVibrant(
//           sourceColorHct: sourceColorHct,
//           isDark: isDark,
//           contrastLevel: contrastLevel,
//         ),
//       Variant.expressive => SchemeExpressive(
//           sourceColorHct: sourceColorHct,
//           isDark: isDark,
//           contrastLevel: contrastLevel,
//         ),
//       Variant.content => SchemeContent(
//           sourceColorHct: sourceColorHct,
//           isDark: isDark,
//           contrastLevel: contrastLevel,
//         ),
//       Variant.fidelity => SchemeFidelity(
//           sourceColorHct: sourceColorHct,
//           isDark: isDark,
//           contrastLevel: contrastLevel,
//         ),
//       Variant.rainbow => SchemeRainbow(
//           sourceColorHct: sourceColorHct,
//           isDark: isDark,
//           contrastLevel: contrastLevel,
//         ),
//       Variant.fruitSalad => SchemeFruitSalad(
//           sourceColorHct: sourceColorHct,
//           isDark: isDark,
//           contrastLevel: contrastLevel,
//         ),
//     };
//   }
// }
