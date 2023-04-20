import 'dart:developer';
import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loggy/loggy.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_prov;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'secret.dart';
import 'src/constants/box_types.dart';
import 'src/presentation/shiki.dart';
import 'src/presentation/widgets/window_watcher.dart';
import 'src/services/secure_storage/secure_storage_service.dart';

import 'src/data/repositories/cache_storage_repo.dart';
import 'src/services/http/cache_storage/cache_storage_provider.dart';
import 'src/services/http/cache_storage/cache_storage_service.dart';

import 'src/services/anime_database/anime_database_provider.dart';
import 'src/services/anime_database/anime_database_service.dart';
import 'src/services/shared_pref/shared_preferences_provider.dart';
import 'src/utils/target_platform.dart';

Future<void> main() async {
  try {
    debugPrint(Platform.operatingSystemVersion);
  } catch (exception, stacktrace) {
    debugPrint(exception.toString());
    debugPrint(stacktrace.toString());
  }

  WidgetsFlutterBinding.ensureInitialized();

  Intl.defaultLocale = 'ru_RU';
  initializeDateFormatting("ru_RU", null);

  TargetP.init();

  Loggy.initLoggy(
    logPrinter: const PrettyPrinter(),
  );

  Paint.enableDithering = true;

  if (!TargetP.instance.isDesktop) {
    AppMetrica.runZoneGuarded(
      () async {
        if (Platform.isAndroid) {
          await setOptimalDisplayMode();
          //await FlutterDisplayMode.setHighRefreshRate();
        }
        await runMain();
      },
    );
  } else {
    if (Platform.isWindows) {
      await windowManager.ensureInitialized();
      DiscordRPC.initialize();
    }
    await runMain();
  }
}

runMain() async {
  if (!kDebugMode && !TargetP.instance.isDesktop) {
    AppMetrica.activate(const AppMetricaConfig(
      kAppMetricaApiKey,
      logs: true,
      appVersion: '0.0.2',
      crashReporting: true,
      nativeCrashReporting: true, // ??
    ));
  }

  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  //   systemNavigationBarColor: Colors.transparent,
  // ));

  // await SystemChrome.setEnabledSystemUIMode(
  //   SystemUiMode.edgeToEdge,
  //   overlays: [SystemUiOverlay.top],
  // );

  await SecureStorageService.initialize();

  if (Platform.isWindows) {
    WindowOptions windowOptions = const WindowOptions(
      //size: Size(1200, 1200 / (16 / 9)),
      size: Size(1200, 800),
      // minimumSize: Size(900, 500),
      minimumSize: Size(900, 900 / (16 / 9)),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Shiki!',
      //alwaysOnTop: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final hiveDir = await path_prov.getApplicationSupportDirectory();

  await Hive.initFlutter(hiveDir.path);
  await Hive.openBox<dynamic>(BoxType.settings.name);

  final CacheStorageRepo initializedStorageService = CacheStorageImpl();
  await initializedStorageService.init();

  final animeDatabase = await LocalAnimeDatabaseImpl.initialization();
  await animeDatabase.migration();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      observers: const [
        if (kDebugMode) ProviderLogger(),
      ],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        animeDatabaseProvider.overrideWithValue(animeDatabase),
        cacheStorageServiceProvider
            .overrideWithValue(initializedStorageService),
      ],
      child: WindowWatcher(
        child: const ShikiApp(),
        onClose: () {},
      ),
    ),
  );
}

/// Logs all riverpod provider changes
class ProviderLogger extends ProviderObserver {
  /// Logs all riverpod provider changes
  const ProviderLogger();

  @override
  void didAddProvider(
    final ProviderBase provider,
    final Object? value,
    final ProviderContainer container,
  ) {
    log(
      'add: ${provider.name ?? provider.runtimeType}, '
      'value: $value',
      name: 'Riverpod',
    );
  }

  @override
  void didUpdateProvider(
    final ProviderBase provider,
    final Object? previousValue,
    final Object? newValue,
    final ProviderContainer container,
  ) {
    log(
      'update: ${provider.name ?? provider.runtimeType}, '
      'value: $newValue',
      name: 'Riverpod',
    );
  }

  @override
  void didDisposeProvider(
    final ProviderBase provider,
    final ProviderContainer container,
  ) {
    log(
      'dispose: ${provider.name ?? provider.runtimeType}',
      name: 'Riverpod',
    );
  }
}

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;

  final List<DisplayMode> sameResolution = supported
      .where(
        (DisplayMode m) => m.width == active.width && m.height == active.height,
      )
      .toList()
    ..sort(
      (DisplayMode a, DisplayMode b) => b.refreshRate.compareTo(a.refreshRate),
    );

  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;

  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);

  final t = await FlutterDisplayMode.preferred;
  print('refresh rate: ${t.refreshRate}');
}
