import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ScrollableSlider extends StatelessWidget {
  final double min;
  final double max;
  final bool enabled;
  final double value;
  final Color? color;
  final Color? secondaryColor;
  final VoidCallback onScrolledUp;
  final VoidCallback onScrolledDown;
  final void Function(double) onChanged;
  final bool inferSliderInactiveTrackColor;
  final bool mobile;

  const ScrollableSlider({
    Key? key,
    required this.min,
    required this.max,
    this.enabled = true,
    required this.value,
    this.color,
    this.secondaryColor,
    required this.onScrolledUp,
    required this.onScrolledDown,
    required this.onChanged,
    this.inferSliderInactiveTrackColor = true,
    this.mobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          if (event.scrollDelta.dy < 0) {
            onScrolledUp();
          }
          if (event.scrollDelta.dy > 0) {
            onScrolledDown();
          }
        }
      },
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 2.0,
          trackShape: CustomTrackShape(),
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 6.0,
            pressedElevation: 4.0,
            elevation: 2.0,
          ),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
          overlayColor:
              (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.4),
          thumbColor: enabled
              ? (color ?? Theme.of(context).colorScheme.primary)
              : Theme.of(context).disabledColor,
          activeTrackColor: enabled
              ? (color ?? Theme.of(context).colorScheme.primary)
              : Theme.of(context).disabledColor,
          inactiveTrackColor: enabled
              ? (inferSliderInactiveTrackColor
                  ? ((secondaryColor != null
                          ? (secondaryColor?.computeLuminance() ?? 0.0) < 0.5
                          : Theme.of(context).brightness == Brightness.dark)
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.2))
                  : Colors.white.withOpacity(0.4))
              : Theme.of(context).disabledColor.withOpacity(0.2),
        ),
        child: Slider(
          value: value,
          onChanged: enabled ? onChanged : null,
          min: min,
          max: max,
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
