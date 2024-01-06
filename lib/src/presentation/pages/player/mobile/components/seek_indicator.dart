import 'package:flutter/material.dart';

class SeekIndicator extends StatelessWidget {
  final String position;
  final String diff;

  const SeekIndicator({
    super.key,
    required this.position,
    required this.diff,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          position,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          diff,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
