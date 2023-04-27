import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/box_types.dart';
import '../constants/hive_keys.dart';
import '../utils/router.dart';
import 'providers/environment_provider.dart';
import 'widgets/app_theme_builder.dart';

// const _appMainColor = Colors.orange;
// bool monetUI = true;

String appTitle = kDebugMode ? 'ShikiDev' : 'ShikiWatch';

class ShikiApp extends ConsumerWidget {
  const ShikiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);

    if ((environment.sdkVersion ?? 0) > 28) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box(BoxType.settings.name).listenable(
        keys: [oledModeKey],
      ),
      builder: (context, value, child) {
        final bool isOled = value.get(oledModeKey, defaultValue: false);
        return AppThemeBuilder(
          builder: (context, appTheme) => MaterialApp.router(
            //useInheritedMediaQuery: true,
            debugShowCheckedModeBanner: false,
            theme: appTheme.day,
            darkTheme: isOled ? appTheme.midnight : appTheme.night,
            title: appTitle,
            themeMode: ThemeMode.system,
            routerConfig: router,
          ),
        );
      },
    );
  }
}
