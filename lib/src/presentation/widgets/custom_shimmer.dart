import 'package:flutter/material.dart';

import 'package:tinycolor2/tinycolor2.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/extensions/buildcontext.dart';

class CustomShimmer extends StatelessWidget {
  const CustomShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isLightThemed
        ? context.colorScheme.background.desaturate(50).darken(2)
        : context.colorScheme.surface;
    final highlightColor = context.isLightThemed
        ? context.colorScheme.background.desaturate(50).lighten(2)
        : context.colorScheme.surface.lighten(5);

    return Shimmer(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[
          baseColor,
          baseColor,
          highlightColor,
          baseColor,
          baseColor
        ],
        stops: const <double>[0.0, 0.35, 0.5, 0.65, 1.0],
      ),
      child: Container(
        color: Colors.black,
        child: const SizedBox.expand(),
      ),
    );

    // return Shimmer.fromColors(
    //   //baseColor: Theme.of(context).colorScheme.surface,
    //   baseColor: Theme.of(context).colorScheme.surfaceVariant,
    //   highlightColor: Theme.of(context).colorScheme.onInverseSurface,
    //   child: Container(
    //     color: Colors.black,
    //   ),
    // );
  }
}
