import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/enums/color_scheme_variant.dart';
import '../providers/app_theme_provider.dart';

class AppThemeBuilder extends ConsumerWidget {
  const AppThemeBuilder({
    super.key,
    required this.builder,
    required this.dynamicLight,
    required this.dynamicDark,
    required this.colorSchemeVariant,
    required this.isDynamic,
  });

  final Widget Function(BuildContext context, AppThemeData appTheme) builder;
  final ColorScheme? dynamicDark;
  final ColorScheme? dynamicLight;
  final ColorSchemeVariant colorSchemeVariant;
  final bool isDynamic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeDataProvider);

    return builder(
      context,
      appTheme.fillWith(
        light: dynamicLight,
        dark: dynamicDark,
        useMonet: isDynamic,
        colorSchemeVariant: colorSchemeVariant,
      ),
    );
  }
}
