import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/game_model.dart';

class GameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  String _formatMoney(double value) {
    return '${value.toStringAsFixed(2)} €';
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final margin = game.salePrice - game.cost;
    final marginColor =
        margin >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 18,
                spreadRadius: -4,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICONA / AVATAR
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4F46E5),
                      Color(0xFF06B6D4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.videogame_asset,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),

              // TESTI PRINCIPALI
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NOME + STATO
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            game.gameName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _ActiveBadge(isActive: game.isActive),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // PROFILO + ORDINE
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Profile: ${game.gameProfileId}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Order: ${game.orderNumber}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // 🔹 SOLDI + MARGINE → WRAP (niente overflow)
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Price: ${_formatMoney(game.price)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          'Sale: ${_formatMoney(game.salePrice)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: marginColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: marginColor.withOpacity(0.7),
                            ),
                          ),
                          child: Text(
                            'Δ ${margin.toStringAsFixed(2)}€',
                            style: TextStyle(
                              fontSize: 11,
                              color: marginColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 🔹 NAZIONE + DATE → WRAP (niente overflow)
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          game.nation,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Acq: ${_formatDate(game.purchaseDate)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          'Vend: ${_formatDate(game.saleDate)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),

                    if (game.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        game.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.75),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // COLONNA DESTRA: console badges (teniamo width fissa per sicurezza)
              SizedBox(
                width: 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ConsoleBadge(
                      label: 'PS5 P',
                      available: game.isPS5PrimaryAvailable,
                    ),
                    const SizedBox(height: 4),
                    _ConsoleBadge(
                      label: 'PS5 S',
                      available: game.isPS5SecondaryAvailable,
                    ),
                    const SizedBox(height: 4),
                    _ConsoleBadge(
                      label: 'PS4 P',
                      available: game.isPS4PrimaryAvailable,
                    ),
                    const SizedBox(height: 4),
                    _ConsoleBadge(
                      label: 'PS4 S',
                      available: game.isPS4SecondaryAvailable,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool isActive;

  const _ActiveBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF4CAF50) : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.8)),
        color: color.withOpacity(0.15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.pause_circle_filled,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'ACTIVE' : 'INACTIVE',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleBadge extends StatelessWidget {
  final String label;
  final bool available;

  const _ConsoleBadge({
    required this.label,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    final color = available ? Pallete.accentBlue : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.7)),
        color:
            available ? color.withOpacity(0.20) : Colors.black.withOpacity(0.25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            available ? Icons.check : Icons.close,
            size: 11,
            color: available ? Colors.white : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
