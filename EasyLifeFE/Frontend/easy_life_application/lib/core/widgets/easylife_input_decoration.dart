// lib/core/widgets/easylife_input_decoration.dart
import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';

InputDecoration easyLifeFieldDecoration(
  String label, {
  String? hint,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.black.withOpacity(0.20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.08),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.08),
      ),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(
        color: Pallete.accentBlue,
        width: 1.6,
      ),
    ),
  );
}
