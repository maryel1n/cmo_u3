import 'dart:convert';
import 'package:http/http.dart' as http;

import 'env.dart';

class OrdersService {
  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Authorization': Env.basicAuth,
  };

  Future<String> createOrder({
    String? userId,
    required List<Map<String, dynamic>> items,
    required int total,
    required String paymentMethod,
    required Map<String, dynamic> shipping,
  }) async {
    final url = Uri.parse(Env.createOrder);

    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'userId': userId,
        'items': items,
        'total': total,
        'paymentMethod': paymentMethod,
        'shipping': shipping,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Error creando orden: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final ok = data['ok'] == true;
    final id = data['id'] as String?;
    if (!ok || id == null) {
      throw Exception('Respuesta inesperada al crear orden: ${res.body}');
    }
    return id;
  }
}
