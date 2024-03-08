import 'package:flutter/material.dart';

import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';

import '../../utils/extensions/variant_extension.dart';

final appThemeDataProvider = Provider<AppThemeDataNotifier>((ref) {
  return AppThemeDataNotifier();
});

class AppThemeData {
  const AppThemeData({
    required this.light,
    required this.dark,
    required this.oled,
  });

  final ThemeData light;
  final ThemeData dark;
  final ThemeData oled;
}

class AppThemeDataNotifier {
  late AppThemeData _data = _createAppThemeData();

  AppThemeData get data => _data;

  static const Color backgroundReducedSmearingColor = Colors.black;
  //Color.fromRGBO(5, 5, 5, 1.0);

  AppThemeData fillWith({
    ColorScheme? light,
    ColorScheme? dark,
    bool? useMonet,
    Variant? colorSchemeVariant,
  }) {
    _data = _createAppThemeData(
      light: light,
      dark: dark,
      useMonet: useMonet,
      colorSchemeVariant: colorSchemeVariant,
    );
    return _data;
  }

  AppThemeData _createAppThemeData({
    ColorScheme? light,
    ColorScheme? dark,
    bool? useMonet,
    Variant? colorSchemeVariant,
  }) {
    return AppThemeData(
      light: _createThemeData(
        light,
        Brightness.light,
        useMonet!,
        colorSchemeVariant!,
      ),
      dark: _createThemeData(
        dark,
        Brightness.dark,
        useMonet,
        colorSchemeVariant,
      ),
      oled: _createThemeDataMidnight(
        dark,
        useMonet,
        colorSchemeVariant,
      ),
    );
  }

  ThemeData _createThemeData(
    ColorScheme? scheme,
    Brightness brightness,
    bool useMonet,
    Variant colorSchemeVariant,
  ) {
    final isDark = brightness == Brightness.dark;
    final defScheme = isDark ? defDarkScheme : defLightScheme;
    final harmonized = useMonet ? scheme?.harmonized() ?? defScheme : defScheme;
    // final colorScheme = harmonized.copyWith(
    //   outlineVariant: harmonized.outlineVariant.withOpacity(0.3),
    // );

    final colorScheme = colorSchemeVariant
        .toColorScheme(
          harmonized.primary,
          brightness,
        )
        .harmonized();

    final origin = isDark
        ? ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            fontFamily: 'Jost',
          )
        : ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            fontFamily: 'Jost',
          );

    return origin.copyWith(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme.copyWith(
        outlineVariant: colorScheme.outlineVariant.withOpacity(0.3),
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
      ),
      listTileTheme: origin.listTileTheme.copyWith(
        minVerticalPadding: 12,
        iconColor: colorScheme.onSurfaceVariant,
      ),
      tabBarTheme: origin.tabBarTheme.copyWith(
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
      ),
      // navigationBarTheme: NavigationBarThemeData(
      //   labelTextStyle: MaterialStateProperty.resolveWith(
      //     (states) {
      //       if (states.contains(MaterialState.selected)) {
      //         return TextStyle(
      //           color: colorScheme.onSurface,
      //           fontSize: 12,
      //           //fontWeight: FontWeight.bold,
      //         );
      //       }

      //       return TextStyle(
      //         color: colorScheme.onSurfaceVariant,
      //         fontSize: 12,
      //         //fontWeight: FontWeight.normal,
      //       );
      //     },
      //   ),
      // ),
    );
  }

  ThemeData _createThemeDataMidnight(
    ColorScheme? scheme,
    bool useMonet,
    Variant colorSchemeVariant,
  ) {
    final origin = _createThemeData(
      scheme,
      Brightness.dark,
      useMonet,
      colorSchemeVariant,
    );

    return origin.copyWith(
      appBarTheme: AppBarTheme(
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

  static const defaultAccent = Colors.lightBlue;

  static final defLightScheme = ColorScheme.fromSeed(
    seedColor: defaultAccent,
    brightness: Brightness.light,
  );

  static final defDarkScheme = ColorScheme.fromSeed(
    seedColor: defaultAccent,
    brightness: Brightness.dark,
  );
}
