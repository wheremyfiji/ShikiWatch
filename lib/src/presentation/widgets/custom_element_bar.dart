import 'package:flutter/material.dart';

Color getStatElementColor({required BuildContext ctx, required int index}) {
  switch (index) {
    case 0:
      return MediaQuery.of(ctx).platformBrightness == Brightness.dark
          ? Colors.lime.shade300
          : Colors.lime.shade400;
    case 1:
      return MediaQuery.of(ctx).platformBrightness == Brightness.dark
          ? Colors.green.shade300
          : Colors.green.shade400;
    case 2:
      return MediaQuery.of(ctx).platformBrightness == Brightness.dark
          ? Colors.deepPurple.shade300
          : Colors.deepPurple.shade400;
    case 3:
      return MediaQuery.of(ctx).platformBrightness == Brightness.dark
          ? Colors.red.shade300
          : Colors.red.shade400;
    case 4:
      return MediaQuery.of(ctx).platformBrightness == Brightness.dark
          ? Colors.blue.shade300
          : Colors.blue.shade400;

    default:
      return Colors.white;
  }
}

Color getStatElementColorUserProfile(
    {required BuildContext ctx, required int index}) {
  switch (index) {
    case 0:
      return MediaQuery.of(ctx).platformBrightness == Brightness.dark
          ? Colors.lime.shade300
          : Colors.lime.shade400;
    case 1:
      return MediaQuery.of(ctx).platformBrightness == Brightness.dark
          ? Colors.deepPurple.shade300
          : Colors.deepPurple.shade400;
    case 2:
      return MediaQuery.of(ctx).platformBrightness == Brightness.dark
          ? Colors.green.shade300
          : Colors.green.shade400;

    case 3:
      return MediaQuery.of(ctx).platformBrightness == Brightness.dark
          ? Colors.blue.shade300
          : Colors.blue.shade400;
    case 4:
      return MediaQuery.of(ctx).platformBrightness == Brightness.dark
          ? Colors.red.shade300
          : Colors.red.shade400;

    default:
      return Colors.white;
  }
}

class CustomElementBar extends StatelessWidget {
  final List<int> values;
  final double height;
  final double radius;
  final bool p;

  const CustomElementBar({
    super.key,
    required this.values,
    required this.height,
    this.radius = 8.0,
    this.p = false,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int sum = values.reduce((a, b) => a + b);
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            padding: const EdgeInsets.all(0.0),
            width: constraints.maxWidth,
            child: Wrap(
              spacing: 0.0,
              runSpacing: 0.0,
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                ...List.generate(
                  values.length,
                  (index) {
                    final elementWidthPercent = values[index] * 100 / sum; //~
                    final elementWidth = elementWidthPercent *
                        (constraints.maxWidth - 0.01) /
                        100;
                    return Container(
                      width: elementWidth.toDouble(),
                      height: height,
                      color: p
                          ? getStatElementColorUserProfile(
                              ctx: context, index: index)
                          : getStatElementColor(ctx: context, index: index),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
