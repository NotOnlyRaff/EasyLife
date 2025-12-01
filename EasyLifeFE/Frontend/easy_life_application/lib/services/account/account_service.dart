import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_life_application/config/api_config.dart';
import 'package:easy_life_application/models/account_model.dart';

class AccountService {
  final http.Client _client;

  AccountService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<AccountModel>> getAllAccounts() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/accounts');

    final response = await _client.get(uri);
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to load accounts: ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body);
    return data
        .map((e) => AccountModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<AccountModel> getAccountById(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/accounts/$id');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load account $id: ${response.statusCode}');
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    return AccountModel.fromMap(data);
  }

  /// 🔎 Cerca un account per email.
  /// Ritorna `AccountModel` se esiste, `null` se il backend risponde 404.
  Future<AccountModel?> getAccountByEmail(String email) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/accounts/email?email=$email',
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      return AccountModel.fromMap(data);
    }

    if (response.statusCode == 404) {
      // account non trovato
      return null;
    }
    print(response.body);
    throw Exception(
      'Errore durante la ricerca account: ${response.statusCode} ${response.body}',
    );
  }

  /// ➕ Crea un nuovo account.
  Future<AccountModel> createAccount({
    required String email,
    required String password,
    required String nation,
    String? description,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/accounts');

    final body = json.encode({
      'email': email,
      'password': password,
      'nation': nation,
      'description': description,
      // createdAt e status li setta il backend
    });

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return AccountModel.fromMap(data);
    }

    throw Exception(
      'Errore nella creazione account: ${response.statusCode} ${response.body}',
    );
  }

  /// ✏️ Aggiorna un account esistente (PUT /accounts/{id})
  Future<AccountModel> updateAccount(AccountModel account) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/accounts/${account.id}');

    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: account.toJson(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return AccountModel.fromMap(data);
    }

    throw Exception(
      'Errore nell\'update account: ${response.statusCode} ${response.body}',
    );
  }

  /// 🗑️ Elimina un account (DELETE /accounts/{id})
  Future<void> deleteAccount(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/accounts/$id');

    final response = await _client.delete(uri);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Errore nella cancellazione account: ${response.statusCode} ${response.body}',
      );
    }
  }
}
