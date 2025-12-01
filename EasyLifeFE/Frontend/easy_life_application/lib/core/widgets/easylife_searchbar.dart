// lib/core/widgets/easylife_search_bar.dart
import 'package:flutter/material.dart';

class EasyLifeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onAddPressed;

  const EasyLifeSearchBar({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Container(
        // glow leggero sotto la linea → effetto neon
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 12,
              spreadRadius: -4,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Cerca o scrivi l’account da aggiungere...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
            ),

            // 🔍 PREFIX: cerchio cliccabile per la ricerca
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _RoundIconButton(
                icon: Icons.search,
                tooltip: 'Cerca',
                onTap: onSubmitted != null
                    ? () => onSubmitted!(controller.text)
                    : null,
              ),
            ),

            // 👤 SUFFIX: cerchio cliccabile per add account
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _RoundIconButton(
                icon: Icons.account_circle,
                tooltip: 'Aggiungi account',
                onTap: onAddPressed,
              ),
            ),

            // per non far esplodere le dimensioni
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),

            // niente box pieno
            filled: false,

            // solo underline, stile minimale
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
                width: 2.5,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

/// 🔘 Icona rotonda con ripple / effetto pressione
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled
            ? Colors.white.withOpacity(0.10)
            : Colors.white.withOpacity(0.04),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          splashColor: Colors.white.withOpacity(0.25),
          highlightColor: Colors.white.withOpacity(0.15),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white.withOpacity(enabled ? 0.95 : 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
