import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductsService {
  // Basic Auth del backend (emulador)
  static const _headers = <String, String>{
    'Authorization': 'Basic dGVzdDp0ZXN0MjAyMw==',
    'Content-Type': 'application/json',
  };

  // Host del emulador visto desde el dispositivo
  String get _host {
    if (kIsWeb) return '127.0.0.1';
    if (Platform.isAndroid) return '10.0.2.2'; // Android Emulator -> host
    return '127.0.0.1'; // iOS simulator / desktop
  }

  // BASE CORRECTA **con /api** ya incluido y SIN guiones
  Uri _uri(String path) =>
      Uri.parse('http://$_host:5001/cmo-u3-quintanilla/us-central1/api$path');

  Future<List<Product>> fetchProducts() async {
    final res = await http.get(
      _uri('/ejemplos/product_list_rest/'),
      headers: _headers,
    );

    if (res.statusCode != 200) {
      throw Exception('GET ${res.statusCode}: ${res.body}');
    }

    final map = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final list = (map['listado'] as List).cast<Map<String, dynamic>>();
    return list.map(Product.fromJson).toList();
  }

  // (Opcional) CRUD restante si lo usas:
  Future<String> createProduct(Product p) async {
    final res = await http.post(
      _uri('/ejemplos/product_create/'),
      headers: _headers,
      body: json.encode(p.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('POST ${res.statusCode}: ${res.body}');
    }
    final map = json.decode(res.body) as Map<String, dynamic>;
    return map['id'] as String;
  }

  Future<void> updateProduct(String id, Map<String, dynamic> fields) async {
    final res = await http.put(
      _uri('/ejemplos/product_update/$id'),
      headers: _headers,
      body: json.encode(fields),
    );
    if (res.statusCode != 200) {
      throw Exception('PUT ${res.statusCode}: ${res.body}');
    }
  }

  Future<void> deleteProduct(String id) async {
    final res = await http.delete(
      _uri('/ejemplos/product_delete/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('DELETE ${res.statusCode}: ${res.body}');
    }
  }
}
