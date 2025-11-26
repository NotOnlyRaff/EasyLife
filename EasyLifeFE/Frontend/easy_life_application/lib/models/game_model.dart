import 'dart:convert';

class GameModel {

  final int id;
  final String gameName;
  final String gameProfileId;
  final double price;
  final double salePrice;
  final double cost;
  final String nation;
  final DateTime saleDate;
  final DateTime purchaseDate;
  final String orderNumber;
  final String description;
  final bool isPS5PrimaryAvailable;
  final bool isPS5SecondaryAvailable;
  final bool isPS4PrimaryAvailable;
  final bool isPS4SecondaryAvailable;
  final bool isActive;
  final int accountId;

  GameModel({
    required this.id,
    required this.gameName,
    required this.gameProfileId,
    required this.price,
    required this.salePrice,
    required this.cost,
    required this.nation,
    required this.saleDate,
    required this.purchaseDate,
    required this.orderNumber,
    required this.description,
    required this.isPS5PrimaryAvailable,
    required this.isPS5SecondaryAvailable,
    required this.isPS4PrimaryAvailable,
    required this.isPS4SecondaryAvailable,
    required this.isActive,
    required this.accountId,
  });

  GameModel copyWith({
    int? id,
    String? gameName,
    String? gameProfileId,
    double? price,
    double? salePrice,
    double? cost,
    String? nation,
    DateTime? saleDate,
    DateTime? purchaseDate,
    String? orderNumber,
    String? description,
    bool? isPS5PrimaryAvailable,
    bool? isPS5SecondaryAvailable,
    bool? isPS4PrimaryAvailable,
    bool? isPS4SecondaryAvailable,
    bool? isActive,
    int? accountId,
  }) {
    return GameModel(
      id: id ?? this.id,
      gameName: gameName ?? this.gameName,
      gameProfileId: gameProfileId ?? this.gameProfileId,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      cost: cost ?? this.cost,
      nation: nation ?? this.nation,
      saleDate: saleDate ?? this.saleDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      orderNumber: orderNumber ?? this.orderNumber,
      description: description ?? this.description,
      isPS5PrimaryAvailable:
          isPS5PrimaryAvailable ?? this.isPS5PrimaryAvailable,
      isPS5SecondaryAvailable:
          isPS5SecondaryAvailable ?? this.isPS5SecondaryAvailable,
      isPS4PrimaryAvailable:
          isPS4PrimaryAvailable ?? this.isPS4PrimaryAvailable,
      isPS4SecondaryAvailable:
          isPS4SecondaryAvailable ?? this.isPS4SecondaryAvailable,
      isActive: isActive ?? this.isActive,
      accountId: accountId ?? this.accountId,
    );
  }

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'],
      gameName: map['gameName'],
      gameProfileId: map['gameProfileId'],
      price: map['price'],
      salePrice: map['salePrice'],
      cost: map['cost'],
      nation: map['nation'],
      saleDate: DateTime.parse(map['saleDate']),
      purchaseDate: DateTime.parse(map['purchaseDate']),
      orderNumber: map['orderNumber'],
      description: map['description'],
      isPS5PrimaryAvailable: map['isPS5PrimaryAvailable'],
      isPS5SecondaryAvailable: map['isPS5SecondaryAvailable'],
      isPS4PrimaryAvailable: map['isPS4PrimaryAvailable'],
      isPS4SecondaryAvailable: map['isPS4SecondaryAvailable'],
      isActive: map['isActive'],
      accountId: map['accountId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
    };
  }

  factory GameModel.fromJson(String source) =>
      GameModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  String toString() {
    return 'GameModel(id: $id, gameName: $gameName, gameProfileId: $gameProfileId, price: $price, salePrice: $salePrice, cost: $cost, nation: $nation, saleDate: $saleDate, purchaseDate: $purchaseDate, orderNumber: $orderNumber, description: $description, isPS5PrimaryAvailable: $isPS5PrimaryAvailable, isPS5SecondaryAvailable: $isPS5SecondaryAvailable, isPS4PrimaryAvailable: $isPS4PrimaryAvailable, isPS4SecondaryAvailable: $isPS4SecondaryAvailable, isActive: $isActive, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GameModel &&
        other.id == id &&
        other.gameName == gameName &&
        other.gameProfileId == gameProfileId &&
        other.orderNumber == orderNumber &&
         other.accountId == accountId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        gameName.hashCode ^
        gameProfileId.hashCode ^
        orderNumber.hashCode ^
        accountId.hashCode;
  }
}