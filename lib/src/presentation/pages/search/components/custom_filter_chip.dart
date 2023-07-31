import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool)? onSelected;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      padding: const EdgeInsets.all(6), //0
      shadowColor: Colors.transparent,
      elevation: 0,

      label: Text(label),
      selected: selected,
      onSelected: (value) => onSelected == null ? () {} : onSelected!(value),
    );
  }
}
