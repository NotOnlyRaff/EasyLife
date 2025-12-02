import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/subscription_model.dart';
import 'package:easy_life_application/services/subscription/subscription_service.dart';
import 'package:easy_life_application/screen/subscription/subscription_edit_page.dart';

// 👇 NUOVI IMPORT
import 'package:easy_life_application/models/account_model.dart';
import 'package:easy_life_application/services/account/account_service.dart';
import 'package:easy_life_application/screen/account/account_detail_page.dart';

class SubscriptionDetailPage extends StatefulWidget {
  final SubscriptionModel subscription;

  const SubscriptionDetailPage({
    super.key,
    required this.subscription,
  });

  @override
  State<SubscriptionDetailPage> createState() => _SubscriptionDetailPageState();
}

class _SubscriptionDetailPageState extends State<SubscriptionDetailPage> {
  late SubscriptionModel _sub;
  late final SubscriptionService _subscriptionService;

  // 🔗 Account collegato
  late final AccountService _accountService;
  AccountModel? _account;
  bool _isLoadingAccount = false;
  String? _accountError;

  bool _isDeleting = false;

  String? get _accountEmail => _account?.email;

  @override
  void initState() {
    super.initState();
    _sub = widget.subscription;
    _subscriptionService = SubscriptionService();
    _accountService = AccountService();

    _loadAccount();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _isLoadingAccount = true;
      _accountError = null;
    });

    try {
      final acc = await _accountService.getAccountById(_sub.accountId);
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
      if (!mounted) return;
      setState(() {
        _isLoadingAccount = false;
      });
    }
  }

  String _formatMoney(double? value) {
    if (value == null) return '—';
    return '${value.toStringAsFixed(2)} €';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
  }

  double? get _margin {
    if (_sub.salePrice == null || _sub.cost == null) return null;
    return _sub.salePrice! - _sub.cost!;
  }

  double? get _marginPercent {
    final margin = _margin;
    if (margin == null || _sub.cost == null || _sub.cost == 0) return null;
    return (margin / _sub.cost!) * 100;
  }

  Color get _marginColor {
    final margin = _margin;
    if (margin == null || margin >= 0) {
      return const Color(0xFF4CAF50);
    } else {
      return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = media.size.width > 700 ? 600.0 : double.infinity;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Subscription'),
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

  Widget _buildHeader(BuildContext context) {
    final margin = _margin;
    final marginPercent = _marginPercent;
    final marginColor = _marginColor;

    String accountLabel;
    if (_isLoadingAccount) {
      accountLabel = 'Account: caricamento...';
    } else if (_accountEmail != null) {
      accountLabel = 'Account: $_accountEmail';
    } else {
      accountLabel = 'Account ID: ${_sub.accountId}';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar sub
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0EA5E9),
                Color(0xFF6366F1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.subscriptions_outlined,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _sub.subscriptionType,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 2,
                children: [
                  Text(
                    _sub.nation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'VPN: ${_sub.vpnUsed}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    accountLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _activeBadge(_sub.isActive),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_alt,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Free profiles: ${_sub.freeProfileNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (margin != null && marginPercent != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: marginColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: marginColor.withOpacity(0.9),
                        ),
                      ),
                      child: Text(
                        'Δ ${margin.toStringAsFixed(2)}€ (${marginPercent.toStringAsFixed(1)}%)',
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

  Widget _buildFinanceCard(BuildContext context) {
    final margin = _margin;
    final marginPercent = _marginPercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Finanza & Prezzi'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _statChip(
                label: 'Prezzo base',
                value: _formatMoney(_sub.price),
                icon: Icons.sell_outlined,
              ),
              _statChip(
                label: 'Prezzo vendita',
                value: _formatMoney(_sub.salePrice),
                icon: Icons.shopping_bag_outlined,
              ),
              _statChip(
                label: 'Costo',
                value: _formatMoney(_sub.cost),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (margin != null && marginPercent != null)
            Row(
              children: [
                Icon(
                  margin >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 18,
                  color: _marginColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    margin >= 0
                        ? 'Margine positivo: ${margin.toStringAsFixed(2)}€ (${marginPercent.toStringAsFixed(1)}%)'
                        : 'Margine negativo: ${margin.toStringAsFixed(2)}€ (${marginPercent.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      color: _marginColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          else
            const Text(
              'Dati margine non disponibili (manca salePrice o cost).',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Dettagli & Date'),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.location_on_outlined,
            label: 'Nation',
            value: _sub.nation,
          ),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.vpn_key_outlined,
            label: 'VPN usata',
            value: _sub.vpnUsed,
          ),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Purchase date',
            value: _formatDate(_sub.purchaseDate),
          ),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.event_available_outlined,
            label: 'Sale date',
            value: _formatDate(_sub.saleDate),
          ),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.play_circle_outline,
            label: 'Activation date',
            value: _formatDate(_sub.activationDate),
          ),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.timer_off_outlined,
            label: 'Expiration date',
            value: _formatDate(_sub.expirationDate),
          ),
          const SizedBox(height: 8),
          _accountInfoRow(context), // 👈 sostituisce "Account ID"
        ],
      ),
    );
  }

  // 👇 Row custom per account con email + tap su AccountDetailPage
  Widget _accountInfoRow(BuildContext context) {
    String value;

    if (_isLoadingAccount) {
      value = 'Caricamento account...';
    } else if (_accountError != null) {
      value = _accountError!;
    } else if (_accountEmail != null) {
      value = _accountEmail!;
    } else {
      value = 'ID: ${_sub.accountId}';
    }

    final canOpenDetail = !_isLoadingAccount && _account != null;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: canOpenDetail
          ? () async {
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => AccountDetailPage(account: _account!),
                ),
              );

              // se da AccountDetail cancelli o modifichi cose rilevanti
              if (changed == true) {
                _loadAccount();
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (canOpenDetail)
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Colors.white54,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              // 👇 APRI SUBSCRIPTION EDIT PAGE
              final updated = await Navigator.of(context)
                  .push<SubscriptionModel?>(
                MaterialPageRoute(
                  builder: (_) => SubscriptionEditPage(subscription: _sub),
                ),
              );

              if (updated != null) {
                setState(() {
                  _sub = updated;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscription aggiornata.'),
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
        title: const Text('Elimina subscription'),
        content: Text(
          'Sei sicuro di voler eliminare "${_sub.subscriptionType}" (account: ${_accountEmail ?? _sub.accountId})?',
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
      await _subscriptionService.deleteSubscription(_sub.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isDeleting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore eliminazione: $e')),
      );
    }
  }

  // UTILS UI

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
}
