import 'dart:convert';

class SubscriptionModel{
  final int id;
  final String subscriptionType;
  final double price;
  final double? salePrice;
  final double? cost;
  final String nation;
  final String vpnUsed;
  final DateTime? saleDate;
  final DateTime? purchaseDate;
  final DateTime? activationDate;
  final DateTime? expirationDate;
  final bool isActive;
  final int freeProfileNumber;
  final int accountId;

  SubscriptionModel({
    required this.id,
    required this.subscriptionType,
    required this.price,
    this.salePrice,
    this.cost,
    required this.nation,
    required this.vpnUsed,
    this.saleDate,
    this.purchaseDate,
    this.activationDate,
    this.expirationDate,
    required this.isActive,
    required this.freeProfileNumber,
    required this.accountId,
  });

  SubscriptionModel copyWith({
    int? id,
    String? subscriptionType,
    double? price,
    double? salePrice,
    double? cost,
    String? nation,
    String? vpnUsed,
    DateTime? saleDate,
    DateTime? purchaseDate,
    DateTime? activationDate,
    DateTime? expirationDate,
    bool? isActive,
    int? freeProfileNumber,
    int? accountId,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      cost: cost ?? this.cost,
      nation: nation ?? this.nation,
      vpnUsed: vpnUsed ?? this.vpnUsed,
      saleDate: saleDate ?? this.saleDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      activationDate: activationDate ?? this.activationDate,
      expirationDate: expirationDate ?? this.expirationDate,
      isActive: isActive ?? this.isActive,
      freeProfileNumber: freeProfileNumber ?? this.freeProfileNumber,
      accountId: accountId ?? this.accountId,
    );
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'],
      subscriptionType: map['subscriptionType'],
      price: map['price'],
      salePrice: map['salePrice'],
      cost: map['cost'],
      nation: map['nation'],
      vpnUsed: map['vpnUsed'],
      saleDate: DateTime.parse(map['saleDate']),
      purchaseDate: DateTime.parse(map['purchaseDate']),
      activationDate: DateTime.parse(map['activationDate']),
      expirationDate: DateTime.parse(map['expirationDate']),
      isActive: map['isActive'],
      freeProfileNumber: map['freeProfileNumber'],
      accountId: map['accountId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
    };
  }
  
  factory SubscriptionModel.fromJson(String source) => SubscriptionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  String toString() {
    return 'SubscriptionModel(id: $id, subscriptionType: $subscriptionType, price: $price, salePrice: $salePrice, cost: $cost, nation: $nation, vpnUsed: $vpnUsed, saleDate: $saleDate, purchaseDate: $purchaseDate, activationDate: $activationDate, expirationDate: $expirationDate, isActive: $isActive, freeProfileNumber: $freeProfileNumber, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubscriptionModel &&
        other.id == id &&
        other.subscriptionType == subscriptionType &&
        other.nation == nation &&
        other.vpnUsed == vpnUsed &&
        other.accountId == accountId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        subscriptionType.hashCode ^
        nation.hashCode ^
        vpnUsed.hashCode ^
        accountId.hashCode;
  }
  
}