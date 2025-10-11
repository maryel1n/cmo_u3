import 'package:flutter/foundation.dart';
import 'package:cmo_u3/models/product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, this.qty = 1});
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _map = {}; // key = product.id

  List<CartItem> get items => _map.values.toList();
  int get totalItems => _map.values.fold(0, (acc, it) => acc + it.qty);
  int get distinctItems => _map.length;
  int get totalPrice =>
      _map.values.fold(0, (acc, it) => acc + (it.product.price * it.qty));

  void add(Product p, {int qty = 1}) {
    if (p.id == null || p.id!.isEmpty) return;
    final id = p.id!;
    if (_map.containsKey(id)) {
      _map[id]!.qty += qty;
    } else {
      _map[id] = CartItem(product: p, qty: qty);
    }
    notifyListeners();
  }

  void setQty(String productId, int qty) {
    if (!_map.containsKey(productId)) return;
    if (qty <= 0) {
      _map.remove(productId);
    } else {
      _map[productId]!.qty = qty;
    }
    notifyListeners();
  }

  void removeOne(String productId) {
    if (!_map.containsKey(productId)) return;
    final item = _map[productId]!;
    item.qty -= 1;
    if (item.qty <= 0) _map.remove(productId);
    notifyListeners();
  }

  void remove(String productId) {
    _map.remove(productId);
    notifyListeners();
  }

  void clear() {
    _map.clear();
    notifyListeners();
  }
}
