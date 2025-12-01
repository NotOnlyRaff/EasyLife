
import 'dart:math';
import 'package:flutter/material.dart';

class EasyLifeRadialMenu extends StatefulWidget {
  /// Callback: quando clicchi un'icona ti passo l'indice:
  /// 0 = Games, 1 = Subs, 2 = Accounts, 3 = Users, 4 = Purchases
  final void Function(int index) onItemSelected;

  const EasyLifeRadialMenu({
    super.key,
    required this.onItemSelected,
  });

  @override
  State<EasyLifeRadialMenu> createState() => _EasyLifeRadialMenuState();
}

class _EasyLifeRadialMenuState extends State<EasyLifeRadialMenu> {
  bool _isOpen = false;
  final double _radius = 120; // distanza dal centro

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Mettiamo il timone verso il basso (tipo dock)
    final Offset center = Offset(size.width / 2, size.height * 0.75);

    // Definiamo le voci del menu
    final items = <_RadialItem>[
      _RadialItem(
        icon: Icons.videogame_asset,
        label: 'Games',
        onTap: () => widget.onItemSelected(0),
      ),
      _RadialItem(
        icon: Icons.subscriptions,
        label: 'Subs',
        onTap: () => widget.onItemSelected(1),
      ),
      _RadialItem(
        icon: Icons.account_circle,
        label: 'Accounts',
        onTap: () => widget.onItemSelected(2),
      ),
      _RadialItem(
        icon: Icons.person,
        label: 'Users',
        onTap: () => widget.onItemSelected(3),
      ),
      _RadialItem(
        icon: Icons.receipt_long,
        label: 'Purchases',
        onTap: () => widget.onItemSelected(4),
      ),
    ];

    return Stack(
      children: [
        // 🔘 Bottone centrale (timone)
        Positioned(
          left: center.dx - 30,
          top: center.dy - 30,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
            child: const Icon(Icons.sports_esports, size: 32,), // qui in futuro ci metti il timone custom
          ),
        ),

        // ▶️ Icone radiali
        ..._buildRadialItems(center, items),
      ],
    );
  }

  List<Widget> _buildRadialItems(Offset center, List<_RadialItem> items) {
    final List<Widget> widgets = [];
    final int n = items.length;

    for (int i = 0; i < n; i++) {
      final angle = (2 * pi / n) * i; // distribuite a 360°
      final double dx = center.dx + (_isOpen ? _radius * cos(angle) : 0);
      final double dy = center.dy + (_isOpen ? _radius * sin(angle) : 0);

      widgets.add(
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          left: dx - 24,
          top: dy - 24,
          child: Opacity(
            opacity: _isOpen ? 1 : 0,
            child: IconButton(
              icon: Icon(items[i].icon),
              onPressed: _isOpen
                  ? () {
                      items[i].onTap();
                      // opzionale: chiudi menu dopo il tap
                      setState(() {
                        _isOpen = false;
                      });
                    }
                  : null,
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}

class _RadialItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _RadialItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
