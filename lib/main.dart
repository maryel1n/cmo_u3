import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/products_provider.dart';
import 'screen/home_screen.dart';
import 'screen/auth/login_screen.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        // Tema global CLARO (Catálogo y resto de la app)
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4C6FFF),
            brightness: Brightness.light,
          ),
        ),
        // Pantalla inicial (Login con su theme dark interno)
        home: const LoginScreen(),
      ),
    );
  }
}
