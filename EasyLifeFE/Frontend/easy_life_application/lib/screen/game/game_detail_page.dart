import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/game_model.dart';
import 'package:easy_life_application/services/game/game_service.dart';
import 'package:easy_life_application/screen/game/game_edit_page.dart';

// 👇 Adatta i path a come hai strutturato il progetto
import 'package:easy_life_application/services/account/account_service.dart';
import 'package:easy_life_application/models/account_model.dart';
import 'package:easy_life_application/screen/account/account_detail_page.dart';

class GameDetailPage extends StatefulWidget {
  final GameModel game;

  const GameDetailPage({
    super.key,
    required this.game,
  });

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  late GameModel _game;
  late final GameService _gameService;

  // 👇 stato per account/email
  late final AccountService _accountService;
  AccountModel? _account;
  bool _isAccountLoading = false;
  String? _accountError;

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
    _gameService = GameService();

    _accountService = AccountService();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _isAccountLoading = true;
      _accountError = null;
    });

    try {
      final acc = await _accountService.getAccountById(_game.accountId);
      if (!mounted) return;
      setState(() {
        _account = acc;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _accountError = 'Errore caricamento account: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAccountLoading = false;
        });
      }
    }
  }

  // ------- HELPERS -------

  String _formatMoney(double value) {
    return '${value.toStringAsFixed(2)} €';
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
  }

  double get _margin => _game.salePrice - _game.cost;
  double get _marginPercent =>
      _game.cost == 0 ? 0 : (_margin / _game.cost) * 100;

  Color get _marginColor =>
      _margin >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

  // ------- UI -------

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = media.size.width > 700 ? 600.0 : double.infinity;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Game'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: Pallete.mainBackgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildFinanceCard(context),
                    const SizedBox(height: 16),
                    _buildMetaCard(context),
                    if (_game.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDescriptionCard(context),
                    ],
                    const SizedBox(height: 24),
                    _buildActions(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // HEADER: titolo + stato + margine

  Widget _buildHeader(BuildContext context) {
    final marginColor = _marginColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar gioco
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
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
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome gioco
              Text(
                _game.gameName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Profile ID + Order
              Wrap(
                spacing: 8,
                runSpacing: 2,
                children: [
                  Text(
                    'Profile: ${_game.gameProfileId}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Order: ${_game.orderNumber}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Stato + Margine pill
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _activeBadge(_game.isActive),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: marginColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: marginColor.withOpacity(0.9)),
                    ),
                    child: Text(
                      'Δ ${_margin.toStringAsFixed(2)}€ (${_marginPercent.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: marginColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // CARD 1: finanza

  Widget _buildFinanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Finanza & Prezzi'),
          const SizedBox(height: 12),

          // Price / Sale / Cost
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _statChip(
                label: 'Prezzo base',
                value: _formatMoney(_game.price),
                icon: Icons.sell_outlined,
              ),
              _statChip(
                label: 'Vendita',
                value: _formatMoney(_game.salePrice),
                icon: Icons.shopping_bag_outlined,
              ),
              _statChip(
                label: 'Costo',
                value: _formatMoney(_game.cost),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Margine
          Row(
            children: [
              Icon(
                _margin >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 18,
                color: _marginColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _margin >= 0
                      ? 'Margine positivo: ${_margin.toStringAsFixed(2)}€ (${_marginPercent.toStringAsFixed(1)}%)'
                      : 'Margine negativo: ${_margin.toStringAsFixed(2)}€ (${_marginPercent.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: _marginColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CARD 2: meta + date + console

  Widget _buildMetaCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Dettagli & Meta'),
          const SizedBox(height: 12),

          _infoRow(
            icon: Icons.location_on_outlined,
            label: 'Nation',
            value: _game.nation,
          ),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Purchase date',
            value: _formatDate(_game.purchaseDate),
          ),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.event_available_outlined,
            label: 'Sale date',
            value: _formatDate(_game.saleDate),
          ),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Order number',
            value: _game.orderNumber,
          ),
          const SizedBox(height: 8),

          // 👇 QUI: invece di Account ID, mostriamo l’EMAIL cliccabile
          _buildAccountRow(context),

          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 16),
          const SizedBox(height: 6),

          Text(
            'Disponibilità slot',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _consoleBadge('PS5 Primary', _game.isPS5PrimaryAvailable),
              _consoleBadge('PS5 Secondary', _game.isPS5SecondaryAvailable),
              _consoleBadge('PS4 Primary', _game.isPS4PrimaryAvailable),
              _consoleBadge('PS4 Secondary', _game.isPS4SecondaryAvailable),
            ],
          ),
        ],
      ),
    );
  }

  /// Riga Account: gestisce loading, errore e caso con email + link
  Widget _buildAccountRow(BuildContext context) {
    // caricamento
    if (_isAccountLoading) {
      return _infoRow(
        icon: Icons.account_circle_outlined,
        label: 'Account',
        value: 'Caricamento...',
      );
    }

    // errore → fallback su ID
    if (_accountError != null) {
      return _infoRow(
        icon: Icons.account_circle_outlined,
        label: 'Account',
        value: 'ID ${_game.accountId}',
      );
    }

    // nessun account trovato
    if (_account == null) {
      return _infoRow(
        icon: Icons.account_circle_outlined,
        label: 'Account',
        value: '—',
      );
    }

    // account ok → riga cliccabile con email + freccetta
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AccountDetailPage(
              account: _account!, // adatta in base alla tua firma
            ),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 18,
            color: Colors.white70,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _account!.email, // 👈 CAMPO EMAIL (adatta se si chiama diverso)
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }

  // CARD 3: descrizione

  Widget _buildDescriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Note / Descrizione'),
          const SizedBox(height: 8),
          Text(
            _game.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // AZIONI: Edit + Delete

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              final updated = await Navigator.of(context).push<GameModel?>(
                MaterialPageRoute(
                  builder: (_) => GameEditPage(game: _game),
                ),
              );

              if (updated != null) {
                setState(() {
                  _game = updated;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Game aggiornato.'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Modifica'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              foregroundColor: Colors.redAccent,
            ),
            onPressed: _isDeleting ? null : () => _onDeletePressed(context),
            icon: _isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            label: const Text('Elimina'),
          ),
        ),
      ],
    );
  }

  Future<void> _onDeletePressed(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina gioco'),
        content: Text(
          'Sei sicuro di voler eliminare "${_game.gameName}" (order: ${_game.orderNumber})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);
    try {
      await _gameService.deleteGame(_game.id);
      if (!mounted) return;
      Navigator.of(context).pop(true); // true = cancellato
    } catch (e) {
      setState(() => _isDeleting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore eliminazione: $e')),
      );
    }
  }

  // ------- UI UTILS -------

  BoxDecoration _glassCardDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.12),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white70,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white70,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activeBadge(bool isActive) {
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

  Widget _consoleBadge(String label, bool available) {
    final color = available ? Pallete.accentBlue : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
