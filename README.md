CMO U3 — Backend + Auth + CRUD + Carrito + Checkout

Rama actual: part2-auth-flows-carrito
Stack: Flutter (Provider + http) · Firebase Emulator Suite (Auth, Functions, Firestore) · Cloud Functions (Express + CORS + Basic Auth)

--------------------------------------------------------------------------------
1) Requisitos
- Flutter 3.x
- Node 18+ (recomendado 20)
- Firebase CLI → npm i -g firebase-tools

--------------------------------------------------------------------------------
2) Configuración del proyecto

Dependencias
- en la raíz del repo:
  flutter pub get
- funciones:
  cd functions && npm install && cd ..

Emuladores (Auth + Functions + Firestore)
  npx firebase-tools emulators:start --only auth,functions,firestore

- UI de Emuladores: http://127.0.0.1:4000/
- Auth:         http://127.0.0.1:4000/auth
- Functions:    http://127.0.0.1:4000/functions
- Firestore:    http://127.0.0.1:4000/firestore

Asegúrate de tener en firebase.json:
"firestore": { "rules": "firestore.rules", "indexes": "firestore.indexes.json" }

Ejecutar la app (Android)
  flutter emulators --launch Medium_Phone_API_36.1
  flutter run -d emulator-5554

Nota Android: la app llama a Functions en http://10.0.2.2:5001 (loopback del host desde el emulador). No uses localhost en Android.

--------------------------------------------------------------------------------
3) Configuración de entorno (lib/services/env.dart)

- Basic Auth para las Functions del emulador:
  Usuario/clave: test:test2023 → Base64: dGVzdDp0ZXN0MjAyMw==

- Base de API (emulador):
  http://10.0.2.2:5001/cmo-u3-quintanilla/us-central1/api/ejemplos

- Admins (para ver FAB “Nuevo producto” y menú de editar/eliminar):
  static const List<String> adminEmails = ['maryelinqc@gmail.com'];

--------------------------------------------------------------------------------
4) Endpoints REST (Functions)
Todos requieren header: Authorization: Basic dGVzdDp0ZXN0MjAyMw==

Listar productos
curl -H "Authorization: Basic dGVzdDp0ZXN0MjAyMw==" \
  "http://127.0.0.1:5001/cmo-u3-quintanilla/us-central1/api/ejemplos/product_list_rest/"

Crear producto
curl -X POST \
  -H "Authorization: Basic dGVzdDp0ZXN0MjAyMw==" \
  -H "Content-Type: application/json" \
  -d '{"productName":"Polera Básica","price":9990,"stock":10,"category":"ropa","estado":"Activo"}' \
  "http://127.0.0.1:5001/cmo-u3-quintanilla/us-central1/api/ejemplos/product_create/"

Actualizar producto (usa POST)
curl -X POST \
  -H "Authorization: Basic dGVzdDp0ZXN0MjAyMw==" \
  -H "Content-Type: application/json" \
  -d '{"price":10990,"stock":9}' \
  "http://127.0.0.1:5001/cmo-u3-quintanilla/us-central1/api/ejemplos/product_update/<ID>"

Eliminar producto
curl -X DELETE \
  -H "Authorization: Basic dGVzdDp0ZXN0MjAyMw==" \
  "http://127.0.0.1:5001/cmo-u3-quintanilla/us-central1/api/ejemplos/product_delete/<ID>"

Crear orden (checkout)
curl -X POST \
  -H "Authorization: Basic dGVzdDp0ZXN0MjAyMw==" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": null,
    "items": [
      {"productId":"<ID>","name":"Zapatillas Ultra","price":59990,"qty":1,"subtotal":59990}
    ],
    "total": 59990,
    "paymentMethod": "tarjeta",
    "shipping": {"name":"Cliente Demo","address":"Calle 1 #123","comuna":"Santiago"}
  }' \
  "http://127.0.0.1:5001/cmo-u3-quintanilla/us-central1/api/ejemplos/order_create/"

--------------------------------------------------------------------------------
5) Sembrado rápido (seed)

# 1) Polera
curl -X POST -H "Authorization: Basic dGVzdDp0ZXN0MjAyMw==" -H "Content-Type: application/json" \
  -d '{"productName":"Polera Básica","price":9990,"stock":15,"category":"ropa","estado":"Activo"}' \
  "http://127.0.0.1:5001/cmo-u3-quintanilla/us-central1/api/ejemplos/product_create/"

# 2) Zapatillas
curl -X POST -H "Authorization: Basic dGVzdDp0ZXN0MjAyMw==" -H "Content-Type: application/json" \
  -d '{"productName":"Zapatillas Ultra","price":59990,"stock":6,"category":"calzado","estado":"Activo"}' \
  "http://127.0.0.1:5001/cmo-u3-quintanilla/us-central1/api/ejemplos/product_create/"

# 3) Parka
curl -X POST -H "Authorization: Basic dGVzdDp0ZXN0MjAyMw==" -H "Content-Type: application/json" \
  -d '{"productName":"Parka Ligera","price":34990,"stock":3,"category":"abrigo","estado":"Activo"}' \
  "http://127.0.0.1:5001/cmo-u3-quintanilla/us-central1/api/ejemplos/product_create/"

--------------------------------------------------------------------------------
6) App Flutter — Funcionalidades

Autenticación (Firebase Auth)
- Registro / Login / Logout
- Reset password (sendPasswordResetEmail)
- Persistencia de sesión con authStateChanges() vía AuthGate
- Rutas protegidas: si no hay sesión → Login; si hay → Home

Reset de contraseña en emulador:
Tras pedir el correo de recuperación, obtén el enlace desde el emulador:
  curl -s "http://127.0.0.1:9099/emulator/v1/projects/cmo-u3-quintanilla/oobCodes"
Copia oobLink → pega en el navegador → define nueva clave → vuelve a la app y haz login.

Catálogo
- Grid de productos, buscador por texto
- Botón Agregar al carrito en cada tarjeta
- Badge de cantidad en ícono de carrito (AppBar)
- Admin:
  - FAB “Nuevo producto” (solo correos en Env.adminEmails)
  - Editar/Eliminar con long-press en una tarjeta

Carrito
- Ver, sumar/restar/eliminar ítems
- Total en tiempo real
- Botón inferior “Revisar carrito”

Checkout
- Datos de envío (nombre, dirección, comuna)
- Pago: tarjeta (muestra inputs cuando se selecciona) o transferencia
- Descuenta stock por cada ítem comprado
- Crea orden en la colección orders (vía endpoint)
- Pantalla “Pago confirmado” con resumen de compra

--------------------------------------------------------------------------------
7) Reglas de seguridad (emulador) — firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /products/{id} {
      // listado público
      allow read: if true;

      // solo admin puede crear/editar/eliminar
      allow write: if request.auth != null &&
                   request.auth.token.email in ['maryelinqc@gmail.com'];
    }

    match /orders/{orderId} {
      // el usuario autenticado puede crear su orden y leer la suya
      allow create: if request.auth != null &&
                    request.resource.data.userId == request.auth.uid;
      allow read: if request.auth != null &&
                  resource.data.userId == request.auth.uid;
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}

Importante: levantar emuladores tras editar reglas:
  npx firebase-tools emulators:start --only auth,functions,firestore

--------------------------------------------------------------------------------
8) Estructura

lib/
  models/
    product.dart
  routes/
    auth_gate.dart
  screen/
    auth/
      login_screen.dart
      register_screen.dart
    home_screen.dart
    cart_screen.dart
    checkout_screen.dart
    order_success_screen.dart
    product_form_screen.dart
  services/
    env.dart
    products_service.dart
    products_provider.dart
    orders_service.dart
    cart_provider.dart
  firebase_options.dart
functions/
  index.js
firebase.json
firestore.rules
firestore.indexes.json

--------------------------------------------------------------------------------
9) Flujo de prueba (checklist)

1. Registro → Login
2. Redirección automática a Home (ruta protegida)
3. Ver catálogo (pull-to-refresh, buscador)
4. Agregar productos al carrito
5. Abrir Carrito → modificar cantidades
6. Ir a Checkout → completar formulario → Pagar
7. Ver Pago confirmado
8. Validar en Firestore:
   - products con stock descontado
   - orders con la orden creada
9. (Admin) Crear / Editar / Eliminar productos desde la app

--------------------------------------------------------------------------------
10) Troubleshooting

- “No hay productos”: usa los curls de “Sembrado rápido”.
- Reset de contraseña: recuerda usar el oobLink del emulador (no se envía correo real).
- Android: Functions deben apuntar a 10.0.2.2 (ya configurado en Env).
- Cambios en Functions: reinicia emuladores para tomar cambios.