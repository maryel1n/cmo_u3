
# CMO U3 — Parte 1 (Backend + Listado + Auth UI)

**Rama:** `part1-backend-auth-listado`  
**Stack:** Flutter (Provider + http), Firebase Emulators (Functions + Firestore), Cloud Functions (Express + CORS + Basic Auth).

## Emuladores Firebase

Proyecto: `cmo-u3-quintanilla`  
Autenticación a la API: **Basic** `test:test2023` → base64 `dGVzdDp0ZXN0MjAyMw==`

```bash
# desde la raíz del repo
npx firebase-tools emulators:start --only functions,firestore
# UI del Emulator: http://127.0.0.1:4000
# Functions:       http://127.0.0.1:5001
# Firestore:       http://127.0.0.1:8080
```

### Contrato de API (Functions – emulador)

- **Listar**  
  `GET /ejemplos/product_list_rest/`  
  `200 OK`
  ```json
  { "listado": [ { "id": "...", "productName": "...", "price": 0, "stock": 0, "category": "...", "estado": "Activo" } ] }
  ```

- **Crear**  
  `POST /ejemplos/product_create/`  
  Body:
  ```json
  { "productName": "Teclado", "price": 19990, "stock": 12, "category": "accesorios", "estado": "Activo" }
  ```
  Respuesta:
  ```json
  { "ok": true, "id": "<nuevoId>" }
  ```

- **Actualizar**  
  `PUT /ejemplos/product_update/:id` → `200 OK { "ok": true }`

- **Eliminar**  
  `DELETE /ejemplos/product_delete/:id` → `200 OK { "ok": true }`

### Sembrar datos (seed)
```bash
# crear producto de ejemplo
curl -X POST   -H "Authorization: Basic dGVzdDp0ZXN0MjAyMw=="   -H "Content-Type: application/json"   -d '{"productName":"Zapatillas Ultra","price":59990,"stock":8,"category":"calzado","estado":"Activo"}'   "http://127.0.0.1:5001/cmo-u3-quintanilla/us-central1/api/ejemplos/product_create/"

# listar productos
curl -H "Authorization: Basic dGVzdDp0ZXN0MjAyMw=="   "http://127.0.0.1:5001/cmo-u3-quintanilla/us-central1/api/ejemplos/product_list_rest/"
```

## App Flutter

```bash
flutter pub get
flutter run -d emulator-5554
```

- **Home (Catálogo):** lista productos desde Functions (pull-to-refresh e ícono ↻).
- **Login/Registro:** UI **dark** (solo interfaz, sin lógica auth real).
- **Tema global:** claro para el resto de pantallas.

## Estructura
```
lib/
  models/
    product.dart
  services/
    env.dart                 # URLs y credenciales centralizadas (emulador)
    products_service.dart    # http + Basic Auth → Functions
    products_provider.dart   # estado, carga inicial, refresh
  screen/
    auth/
      login_screen.dart      # dark (UI + navegación a Home/Registro)
      register_screen.dart   # dark (UI)
    home_screen.dart         # catálogo (tema claro global)
  firebase_options.dart      # generado por flutterfire (si aplica)
```

## Notas Android/iOS

- Android: el `localhost` del host se accede como **`10.0.2.2`** (ya configurado en `lib/services/env.dart`).
- iOS (si se prueba): usar `127.0.0.1` o un `Env` por plataforma.

## Checklist Parte 1 (✓)

- [x] Emuladores (Functions + Firestore) y `firebase.json`
- [x] Functions REST con Basic Auth (GET/POST/PUT/DELETE)
- [x] Firestore: colección `products`
- [x] App Flutter con Provider + http (listado, loading/error, refresh)
- [x] Login/Registro UI (dark); tema global claro
- [x] README con pasos y contrato de API

## Guía Parte 2 (próximo paso)

1. **Firebase Auth** (email/clave): registro, login, logout, reset password.
2. **Rutas protegidas** con `authStateChanges()`.
3. **CRUD desde la app** (formularios y validaciones).
4. (Opcional) Migrar Basic Auth a verificación por usuario / reglas.
5. Mejoras de UX (errores y loaders en operaciones).
