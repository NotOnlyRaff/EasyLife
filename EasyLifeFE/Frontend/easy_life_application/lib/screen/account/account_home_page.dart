import 'package:flutter/material.dart';
import 'package:easy_life_application/services/account_service.dart';
import 'package:easy_life_application/models/account_model.dart';

class AccountHomePage extends StatefulWidget {
  const AccountHomePage({super.key});

  @override
  State<AccountHomePage> createState() => _AccountHomePageState();
}

class _AccountHomePageState extends State<AccountHomePage> {
  late final AccountService _apiService;
  late Future<List<AccountModel>> _futureAccounts;

  @override
  void initState() {
    super.initState();
    _apiService = AccountService();
    _futureAccounts = _apiService.getAllAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: FutureBuilder<List<AccountModel>>(
        future: _futureAccounts,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            
            return Center(
              child: Text('Errore: ${snapshot.error}  ${snapshot.data?.first.toString() ?? ''}'),
            );
          }

          final accounts = snapshot.data ?? [];

          if (accounts.isEmpty) {
            return const Center(child: Text('Nessun account trovato'));
          }

          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                title: Text(account.email),
                subtitle: Text(
                  'Nation: ${account.nation}',
                ),
                onTap: () {
                  // TODO: vai a AccountDetailPage(accountId: account.id)
                },
              );
            },
          );
        },
      ),
    );
  }
}
