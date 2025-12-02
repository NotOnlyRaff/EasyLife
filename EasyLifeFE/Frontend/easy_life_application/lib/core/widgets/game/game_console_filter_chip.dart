import 'package:flutter/material.dart';

class GameConsoleFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final ValueChanged<bool> onSelected;

  const GameConsoleFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: selected ? color : Colors.white24,
      ),
      backgroundColor: Colors.black.withOpacity(0.25),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
        fontSize: 12,
      ),
    );
  }
}
