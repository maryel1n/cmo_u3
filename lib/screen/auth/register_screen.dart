import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
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

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _register() async {
    final email = _email.text.trim();
    final p1 = _pass.text;
    final p2 = _pass2.text;

    if (email.isEmpty || p1.isEmpty || p2.isEmpty) {
      _show('Completa todos los campos');
      return;
    }
    if (p1.length < 6) {
      _show('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (p1 != p2) {
      _show('Las contraseñas no coinciden');
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: p1,
      );
      // AuthGate detectará la sesión y llevará al Home.
      if (mounted) {
        Navigator.of(context).pop(); // Volver al login (opcional)
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'No se pudo crear la cuenta';
      if (e.code == 'email-already-in-use') msg = 'El correo ya está en uso';
      if (e.code == 'invalid-email') msg = 'Correo inválido';
      _show(msg);
    } catch (_) {
      _show('Ocurrió un problema');
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
        appBar: AppBar(title: const Text('Crear cuenta')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Icon(Icons.person_add_alt_1_outlined, color: primary, size: 32),
                const SizedBox(height: 6),
                const Text(
                  'Regístrate',
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
                  obscureText: _obscure1,
                  decoration: _field('Contraseña').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                      icon: Icon(
                        _obscure1 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 12),

                // Confirm Password
                TextField(
                  controller: _pass2,
                  style: const TextStyle(color: Colors.white),
                  obscureText: _obscure2,
                  decoration: _field('Confirmar contraseña').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                      icon: Icon(
                        _obscure2 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  cursorColor: Colors.white,
                ),
                const SizedBox(height: 20),

                // Crear cuenta
                ElevatedButton(
                  onPressed: _loading ? null : _register,
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
                      : const Text('Crear cuenta'),
                ),
                const SizedBox(height: 12),

                // Volver
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: const Text('Volver'),
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
