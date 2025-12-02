import 'package:easy_life_application/screen/purchase/purchase_create_page.dart';
import 'package:easy_life_application/services/purchase/purcase_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/purchase_model.dart';
// import 'package:easy_life_application/screen/purchase/purchase_detail_page.dart';
// import 'package:easy_life_application/screen/purchase/purchase_create_page.dart';

class PurchaseHomePage extends StatefulWidget {
  const PurchaseHomePage({super.key});

  @override
  State<PurchaseHomePage> createState() => _PurchaseHomePageState();
}

class _PurchaseHomePageState extends State<PurchaseHomePage> {
  final PurchaseService _purchaseService = PurchaseService();
  final TextEditingController _searchController = TextEditingController();

  List<PurchaseModel> _allPurchases = [];
  List<PurchaseModel> _filteredPurchases = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPurchases() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final purchases = await _purchaseService.getAllPurchases();
      if (!mounted) return;
      setState(() {
        _allPurchases = purchases;
        _applyFilter(_searchController.text);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredPurchases = List.from(_allPurchases);
    } else {
      _filteredPurchases = _allPurchases.where((p) {
        final type = _purchaseTypeLabel(p.purchaseType).toLowerCase();
        final status = _purchaseStatusLabel(p.purchaseStatus).toLowerCase();
        final payment = p.paymentMethod.toLowerCase();
        final idStr = p.id.toString();
        return type.contains(q) ||
            status.contains(q) ||
            payment.contains(q) ||
            idStr.contains(q);
      }).toList();
    }
    setState(() {});
  }

  String _purchaseTypeLabel(PurchaseType type) {
    switch (type) {
      case PurchaseType.FULL:
        return 'Full';
      case PurchaseType.RENTAL:
        return 'Rental';
    }
  }

  String _purchaseStatusLabel(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.PLANNED:
        return 'Planned';
      case PurchaseStatus.ACTIVE:
        return 'Active';
      case PurchaseStatus.EXPIRED:
        return 'Expired';
      case PurchaseStatus.CANCELLED:
        return 'Cancelled';
    }
  }

  Color _statusColor(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.ACTIVE:
        return const Color(0xFF22C55E); // verde
      case PurchaseStatus.PLANNED:
        return const Color(0xFFFACC15); // giallo
      case PurchaseStatus.EXPIRED:
        return const Color(0xFF9CA3AF); // grigio
      case PurchaseStatus.CANCELLED:
        return const Color(0xFFEF4444); // rosso
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
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
        title: const Text('Purchases'),
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
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(context),
                  const SizedBox(height: 12),
                  _buildSearchBar(context),
                  const SizedBox(height: 8),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadPurchases,
                      child: _buildBody(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<PurchaseModel?>(
            MaterialPageRoute(builder: (_) => const PurchaseCreatePage()),
          );

          if (created != null) {
            setState(() {
              _allPurchases.add(created);
              _applyFilter(_searchController.text);
            });
          }
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add purchase'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acquisti',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gestisci gli acquisti collegati ad account e utenti.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _applyFilter,
        decoration: InputDecoration(
          hintText: 'Cerca per tipo, stato, metodo pagamento, ID...',
          filled: true,
          fillColor: Colors.black.withOpacity(0.25),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Pallete.accentBlue, width: 1.6),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Errore: $_error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    if (_filteredPurchases.isEmpty) {
      return const Center(
        child: Text(
          'Nessun acquisto trovato.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _filteredPurchases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final purchase = _filteredPurchases[index];
        return _buildPurchaseCard(context, purchase);
      },
    );
  }

  Widget _buildPurchaseCard(BuildContext context, PurchaseModel purchase) {
    final statusColor = _statusColor(purchase.purchaseStatus);
    final typeLabel = _purchaseTypeLabel(purchase.purchaseType);
    final statusLabel = _purchaseStatusLabel(purchase.purchaseStatus);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // TODO: collega alla PurchaseDetailPage quando esiste
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (_) => PurchaseDetailPage(purchase: purchase),
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          children: [
            // Avatar / Icona
            CircleAvatar(
              radius: 22,
              backgroundColor: statusColor.withOpacity(0.20),
              child: Icon(
                typeLabel == 'Rental'
                    ? Icons.schedule
                    : Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Testo principale
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Riga titolo: tipo + prezzo
                  Row(
                    children: [
                      Text(
                        typeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${purchase.price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Riga date
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(purchase.startDate),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.timer_off_outlined,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(purchase.expirationDate),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Riga payment method
                  Row(
                    children: [
                      Icon(
                        Icons.payment,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        purchase.paymentMethod,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Pill status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: statusColor.withOpacity(0.8)),
                color: statusColor.withOpacity(0.12),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
