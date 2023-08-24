import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../utils/dynamic_colors.dart';
import '../utils/router.dart';

import 'providers/environment_provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/app_theme_builder.dart';

//String appTitle = kDebugMode ? 'ShikiDev' : 'ShikiWatch';

class ShikiApp extends ConsumerWidget {
  const ShikiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final environment = ref.watch(environmentProvider);
    final dynamicColors = ref.watch(dynamicColorsProvider);

    final (themeMode, useDynamicColors, oledMode) = ref.watch(
        settingsProvider.select((s) => (s.theme, s.dynamicColors, s.oledMode)));

    if ((environment.sdkVersion ?? 0) > 28) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return AppThemeBuilder(
      dynamicLight: dynamicColors?.light,
      dynamicDark: dynamicColors?.dark,
      isDynamic: useDynamicColors,
      builder: (context, appTheme) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        //showPerformanceOverlay: true,
        //checkerboardOffscreenLayers: true,
        //checkerboardRasterCacheImages: true,
        theme: appTheme.light,
        darkTheme: oledMode ? appTheme.oled : appTheme.dark,
        title: kDebugMode ? 'ShikiDev' : 'ShikiWatch',
        themeMode: themeMode,
        routerConfig: router,
        scrollBehavior: ScrollBehavior(),
        builder: (context, child) {
          if (!kDebugMode) {
            ErrorWidget.builder = (FlutterErrorDetails error) {
              return const Center(
                child: Text('Произошла ошибка'),
              );
            };
          }

          /// fix high textScaleFactor
          final mediaQuery = MediaQuery.of(context);
          final scale = mediaQuery.textScaleFactor.clamp(0.8, 1).toDouble();

          return MediaQuery(
            data: mediaQuery.copyWith(textScaleFactor: scale),
            child: child!,
          );
        },
      ),
    );
  }
}

class ScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
