// lib/screen/subscription/subscription_edit_page.dart

import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/subscription_model.dart';
import 'package:easy_life_application/services/subscription/subscription_service.dart';

class SubscriptionEditPage extends StatefulWidget {
  final SubscriptionModel subscription;

  const SubscriptionEditPage({
    super.key,
    required this.subscription,
  });

  @override
  State<SubscriptionEditPage> createState() => _SubscriptionEditPageState();
}

class _SubscriptionEditPageState extends State<SubscriptionEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _typeController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _costController;
  late final TextEditingController _nationController;
  late final TextEditingController _vpnController;
  late final TextEditingController _freeProfilesController;
  late final TextEditingController _accountIdController;

  DateTime? _saleDate;
  DateTime? _purchaseDate;
  DateTime? _activationDate;
  DateTime? _expirationDate;

  bool _isActive = true;
  bool _isSubmitting = false;

  final SubscriptionService _subscriptionService = SubscriptionService();

  @override
  void initState() {
    super.initState();
    final s = widget.subscription;

    _typeController = TextEditingController(text: s.subscriptionType);
    _priceController =
        TextEditingController(text: s.price.toStringAsFixed(2));
    _salePriceController = TextEditingController(
      text: s.salePrice != null ? s.salePrice!.toStringAsFixed(2) : '',
    );
    _costController = TextEditingController(
      text: s.cost != null ? s.cost!.toStringAsFixed(2) : '',
    );
    _nationController = TextEditingController(text: s.nation);
    _vpnController = TextEditingController(text: s.vpnUsed);
    _freeProfilesController =
        TextEditingController(text: s.freeProfileNumber.toString());
    _accountIdController =
        TextEditingController(text: s.accountId.toString());

    _saleDate = s.saleDate;
    _purchaseDate = s.purchaseDate;
    _activationDate = s.activationDate;
    _expirationDate = s.expirationDate;

    _isActive = s.isActive;
  }

  @override
  void dispose() {
    _typeController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _costController.dispose();
    _nationController.dispose();
    _vpnController.dispose();
    _freeProfilesController.dispose();
    _accountIdController.dispose();
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

  Future<void> _pickDate(String fieldKey) async {
    final now = DateTime.now();
    DateTime initial;

    switch (fieldKey) {
      case 'sale':
        initial = _saleDate ?? now;
        break;
      case 'purchase':
        initial = _purchaseDate ?? now;
        break;
      case 'activation':
        initial = _activationDate ?? now;
        break;
      case 'expiration':
        initial = _expirationDate ?? now;
        break;
      default:
        initial = now;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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
      switch (fieldKey) {
        case 'sale':
          _saleDate = picked;
          break;
        case 'purchase':
          _purchaseDate = picked;
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

  double _parseDoubleRequired(String input) {
    final cleaned = input.replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  double? _parseDoubleOptional(String input) {
    final v = input.trim();
    if (v.isEmpty) return null;
    final cleaned = v.replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final updated = widget.subscription.copyWith(
        subscriptionType: _typeController.text.trim(),
        price: _parseDoubleRequired(_priceController.text),
        salePrice: _parseDoubleOptional(_salePriceController.text),
        cost: _parseDoubleOptional(_costController.text),
        nation: _nationController.text.trim(),
        vpnUsed: _vpnController.text.trim(),
        saleDate: _saleDate,
        purchaseDate: _purchaseDate,
        activationDate: _activationDate,
        expirationDate: _expirationDate,
        isActive: _isActive,
        freeProfileNumber:
            int.parse(_freeProfilesController.text.trim()),
        accountId: int.parse(_accountIdController.text.trim()),
      );

      final saved =
          await _subscriptionService.updateSubscription(updated);

      if (!mounted) return;
      Navigator.of(context).pop<SubscriptionModel>(saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore aggiornamento subscription: $e')),
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
        title: const Text('Modifica subscription'),
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
                          'Modifica subscription',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aggiorna i dati di questa subscription.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),

                        // TIPO
                        TextFormField(
                          controller: _typeController,
                          decoration: _fieldDecoration(
                            'Tipo subscription',
                            hint: 'es. Netflix Premium, Spotify Family...',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) {
                              return 'Tipo subscription obbligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // PREZZI
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: _fieldDecoration(
                                  'Prezzo base',
                                  hint: 'es. 15.99',
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
                                  hint: 'es. 4.99',
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

                        // COSTO
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
                            if (double.tryParse(
                                    v.replaceAll(',', '.')) ==
                                null) {
                              return 'Numero non valido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // NAZIONE
                        TextFormField(
                          controller: _nationController,
                          decoration: _fieldDecoration(
                            'Nazione',
                            hint: 'es. Italy, Turkey, Argentina...',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Nazione obbligatoria';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // VPN USED
                        TextFormField(
                          controller: _vpnController,
                          decoration: _fieldDecoration(
                            'VPN usata',
                            hint: 'es. Windscribe, None...',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'VPN obbligatoria';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // FREE PROFILES + ACCOUNT ID
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _freeProfilesController,
                                decoration: _fieldDecoration(
                                  'Profili liberi',
                                  hint: 'es. 2',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return 'Obbligatorio';
                                  }
                                  if (int.tryParse(v) == null) {
                                    return 'Deve essere un intero';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _accountIdController,
                                decoration: _fieldDecoration(
                                  'Account ID',
                                  hint: 'ID account collegato',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return 'Account ID obbligatorio';
                                  }
                                  if (int.tryParse(v) == null) {
                                    return 'Deve essere un intero';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // DATE ROW 1: sale/purchase
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate('sale'),
                                icon: const Icon(Icons.sell_outlined),
                                label: Text(
                                  'Vendita: ${_formatDate(_saleDate)}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate('purchase'),
                                icon: const Icon(
                                    Icons.shopping_cart_checkout),
                                label: Text(
                                  'Acquisto: ${_formatDate(_purchaseDate)}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // DATE ROW 2: activation/expiration
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate('activation'),
                                icon: const Icon(Icons.play_circle_outline),
                                label: Text(
                                  'Attiv.: ${_formatDate(_activationDate)}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate('expiration'),
                                icon: const Icon(Icons.timer_off_outlined),
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
                                : const Text('Salva modifiche'),
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
