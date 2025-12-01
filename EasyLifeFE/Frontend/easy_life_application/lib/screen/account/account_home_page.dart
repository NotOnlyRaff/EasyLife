import 'package:easy_life_application/screen/account/account_create_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_life_application/models/account_model.dart';
import 'package:easy_life_application/services/account/account_service.dart';
import 'package:easy_life_application/screen/account/account_detail_page.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';

enum AccountSortField { email, createdAt }

class AccountHomePage extends StatefulWidget {
  const AccountHomePage({super.key});

  @override
  State<AccountHomePage> createState() => _AccountHomePageState();
}

class _AccountHomePageState extends State<AccountHomePage> {
  late final AccountService _apiService = AccountService();

  final TextEditingController _searchController = TextEditingController();

  List<AccountModel> _allAccounts = [];
  List<AccountModel> _filteredAccounts = [];

  AccountStatus? _selectedStatus;
  String? _selectedNation;

  AccountSortField _sortField = AccountSortField.email;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _onAddAccountPressed() async {
    final initialEmail = _searchController.text.trim();

    final created = await Navigator.of(context).push<AccountModel?>(
      MaterialPageRoute(
        builder: (_) => AccountCreatePage(initialEmail: initialEmail),
      ),
    );

    if (created != null) {
      await _loadAccounts(); // ricarica + riapplica i filtri
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _apiService.getAllAccounts();
      setState(() {
        _allAccounts = accounts;
      });
      _applyFilters();
    } catch (e) {
      debugPrint('Errore caricamento accounts: $e');
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    List<AccountModel> result = _allAccounts.where((a) {
      final matchesQuery =
          query.isEmpty ||
          a.email.toLowerCase().contains(query) ||
          (a.nation?.toLowerCase().contains(query) ?? false) ||
          (a.description?.toLowerCase().contains(query) ?? false);

      final matchesStatus =
          _selectedStatus == null || a.accountStatus == _selectedStatus;

      final matchesNation =
          _selectedNation == null ||
          _selectedNation == 'Tutte' ||
          (a.nation?.toLowerCase() == _selectedNation!.toLowerCase());

      return matchesQuery && matchesStatus && matchesNation;
    }).toList();

    // 🔽 ORDINAMENTO
    result.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case AccountSortField.email:
          cmp = a.email.toLowerCase().compareTo(b.email.toLowerCase());
          break;
        case AccountSortField.createdAt:
          // se createdAt è nullable, gestisci con ?? DateTime(1970)
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    setState(() {
      _filteredAccounts = result;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Add button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Accounts',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Pallete.accentBlue,
                ),
                onPressed: _onAddAccountPressed,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add account'),
              ),
            ],
          ),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _applyFilters(),
            decoration: InputDecoration(
              hintText: 'Filtra per email, nazione o descrizione...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.black.withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Pallete.accentBlue,
                  width: 1.6,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Filters row (status + nation)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Row(
            children: [
              // Status
              Expanded(
                child: DropdownButtonFormField<AccountStatus?>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tutti')),
                    DropdownMenuItem(
                      value: AccountStatus.ACTIVE,
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: AccountStatus.PENDING,
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: AccountStatus.CANCELLED,
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: (value) {
                    _selectedStatus = value;
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Nation
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedNation ?? 'Tutte',
                  decoration: InputDecoration(
                    labelText: 'Nation',
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: [
                    const DropdownMenuItem(
                      value: 'Tutte',
                      child: Text('Tutte'),
                    ),
                    ..._allAccounts
                        .map((e) => e.nation)
                        .where((n) => n != null && n!.isNotEmpty)
                        .map((n) => n!)
                        .toSet()
                        .map((n) => DropdownMenuItem(value: n, child: Text(n))),
                  ],
                  onChanged: (value) {
                    if (value == 'Tutte') {
                      _selectedNation = null;
                    } else {
                      _selectedNation = value;
                    }
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 🔽 Sort row (campo + direzione)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<AccountSortField>(
                  segments: const [
                    ButtonSegment(
                      value: AccountSortField.email,
                      icon: Icon(Icons.alternate_email, size: 18),
                      label: Text('Email'),
                    ),
                    ButtonSegment(
                      value: AccountSortField.createdAt,
                      icon: Icon(Icons.schedule, size: 18),
                      label: Text('Data'),
                    ),
                  ],
                  selected: <AccountSortField>{_sortField},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _sortField = selection.first;
                      _applyFilters();
                    });
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.white.withOpacity(0.10);
                      }
                      return Colors.black.withOpacity(0.20);
                    }),
                    side: MaterialStateProperty.all(
                      BorderSide(color: Colors.white.withOpacity(0.15)),
                    ),
                  ),
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

        // 🔹 Separatore figo tra filtri e lista
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

        // Lista accounts
        Expanded(
          child: _filteredAccounts.isEmpty
              ? const Center(
                  child: Text(
                    'Nessun account trovato',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  itemCount: _filteredAccounts.length,
                  itemBuilder: (context, index) {
                    final account = _filteredAccounts[index];

                    Color statusColor;
                    switch (account.accountStatus) {
                      case AccountStatus.ACTIVE:
                        statusColor = const Color(0xFF4CAF50);
                        break;
                      case AccountStatus.PENDING:
                        statusColor = const Color(0xFFFFC107);
                        break;
                      case AccountStatus.CANCELLED:
                        statusColor = const Color(0xFFF44336);
                        break;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          final changed = await Navigator.of(context)
                              .push<bool>(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AccountDetailPage(account: account),
                                ),
                              );

                          if (changed == true) {
                            await _loadAccounts();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.28),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: statusColor,
                                child: Text(
                                  account.email.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.email,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${account.nation} • ${account.accountStatus.name}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
