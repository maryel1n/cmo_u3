// lib/models/product.dart
class Product {
  final String id;
  final String productName;
  final int price;
  final int stock;
  final String category;
  final String estado;

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.stock,
    required this.category,
    required this.estado,
  });

  /// Constructor de fábrica: crea un Product desde un mapa (JSON)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      productName: map['productName'] ?? '',
      price: map['price'] is int
          ? map['price']
          : int.tryParse(map['price']?.toString() ?? '0') ?? 0,
      stock: map['stock'] is int
          ? map['stock']
          : int.tryParse(map['stock']?.toString() ?? '0') ?? 0,
      category: map['category'] ?? '',
      estado: map['estado'] ?? '',
    );
  }

  /// Convierte el objeto Product a Map (opcional, útil para updates)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'price': price,
      'stock': stock,
      'category': category,
      'estado': estado,
    };
  }
}
