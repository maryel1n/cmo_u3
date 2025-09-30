import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductsService {
  /// URL del emulador de Functions vista desde **Android Emulator** (10.0.2.2 = localhost del host)
  static const String baseUrl =
      'http://10.0.2.2:5001/cmo-u3-quintanilla/us-central1/api';

  // Credenciales Basic Auth (mismas que en Functions)
  static const String _user = 'test';
  static const String _pass = 'test2023';

  final http.Client _client;
  ProductsService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Authorization': 'Basic ${base64Encode(utf8.encode('$_user:$_pass'))}',
    'Accept': 'application/json',
  };

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('$baseUrl/ejemplos/product_list_rest/');
    final resp = await _client
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }

    final Map<String, dynamic> jsonBody =
        json.decode(resp.body) as Map<String, dynamic>;
    final List listado = (jsonBody['listado'] as List?) ?? [];

    return listado
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
