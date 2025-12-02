import 'package:easy_life_application/services/purchase/purcase_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/users_model.dart';
import 'package:easy_life_application/models/purchase_model.dart';

class UserDetailPage extends StatefulWidget {
  final UsersModel user;

  const UserDetailPage({super.key, required this.user});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late UsersModel _user;
  late final PurchaseService _purchaseService;

  bool _isLoadingPurchases = false;
  String? _purchasesError;
  List<PurchaseModel> _purchases = [];

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _purchaseService = PurchaseService();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() {
      _isLoadingPurchases = true;
      _purchasesError = null;
    });

    try {
      final items = await _purchaseService.getPurchasesByUserId(_user.id);
      if (!mounted) return;
      setState(() {
        _purchases = items;
        _isLoadingPurchases = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPurchases = false;
        _purchasesError = e.toString();
      });
    }
  }

  String get _fullName => '${_user.firstName} ${_user.surname}'.trim();

  String _initials(UsersModel u) {
    final f = u.firstName.isNotEmpty ? u.firstName[0] : '';
    final s = u.surname.isNotEmpty ? u.surname[0] : '';
    final initials = (f + s).trim();
    return initials.isEmpty ? '?' : initials.toUpperCase();
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
        title: const Text('User'),
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
                    _buildInfoCard(context),
                    const SizedBox(height: 16),
                    _buildPurchasesSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // HEADER: avatar + nome + numero acquisti
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Pallete.accentBlue.withOpacity(0.25),
          child: Text(
            _initials(_user),
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
                _fullName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 16,
                    color: Colors.white.withOpacity(0.75),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_user.purchaseNumber} acquisti totali',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  // CARD INFO BASE
  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Dettagli utente'),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.person_outline,
            label: 'Nome',
            value: _user.firstName,
          ),
          const SizedBox(height: 8),
          _infoRow(icon: Icons.person, label: 'Cognome', value: _user.surname),
          const SizedBox(height: 8),
          _infoRow(icon: Icons.tag, label: 'ID', value: _user.id.toString()),
          const SizedBox(height: 8),
          _infoRow(
            icon: Icons.shopping_bag_outlined,
            label: 'Numero acquisti',
            value: _user.purchaseNumber.toString(),
          ),
        ],
      ),
    );
  }

  // SEZIONE ACQUISTI
  Widget _buildPurchasesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle('Acquisti'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_purchases.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadPurchases,
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                  color: Colors.white70,
                ),
                tooltip: 'Ricarica acquisti',
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoadingPurchases)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_purchasesError != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Errore nel caricamento degli acquisti:\n$_purchasesError',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            )
          else if (_purchases.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Nessun acquisto trovato per questo utente.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _purchases.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.white.withOpacity(0.08), height: 10),
              itemBuilder: (context, index) {
                final purchase = _purchases[index];
                return _buildPurchaseTile(context, purchase);
              },
            ),
        ],
      ),
    );
  }

  // TILE ACQUISTO
  Widget _buildPurchaseTile(BuildContext context, PurchaseModel purchase) {
    // TODO: adatta questi campi al tuo PurchaseModel
    // Per ora uso id e toString() come fallback
    final subtitle = purchase.toString();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // in futuro puoi collegare a una PurchaseDetailPage
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (_) => PurchaseDetailPage(purchase: purchase),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Pallete.accentBlue.withOpacity(0.20),
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acquisto #${purchase.id}', // presumo che `id` esista
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
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
