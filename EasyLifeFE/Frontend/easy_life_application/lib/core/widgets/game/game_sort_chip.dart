import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';

class GameSortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const GameSortChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.white.withOpacity(0.15),
      backgroundColor: Colors.black.withOpacity(0.20),
      side: BorderSide(
        color: selected ? Pallete.accentBlue : Colors.white.withOpacity(0.15),
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        color: selected ? Colors.white : Colors.white70,
      ),
    );
  }
}
