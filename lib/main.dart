import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_api_availability/google_api_availability.dart';
import 'package:path_provider/path_provider.dart' as path_prov;
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dart_discord_rpc/dart_discord_rpc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:media_kit/media_kit.dart';
import 'package:intl/intl.dart';

import 'src/services/anime_database/anime_database_provider.dart';
import 'src/services/anime_database/anime_database_service.dart';
import 'src/services/secure_storage/secure_storage_service.dart';
import 'src/presentation/providers/environment_provider.dart';
import 'src/services/preferences/preferences_service.dart';
import 'src/data/data_sources/environment_data_src.dart';
import 'src/utils/player/player_utils.dart';
// import 'src/utils/provider_logger.dart';
import 'src/utils/dynamic_colors.dart';
import 'src/presentation/shiki.dart';
import 'src/utils/app_utils.dart';

import 'secret.dart';

Future<void> main() async {
  if (kReleaseMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      Sentry.captureException(details.exception, stackTrace: details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      return true;
    };

    await runZonedGuarded(() async {
      await SentryFlutter.init(
        (options) {
          options.dsn = sentryDsn;
          options.tracesSampleRate = 0.8;
          options.captureFailedRequests = true;
        },
      );

      initApp();
    }, (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
    });
  } else {
    initApp();
  }

  // if (kReleaseMode) {
  //   await SentryFlutter.init(
  //     (options) {
  //       options.dsn = sentryDsn;
  //       options.tracesSampleRate = 1.0;
  //       options.captureFailedRequests = true;
  //     },
  //     appRunner: () => initApp(),
  //   );
  // } else {
  //   initApp();
  // }
}

void initApp() async {
  debugPrint(Platform.version);
  debugPrint(Platform.operatingSystemVersion);

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(900, 900 / (16 / 9)),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'ShikiWatch',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  MediaKit.ensureInitialized();

  Intl.defaultLocale = 'ru_RU';
  initializeDateFormatting("ru_RU", null);
  timeago.setLocaleMessages('ru', timeago.RuMessages());

  final appCacheDir = await path_prov.getTemporaryDirectory();

  bool hasGoogleServices = false;

  try {
    if (Platform.isAndroid) {
      hasGoogleServices = await GoogleApiAvailability.instance
              .checkGooglePlayServicesAvailability() ==
          GooglePlayServicesAvailability.success;
    }
  } catch (e) {
    debugPrint('hasGoogleServices: $e');
  }

  debugPrint('hasGoogleServices: $hasGoogleServices');

  AppUtils.init(appCacheDir, hasGoogleServices);

  final appDocumentsPath =
      await path_prov.getApplicationSupportDirectory().then((d) => d.path);
  PlayerUtils.init(appDocumentsPath);

  await SecureStorageService.initialize();

  if (Platform.isWindows || Platform.isLinux) {
    DiscordRPC.initialize();
  }

  final animeDatabase = await LocalAnimeDatabaseImpl.initialization();
  final preferencesService = await PreferencesService.initialize();
  final packageInfo = await PackageInfo.fromPlatform();
  final dynamicColors = await getDynamicColors();

  AndroidDeviceInfo? androidInfo;
  WindowsDeviceInfo? windowsInfo;

  if (Platform.isWindows) {
    windowsInfo = await DeviceInfoPlugin().windowsInfo;
  }

  if (Platform.isAndroid) {
    androidInfo = await DeviceInfoPlugin().androidInfo;

    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      debugPrint('FlutterDisplayMode: $e');
    }

    if (androidInfo.version.sdkInt > 28) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  //debugRepaintRainbowEnabled = true;

  runApp(
    ProviderScope(
      // observers: const [
      //   kDebugMode ? ProviderLogger() : SentryProviderObserver(),
      // ],
      overrides: [
        environmentProvider.overrideWithValue(
          EnvironmentDataSource(
            packageInfo: packageInfo,
            androidInfo: androidInfo,
            windowsInfo: windowsInfo,
          ),
        ),
        animeDatabaseProvider.overrideWithValue(animeDatabase),
        preferencesProvider.overrideWithValue(preferencesService),
        dynamicColorsProvider.overrideWithValue(dynamicColors)
      ],
      child: const ShikiApp(),
    ),
  );
}
