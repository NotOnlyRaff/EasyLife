import 'package:flutter/material.dart';
import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/models/users_model.dart';
import 'package:easy_life_application/services/users/users_service.dart';

class UserCreatePage extends StatefulWidget {
  const UserCreatePage({super.key});

  @override
  State<UserCreatePage> createState() => _UserCreatePageState();
}

class _UserCreatePageState extends State<UserCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();

  final UsersService _usersService = UsersService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.black.withOpacity(0.20),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final created = await _usersService.createUser(
        firstName: _firstNameController.text.trim(),
        surname: _surnameController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop<UsersModel>(created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore creazione utente: $e')));
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
        title: const Text('Aggiungi utente'),
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
                          'Nuovo utente',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Crea un nuovo profilo utente da collegare agli acquisti.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),

                        // FIRST NAME
                        TextFormField(
                          controller: _firstNameController,
                          decoration: _fieldDecoration(
                            'Nome',
                            hint: 'es. Mario',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Nome obbligatorio';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // SURNAME
                        TextFormField(
                          controller: _surnameController,
                          decoration: _fieldDecoration(
                            'Cognome',
                            hint: 'es. Rossi',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Cognome obbligatorio';
                            return null;
                          },
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
                                : const Text('Crea utente'),
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
