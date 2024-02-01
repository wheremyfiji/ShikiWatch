import 'package:flutter/material.dart';

const List<double> _playbackRates = <double>[
  0.25,
  0.5,
  1.0,
  1.25,
  1.5,
  2.0,
];

class PlayerSpeedPopUp extends StatelessWidget {
  final double playbackSpeed;
  final Function(double) onSelected;

  const PlayerSpeedPopUp({
    super.key,
    required this.playbackSpeed,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: playbackSpeed,
      tooltip: 'Скорость воспроизведения',
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<double>>[
          for (final double speed in _playbackRates)
            PopupMenuItem<double>(
              value: speed,
              child: Text('${speed}x'),
            )
        ];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${playbackSpeed}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(
              width: 4,
            ),
            const Icon(Icons.expand_more)
          ],
        ),
      ),
    );
  }
}
