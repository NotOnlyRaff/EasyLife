import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/account_model.dart';
import 'package:easy_life_application/screen/account/account_edit_page.dart';
import 'package:easy_life_application/services/account/account_service.dart';
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
  bool _obscurePassword = true;
  bool _isDeleting = false;
  @override
  void initState() {
    super.initState();
    _account = widget.account;
    _accountService = AccountService();
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
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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
    final displayedPassword = _obscurePassword ? '••••••••' : _account.password;

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
    final createdAtString = _account.createdAt
        .toLocal()
        .toString()
        .split('.')
        .first;

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
    // dopo update riuscito
    Navigator.of(context).pop(true);


    if (!mounted) return;
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
