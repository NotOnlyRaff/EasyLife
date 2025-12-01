import 'package:flutter/material.dart';

class EasyLifeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EasyLifeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(90); // altezza custom

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 90,
      flexibleSpace: 
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF020617),       // quasi nero
              Color(0x88020B2E),       // blu scuro semi-trasparente
              Colors.transparent,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            'EasyLife',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: const Color(0xFF38BDF8),
              shadows: [
                Shadow(
                  offset: const Offset(0, 0),
                  blurRadius: 15,
                  color: const Color(0xFF38BDF8).withOpacity(0.8),
                ),
                Shadow(
                  offset: const Offset(0, 0),
                  blurRadius: 30,
                  color: const Color(0xFF22D3EE).withOpacity(0.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Icon(
            Icons.sports_esports,
            color: Color(0xFF38BDF8),
            size: 40,
          ),
        ],
      ),
    );
  }
}
