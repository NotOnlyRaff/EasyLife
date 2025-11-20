import 'dart:convert';

import 'package:easy_life_application/models/purchase_model.dart';

class UsersModel {

  final int id;
  final String firstName;
  final String surname;
  final int purchaseNumber;
  final List<PurchaseModel> purchases;

  UsersModel({
    required this.id,
    required this.firstName,
    required this.surname,
    required this.purchaseNumber,
    required this.purchases,
  });

  UsersModel copyWith({
    int? id,
    String? firstName,
    String? surname,
    int? purchaseNumber,
    List<PurchaseModel>? purchases,
  }) {
    return UsersModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      purchaseNumber: purchaseNumber ?? this.purchaseNumber,
      purchases: purchases ?? this.purchases,
    );
  }

  factory UsersModel.fromMap(Map<String, dynamic> map) {
    return UsersModel(
      id: map['id'],
      firstName: map['firstName'],
      surname: map['surname'],
      purchaseNumber: map['purchaseNumber'],
      purchases: List<PurchaseModel>.from(
        map['purchases']?.map((x) => PurchaseModel.fromMap(x))),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'surname': surname,
      'purchaseNumber': purchaseNumber,
      'purchases': purchases.map((x) => x.toMap()).toList(),
    };
  }

  factory UsersModel.fromJson(String source) => UsersModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'UsersModel(id: $id, firstName: $firstName, surname: $surname, purchaseNumber: $purchaseNumber, purchases: $purchases)';
  }

}