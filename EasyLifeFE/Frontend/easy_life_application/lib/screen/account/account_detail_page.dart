import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/account_model.dart';
import 'package:easy_life_application/models/game_model.dart';
import 'package:easy_life_application/models/subscription_model.dart';
import 'package:easy_life_application/screen/account/account_edit_page.dart';
import 'package:easy_life_application/screen/game/game_detail_page.dart';
import 'package:easy_life_application/screen/subscription/subscription_detail_page.dart';
import 'package:easy_life_application/services/account/account_service.dart';
import 'package:easy_life_application/services/game/game_service.dart';
import 'package:easy_life_application/services/subscription/subscription_service.dart';
import 'package:flutter/material.dart';

class AccountDetailPage extends StatefulWidget {
  final AccountModel account;

  const AccountDetailPage({super.key, required this.account});

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  late AccountModel _account;
  late final AccountService _accountService;
  late final GameService _gameService;
  late final SubscriptionService _subscriptionService;

  bool _obscurePassword = true;
  bool _isDeleting = false;

  // 🔗 Relazioni
  List<GameModel> _games = [];
  List<SubscriptionModel> _subscriptions = [];
  bool _isLoadingRelations = false;
  String? _relationsError;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
    _accountService = AccountService();
    _gameService = GameService();
    _subscriptionService = SubscriptionService();

    _loadRelatedData();
  }

  Future<void> _loadRelatedData() async {
    setState(() {
      _isLoadingRelations = true;
      _relationsError = null;
    });

    try {
      // puoi ottimizzare con endpoint dedicati, per ora riuso getAll*
      final games = await _gameService.getAllGames();
      final subs = await _subscriptionService.getAllSubscriptions();

      if (!mounted) return;

      setState(() {
        _games =
            games.where((g) => g.accountId == _account.id).toList(growable: false);
        _subscriptions = subs
            .where((s) => s.accountId == _account.id)
            .toList(growable: false);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _relationsError = 'Errore caricamento giochi/subscription: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingRelations = false;
      });
    }
  }

  Color _statusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.ACTIVE:
        return const Color(0xFF4CAF50);
      case AccountStatus.PENDING:
        return const Color(0xFFFFC107);
      case AccountStatus.CANCELLED:
        return const Color(0xFFF44336);
    }
  }

  String _statusLabel(AccountStatus status) {
    switch (status) {
      case AccountStatus.ACTIVE:
        return 'ACTIVE';
      case AccountStatus.PENDING:
        return 'PENDING';
      case AccountStatus.CANCELLED:
        return 'CANCELLED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: Pallete.mainBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildMainInfoCard(context),
                const SizedBox(height: 16),
                _buildMetaInfoCard(context),
                const SizedBox(height: 16),
                _buildRelationsSection(context), // 👈 NUOVA SEZIONE
                const SizedBox(height: 24),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context) {
    final statusColor = _statusColor(_account.accountStatus);

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: statusColor.withOpacity(0.2),
          child: Text(
            _account.email.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _account.email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: statusColor.withOpacity(0.8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _statusLabel(_account.accountStatus),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _account.nation,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // CARD PRINCIPALE
  Widget _buildMainInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Dettagli account'),
          const SizedBox(height: 12),
          _infoRow(icon: Icons.mail, label: 'Email', value: _account.email),
          const SizedBox(height: 8),
          _passwordRow(),
          const SizedBox(height: 8),
          _infoRow(icon: Icons.flag, label: 'Nation', value: _account.nation),
          if ((_account.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 16),
            const SizedBox(height: 4),
            Text(
              'Description',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _account.description!,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  // Row specifica per password con occhio
  Widget _passwordRow() {
    final displayedPassword =
        _obscurePassword ? '••••••••' : _account.password;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lock, size: 18, color: Colors.white70),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayedPassword,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // CARD META
  Widget _buildMetaInfoCard(BuildContext context) {
    final createdAtString =
        _account.createdAt.toLocal().toString().split('.').first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Meta'),
          const SizedBox(height: 12),
          _infoRow(icon: Icons.tag, label: 'ID', value: _account.id.toString()),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.calendar_today,
            label: 'Created at',
            value: createdAtString,
          ),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.shield,
            label: 'Status',
            value: _statusLabel(_account.accountStatus),
          ),
        ],
      ),
    );
  }

  // 🔗 SEZIONE RELAZIONI (Giochi + Subscription)
  Widget _buildRelationsSection(BuildContext context) {
    if (_isLoadingRelations) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'Caricamento giochi e subscription...',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (_relationsError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
        ),
        child: Text(
          _relationsError!,
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_games.isNotEmpty) _buildGamesCard(context) else _buildEmptyGames(),
        const SizedBox(height: 12),
        if (_subscriptions.isNotEmpty)
          _buildSubscriptionsCard(context)
        else
          _buildEmptySubscriptions(),
      ],
    );
  }

  Widget _buildGamesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Games collegati'),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _games.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Colors.white12, height: 10),
            itemBuilder: (context, index) {
              final game = _games[index];
              final margin = game.salePrice - game.cost;
              final marginColor =
                  margin >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => GameDetailPage(game: game),
                    ),
                  );
                  if (changed == true) {
                    _loadRelatedData();
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.videogame_asset,
                        size: 20,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.gameName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Order: ${game.orderNumber} • ${game.nation}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${margin.toStringAsFixed(2)}€',
                        style: TextStyle(
                          color: marginColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Subscriptions collegate'),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subscriptions.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Colors.white12, height: 10),
            itemBuilder: (context, index) {
              final sub = _subscriptions[index];
              final margin = (sub.salePrice ?? 0) - (sub.cost ?? 0);
              final marginColor =
                  margin >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => SubscriptionDetailPage(
                        subscription: sub,
                      ),
                    ),
                  );
                  if (changed == true) {
                    _loadRelatedData();
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.subscriptions_outlined,
                        size: 20,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.subscriptionType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${sub.nation} • VPN: ${sub.vpnUsed}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${margin.toStringAsFixed(2)}€',
                        style: TextStyle(
                          color: marginColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGames() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _glassCardDecoration(),
      child: Row(
        children: const [
          Icon(Icons.videogame_asset_off, size: 18, color: Colors.white54),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nessun game collegato a questo account.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySubscriptions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _glassCardDecoration(),
      child: Row(
        children: const [
          Icon(Icons.subscriptions, size: 18, color: Colors.white54),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nessuna subscription collegata a questo account.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // AZIONI: EDIT + DELETE
  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _onEditPressed(context),
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

  // EDIT LOGIC
  Future<void> _onEditPressed(BuildContext context) async {
    final updated = await Navigator.of(context).push<AccountModel?>(
      MaterialPageRoute(builder: (_) => AccountEditPage(account: _account)),
    );

    if (updated == null) return;

    setState(() {
      _account = updated;
    });

    if (!mounted) return;
    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account aggiornato')));
  }

  // DELETE LOGIC
  Future<void> _onDeletePressed(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina account'),
        content: Text(
          'Sei sicuro di voler eliminare l\'account "${_account.email}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);
    try {
      await _accountService.deleteAccount(_account.id);
      if (!mounted) return;
      Navigator.of(context).pop(true); // true = cambiato (deleted)
    } catch (e) {
      setState(() => _isDeleting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore eliminazione: $e')));
    }
  }

  // UTILS UI
  BoxDecoration _glassCardDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.12)),
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
        Icon(icon, size: 18, color: Colors.white70),
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
}
