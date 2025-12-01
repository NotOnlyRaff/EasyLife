// lib/core/theme/app_theme.dart
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static OutlineInputBorder _focusedBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      );

  static final darkThemeMode = ThemeData.dark().copyWith(
    // 🔹 Colore base di sfondo (per schermate senza gradiente custom)
    scaffoldBackgroundColor: Pallete.backgroundColor,

    // 🎨 ColorScheme coerente con il blu "dark"
    colorScheme: const ColorScheme.dark(
      primary: Pallete.accentBlue,
      secondary: Pallete.accentGreen,
      background: Pallete.backgroundColor,
    ),

    // 🧭 AppBar di default (quella custom EasyLifeAppBar la sovrascrive comunque)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Pallete.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      iconTheme: IconThemeData(
        color: Pallete.textPrimary,
      ),
    ),

    // 🧾 Input base (non la searchbar custom, ma tutti gli altri TextField/Form)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white10,
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: _focusedBorder(Pallete.borderColor),
      focusedBorder: _focusedBorder(Pallete.accentBlue),
      hintStyle: const TextStyle(
        color: Pallete.textSecondary,
      ),
      labelStyle: const TextStyle(
        color: Pallete.textSecondary,
      ),
    ),

    // 🔤 Testi
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Pallete.textPrimary,
          displayColor: Pallete.textPrimary,
        ),

    // 🍞 SnackBar (per gli errori/feedback che stai usando nella Home)
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Pallete.backgroundMiddle,
      contentTextStyle: TextStyle(
        color: Pallete.textPrimary,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
