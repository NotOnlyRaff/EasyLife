// lib/screen/game/game_edit_page.dart

import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/game_model.dart';
import 'package:easy_life_application/services/game/game_service.dart';

class GameEditPage extends StatefulWidget {
  final GameModel game;

  const GameEditPage({
    super.key,
    required this.game,
  });

  @override
  State<GameEditPage> createState() => _GameEditPageState();
}

class _GameEditPageState extends State<GameEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _gameNameController;
  late final TextEditingController _profileIdController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _costController;
  late final TextEditingController _nationController;
  late final TextEditingController _orderNumberController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _accountIdController;

  DateTime? _purchaseDate;
  DateTime? _saleDate;

  bool _ps5Primary = false;
  bool _ps5Secondary = false;
  bool _ps4Primary = false;
  bool _ps4Secondary = false;
  bool _isActive = true;

  final GameService _gameService = GameService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final game = widget.game;

    _gameNameController = TextEditingController(text: game.gameName);
    _profileIdController = TextEditingController(text: game.gameProfileId);
    _priceController =
        TextEditingController(text: game.price.toStringAsFixed(2));
    _salePriceController =
        TextEditingController(text: game.salePrice.toStringAsFixed(2));
    _costController =
        TextEditingController(text: game.cost.toStringAsFixed(2));
    _nationController = TextEditingController(text: game.nation);
    _orderNumberController = TextEditingController(text: game.orderNumber);
    _descriptionController = TextEditingController(text: game.description);
    _accountIdController =
        TextEditingController(text: game.accountId.toString());

    _purchaseDate = game.purchaseDate;
    _saleDate = game.saleDate;

    _ps5Primary = game.isPS5PrimaryAvailable;
    _ps5Secondary = game.isPS5SecondaryAvailable;
    _ps4Primary = game.isPS4PrimaryAvailable;
    _ps4Secondary = game.isPS4SecondaryAvailable;
    _isActive = game.isActive;
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _profileIdController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _costController.dispose();
    _nationController.dispose();
    _orderNumberController.dispose();
    _descriptionController.dispose();
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

  Future<void> _pickDate({required bool isPurchase}) async {
    final now = DateTime.now();
    final initial = isPurchase
        ? (_purchaseDate ?? now)
        : (_saleDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2010),
      lastDate: DateTime(now.year + 3),
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
      if (isPurchase) {
        _purchaseDate = picked;
      } else {
        _saleDate = picked;
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

  double _parseDouble(String input) {
    final cleaned = input.replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_purchaseDate == null || _saleDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Seleziona sia data di acquisto che di vendita'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final updated = widget.game.copyWith(
        gameName: _gameNameController.text.trim(),
        gameProfileId: _profileIdController.text.trim(),
        price: _parseDouble(_priceController.text),
        salePrice: _parseDouble(_salePriceController.text),
        cost: _parseDouble(_costController.text),
        nation: _nationController.text.trim(),
        saleDate: _saleDate!,
        purchaseDate: _purchaseDate!,
        orderNumber: _orderNumberController.text.trim(),
        description: _descriptionController.text.trim(),
        isPS5PrimaryAvailable: _ps5Primary,
        isPS5SecondaryAvailable: _ps5Secondary,
        isPS4PrimaryAvailable: _ps4Primary,
        isPS4SecondaryAvailable: _ps4Secondary,
        isActive: _isActive,
        accountId: int.parse(_accountIdController.text.trim()),
      );

      final saved = await _gameService.updateGame(updated);

      if (!mounted) return;
      Navigator.of(context).pop<GameModel>(saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore aggiornamento game: $e')),
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
        title: const Text('Modifica game'),
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
                          'Modifica game',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aggiorna i dati di questo gioco.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),

                        // NOME GIOCO
                        TextFormField(
                          controller: _gameNameController,
                          decoration: _fieldDecoration(
                            'Nome gioco',
                            hint: 'es. Elden Ring',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Nome obbligatorio';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // PROFILE ID
                        TextFormField(
                          controller: _profileIdController,
                          decoration: _fieldDecoration(
                            'Game profile ID',
                            hint: 'es. email profilo / ID PSN',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Profile ID obbligatorio';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // PREZZI (riga doppia)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: _fieldDecoration(
                                  'Prezzo base',
                                  hint: 'es. 69.99',
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
                                  'Prezzo vendita',
                                  hint: 'es. 49.99',
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
                          ],
                        ),
                        const SizedBox(height: 14),

                        // COSTO
                        TextFormField(
                          controller: _costController,
                          decoration: _fieldDecoration(
                            'Costo',
                            hint: 'Costo effettivo per te',
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Costo obbligatorio';
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
                            hint: 'es. Italy, USA...',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Nazione obbligatoria';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ORDER NUMBER
                        TextFormField(
                          controller: _orderNumberController,
                          decoration: _fieldDecoration(
                            'Numero ordine',
                            hint: 'es. #ORD12345',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) {
                              return 'Numero ordine obbligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ACCOUNT ID
                        TextFormField(
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
                              return 'Deve essere un numero intero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // DATE
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _pickDate(isPurchase: true),
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
                                    _pickDate(isPurchase: false),
                                icon: const Icon(Icons.event),
                                label: Text(
                                  'Vendita: ${_formatDate(_saleDate)}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // TOGGLE CONSOLE
                        const Text(
                          'Disponibilità slot',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            FilterChip(
                              label: const Text('PS5 Primary'),
                              selected: _ps5Primary,
                              onSelected: (val) =>
                                  setState(() => _ps5Primary = val),
                            ),
                            FilterChip(
                              label: const Text('PS5 Secondary'),
                              selected: _ps5Secondary,
                              onSelected: (val) =>
                                  setState(() => _ps5Secondary = val),
                            ),
                            FilterChip(
                              label: const Text('PS4 Primary'),
                              selected: _ps4Primary,
                              onSelected: (val) =>
                                  setState(() => _ps4Primary = val),
                            ),
                            FilterChip(
                              label: const Text('PS4 Secondary'),
                              selected: _ps4Secondary,
                              onSelected: (val) =>
                                  setState(() => _ps4Secondary = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        SwitchListTile(
                          value: _isActive,
                          onChanged: (val) =>
                              setState(() => _isActive = val),
                          title: const Text('Game attivo'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 14),

                        // DESCRIPTION
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _fieldDecoration(
                            'Descrizione (opzionale)',
                            hint: 'Note, dettagli, info extra...',
                          ),
                          maxLines: 3,
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
