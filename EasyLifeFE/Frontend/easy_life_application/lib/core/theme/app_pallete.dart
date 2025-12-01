// lib/core/theme/app_pallete.dart
import 'package:flutter/material.dart';

class Pallete {
  // 🔵 Background gradient (come in HomePage)
  static const Color backgroundTop = Color(0xFF020617);   // blu quasi nero
  static const Color backgroundMiddle = Color(0xFF0F172A); // blu scuro
  static const Color backgroundBottom = Color(0xFF1D3557); // blu più morbido

  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundTop,
      backgroundMiddle,
      backgroundBottom,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ✏️ Testi
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFCBD5F5);

  // 🟦 Bordi / linee / card
  static const Color borderColor = Color(0xFF1F2937);

  // 💡 Accenti "neon" (per searchbar, icone, etc.)
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color accentGreen = Color(0xFF22C55E);

  // 🧱 Background di scaffold quando non usi il gradiente
  static const Color backgroundColor = backgroundMiddle;
}
