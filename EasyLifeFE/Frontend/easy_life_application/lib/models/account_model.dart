import 'dart:convert';

enum AccountStatus {ACTIVE, PENDING, CANCELLED }
class AccountModel {

  final int id;
  final String email;
  final String password;
  final DateTime createdAt;
  final String nation;
  final String? description;
  final AccountStatus accountStatus;

  AccountModel({
    required this.id,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.nation,
    this.description,
    required this.accountStatus,
  });

  AccountModel copyWith({
    int? id,
    String? email,
    String? password,
    DateTime? createdAt,
    String? nation,
    String? description,
    AccountStatus? accountStatus,
  }) {
    return AccountModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      nation: nation ?? this.nation,
      description: description ?? this.description,
      accountStatus: accountStatus ?? this.accountStatus,
    );
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
      nation: map['nation'],
      description: (map['description'] ?? '') as String?,
      accountStatus: AccountStatus.values.firstWhere((e) => e.toString() == 'AccountStatus.' + map['accountStatus']),
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
      'accountStatus': accountStatus.toString().split('.').last,
    };
  }

  factory AccountModel.fromJson(String source) => AccountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'AccountModel(id: $id, email: $email, password: $password, createdAt: $createdAt, nation: $nation, description: $description, accountStatus: $accountStatus)';
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