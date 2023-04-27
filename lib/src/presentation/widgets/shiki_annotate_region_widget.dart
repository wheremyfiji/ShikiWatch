import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../providers/environment_provider.dart';

class ShikiAnnotatedRegionWidget extends ConsumerWidget {
  const ShikiAnnotatedRegionWidget({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.edgeToEdge,
    //   overlays: [SystemUiOverlay.top],
    // );

    final environment = ref.watch(environmentProvider);

    final isDarkMode = context.brightness == Brightness.dark;
    final brightness = isDarkMode ? Brightness.light : Brightness.dark;

    final defaultStyle =
        (isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent);

    final customStyle = defaultStyle.copyWith(
      statusBarIconBrightness: brightness,
      systemNavigationBarIconBrightness: brightness,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarColor: Colors.transparent,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (environment.sdkVersion ?? 0) > 28 ? customStyle : defaultStyle,
      child: child,
    );
  }
}
