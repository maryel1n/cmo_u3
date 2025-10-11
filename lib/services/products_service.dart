import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'env.dart';

/// Servicio HTTP que consume tus Cloud Functions (emulador) con Basic Auth.
/// Endpoints definidos en env.dart (listProducts, createProduct, etc.)
class ProductsService {
  final http.Client _client;

  ProductsService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Authorization': Env.basicAuth,
    'Content-Type': 'application/json',
  };

  /// Lista de productos
  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse(Env.listProducts);
    final res = await _client.get(uri, headers: _headers);

    if (res.statusCode != 200) {
      throw Exception('GET $uri failed (${res.statusCode}): ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final listado = (data['listado'] as List? ?? []);
    return listado
        .map((e) => Product.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Crear producto. Devuelve el id creado.
  Future<String> createProduct({
    required String productName,
    required int price,
    required int stock,
    String category = 'general',
    String estado = 'Activo',
  }) async {
    final uri = Uri.parse(Env.createProduct);
    final body = jsonEncode({
      'productName': productName,
      'price': price,
      'stock': stock,
      'category': category,
      'estado': estado,
    });

    final res = await _client.post(uri, headers: _headers, body: body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('POST $uri failed (${res.statusCode}): ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['id'] as String?) ?? '';
  }

  /// Actualizar producto por ID
  Future<void> update(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse(Env.updateProduct(id));
    final res = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode(data),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('PUT $uri failed (${res.statusCode}): ${res.body}');
    }
  }

  /// Eliminar producto por ID
  Future<void> delete(String id) async {
    final uri = Uri.parse(Env.deleteProduct(id));
    final res = await _client.delete(uri, headers: _headers);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('DELETE $uri failed (${res.statusCode}): ${res.body}');
    }
  }

  void dispose() {
    _client.close();
  }
}
