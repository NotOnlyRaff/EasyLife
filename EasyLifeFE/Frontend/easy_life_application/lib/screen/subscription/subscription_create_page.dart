// lib/screen/subscription/subscription_create_page.dart

import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/subscription_model.dart';
import 'package:easy_life_application/services/subscription/subscription_service.dart';

// 👇 IMPORT PER ACCOUNT
import 'package:easy_life_application/services/account/account_service.dart';
import 'package:easy_life_application/models/account_suggestion.dart';

class SubscriptionCreatePage extends StatefulWidget {
  const SubscriptionCreatePage({super.key});

  @override
  State<SubscriptionCreatePage> createState() => _SubscriptionCreatePageState();
}

class _SubscriptionCreatePageState extends State<SubscriptionCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _costController = TextEditingController();
  final _nationController = TextEditingController();
  final _vpnController = TextEditingController();
  final _freeProfilesController = TextEditingController();

  // 👇 ora si usa email + suggerimenti
  final _accountEmailController = TextEditingController();

  DateTime? _purchaseDate;
  DateTime? _saleDate;
  DateTime? _activationDate;
  DateTime? _expirationDate;

  bool _isActive = true;

  final SubscriptionService _subscriptionService = SubscriptionService();
  final AccountService _accountService = AccountService();

  bool _isSubmitting = false;

  // 👇 stato per suggerimenti
  List<AccountSuggestion> _accountSuggestions = [];
  bool _isLoadingAccountSuggestions = false;
  AccountSuggestion? _selectedAccount; // scelta finale

  @override
  void dispose() {
    _typeController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _costController.dispose();
    _nationController.dispose();
    _vpnController.dispose();
    _freeProfilesController.dispose();
    _accountEmailController.dispose();
    super.dispose();
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
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: Pallete.accentBlue,
          width: 1.6,
        ),
      ),
    );
  }

  Future<void> _pickDate({required String kind}) async {
    final now = DateTime.now();
    DateTime? current;
    switch (kind) {
      case 'purchase':
        current = _purchaseDate;
        break;
      case 'sale':
        current = _saleDate;
        break;
      case 'activation':
        current = _activationDate;
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
        case 'sale':
          _saleDate = picked;
          break;
        case 'activation':
          _activationDate = picked;
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

  double? _parseOptionalDouble(String input) {
    final cleaned = input.replaceAll(',', '.').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  // 👇 usa il tuo searchAccounts(query)
  Future<void> _onAccountEmailChanged(String input) async {
    final query = input.trim();
    _selectedAccount = null; // se cambia il testo, resetto la scelta

    if (query.length < 2) {
      setState(() {
        _accountSuggestions = [];
      });
      return;
    }

    setState(() {
      _isLoadingAccountSuggestions = true;
    });

    try {
      final results = await _accountService.searchAccounts(query);

      if (!mounted) return;
      setState(() {
        _accountSuggestions = results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _accountSuggestions = [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingAccountSuggestions = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _accountEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci l\'email dell\'account')),
      );
      return;
    }

    // 👇 se non ha cliccato un suggerimento, provo a risolvere la mail da searchAccounts
    if (_selectedAccount == null) {
      try {
        final matches = await _accountService.searchAccounts(email);
        final exact = matches.firstWhere(
          (a) => a.email.toLowerCase() == email.toLowerCase(),
          orElse: () => throw Exception('not-found'),
        );
        _selectedAccount = exact;
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account non trovato. Seleziona un account valido dai suggerimenti o controlla l\'email.',
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final created = await _subscriptionService.createSubscription(
        subscriptionType: _typeController.text.trim(),
        price: _parseRequiredDouble(_priceController.text),
        salePrice: _parseOptionalDouble(_salePriceController.text),
        cost: _parseOptionalDouble(_costController.text),
        nation: _nationController.text.trim(),
        vpnUsed: _vpnController.text.trim(),
        saleDate: _saleDate,
        purchaseDate: _purchaseDate,
        activationDate: _activationDate,
        expirationDate: _expirationDate,
        isActive: _isActive,
        freeProfileNumber: int.parse(_freeProfilesController.text.trim()),
        accountId: _selectedAccount!.id, // 👈 ID dall’AccountSuggestion
      );

      if (!mounted) return;
      Navigator.of(context).pop<SubscriptionModel>(created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore creazione subscription: $e')),
      );
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
        title: const Text('Aggiungi subscription'),
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
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Text(
                          'Nuova subscription',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Compila i dati per aggiungere una nuova subscription.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),

                        // TYPE
                        TextFormField(
                          controller: _typeController,
                          decoration: _fieldDecoration(
                            'Tipo subscription',
                            hint: 'es. Netflix Premium, Disney+ Annuale',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Tipo obbligatorio';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // PRICE + SALE PRICE
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: _fieldDecoration(
                                  'Prezzo base',
                                  hint: 'es. 14.99',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) return 'Obbligatorio';
                                  if (double.tryParse(
                                          v.replaceAll(',', '.')) ==
                                      null) {
                                    return 'Numero non valido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _salePriceController,
                                decoration: _fieldDecoration(
                                  'Prezzo vendita (opz.)',
                                  hint: 'es. 19.99',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) return null;
                                  if (double.tryParse(
                                          v.replaceAll(',', '.')) ==
                                      null) {
                                    return 'Numero non valido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // COST
                        TextFormField(
                          controller: _costController,
                          decoration: _fieldDecoration(
                            'Costo (opz.)',
                            hint: 'Costo effettivo per te',
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return null;
                            if (double.tryParse(v.replaceAll(',', '.')) ==
                                null) {
                              return 'Numero non valido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // NATION
                        TextFormField(
                          controller: _nationController,
                          decoration: _fieldDecoration(
                            'Nazione',
                            hint: 'es. Turkey, Italy, USA...',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Nazione obbligatoria';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // VPN
                        TextFormField(
                          controller: _vpnController,
                          decoration: _fieldDecoration(
                            'VPN usata',
                            hint: 'es. NordVPN, Surfshark...',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'VPN obbligatoria';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // EMAIL ACCOUNT + SUGGERIMENTI
                        TextFormField(
                          controller: _accountEmailController,
                          decoration: _fieldDecoration(
                            'Email account',
                            hint: 'es. user@domain.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: _onAccountEmailChanged,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) {
                              return 'Email account obbligatoria';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Email non valida';
                            }
                            return null;
                          },
                        ),
                        if (_isLoadingAccountSuggestions)
                          const Padding(
                            padding: EdgeInsets.only(top: 6.0),
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        if (_accountSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF020617).withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.45),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: _accountSuggestions.length,
                              separatorBuilder: (_, __) => Divider(
                                color: Colors.white.withOpacity(0.06),
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final acc = _accountSuggestions[index];
                                return ListTile(
                                  dense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Pallete.accentBlue
                                        .withOpacity(0.25),
                                    child: Text(
                                      acc.email
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    acc.email,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedAccount = acc;
                                      _accountEmailController.text =
                                          acc.email;
                                      _accountSuggestions = [];
                                    });
                                    FocusScope.of(context).unfocus();
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 14),

                        // FREE PROFILES
                        TextFormField(
                          controller: _freeProfilesController,
                          decoration: _fieldDecoration(
                            'Profili liberi',
                            hint: 'es. 2',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Obbligatorio';
                            if (int.tryParse(v) == null) {
                              return 'Deve essere un intero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // DATE ROW 1: Purchase / Sale
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _pickDate(kind: 'purchase'),
                                icon: const Icon(
                                    Icons.shopping_cart_checkout),
                                label: Text(
                                  'Acquisto: ${_formatDate(_purchaseDate)}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _pickDate(kind: 'sale'),
                                icon: const Icon(Icons.event),
                                label: Text(
                                  'Vendita: ${_formatDate(_saleDate)}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // DATE ROW 2: Activation / Expiration
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _pickDate(kind: 'activation'),
                                icon: const Icon(
                                    Icons.play_circle_outline),
                                label: Text(
                                  'Attiv.: ${_formatDate(_activationDate)}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _pickDate(kind: 'expiration'),
                                icon: const Icon(
                                    Icons.timer_off_outlined),
                                label: Text(
                                  'Scad.: ${_formatDate(_expirationDate)}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        SwitchListTile(
                          value: _isActive,
                          onChanged: (val) =>
                              setState(() => _isActive = val),
                          title: const Text('Subscription attiva'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
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
                                : const Text('Crea subscription'),
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
}
