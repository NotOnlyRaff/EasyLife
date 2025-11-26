import 'dart:convert';

enum PurchaseType { FULL, RENTAL }
enum PurchaseStatus { PLANNED, ACTIVE, EXPIRED, CANCELLED }

class PurchaseModel {
  final int id;
  final int userId;
  final int accountId;
  final PurchaseType purchaseType;
  final double price;
  final DateTime purchaseDate;
  final DateTime startDate;
  final DateTime expirationDate;
  final String paymentMethod;
  final PurchaseStatus purchaseStatus;

  PurchaseModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.purchaseType,
    required this.price,
    required this.purchaseDate,
    required this.startDate,
    required this.expirationDate,
    required this.paymentMethod,
    required this.purchaseStatus,
  });

  PurchaseModel copyWith({
    int? id,
    int? userId,
    int? accountId,
    PurchaseType? purchaseType,
    double? price,
    DateTime? purchaseDate,
    DateTime? startDate,
    DateTime? expirationDate,
    String? paymentMethod,
    PurchaseStatus? purchaseStatus,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      purchaseType: purchaseType ?? this.purchaseType,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      startDate: startDate ?? this.startDate,
      expirationDate: expirationDate ?? this.expirationDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
    );
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'],
      userId: map['userId'],
      accountId: map['accountId'],
      purchaseType: PurchaseType.values.firstWhere((e) => e.toString() == 'PurchaseType.' + map['purchaseType']),
      price: map['price'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      startDate: DateTime.parse(map['startDate']),
      expirationDate: DateTime.parse(map['expirationDate']),
      paymentMethod: map['paymentMethod'],
      purchaseStatus: PurchaseStatus.values.firstWhere((e) => e.toString() == 'PurchaseStatus.' + map['purchaseStatus']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'accountId': accountId,
      'purchaseType': purchaseType.toString().split('.').last,
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'purchaseStatus': purchaseStatus.toString().split('.').last,
    };
  }

  factory PurchaseModel.fromJson(String source) => PurchaseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'PurchaseModel(id: $id, userId: $userId, accountId: $accountId, purchaseType: $purchaseType, price: $price, purchaseDate: $purchaseDate, startDate: $startDate, expirationDate: $expirationDate, paymentMethod: $paymentMethod, purchaseStatus: $purchaseStatus)';
  }
}