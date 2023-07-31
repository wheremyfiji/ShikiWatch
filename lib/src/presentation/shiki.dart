import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';

import '../utils/router.dart';

import 'providers/environment_provider.dart';
import 'providers/settings_provider.dart';
import 'widgets/app_theme_builder.dart';

// const _appMainColor = Colors.orange;
// bool monetUI = true;

String appTitle = kDebugMode ? 'ShikiDev' : 'ShikiWatch';

class ShikiApp extends ConsumerWidget {
  const ShikiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final environment = ref.watch(environmentProvider);

    final ThemeMode themeMode =
        ref.watch(settingsProvider.select((settings) => settings.theme));

    final bool dynamicColors = ref
        .watch(settingsProvider.select((settings) => settings.dynamicColors));

    final bool oledMode =
        ref.watch(settingsProvider.select((settings) => settings.oledMode));

    if ((environment.sdkVersion ?? 0) > 28) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        if (environment.androidInfo != null &&
            lightDynamic == null &&
            environment.sdkVersion! > 30) {
          return const SizedBox.shrink();
        }

        return AppThemeBuilder(
          dynamicLight: lightDynamic,
          dynamicDark: darkDynamic,
          isDynamic: dynamicColors,
          builder: (context, appTheme) => MaterialApp.router(
            //themeAnimationDuration: Duration.zero,
            debugShowCheckedModeBanner: false,

            //showPerformanceOverlay: true,
            //checkerboardOffscreenLayers: true,
            //checkerboardRasterCacheImages: true,

            theme: appTheme.day,
            darkTheme: oledMode ? appTheme.midnight : appTheme.night,
            title: appTitle,
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
      },
    );
  }
}

class ScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
