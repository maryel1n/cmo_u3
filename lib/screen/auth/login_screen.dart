import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );
      // AuthGate escuchará el cambio de sesión y te llevará al Home.
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'invalid-credential' => 'Credenciales inválidas.',
        'user-not-found' => 'Usuario no encontrado.',
        'wrong-password' => 'Contraseña incorrecta.',
        'invalid-email' => 'Correo inválido.',
        _ => 'Error de inicio de sesión: ${e.code}',
      };
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al iniciar sesión')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un correo válido para resetear.'),
        ),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Te enviamos un correo de restablecimiento a $email'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      final msg = (e.code == 'user-not-found')
          ? 'No existe un usuario con ese correo.'
          : 'No se pudo enviar el correo (${e.code}).';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al enviar el correo')),
        );
      }
    }
  }

  Future<void> _showResetPasswordDialog(BuildContext context) async {
    final emailCtrl = TextEditingController(text: _email.text.trim());
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Restablecer contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo',
                      hintText: 'tu@correo.cl',
                      errorText: errorText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Te enviaremos un correo con el enlace para restablecer tu contraseña.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    final email = emailCtrl.text.trim();
                    if (email.isEmpty || !email.contains('@')) {
                      setState(() => errorText = 'Ingresa un correo válido');
                      return;
                    }
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: email,
                      );

                      // Cierra el diálogo y muestra feedback
                      Navigator.of(ctx).pop();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Correo de restablecimiento enviado a $email',
                            ),
                          ),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      String msg = 'No se pudo enviar el correo';
                      if (e.code == 'user-not-found') {
                        msg = 'No existe un usuario con ese correo.';
                      } else if (e.code == 'invalid-email') {
                        msg = 'Correo inválido.';
                      }
                      setState(() => errorText = msg);
                    } catch (_) {
                      setState(
                        () => errorText =
                            'Ocurrió un error inesperado. Intenta nuevamente.',
                      );
                    }
                  },
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
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
        inputDecorationTheme: const InputDecorationTheme(
          // En Flutter 3.x el color del texto va en el propio TextField.style,
          // aquí dejamos la decoración por defecto oscura.
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Inicio de Sesión')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
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
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(
                      color: Colors.white,
                    ), // texto visible
                    decoration: _field('Correo electrónico'),
                    validator: (v) {
                      final x = (v ?? '').trim();
                      if (x.isEmpty) return 'Ingresa tu correo';
                      if (!x.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextFormField(
                    controller: _pass,
                    obscureText: _obscure,
                    style: const TextStyle(
                      color: Colors.white,
                    ), // texto visible
                    decoration: _field('Contraseña').copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    validator: (v) {
                      final x = v ?? '';
                      if (x.isEmpty) return 'Ingresa tu contraseña';
                      if (x.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
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
                    onPressed: _loading
                        ? null
                        : () => _showResetPasswordDialog(context),
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
                            Navigator.push(
                              context,
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
      ),
    );
  }
}
