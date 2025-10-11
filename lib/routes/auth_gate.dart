import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screen/home_screen.dart';
import '../screen/auth/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        // Mientras Firebase determina el estado de sesión
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snap.data;
        // Si NO hay usuario -> Login
        if (user == null) {
          return const LoginScreen();
        }

        // Si HAY usuario -> Home
        return const HomeScreen();
      },
    );
  }
}
