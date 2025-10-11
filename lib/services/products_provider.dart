import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'products_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductsService _service;
  ProductsProvider({ProductsService? service})
    : _service = service ?? ProductsService() {
    // igual al ejemplo del profe: carga al crear el provider
    fetch();
  }

  List<Product> items = [];
  bool isLoading = false;
  String? error;

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
}
