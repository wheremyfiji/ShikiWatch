import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appThemeDataProvider = Provider.autoDispose<AppThemeDataNotifier>((ref) {
  return AppThemeDataNotifier();
});

class AppThemeData {
  const AppThemeData({
    required this.day,
    required this.night,
    required this.midnight,
  });

  final ThemeData day;
  final ThemeData night;
  final ThemeData midnight;
}

class AppThemeDataNotifier {
  late AppThemeData _data = _createAppThemeData();

  AppThemeData get data => _data;

  static const Color backgroundReducedSmearingColor =
      Color.fromRGBO(5, 5, 5, 1.0);

  AppThemeData fillWith(
      {ColorScheme? light, ColorScheme? dark, bool? useMonet}) {
    _data = _createAppThemeData(light: light, dark: dark, useMonet: useMonet);
    return _data;
  }

  AppThemeData _createAppThemeData(
      {ColorScheme? light, ColorScheme? dark, bool? useMonet}) {
    return AppThemeData(
      day: _createThemeData(light, Brightness.light, useMonet!),
      night: _createThemeData(dark, Brightness.dark, useMonet),
      midnight: _createThemeDataMidnight(dark, useMonet),
    );
  }

  ThemeData _createThemeData(
      ColorScheme? scheme, Brightness brightness, bool useMonet) {
    final isDark = brightness == Brightness.dark;
    final defScheme = isDark ? defDarkScheme : defLightScheme;
    final harmonized = useMonet ? scheme?.harmonized() ?? defScheme : defScheme;
    final colorScheme = harmonized.copyWith(
      //background: harmonized.surface.shade(isDark ? 30 : 3),
      outlineVariant: harmonized.outlineVariant.withOpacity(0.3),
    );
    final origin = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    return origin.copyWith(
      //pageTransitionsTheme: NoTransitions(),
      visualDensity: VisualDensity.standard,
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onSurface,
        //shadowColor: Colors.transparent,
        //surfaceTintColor: Colors.transparent,
      ),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      dialogBackgroundColor: colorScheme.background,
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: colorScheme.surface,
      ),
      cardTheme: origin.cardTheme.copyWith(
        elevation: 8,
        shadowColor: Colors.transparent,
      ),
      snackBarTheme: origin.snackBarTheme.copyWith(
        backgroundColor: colorScheme.secondaryContainer,
        contentTextStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        //backgroundColor: colorScheme.primaryContainer,
        //contentTextStyle: TextStyle(color: colorScheme.onPrimaryContainer),
      ),
      listTileTheme: origin.listTileTheme.copyWith(
        minVerticalPadding: 12,
        iconColor: colorScheme.onSurfaceVariant,
      ),

      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                color: colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              );
            }

            return TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            );
          },
        ),
      ),

      // dropdownMenuTheme: origin.dropdownMenuTheme.copyWith(
      //   inputDecorationTheme:
      //       const InputDecorationTheme(border: OutlineInputBorder()),
      //   //menuStyle: MenuStyle(),
      // ),
    );
  }

  ThemeData _createThemeDataMidnight(ColorScheme? scheme, bool useMonet) {
    final origin = _createThemeData(scheme, Brightness.dark, useMonet);
    return origin.copyWith(
      appBarTheme: AppBarTheme(
        //backgroundColor: Colors.black,
        backgroundColor: backgroundReducedSmearingColor,
        foregroundColor: origin.colorScheme.onSurface,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      primaryColor: backgroundReducedSmearingColor,
      canvasColor: backgroundReducedSmearingColor,
      scaffoldBackgroundColor: backgroundReducedSmearingColor,
      drawerTheme: origin.drawerTheme.copyWith(
        backgroundColor: backgroundReducedSmearingColor,
      ),
      cardTheme: origin.cardTheme.copyWith(
        elevation: 1,
      ),
      bottomSheetTheme: origin.bottomSheetTheme.copyWith(
        backgroundColor: backgroundReducedSmearingColor,
        elevation: 0,
      ),
      colorScheme: origin.colorScheme.copyWith(
        brightness: Brightness.dark,
        background: backgroundReducedSmearingColor,
        surface: origin.colorScheme.background,
      ),
      navigationRailTheme: origin.navigationRailTheme.copyWith(
        backgroundColor: backgroundReducedSmearingColor,
      ),
      navigationBarTheme: origin.navigationBarTheme.copyWith(
        elevation: 0,
        backgroundColor: backgroundReducedSmearingColor,
      ),
    );
  }

  static const defaultAccent = Colors.orange;
  //Color.fromARGB(255, 149, 30, 229);

  static final defLightScheme = ColorScheme.fromSeed(
    seedColor: defaultAccent,
    brightness: Brightness.light,
  );

  static final defDarkScheme = ColorScheme.fromSeed(
    seedColor: defaultAccent,
    brightness: Brightness.dark,
  );
}
