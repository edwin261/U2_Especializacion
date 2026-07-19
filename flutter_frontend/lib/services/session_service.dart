import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';

class SessionService {
  static const _tokenKey = 'token';
  static const _usernameKey = 'name';
  static const _userIdKey = 'userId';
  static const _productCountKey = 'productCount';

  Future<AuthSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      return null;
    }

    return AuthSession(
      token: token,
      username: prefs.getString(_usernameKey) ?? '',
      userId: prefs.getInt(_userIdKey) ?? 0,
      productCount: prefs.getInt(_productCountKey) ?? 0,
    );
  }

  Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.token);
    await prefs.setString(_usernameKey, session.username);
    await prefs.setInt(_userIdKey, session.userId);
    await prefs.setInt(_productCountKey, session.productCount);
  }

  Future<void> saveProductCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_productCountKey, count);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_productCountKey);
  }
}
