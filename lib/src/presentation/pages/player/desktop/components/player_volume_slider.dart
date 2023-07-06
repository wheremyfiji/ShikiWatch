import 'package:flutter/material.dart';

import '../../../../widgets/scrollable_slider.dart';

class PlayerVolumeSlider extends StatelessWidget {
  final double volume;

  final void Function(double) onChange;

  const PlayerVolumeSlider(
    this.volume, {
    super.key,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              child: ScrollableSlider(
                min: 0,
                max: 100,
                value: volume,
                onScrolledUp: () {
                  final vol =
                      (volume.clamp(0.0, 100.0) + 5.0).clamp(0.0, 100.0);

                  onChange(vol);
                },
                onScrolledDown: () {
                  final vol =
                      (volume.clamp(0.0, 100.0) - 5.0).clamp(0.0, 100.0);

                  onChange(vol);
                },
                onChanged: (double value) {
                  onChange(value);
                },
              ),
            ),
            const SizedBox(
              width: 16.0,
            ),
            Text(
              '${volume.round()}%',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
