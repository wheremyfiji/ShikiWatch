import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../utils/extensions/buildcontext.dart';

import '../providers/environment_provider.dart';

class StyledOverlayRegion extends ConsumerWidget {
  final Widget child;
  final bool? nightMode;

  const StyledOverlayRegion({
    super.key,
    required this.child,
    this.nightMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);
    final isNightMode = nightMode ?? context.brightness == Brightness.dark;
    final foregroundBrightness =
        isNightMode ? Brightness.light : Brightness.dark;

    final defStyle =
        (isNightMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent);

    final style = defStyle.copyWith(
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: foregroundBrightness,
      systemNavigationBarIconBrightness: foregroundBrightness,
      systemNavigationBarContrastEnforced: false,
    );

    return AnnotatedRegion(
      value: (environment.sdkVersion ?? 0) > 28 ? style : defStyle,
      child: child,
    );
  }
}

// class ShikiAnnotatedRegionWidget extends ConsumerWidget {
//   const ShikiAnnotatedRegionWidget({
//     super.key,
//     required this.child,
//   });
//   final Widget child;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // SystemChrome.setEnabledSystemUIMode(
//     //   SystemUiMode.edgeToEdge,
//     //   overlays: [SystemUiOverlay.top],
//     // );

//     final environment = ref.watch(environmentProvider);

//     final isDarkMode = context.brightness == Brightness.dark;
//     final brightness = isDarkMode ? Brightness.light : Brightness.dark;

//     final defaultStyle =
//         (isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
//             .copyWith(statusBarColor: Colors.transparent);

//     final customStyle = defaultStyle.copyWith(
//       statusBarIconBrightness: brightness,
//       systemNavigationBarIconBrightness: brightness,
//       systemNavigationBarContrastEnforced: false,
//       systemNavigationBarColor: Colors.transparent,
//     );

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: (environment.sdkVersion ?? 0) > 28 ? customStyle : defaultStyle,
//       child: child,
//     );
//   }
// }
