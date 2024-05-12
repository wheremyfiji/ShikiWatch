import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class CustomFlexibleSpace extends StatelessWidget {
  const CustomFlexibleSpace({
    super.key,
    required this.title,
    required this.background,
    this.style,
    this.act = false,
  });

  final String title;
  final Widget? background;
  final TextStyle? style;
  final bool act;

  @override
  Widget build(BuildContext context) {
    final FlexibleSpaceBarSettings settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

    final double deltaExtent = settings.maxExtent - settings.minExtent;

    final double t = clampDouble(
        1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent,
        0.0,
        1.0);

    final fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
    const fadeEnd = 1.0;

    final double opacity = settings.maxExtent == settings.minExtent
        ? 1.0
        : 1.0 - Interval(fadeStart, fadeEnd).transform(t);

    double height = settings.maxExtent;

    final List<Widget> children = <Widget>[];

    // background
    if (background != null) {
      children.add(
        Positioned(
          top: -(settings.maxExtent - settings.currentExtent),
          left: 0.0,
          right: 0.0,
          height: height,
          child: Opacity(
            opacity: opacity,
            child: background,
          ),
        ),
      );
    }

    // title
    // final double scaleValue = Tween<double>(begin: 1.5, end: 1.0).transform(t);
    // final Matrix4 scaleTransform = Matrix4.identity()
    //   ..scale(scaleValue, scaleValue, 1.0);

    final ThemeData theme = Theme.of(context);

    TextStyle titleStyle = style ?? theme.primaryTextTheme.titleLarge!;
    titleStyle = titleStyle.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(1 - opacity),
    );

    children.add(
      Padding(
        padding:
            EdgeInsets.only(left: 72.0, bottom: 14.0, right: act ? 42.0 : 0.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
        ),
      ),
    );

    return ClipRect(child: Stack(children: children));
  }
}
