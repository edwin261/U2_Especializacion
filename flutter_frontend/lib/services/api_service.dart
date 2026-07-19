import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/auth_session.dart';
import '../models/product.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = _decode(response);
    if (response.statusCode >= 400) {
      throw ApiException(_messageFrom(body, 'Error al iniciar sesion'));
    }

    return AuthSession.fromJson(body);
  }

  Future<List<Product>> getProducts(String token) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/products'),
      headers: _authHeaders(token),
    );

    final body = _decode(response);
    if (response.statusCode >= 400) {
      throw ApiException(_messageFrom(body, 'No se pudieron cargar los productos'));
    }

    return (body as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<int> getMyProductCount(String token) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}/products/my-count'),
      headers: _authHeaders(token),
    );

    final body = _decode(response);
    if (response.statusCode >= 400) {
      throw ApiException(_messageFrom(body, 'No se pudo consultar el conteo'));
    }

    final count = body['count'];
    if (count is int) return count;
    if (count is num) return count.toInt();
    return int.tryParse(count?.toString() ?? '') ?? 0;
  }

  Future<Product> createProduct({
    required String token,
    required String name,
    required String price,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}/products'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'name': name,
        'price': price,
      }),
    );

    final body = _decode(response);
    if (response.statusCode >= 400) {
      throw ApiException(_messageFrom(body, 'No se pudo crear el producto'));
    }

    return Product.fromJson(body);
  }

  Future<Product> updateProduct({
    required String token,
    required int productId,
    required String name,
    required String price,
  }) async {
    final response = await _client.put(
      Uri.parse('${AppConfig.apiBaseUrl}/products/$productId'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'name': name,
        'price': price,
      }),
    );

    final body = _decode(response);
    if (response.statusCode >= 400) {
      throw ApiException(_messageFrom(body, 'No se pudo actualizar el producto'));
    }

    return Product.fromJson(body);
  }

  Future<void> deleteProduct({
    required String token,
    required int productId,
  }) async {
    final response = await _client.delete(
      Uri.parse('${AppConfig.apiBaseUrl}/products/$productId'),
      headers: _authHeaders(token),
    );

    final body = _decode(response);
    if (response.statusCode >= 400) {
      throw ApiException(_messageFrom(body, 'No se pudo eliminar el producto'));
    }
  }

  Map<String, String> _jsonHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

  Map<String, String> _authHeaders(String token) {
    return {
      ..._jsonHeaders(),
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(response.body);
  }

  String _messageFrom(dynamic body, String fallback) {
    if (body is Map<String, dynamic> && body['message'] != null) {
      return body['message'].toString();
    }

    return fallback;
  }
}
