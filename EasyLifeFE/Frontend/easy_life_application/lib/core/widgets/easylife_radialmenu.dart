import 'dart:math';
import 'package:flutter/material.dart';

class EasyLifeRadialMenu extends StatefulWidget {
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

  // distanza dal centro per le icone
  final double _radius = 125;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // 🎯 Centro del menu: molto vicino al fondo ma sopra la safe area
    const double fabRadius = 30;
    const double bottomPadding = 32;
    final Offset center = Offset(
      size.width / 2,
      size.height - bottomPadding - fabRadius,
    );

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
        // 🔘 Bottone centrale (timone) – fissato in basso
        Positioned(
          left: center.dx - fabRadius,
          top: center.dy - fabRadius,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
            elevation: 6,
            child: const Icon(
              Icons.sports_esports,
              size: 32,
            ),
          ),
        ),

        // ▶️ Icone radiali (a ventaglio verso l'alto)
        ..._buildRadialItems(center, items),
      ],
    );
  }

  List<Widget> _buildRadialItems(Offset center, List<_RadialItem> items) {
    final List<Widget> widgets = [];
    final int n = items.length;

    // 🔥 invece di 360°, le distribuiamo in un ARCO verso l’alto
    // centro a -90° (in alto), ventaglio -150° → -30°
    const double startAngle = -8 * pi / 9; // -150°
    const double endAngle = -pi / 9;       // -30°
    final double step = (endAngle - startAngle) / (n - 1);

    for (int i = 0; i < n; i++) {
      final double angle = startAngle + step * i;

      final double targetDx = center.dx + _radius * cos(angle);
      final double targetDy = center.dy + _radius * sin(angle);

      widgets.add(
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutQuad,
          left: (_isOpen ? targetDx : center.dx) - 28,
          top: (_isOpen ? targetDy : center.dy) - 28,
          child: IgnorePointer(
            ignoring: !_isOpen, // quando chiuso, non intercetta i tap
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isOpen ? 1 : 0,
              child: _RadialActionButton(
                icon: items[i].icon,
                onTap: () {
                  items[i].onTap();
                  setState(() {
                    _isOpen = false;
                  });
                },
              ),
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

/// 🔘 Pulsante circolare custom, hitbox grande e tappabile DAPPERTUTTO
class _RadialActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RadialActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // tutta la circonferenza è tappabile
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.50),
            border: Border.all(
              color: Colors.white.withOpacity(0.20),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
