// lib/models/cart_item.dart
class CartItem {
  final String id; // id del producto
  final String name; // nombre del producto
  final int price; // precio unitario
  final String category; // categoría
  int qty; // cantidad en el carrito

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.qty = 1,
  });

  CartItem copyWith({int? qty}) => CartItem(
    id: id,
    name: name,
    price: price,
    category: category,
    qty: qty ?? this.qty,
  );
}
