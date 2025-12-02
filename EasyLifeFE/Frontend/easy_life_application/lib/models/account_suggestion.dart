class AccountSuggestion {
  final int id;
  final String email;

  AccountSuggestion({
    required this.id,
    required this.email,
  });

  factory AccountSuggestion.fromMap(Map<String, dynamic> map) {
    return AccountSuggestion(
      id: map['id'] as int,
      email: map['email'] as String,
    );
  }
}
