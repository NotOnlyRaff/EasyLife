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
    return data.map((e) => AccountModel.fromMap(e as Map<String, dynamic>)).toList();
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
}
