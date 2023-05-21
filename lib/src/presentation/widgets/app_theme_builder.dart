import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../constants/box_types.dart';
import '../../constants/hive_keys.dart';
import '../providers/app_theme_provider.dart';

class AppThemeBuilder extends ConsumerWidget {
  const AppThemeBuilder({
    super.key,
    required this.builder,
    required this.dynamicLight,
    required this.dynamicDark,
  });

  final Widget Function(BuildContext context, AppThemeData appTheme) builder;
  final ColorScheme? dynamicDark;
  final ColorScheme? dynamicLight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box(BoxType.settings.name).listenable(
        keys: [
          //appColorKey,
          dynamicThemeKey,
          //themeModeKey,
        ],
      ),
      builder: (context, value, _) {
        final bool isDynamic = value.get(dynamicThemeKey, defaultValue: true);
        // final ThemeMode themeMode =
        //     ThemeMode.values[value.get(themeModeKey, defaultValue: 0)];
        // final int color = value.get(appColorKey, defaultValue: 0xFF795548);
        // final Color primaryColor = Color(color);
        final appTheme = ref.watch(appThemeDataProvider);

        return builder(
          context,
          appTheme.fillWith(
              light: dynamicLight, dark: dynamicDark, useMonet: isDynamic),
        );
        // return DynamicColorBuilder(
        //   builder: (light, dark) => builder(
        //     context,
        //     appTheme.fillWith(light: light, dark: dark, useMonet: isDynamic),
        //   ),
        // );
      },
    );
  }
}
