import 'package:flutter/foundation.dart';
import 'package:cmo_u3/services/cart_provider.dart' show CartItem;

import '../models/product.dart';
import 'products_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductsService _service;

  ProductsProvider({ProductsService? service})
    : _service = service ?? ProductsService() {
    // Carga inicial (igual al ejemplo del profe)
    fetch();
  }

  List<Product> items = [];
  bool isLoading = false;
  String? error;

  /// Carga/recarga la lista de productos desde la API (emulador Functions).
  Future<void> fetch() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      items = await _service.fetchProducts();
    } catch (e) {
      error = e.toString();
      items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetch();

  /// Descuenta stock de un producto en el backend. Si queda negativo, lo trunca a 0.
  Future<void> decrementStock(String productId, int qty) async {
    try {
      // Busca el stock actual en memoria (si está)
      final idx = items.indexWhere((p) => p.id == productId);
      int currentStock = 0;
      if (idx >= 0) {
        currentStock = items[idx].stock;
      }

      final safeStock = (currentStock - qty) < 0 ? 0 : (currentStock - qty);

      // 🔎 Log de diagnóstico
      // ignore: avoid_print
      print(
        '[STOCK] id=$productId current=$currentStock - qty=$qty => new=$safeStock',
      );

      // Actualiza en el backend (ProductsService.update)
      await _service.update(productId, {'stock': safeStock});
    } catch (e) {
      // ignore: avoid_print
      print('[STOCK][ERROR] id=$productId qty=$qty -> $e');
      rethrow;
    }
  }

  /// Aplica el checkout: recorre el carrito y descuenta stock en el backend.
  /// Luego refresca el listado.
  Future<void> applyCheckout(List<CartItem> cart) async {
    for (final it in cart) {
      final p = it.product;
      final id = p.id;

      // 🔎 Logs de diagnóstico
      // ignore: avoid_print
      print(
        '[CHECKOUT] name=${p.productName} id=$id qty=${it.qty} currentStock=${p.stock}',
      );

      if (id == null || id.isEmpty) {
        // ignore: avoid_print
        print('[CHECKOUT][WARN] producto sin id — no se puede descontar.');
        continue;
      }

      await decrementStock(id, it.qty);
    }

    // Refresca el listado tras el checkout
    await fetch();
  }
}
