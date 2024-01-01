import 'package:flutter/material.dart';

class CustomLinearProgressIndicator extends StatelessWidget {
  final int value;
  final int maxValue;

  const CustomLinearProgressIndicator({
    super.key,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value / maxValue,
      borderRadius: BorderRadius.circular(4.0),
    );
  }
}
