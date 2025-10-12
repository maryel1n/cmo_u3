import 'dart:convert';
import 'package:http/http.dart' as http;

import 'env.dart';
import '../models/product.dart';

class ProductsService {
  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Authorization': Env.basicAuth,
  };

  Future<List<Product>> fetchProducts() async {
    final res = await http.get(
      Uri.parse(Env.listProducts),
      headers: _headers(),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Error listando productos: ${res.statusCode} ${res.body}',
      );
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['listado'] as List<dynamic>)
        .map((e) => Product.fromMap(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<String> create({
    required String productName,
    required int price,
    required int stock,
    required String category,
    String estado = 'Activo',
  }) async {
    final res = await http.post(
      Uri.parse(Env.createProduct),
      headers: _headers(),
      body: jsonEncode({
        'productName': productName,
        'price': price,
        'stock': stock,
        'category': category,
        'estado': estado,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error creando producto: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['ok'] != true || data['id'] == null) {
      throw Exception('Respuesta inesperada al crear: ${res.body}');
    }
    return data['id'] as String;
  }

  /// ← CAMBIO: usar PUT para el endpoint /product_update/:id
  Future<void> update(String id, Map<String, dynamic> payload) async {
    final res = await http.put(
      Uri.parse(Env.updateProduct(id)),
      headers: _headers(),
      body: jsonEncode(payload),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error actualizando $id: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['ok'] != true) {
      throw Exception('Respuesta inesperada al actualizar: ${res.body}');
    }
  }

  Future<void> delete(String id) async {
    final res = await http.delete(
      Uri.parse(Env.deleteProduct(id)),
      headers: _headers(),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error eliminando $id: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['ok'] != true) {
      throw Exception('Respuesta inesperada al eliminar: ${res.body}');
    }
  }
}
