import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  
  static OutlineInputBorder focusedBorder(Color color) => OutlineInputBorder(
  borderSide: BorderSide(color: color, width: 3.0),
  borderRadius: BorderRadius.circular(10.0),
);

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Pallete.backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: focusedBorder(Pallete.borderColor),
      focusedBorder: focusedBorder(Pallete.greenColor),
      ),
   );
}