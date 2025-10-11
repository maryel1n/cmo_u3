import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  InputDecoration _field(String hint) {
    const borderColor = Color(0xFF2A2F36);
    const fill = Color(0xFF161A1E);

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: fill,
      hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final pass = _pass.text;

    if (email.isEmpty || pass.isEmpty) {
      _showError('Ingresa correo y contraseña');
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      // No navegamos manualmente: AuthGate detecta sesión y lleva al Home.
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') msg = 'Usuario no encontrado';
      if (e.code == 'wrong-password') msg = 'Contraseña incorrecta';
      if (e.code == 'invalid-email') msg = 'Correo inválido';
      _showError(msg);
    } catch (_) {
      _showError('Ocurrió un problema');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F1115);
    const primary = Color(0xFF4C6FFF);

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Inicio de Sesión')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Icon(Icons.shopping_bag_outlined, color: primary, size: 32),
                const SizedBox(height: 6),
                const Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Email
                TextField(
                  controller: _email,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _field('Correo electrónico'),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 12),

                // Password
                TextField(
                  controller: _pass,
                  style: const TextStyle(color: Colors.white),
                  obscureText: _obscure,
                  decoration: _field('Contraseña').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 20),

                // Ingresar (botón blanco pill)
                ElevatedButton(
                  onPressed: _loading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ingresar'),
                ),
                const SizedBox(height: 10),

                // ¿Olvidaste tu contraseña?
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
                const SizedBox(height: 10),

                // Crear cuenta (outline)
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2A2F36)),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: const Text('Crear cuenta'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
