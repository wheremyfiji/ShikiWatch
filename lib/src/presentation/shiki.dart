import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../constants/box_types.dart';
import '../constants/hive_keys.dart';
import '../utils/router.dart';
import 'widgets/app_theme_builder.dart';
import 'widgets/shiki_annotate_region_widget.dart';

// const _appMainColor = Colors.orange;
// bool monetUI = true;

class ShikiApp extends StatelessWidget {
  const ShikiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShikiAnnotatedRegionWidget(
      child: ValueListenableBuilder<Box>(
        valueListenable: Hive.box(BoxType.settings.name).listenable(
          keys: [oledModeKey],
        ),
        builder: (context, value, child) {
          final bool isOled = value.get(oledModeKey, defaultValue: false);
          return AppThemeBuilder(
            builder: (context, appTheme) => MaterialApp.router(
              useInheritedMediaQuery: true,
              debugShowCheckedModeBanner: false,
              theme: appTheme.day,
              darkTheme: isOled ? appTheme.midnight : appTheme.night,
              title: 'ShikiWatch',
              themeMode: ThemeMode.system,
              routerConfig: router,
            ),
          );
        },
      ),
    );
  }
}
