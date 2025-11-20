import 'dart:convert';

import 'package:easy_life_application/models/game_model.dart';
import 'package:easy_life_application/models/subscription_model.dart';
import 'package:easy_life_application/models/purchase_model.dart';

class AccountModel {

  final int id;
  final String email;
  final String password;
  final DateTime createdAt;
  final String nation;
  final String description;
  final List<GameModel> games;
  final List<SubscriptionModel> subscriptions;
  final List<PurchaseModel> purchases;

  AccountModel({
    required this.id,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.nation,
    required this.description,
    required this.games,
    required this.subscriptions,
    required this.purchases,
  });

  AccountModel copyWith({
    int? id,
    String? email,
    String? password,
    DateTime? createdAt,
    String? nation,
    String? description,
    List<GameModel>? games,
    List<SubscriptionModel>? subscriptions,
    List<PurchaseModel>? purchases,
  }) {
    return AccountModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      nation: nation ?? this.nation,
      description: description ?? this.description,
      games: games ?? this.games,
      subscriptions: subscriptions ?? this.subscriptions,
      purchases: purchases ?? this.purchases,
    );
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
      nation: map['nation'],
      description: map['description'],
      games: List<GameModel>.from(map['games']?.map((x) => GameModel.fromMap(x))),
      subscriptions: List<SubscriptionModel>.from(map['subscriptions']?.map((x) => SubscriptionModel.fromMap(x))),
      purchases: List<PurchaseModel>.from(map['purchases']?.map((x) => PurchaseModel.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'nation': nation,
      'description': description,
      'games': games.map((x) => x.toMap()).toList(),
      'subscriptions': subscriptions.map((x) => x.toMap()).toList(),
      'purchases': purchases.map((x) => x.toMap()).toList(),
    };
  }

  factory AccountModel.fromJson(String source) => AccountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  String toString() {
    return 'AccountModel(id: $id, email: $email, password: $password, createdAt: $createdAt, nation: $nation, description: $description, games: $games, subscriptions: $subscriptions, purchases: $purchases)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccountModel &&
        other.id == id &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ password.hashCode;
  }


}