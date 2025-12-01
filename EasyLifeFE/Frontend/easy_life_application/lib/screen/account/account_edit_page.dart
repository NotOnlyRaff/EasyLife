// lib/screen/account/account_edit_page.dart

import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/account_model.dart';
import 'package:easy_life_application/services/account/account_service.dart';

class AccountEditPage extends StatefulWidget {
  final AccountModel account;

  const AccountEditPage({
    super.key,
    required this.account,
  });

  @override
  State<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nationController;
  late final TextEditingController _descriptionController;

  late AccountStatus _selectedStatus;

  final AccountService _accountService = AccountService();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.account.email);
    _passwordController = TextEditingController(text: widget.account.password);
    _nationController = TextEditingController(text: widget.account.nation);
    _descriptionController =
        TextEditingController(text: widget.account.description ?? '');
    _selectedStatus = widget.account.accountStatus;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nationController.dispose();
    _descriptionController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final updatedAccount = widget.account.copyWith(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nation: _nationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        accountStatus: _selectedStatus,
      );

      final saved = await _accountService.updateAccount(updatedAccount);

      if (!mounted) return;
      Navigator.of(context).pop<AccountModel>(saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore aggiornamento account: $e')),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = media.size.width > 600 ? 500.0 : double.infinity;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Modifica account'),
        centerTitle: true,
      ),
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
                          'Dettagli account',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aggiorna le informazioni dell’account.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 20),

                        // EMAIL
                        TextFormField(
                          controller: _emailController,
                          decoration: _fieldDecoration(
                            'Email account',
                            hint: 'es. gamer@test.it',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Email obbligatoria';
                            if (!v.contains('@')) return 'Email non valida';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // PASSWORD
                        TextFormField(
                          controller: _passwordController,
                          decoration: _fieldDecoration(
                            'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Password obbligatoria';
                            if (v.length < 4) {
                              return 'Almeno 4 caratteri';
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
                            hint: 'es. Italy, USA, Japan...',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Nazione obbligatoria';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // STATUS
                        DropdownButtonFormField<AccountStatus>(
                          value: _selectedStatus,
                          decoration: _fieldDecoration('Status'),
                          items: const [
                            DropdownMenuItem(
                              value: AccountStatus.ACTIVE,
                              child: Text('ACTIVE'),
                            ),
                            DropdownMenuItem(
                              value: AccountStatus.PENDING,
                              child: Text('PENDING'),
                            ),
                            DropdownMenuItem(
                              value: AccountStatus.CANCELLED,
                              child: Text('CANCELLED'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedStatus = value);
                          },
                        ),
                        const SizedBox(height: 14),

                        // DESCRIPTION
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _fieldDecoration(
                            'Descrizione (opzionale)',
                            hint: 'Note, dettagli account, ecc...',
                          ),
                          maxLines: 3,
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
