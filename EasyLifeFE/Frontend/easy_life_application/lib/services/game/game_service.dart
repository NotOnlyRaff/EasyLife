// lib/services/game/game_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:easy_life_application/config/api_config.dart';
import 'package:easy_life_application/models/game_model.dart';

class GameService {
  final http.Client _client;

  GameService({http.Client? client}) : _client = client ?? http.Client();

  /// 🔹 Recupera tutti i games
  Future<List<GameModel>> getAllGames() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/games');

    final response = await _client.get(uri);
    // opzionale: debug
    // print('GET /games => ${response.statusCode} ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load games: ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body) as List<dynamic>;

    return data
        .map(
          (e) => GameModel.fromMap(e as Map<String, dynamic>),
        )
        .toList();
  }

  /// 🔹 Recupera un singolo game per id
  Future<GameModel> getGameById(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/games/$id');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load game $id: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    return GameModel.fromMap(data);
  }

  /// 🔹 Crea un nuovo game.
  /// NB: adatta i campi in base a quello che si aspetta il tuo backend nel DTO.
  Future<GameModel> createGame({
    required String gameName,
    required String gameProfileId,
    required double price,
    required double salePrice,
    required double cost,
    required String nation,
    required DateTime saleDate,
    required DateTime purchaseDate,
    required String orderNumber,
    String description = '',
    required bool isPS5PrimaryAvailable,
    required bool isPS5SecondaryAvailable,
    required bool isPS4PrimaryAvailable,
    required bool isPS4SecondaryAvailable,
    required bool isActive,
    required int accountId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/games');

    final body = json.encode({
      // niente id: lo genera il backend
      'gameName': gameName,
      'gameProfileId': gameProfileId,
      'price': price,
      'salePrice': salePrice,
      'cost': cost,
      'nation': nation,
      'saleDate': saleDate.toIso8601String(),
      'purchaseDate': purchaseDate.toIso8601String(),
      'orderNumber': orderNumber,
      'description': description,
      'isPS5PrimaryAvailable': isPS5PrimaryAvailable,
      'isPS5SecondaryAvailable': isPS5SecondaryAvailable,
      'isPS4PrimaryAvailable': isPS4PrimaryAvailable,
      'isPS4SecondaryAvailable': isPS4SecondaryAvailable,
      'isActive': isActive,
      'accountId': accountId,
    });

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Errore creazione game: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    return GameModel.fromMap(data);
  }

  /// 🔹 Update di un game esistente
  Future<GameModel> updateGame(GameModel game) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/games/${game.id}');

    final body = json.encode(game.toMap());

    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Errore update game ${game.id}: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;

    return GameModel.fromMap(data);
  }

  /// 🔹 Delete di un game
  Future<void> deleteGame(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/games/$id');

    final response = await _client.delete(uri);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Errore delete game $id: ${response.statusCode} ${response.body}',
      );
    }
  }
}
