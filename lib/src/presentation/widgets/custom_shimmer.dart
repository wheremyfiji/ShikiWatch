import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';

import '../../utils/extensions/buildcontext.dart';

class CustomShimmer extends StatelessWidget {
  const CustomShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // final baseColor = context.isLightThemed
    //     ? context.colorScheme.background.desaturate(50).darken(5)
    //     : context.colorScheme.surfaceVariant;
    // final highlightColor = context.isLightThemed
    //     ? context.colorScheme.background.desaturate(50).lighten(5)
    //     : context.colorScheme.surfaceVariant.lighten(5);

    final baseColor = context.colorScheme.surfaceVariant;
    final hsl = HSLColor.fromColor(baseColor);
    final l = hsl.lightness;
    final highlightColor =
        hsl.withLightness(l < 0.5 ? l + 0.1 : l - 0.1).toColor();

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        color: Colors.black,
        child: const SizedBox.expand(),
      ),
    );
  }
}
