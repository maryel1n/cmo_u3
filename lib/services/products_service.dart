import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'env.dart';

class ProductsService {
  final http.Client _client;
  ProductsService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Authorization': Env.basicAuth,
    'Content-Type': 'application/json',
  };

  /// ---- Listar ----
  Future<List<Product>> fetchList() async {
    final uri = Uri.parse(Env.listProducts);
    final res = await _client
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> data =
        json.decode(res.body) as Map<String, dynamic>;
    final List items = (data['listado'] as List?) ?? const [];

    return items
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Aliases para compatibilidad con distintos Providers
  Future<List<Product>> fetch() => fetchList();
  Future<List<Product>> list() => fetchList();
  Future<List<Product>> fetchProducts() => fetchList(); // <— la que te falta

  /// ---- Crear ----
  Future<String> create(Product p) async {
    final uri = Uri.parse(Env.createProduct);
    final body = json.encode({
      'productName': p.productName,
      'price': p.price,
      'stock': p.stock,
      'category': p.category,
      'estado': p.estado,
    });

    final res = await _client
        .post(uri, headers: _headers, body: body)
        .timeout(const Duration(seconds: 10));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> data =
        json.decode(res.body) as Map<String, dynamic>;
    return (data['id'] as String?) ?? '';
  }

  /// ---- Actualizar ----
  Future<void> update(Product p) async {
    if ((p.id ?? '').isEmpty) {
      throw ArgumentError('Falta id de producto para actualizar');
    }
    final uri = Uri.parse(Env.updateProduct(p.id!));
    final body = json.encode({
      'productName': p.productName,
      'price': p.price,
      'stock': p.stock,
      'category': p.category,
      'estado': p.estado,
    });

    final res = await _client
        .put(uri, headers: _headers, body: body)
        .timeout(const Duration(seconds: 10));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  /// ---- Eliminar ----
  Future<void> remove(String id) async {
    final uri = Uri.parse(Env.deleteProduct(id));
    final res = await _client
        .delete(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  // Aliases CRUD para nombres comunes
  Future<String> createProduct(Product p) => create(p);
  Future<void> updateProduct(Product p) => update(p);
  Future<void> deleteProduct(String id) => remove(id);

  void dispose() => _client.close();
}
