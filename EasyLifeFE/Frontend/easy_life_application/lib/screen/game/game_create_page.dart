import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/game_model.dart';
import 'package:easy_life_application/services/game/game_service.dart';
import 'package:easy_life_application/services/account/account_service.dart';
import 'package:easy_life_application/models/account_suggestion.dart';

class GameCreatePage extends StatefulWidget {
  const GameCreatePage({super.key});

  @override
  State<GameCreatePage> createState() => _GameCreatePageState();
}

class _GameCreatePageState extends State<GameCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _gameNameController = TextEditingController();
  final _profileIdController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _costController = TextEditingController();
  final _nationController = TextEditingController();
  final _orderNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _accountEmailController = TextEditingController();
  List<AccountSuggestion> _accountSuggestions = [];
  bool _isLoadingAccounts = false;
  AccountSuggestion? _selectedAccount; // scelta finale
  Timer? _debounce;

  // controller interno usato da RawAutocomplete
  TextEditingController? _accountFieldController;

  DateTime? _purchaseDate;
  DateTime? _saleDate;

  bool _ps5Primary = true;
  bool _ps5Secondary = false;
  bool _ps4Primary = false;
  bool _ps4Secondary = false;
  bool _isActive = true;

  final GameService _gameService = GameService();
  final AccountService _accountService = AccountService();

  bool _isSubmitting = false;

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
    _accountEmailController.dispose();
    _debounce?.cancel();
    _accountFieldController?.dispose();
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

  Future<void> _pickDate({required bool isPurchase}) async {
    final now = DateTime.now();
    final initial = isPurchase ? (_purchaseDate ?? now) : (_saleDate ?? now);

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

  // 🔎 cerca account mentre scrivi l'email
  void _onAccountEmailChanged(String value) {
    _selectedAccount = null; // reset se l’utente cambia testo

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = value.trim();
      if (query.length < 1) {
        setState(() {
          _accountSuggestions = [];
          _isLoadingAccounts = false;
        });
        return;
      }

      setState(() => _isLoadingAccounts = true);

      try {
        final results = await _accountService.searchAccounts(query);
        if (!mounted) return;

        setState(() {
          _accountSuggestions = results;
          _isLoadingAccounts = false;
        });

        // 👉 forza RawAutocomplete a rivalutare le options
        final c = _accountFieldController;
        if (c != null) {
          final text = c.text;
          c.value = c.value.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _accountSuggestions = [];
          _isLoadingAccounts = false;
        });
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_purchaseDate == null || _saleDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona sia data di acquisto che di vendita'),
        ),
      );
      return;
    }

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona un account valido dalla lista email'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final created = await _gameService.createGame(
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
        accountId: _selectedAccount!.id, // 👈 QUI usiamo l'ID ricavato
      );

      if (!mounted) return;
      Navigator.of(context).pop<GameModel>(created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore creazione game: $e')));
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
        title: const Text('Aggiungi game'),
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
                          'Nuovo game',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Compila i dati per aggiungere un nuovo gioco al catalogo.',
                          style: Theme.of(context).textTheme.bodySmall
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
                                  if (double.tryParse(v.replaceAll(',', '.')) ==
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
                                  if (double.tryParse(v.replaceAll(',', '.')) ==
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
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Costo obbligatorio';
                            if (double.tryParse(v.replaceAll(',', '.')) ==
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

                        Autocomplete<AccountSuggestion>(
                          displayStringForOption: (opt) => opt.email,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<AccountSuggestion>.empty();
                            }
                            final lower = textEditingValue.text.toLowerCase();
                            // filtriamo sui suggerimenti già caricati da _onAccountEmailChanged
                            return _accountSuggestions.where(
                              (opt) => opt.email.toLowerCase().contains(lower),
                            );
                          },
                          onSelected: (AccountSuggestion selection) {
                            setState(() {
                              _selectedAccount = selection;
                              _accountEmailController.text = selection.email;
                              _accountSuggestions =
                                  []; // pulisco la lista una volta scelto
                            });
                          },
                          fieldViewBuilder:
                              (
                                context,
                                textEditingController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                // 👉 agganciamo il controller interno, così _onAccountEmailChanged può usarlo
                                _accountFieldController = textEditingController;

                                // tieni in sync il tuo controller "esterno" (se ti serve altrove)
                                _accountEmailController.value =
                                    textEditingController.value;

                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: _fieldDecoration(
                                    'Account email',
                                    hint: 'es. user@example.com',
                                    suffixIcon: _isLoadingAccounts
                                        ? const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : const Icon(Icons.alternate_email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: _onAccountEmailChanged,
                                  validator: (value) {
                                    final v = (value ?? '').trim();
                                    if (v.isEmpty)
                                      return 'Email account obbligatoria';
                                    if (!v.contains('@') || !v.contains('.')) {
                                      return 'Email non valida';
                                    }
                                    if (_selectedAccount == null) {
                                      return 'Seleziona un account valido dalla lista';
                                    }
                                    return null;
                                  },
                                );
                              },
                          optionsViewBuilder: (context, onSelected, options) {
                            if (options.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF020617,
                                    ).withOpacity(0.95),
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
                                    itemCount: options.length,
                                    separatorBuilder: (_, __) => Divider(
                                      color: Colors.white.withOpacity(0.06),
                                      height: 1,
                                    ),
                                    itemBuilder: (context, index) {
                                      final acc = options.elementAt(
                                        index,
                                      ); // 👈 USA options
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
                                        // 👇 QUI la magia: usiamo onSelected del Autocomplete
                                        onTap: () => onSelected(acc),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // DATE
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(isPurchase: true),
                                icon: const Icon(Icons.shopping_cart_checkout),
                                label: Text(
                                  'Acquisto: ${_formatDate(_purchaseDate)}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(isPurchase: false),
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
                          onChanged: (val) => setState(() => _isActive = val),
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
                                : const Text('Crea game'),
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
