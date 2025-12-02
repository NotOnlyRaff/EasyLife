// lib/services/subscription/subscription_service.dart

import 'dart:convert';

import 'package:easy_life_application/models/subscription_model.dart';
// Adatta questi import ai tuoi file reali:
import 'package:easy_life_application/config/api_config.dart';
import 'package:http/http.dart' as http;

class SubscriptionService {
  final http.Client _client;

  SubscriptionService({http.Client? client})
    : _client = client ?? http.Client();

  /// GET /subscriptions
  Future<List<SubscriptionModel>> getAllSubscriptions() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/subscriptions');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load games: ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body) as List<dynamic>;

    return data
        .map((e) => SubscriptionModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// 🔹 Recupera un singolo subscription per id
  Future<SubscriptionModel> getSubscriptionById(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/subscriptions/$id');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load subscription $id: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    return SubscriptionModel.fromMap(data);
  }

  /// POST /subscriptions
  Future<SubscriptionModel> createSubscription({
    required String subscriptionType,
    required double price,
    double? salePrice,
    double? cost,
    required String nation,
    required String vpnUsed,
    DateTime? saleDate,
    DateTime? purchaseDate,
    DateTime? activationDate,
    DateTime? expirationDate,
    required bool isActive,
    required int freeProfileNumber,
    required int accountId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/subscriptions');
    final body = json.encode({
      'subscriptionType': subscriptionType,
      'price': price,
      'salePrice': salePrice,
      'cost': cost,
      'nation': nation,
      'vpnUsed': vpnUsed,
      'saleDate': saleDate?.toIso8601String(),
      'purchaseDate': purchaseDate?.toIso8601String(),
      'activationDate': activationDate?.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'isActive': isActive,
      'freeProfileNumber': freeProfileNumber,
      'accountId': accountId,
    });

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Errore creazione subscription: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    return SubscriptionModel.fromMap(data);

  }

  /// PUT /subscriptions/{id}
  Future<SubscriptionModel> updateSubscription(
    SubscriptionModel subscription,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/subscriptions/${subscription.id}');

    final body = json.encode(subscription.toMap());

    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Errore update subscription ${subscription.id}: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;

    return SubscriptionModel.fromMap(data);
  }

  /// DELETE /subscriptions/{id}
  Future<void> deleteSubscription(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/subscriptions/$id');

    final response = await _client.delete(uri);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Errore delete subscription $id: ${response.statusCode} ${response.body}',
      );
    }
  }
}
