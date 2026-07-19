class AuthSession {
  AuthSession({
    required this.token,
    required this.username,
    required this.userId,
    required this.productCount,
  });

  final String token;
  final String username;
  final int userId;
  final int productCount;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      username: json['username'] as String,
      userId: NumberParser.toInt(json['userId']),
      productCount: NumberParser.toInt(json['productCount']),
    );
  }
}

class NumberParser {
  static int toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
