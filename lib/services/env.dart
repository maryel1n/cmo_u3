/// Config centralizada para Emuladores / Producción.
/// Parte 1: usamos emuladores locales (Android → 10.0.2.2).
class Env {
  // Basic Auth para las Cloud Functions (igual al ejemplo del profe)
  static const String basicAuth = 'Basic dGVzdDp0ZXN0MjAyMw==';

  // Host del emulador de Functions visto desde Android (NO usar localhost aquí)
  static const String _hostAndroid = 'http://10.0.2.2:5001';

  // Proyecto / región / nombre de función HTTP (según tu setup)
  static const String _project = 'cmo-u3-quintanilla';
  static const String _region = 'us-central1';
  static const String _apiName = 'api';

  /// Base para los endpoints REST del ejemplo
  static String get _base =>
      '$_hostAndroid/$_project/$_region/$_apiName/ejemplos';

  // Endpoints usados en Parte 1
  static String get listProducts => '$_base/product_list_rest/';
  static String get createProduct => '$_base/product_create/';
  static String updateProduct(String id) => '$_base/product_update/$id';
  static String deleteProduct(String id) => '$_base/product_delete/$id';

  // TODO(Parte 2): si despliegan a producción,
  // crear otro getter baseProd y conmutar según Flavor/const bool.
}
