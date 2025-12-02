import 'dart:convert';

import 'package:easy_life_application/config/api_config.dart';
import 'package:easy_life_application/models/purchase_model.dart';
import 'package:http/http.dart' as http;

class PurchaseService {
  final http.Client _client;

  PurchaseService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PurchaseModel>> getAllPurchases() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/purchases');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Errore nel caricamento acquisti: ${response.statusCode} - ${response.body}',
      );
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((e) => PurchaseModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Carica tutti gli acquisti associati a uno userId
  Future<List<PurchaseModel>> getPurchasesByUserId(int userId) async {
    // TODO: adatta l'endpoint al tuo backend
    // Esempio: /purchases/user/{id} oppure /users/{id}/purchases
    final uri = Uri.parse('${ApiConfig.baseUrl}/purchases/user/$userId');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Errore nel caricamento acquisti utente $userId: '
        '${response.statusCode} - ${response.body}',
      );
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((e) => PurchaseModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future createPurchase({
    required int userId,
    required int accountId,
    required PurchaseType purchaseType,
    required double price,
    required DateTime purchaseDate,
    required DateTime startDate,
    required DateTime expirationDate,
    required String paymentMethod,
    required PurchaseStatus purchaseStatus,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/purchases');

    final body = json.encode({
      'userId': userId,
      'accountId': accountId,
      'purchaseType': purchaseType.toString().split('.').last,
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'purchaseStatus': purchaseStatus.toString().split('.').last,
    });

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Errore nella creazione dell\'acquisto: '
        '${response.statusCode} - ${response.body}',
      );
    }
  }
}
