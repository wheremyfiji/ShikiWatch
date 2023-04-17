import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShikiAnnotatedRegionWidget extends StatelessWidget {
  const ShikiAnnotatedRegionWidget({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
        systemNavigationBarContrastEnforced: true,
      ),
      child: child,
    );
  }
}
