class Product {
  final String id;
  final String productName;
  final int price;
  final int stock;
  final String category;
  final String estado;

  const Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.stock,
    required this.category,
    required this.estado,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '') as String,
      productName: (json['productName'] ?? '(sin nombre)') as String,
      price: (json['price'] ?? 0) as int,
      stock: (json['stock'] ?? 0) as int,
      category: (json['category'] ?? 'general') as String,
      estado: (json['estado'] ?? 'Activo') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productName': productName,
    'price': price,
    'stock': stock,
    'category': category,
    'estado': estado,
  };
}
