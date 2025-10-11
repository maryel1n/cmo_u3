import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:provider/provider.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Providers / servicios
import 'services/products_provider.dart';

// Gate
import 'routes/auth_gate.dart';

//Screens
import 'screen/auth/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Conectar Firebase Auth al EMULADOR en desarrollo
  if (kDebugMode) {
    final host = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : '127.0.0.1';
    FirebaseAuth.instance.useAuthEmulator(host, 9099);
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider(), lazy: false),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CMO U3',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4C6FFF),
            brightness: Brightness.light,
          ),
        ),
        routes: {'/register': (_) => const RegisterScreen()},
        home: const AuthGate(),
      ),
    );
  }
}
