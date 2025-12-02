// lib/screen/subscription/subscription_home_page.dart

import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/subscription_model.dart';
import 'package:easy_life_application/screen/subscription/subscription_detail_page.dart';
import 'package:easy_life_application/screen/subscription/subscription_create_page.dart';
import 'package:easy_life_application/services/subscription/subscription_service.dart';

enum SubscriptionSortField {
  type,
  price,
  salePrice,
  activationDate,
  expirationDate,
  margin,
}

class SubscriptionHomePage extends StatefulWidget {
  const SubscriptionHomePage({super.key});

  @override
  State<SubscriptionHomePage> createState() => _SubscriptionHomePageState();
}

class _SubscriptionHomePageState extends State<SubscriptionHomePage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final TextEditingController _searchController = TextEditingController();

  List<SubscriptionModel> _allSubs = [];
  List<SubscriptionModel> _filteredSubs = [];

  bool _onlyActive = false;
  bool _onlyWithFreeProfiles = false;

  SubscriptionSortField _sortField = SubscriptionSortField.type;
  bool _sortAscending = true;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final subs = await _subscriptionService.getAllSubscriptions();
      setState(() {
        _allSubs = subs;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = 'Errore caricamento subscriptions: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onAddSubscriptionPressed() async {
    final created = await Navigator.of(context).push<SubscriptionModel?>(
      MaterialPageRoute(
        builder: (_) => const SubscriptionCreatePage(),
      ),
    );

    if (created != null) {
      await _loadSubscriptions();
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    List<SubscriptionModel> result = _allSubs.where((s) {
      final matchesQuery =
          query.isEmpty ||
          s.subscriptionType.toLowerCase().contains(query) ||
          s.nation.toLowerCase().contains(query) ||
          s.vpnUsed.toLowerCase().contains(query) ||
          s.accountId.toString().contains(query);

      final matchesActive = !_onlyActive || s.isActive;
      final matchesFreeProfiles =
          !_onlyWithFreeProfiles || s.freeProfileNumber > 0;

      return matchesQuery && matchesActive && matchesFreeProfiles;
    }).toList();

    // ORDINAMENTO
    result.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case SubscriptionSortField.type:
          cmp = a.subscriptionType
              .toLowerCase()
              .compareTo(b.subscriptionType.toLowerCase());
          break;
        case SubscriptionSortField.price:
          cmp = a.price.compareTo(b.price);
          break;
        case SubscriptionSortField.salePrice:
          cmp = (a.salePrice ?? 0).compareTo(b.salePrice ?? 0);
          break;
        case SubscriptionSortField.activationDate:
          cmp = _compareNullableDate(a.activationDate, b.activationDate);
          break;
        case SubscriptionSortField.expirationDate:
          cmp = _compareNullableDate(a.expirationDate, b.expirationDate);
          break;
        case SubscriptionSortField.margin:
          final marginA = (a.salePrice ?? 0) - (a.cost ?? 0);
          final marginB = (b.salePrice ?? 0) - (b.cost ?? 0);
          cmp = marginA.compareTo(marginB);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    setState(() {
      _filteredSubs = result;
    });
  }

  int _compareNullableDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1; // null in fondo
    if (b == null) return -1;
    return a.compareTo(b);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final total = _allSubs.length;
    final activeCount = _allSubs.where((s) => s.isActive).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITLE + ADD
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Subscriptions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: _onAddSubscriptionPressed,
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Sub'),
              ),
            ],
          ),
        ),

        // SUBTITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Totali: $total • Attive: $activeCount',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ),

        const SizedBox(height: 8),

        // SEARCH
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _applyFilters(),
            decoration: InputDecoration(
              hintText: 'Cerca per tipo, nazione, VPN, account...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.black.withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(
                  color: Pallete.accentBlue,
                  width: 1.6,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // FILTERS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Solo attive'),
                selected: _onlyActive,
                avatar: const Icon(Icons.check_circle, size: 18),
                onSelected: (val) {
                  setState(() => _onlyActive = val);
                  _applyFilters();
                },
              ),
              FilterChip(
                label: const Text('Con profili liberi'),
                selected: _onlyWithFreeProfiles,
                avatar: const Icon(Icons.people_alt, size: 18),
                onSelected: (val) {
                  setState(() => _onlyWithFreeProfiles = val);
                  _applyFilters();
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // SORT
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _sortChip(SubscriptionSortField.type, 'Tipo'),
                    _sortChip(SubscriptionSortField.price, 'Prezzo'),
                    _sortChip(SubscriptionSortField.salePrice, 'Vendita'),
                    _sortChip(SubscriptionSortField.activationDate, 'Attiv.'),
                    _sortChip(SubscriptionSortField.expirationDate, 'Scad.'),
                    _sortChip(SubscriptionSortField.margin, 'Margine'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: _sortAscending
                    ? 'Ordina crescente'
                    : 'Ordina decrescente',
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _applyFilters();
                  });
                },
                icon: Icon(
                  _sortAscending
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ),

        // SEPARATOR
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // BODY
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _sortChip(SubscriptionSortField field, String label) {
    final selected = _sortField == field;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _sortField = field;
          _applyFilters();
        });
      },
      selectedColor: Colors.white.withOpacity(0.15),
      backgroundColor: Colors.black.withOpacity(0.20),
      side: BorderSide(
        color: selected ? Pallete.accentBlue : Colors.white.withOpacity(0.15),
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        color: selected ? Colors.white : Colors.white70,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_filteredSubs.isEmpty) {
      return const Center(
        child: Text(
          'Nessuna subscription trovata',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubscriptions,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _filteredSubs.length,
        itemBuilder: (context, index) {
          final sub = _filteredSubs[index];
          return _buildSubscriptionCard(context, sub);
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    SubscriptionModel sub,
  ) {
    final margin =
        (sub.salePrice ?? 0) - (sub.cost ?? 0); // se null → 0, safe per ora
    final marginColor =
        margin >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => SubscriptionDetailPage(subscription: sub),
            ),
          );

          if (changed == true) {
            await _loadSubscriptions();
          }
        },
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
              // ICONA
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
                ),
              ),
              const SizedBox(width: 12),

              // TESTI
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TIPO + ACTIVE
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sub.subscriptionType,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _activeBadge(sub.isActive),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // NATION + VPN
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            sub.nation,
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
                            'VPN: ${sub.vpnUsed}',
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

                    // MONEY + FREE PROFILES
                    Row(
                      children: [
                        Text(
                          'Price: ${_formatMoney(sub.price)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sale: ${_formatMoney(sub.salePrice)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(width: 6),
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

                    // DATE
                    Row(
                      children: [
                        Text(
                          'Att: ${_formatDate(sub.activationDate)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Scad: ${_formatDate(sub.expirationDate)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Text(
                      'Free profiles: ${sub.freeProfileNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                      ),
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
