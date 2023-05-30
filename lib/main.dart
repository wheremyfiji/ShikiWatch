import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loggy/loggy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart' as path_prov;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'secret.dart';
import 'src/constants/box_types.dart';
import 'src/data/data_sources/environment_data_src.dart';
import 'src/presentation/providers/environment_provider.dart';
import 'src/presentation/shiki.dart';
import 'src/services/secure_storage/secure_storage_service.dart';

import 'src/services/anime_database/anime_database_provider.dart';
import 'src/services/anime_database/anime_database_service.dart';
import 'src/services/shared_pref/shared_preferences_provider.dart';
import 'src/utils/target_platform.dart';

Future<void> main() async {
  if (kReleaseMode) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.captureFailedRequests = true;
      },
      appRunner: () => initApp(),
    );
  } else {
    initApp();
  }
}

void initApp() async {
  try {
    debugPrint(Platform.version);
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

  // if (Platform.isAndroid) {
  //   try {
  //     await FlutterDisplayMode.setHighRefreshRate();
  //     final t = await FlutterDisplayMode.preferred;
  //     debugPrint('refresh rate: ${t.refreshRate}');
  //   } on PlatformException catch (e) {
  //     debugPrint('setHighRefreshRate failed ($e)');
  //   }
  //   // https://stackoverflow.com/a/64184001
  //   //GestureBinding.instance.resamplingEnabled = true;
  // }

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    MediaKit.ensureInitialized();
    DiscordRPC.initialize();
  }

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
      title: 'ShikiWatch',
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

  final animeDatabase = await LocalAnimeDatabaseImpl.initialization();
  //await animeDatabase.migration();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final packageInfo = await PackageInfo.fromPlatform();

  AndroidDeviceInfo? androidInfo;
  WindowsDeviceInfo? windowsInfo;

  if (Platform.isAndroid) {
    androidInfo = await DeviceInfoPlugin().androidInfo;
  }

  if (Platform.isWindows) {
    windowsInfo = await DeviceInfoPlugin().windowsInfo;
  }

  //debugRepaintRainbowEnabled = true;

  runApp(
    ProviderScope(
      observers: const [
        if (kDebugMode) ProviderLogger(),
      ],
      overrides: [
        environmentProvider.overrideWithValue(
          EnvironmentDataSource(
            packageInfo: packageInfo,
            androidInfo: androidInfo,
            windowsInfo: windowsInfo,
          ),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
        animeDatabaseProvider.overrideWithValue(animeDatabase),
      ],
      // child: WindowWatcher(
      //   child: const ShikiApp(),
      //   onClose: () {},
      // ),
      child: const ShikiApp(),
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
