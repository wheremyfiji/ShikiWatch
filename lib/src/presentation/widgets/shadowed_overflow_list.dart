import 'package:flutter/material.dart';

import '../../utils/extensions/buildcontext.dart';

class ShadowedOverflowList extends StatelessWidget {
  final Widget child;
  final double width;

  const ShadowedOverflowList({
    super.key,
    required this.child,
    this.width = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0.0,
          left: -1.0,
          bottom: 0.0,
          child: SizedBox(
            width: width,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    context.colorScheme.background,
                    context.colorScheme.background.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          right: -1.0,
          bottom: 0.0,
          child: SizedBox(
            width: width,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    context.colorScheme.background,
                    context.colorScheme.background.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
