import 'package:easy_life_application/services/purchase/purcase_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/purchase_model.dart';

// 👇 nuovi import
import 'package:easy_life_application/models/users_model.dart';
import 'package:easy_life_application/services/users/users_service.dart';

enum PurchaseProductKind { game, subscription }

class PurchaseCreatePage extends StatefulWidget {
  const PurchaseCreatePage({super.key});

  @override
  State<PurchaseCreatePage> createState() => _PurchaseCreatePageState();
}

class _PurchaseCreatePageState extends State<PurchaseCreatePage> {
  final _formKey = GlobalKey<FormState>();

  // CONTROLLERS
  final _accountIdController = TextEditingController();
  final _priceController = TextEditingController();
  final _paymentMethodController = TextEditingController();

  // ENUMS
  PurchaseType _purchaseType = PurchaseType.FULL;
  PurchaseStatus _purchaseStatus = PurchaseStatus.PLANNED;
  PurchaseProductKind _productKind = PurchaseProductKind.game;

  // DATE
  DateTime? _purchaseDate;
  DateTime? _startDate;
  DateTime? _expirationDate;

  // SERVICES
  final PurchaseService _purchaseService = PurchaseService();
  final UsersService _usersService = UsersService();

  // USERS
  List<UsersModel> _users = [];
  UsersModel? _selectedUser;
  bool _isLoadingUsers = false;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    _priceController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final users = await _usersService.getAllUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingUsers = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore caricamento utenti: $e')));
    }
  }

  InputDecoration _fieldDecoration(
    String label, {
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.black.withOpacity(0.20),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Pallete.accentBlue, width: 1.6),
      ),
    );
  }

  Future<void> _pickDate(String kind) async {
    final now = DateTime.now();
    DateTime? current;
    switch (kind) {
      case 'purchase':
        current = _purchaseDate;
        break;
      case 'start':
        current = _startDate;
        break;
      case 'expiration':
        current = _expirationDate;
        break;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2010),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Pallete.accentBlue,
              surface: Color(0xFF020617),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      switch (kind) {
        case 'purchase':
          _purchaseDate = picked;
          break;
        case 'start':
          _startDate = picked;
          break;
        case 'expiration':
          _expirationDate = picked;
          break;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleziona data';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
  }

  double _parseRequiredDouble(String input) {
    final cleaned = input.replaceAll(',', '.').trim();
    return double.parse(cleaned);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleziona un utente')));
      return;
    }

    if (_purchaseDate == null ||
        _startDate == null ||
        _expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona data acquisto, inizio e scadenza'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final created = await _purchaseService.createPurchase(
        userId: _selectedUser!.id,
        accountId: int.parse(_accountIdController.text.trim()),
        purchaseType: _purchaseType,
        price: _parseRequiredDouble(_priceController.text),
        purchaseDate: _purchaseDate!,
        startDate: _startDate!,
        expirationDate: _expirationDate!,
        paymentMethod: _paymentMethodController.text.trim(),
        purchaseStatus: _purchaseStatus,
      );

      if (!mounted) return;
      Navigator.of(context).pop<PurchaseModel>(created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore creazione purchase: $e')));
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = media.size.width > 600 ? 520.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Aggiungi purchase'),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: Pallete.mainBackgroundGradient,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
              child: Card(
                color: Colors.black.withOpacity(0.45),
                elevation: 18,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Text(
                          'Nuovo purchase',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Collega un utente ad un acquisto di gioco o subscription.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),

                        // 1️⃣ PRIMA RIGA: UTENTE
                        _buildUserSelector(),

                        const SizedBox(height: 16),

                        // 2️⃣ SECONDA RIGA: TIPO "ACCOUNT" (Game vs Subscription)
                        _buildProductKindToggle(),

                        const SizedBox(height: 16),

                        // 3️⃣ SEZIONE DINAMICA (campi per Game / Subscription)
                        _buildDynamicSection(),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Crea purchase'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI WIDGETS DINAMICI ----------

  Widget _buildUserSelector() {
    if (_isLoadingUsers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: LinearProgressIndicator(minHeight: 3),
        ),
      );
    }

    return DropdownButtonFormField<UsersModel>(
      value: _selectedUser,
      decoration: _fieldDecoration(
        'Utente',
        hint: 'Seleziona chi sta facendo l\'acquisto',
        suffixIcon: const Icon(Icons.person_outline),
      ),
      items: _users.map((u) {
        final fullName = '${u.firstName} ${u.surname}';
        return DropdownMenuItem<UsersModel>(value: u, child: Text(fullName));
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedUser = val;
        });
      },
      validator: (_) {
        if (_selectedUser == null) {
          return 'Seleziona un utente';
        }
        return null;
      },
    );
  }

  Widget _buildProductKindToggle() {
    return Row(
      children: [
        Expanded(
          child: _productKindCard(
            kind: PurchaseProductKind.game,
            icon: Icons.videogame_asset,
            title: 'Game',
            subtitle: 'Acquisto gioco / slot',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _productKindCard(
            kind: PurchaseProductKind.subscription,
            icon: Icons.subscriptions_outlined,
            title: 'Subscription',
            subtitle: 'Abbonamento streaming',
          ),
        ),
      ],
    );
  }

  Widget _productKindCard({
    required PurchaseProductKind kind,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool selected = _productKind == kind;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _productKind = kind;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? Pallete.accentBlue.withOpacity(0.25)
              : Colors.white.withOpacity(0.04),
          border: Border.all(
            color: selected
                ? Pallete.accentBlue
                : Colors.white.withOpacity(0.08),
            width: selected ? 1.4 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Pallete.accentBlue.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.50),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSection() {
    switch (_productKind) {
      case PurchaseProductKind.game:
        return _buildGameSection();
      case PurchaseProductKind.subscription:
        return _buildSubscriptionSection();
    }
  }

  // 🔹 Sezione quando è selezionato "Game"
  Widget _buildGameSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dettagli acquisto gioco',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Collega l’utente ad un account game (PSN, ecc.) e definisci il tipo di acquisto.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),

          // ACCOUNT ID
          TextFormField(
            controller: _accountIdController,
            decoration: _fieldDecoration(
              'Account ID (Game)',
              hint: 'ID account collegato al gioco',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Account ID obbligatorio';
              if (int.tryParse(v) == null) return 'Deve essere un intero';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // PURCHASE TYPE
          DropdownButtonFormField<PurchaseType>(
            value: _purchaseType,
            decoration: _fieldDecoration('Tipo acquisto'),
            items: PurchaseType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type == PurchaseType.FULL
                      ? 'Full (definitivo)'
                      : 'Rental (noleggio)',
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _purchaseType = val;
              });
            },
          ),
          const SizedBox(height: 14),

          // PRICE
          TextFormField(
            controller: _priceController,
            decoration: _fieldDecoration('Prezzo gioco', hint: 'es. 29.99'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Prezzo obbligatorio';
              if (double.tryParse(v.replaceAll(',', '.')) == null) {
                return 'Numero non valido';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // PAYMENT METHOD
          TextFormField(
            controller: _paymentMethodController,
            decoration: _fieldDecoration(
              'Metodo di pagamento',
              hint: 'es. PayPal, Carta, Revolut...',
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Metodo di pagamento obbligatorio';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // DATE ROW: Purchase + Start
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate('purchase'),
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Text('Acquisto: ${_formatDate(_purchaseDate)}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate('start'),
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text('Inizio: ${_formatDate(_startDate)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // DATE: Expiration
          OutlinedButton.icon(
            onPressed: () => _pickDate('expiration'),
            icon: const Icon(Icons.timer_off_outlined),
            label: Text('Scadenza: ${_formatDate(_expirationDate)}'),
          ),
          const SizedBox(height: 14),

          // STATUS
          DropdownButtonFormField<PurchaseStatus>(
            value: _purchaseStatus,
            decoration: _fieldDecoration('Stato acquisto'),
            items: PurchaseStatus.values.map((st) {
              String label;
              switch (st) {
                case PurchaseStatus.PLANNED:
                  label = 'Planned';
                  break;
                case PurchaseStatus.ACTIVE:
                  label = 'Active';
                  break;
                case PurchaseStatus.EXPIRED:
                  label = 'Expired';
                  break;
                case PurchaseStatus.CANCELLED:
                  label = 'Cancelled';
                  break;
              }
              return DropdownMenuItem(value: st, child: Text(label));
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _purchaseStatus = val;
              });
            },
          ),
        ],
      ),
    );
  }

  // 🔹 Sezione quando è selezionato "Subscription"
  Widget _buildSubscriptionSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dettagli acquisto subscription',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Collega l’utente ad un account subscription (Netflix, Disney+, ecc.).',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),

          // ACCOUNT ID
          TextFormField(
            controller: _accountIdController,
            decoration: _fieldDecoration(
              'Account ID (Subscription)',
              hint: 'ID account streaming collegato',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Account ID obbligatorio';
              if (int.tryParse(v) == null) return 'Deve essere un intero';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // PURCHASE TYPE (può avere meno senso, ma per ora è la stessa enum)
          DropdownButtonFormField<PurchaseType>(
            value: _purchaseType,
            decoration: _fieldDecoration('Tipo acquisto'),
            items: PurchaseType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type == PurchaseType.FULL
                      ? 'Full (periodo completo)'
                      : 'Rental / Slot limitato',
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _purchaseType = val;
              });
            },
          ),
          const SizedBox(height: 14),

          // PRICE
          TextFormField(
            controller: _priceController,
            decoration: _fieldDecoration(
              'Prezzo subscription',
              hint: 'es. 9.99',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Prezzo obbligatorio';
              if (double.tryParse(v.replaceAll(',', '.')) == null) {
                return 'Numero non valido';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // PAYMENT METHOD
          TextFormField(
            controller: _paymentMethodController,
            decoration: _fieldDecoration(
              'Metodo di pagamento',
              hint: 'es. PayPal, Carta, Revolut...',
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Metodo di pagamento obbligatorio';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // DATE ROW: Purchase + Start
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate('purchase'),
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Text('Acquisto: ${_formatDate(_purchaseDate)}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate('start'),
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text('Inizio: ${_formatDate(_startDate)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // DATE: Expiration
          OutlinedButton.icon(
            onPressed: () => _pickDate('expiration'),
            icon: const Icon(Icons.timer_off_outlined),
            label: Text('Scadenza: ${_formatDate(_expirationDate)}'),
          ),
          const SizedBox(height: 14),

          // STATUS
          DropdownButtonFormField<PurchaseStatus>(
            value: _purchaseStatus,
            decoration: _fieldDecoration('Stato acquisto'),
            items: PurchaseStatus.values.map((st) {
              String label;
              switch (st) {
                case PurchaseStatus.PLANNED:
                  label = 'Planned';
                  break;
                case PurchaseStatus.ACTIVE:
                  label = 'Active';
                  break;
                case PurchaseStatus.EXPIRED:
                  label = 'Expired';
                  break;
                case PurchaseStatus.CANCELLED:
                  label = 'Cancelled';
                  break;
              }
              return DropdownMenuItem(value: st, child: Text(label));
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _purchaseStatus = val;
              });
            },
          ),
        ],
      ),
    );
  }
}
