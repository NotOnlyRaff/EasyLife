import 'package:easy_life_application/core/theme/app_pallete.dart';
import 'package:easy_life_application/core/widgets/easylife_appbar.dart';
import 'package:easy_life_application/core/widgets/easylife_radialmenu.dart';
import 'package:easy_life_application/core/widgets/easylife_searchbar.dart';
import 'package:easy_life_application/models/account_model.dart';
import 'package:easy_life_application/screen/account/account_create_page.dart';
import 'package:easy_life_application/screen/account/account_detail_page.dart';
import 'package:easy_life_application/services/account/account_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_life_application/screen/account/account_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // 0=Games,1=Subs,2=Accounts,3=Users,4=Purchases
  final TextEditingController _searchController = TextEditingController();
  late final AccountService _accountService;

  @override
  void initState() {
    super.initState();
    _accountService = AccountService();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<AccountModel?> _getOrCreateAccountFromEmail(String email) async {
    final existing = await _accountService.getAccountByEmail(email);
    if (existing != null) return existing;

    final created = await Navigator.of(context).push<AccountModel?>(
      MaterialPageRoute(builder: (_) => AccountCreatePage(initialEmail: email)),
    );

    return created;
  }

  Future<void> _handleAccountSearchOrCreate() async {
    final email = _searchController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un\'email prima di procedere')),
      );
      return;
    }

    try {
      final account = await _getOrCreateAccountFromEmail(email);

      if (!mounted) return;

      if (account != null) {
        // se vuoi, qui puoi navigare direttamente al dettaglio
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AccountDetailPage(account: account),
          ),
        );

        _searchController.clear();
      } else {
        // es. l’utente ha annullato la creazione
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nessun account selezionato o creato')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // 🔹 lasciamo che il body vada dietro l'AppBar per effetto più "iOS"
      extendBodyBehindAppBar: true,
      appBar: const EasyLifeAppBar(),
      body: Container(
        // 🎨 SFONDO GRADIENT VERDE CHIARO → BIANCO
        decoration: const BoxDecoration(
          gradient: Pallete.mainBackgroundGradient,
        ),
        child: Stack(
          children: [
            // 👇 Contenuto principale: search + tab body
            Column(
              children: [
                SizedBox(height: screenHeight * 0.15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: EasyLifeSearchBar(
                    controller: _searchController,
                    onSubmitted: (_) => _handleAccountSearchOrCreate(),
                    onAddPressed: _handleAccountSearchOrCreate,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildTabBody()),
              ],
            ),

            // 🎯 Radial menu sopra il contenuto
            // 🎯 Radial menu in basso al centro
            // 🎯 Radial menu in basso al centro, con gestione SafeArea
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 30 + MediaQuery.of(context).padding.bottom,
                ),
                child: IgnorePointer(
                  ignoring: false,
                  child: EasyLifeRadialMenu(
                    onItemSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody() {
    switch (_selectedIndex) {
      case 0:
        return const Center(child: Text('Games (TODO)'));
      case 1:
        return const Center(child: Text('Subscriptions (TODO)'));
      case 2:
        return const AccountHomePage();
      case 3:
        return const Center(child: Text('Users (TODO)'));
      case 4:
        return const Center(child: Text('Purchases (TODO)'));
      default:
        return const SizedBox.shrink();
    }
  }
}
