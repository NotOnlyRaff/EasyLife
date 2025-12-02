import 'dart:convert';
import 'package:easy_life_application/config/api_config.dart';
import 'package:easy_life_application/models/users_model.dart';
import 'package:http/http.dart' as http;

class UsersService {
  final http.Client _client;

  UsersService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<UsersModel>> getAllUsers() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Errore nel caricamento users: ${response.statusCode} - ${response.body}',
      );
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((e) => UsersModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
